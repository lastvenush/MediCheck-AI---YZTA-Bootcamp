from __future__ import annotations

import os
from dataclasses import dataclass
from typing import Any, TypeVar

from pydantic import BaseModel

from .fallback import analysis_fallback, assistant_fallback, comparison_fallback
from .models import (
    AiAnalysisPayload,
    AiAnalysisResult,
    AiAssistantPayload,
    AiAssistantResult,
    AiComparisonPayload,
    AiComparisonResult,
    ProductContext,
)
from .prompts import (
    ANALYSIS_SYSTEM_PROMPT,
    ASSISTANT_SYSTEM_PROMPT,
    COMPARISON_SYSTEM_PROMPT,
    analysis_contents,
    assistant_contents,
    comparison_contents,
)
from .safety import (
    COSMETIC_DISCLAIMER,
    MEDICINE_DISCLAIMER,
    evaluate_question,
    validate_generated_text,
)


SchemaT = TypeVar("SchemaT", bound=BaseModel)


@dataclass(frozen=True)
class GeminiSettings:
    enabled: bool = False
    api_key: str | None = None
    model: str = "gemini-3.5-flash-lite"
    max_output_tokens: int = 512
    thinking_level: str = "minimal"

    @classmethod
    def from_env(cls) -> "GeminiSettings":
        enabled = os.getenv("GEMINI_ENABLED", "false").casefold() in {
            "1",
            "true",
            "yes",
        }
        return cls(
            enabled=enabled,
            api_key=os.getenv("GEMINI_API_KEY") or os.getenv("GOOGLE_API_KEY"),
            model=os.getenv("GEMINI_MODEL", "gemini-3.5-flash-lite"),
            max_output_tokens=_read_int_env(
                "GEMINI_MAX_OUTPUT_TOKENS",
                default=512,
                minimum=128,
                maximum=2048,
            ),
            thinking_level=_read_thinking_level(),
        )


class GeminiService:
    def __init__(
        self,
        *,
        settings: GeminiSettings | None = None,
        client: Any | None = None,
    ) -> None:
        self.settings = settings or GeminiSettings.from_env()
        self._client = client

    def analyze_product(self, product: ProductContext) -> AiAnalysisResult:
        if not self.settings.enabled:
            return analysis_fallback(product, reason="gemini_disabled")
        try:
            payload = self._generate(
                schema=AiAnalysisPayload,
                system_instruction=ANALYSIS_SYSTEM_PROMPT,
                contents=analysis_contents(product),
            )
            validate_generated_text(
                payload.short_summary,
                payload.usage_purpose,
                *payload.important_ingredients,
                *payload.attention_points,
                *payload.common_effects,
            )
            data = payload.model_dump()
            data["disclaimer"] = _disclaimer(product)
            return AiAnalysisResult(**data, source="gemini")
        except Exception as error:
            return analysis_fallback(product, reason=type(error).__name__)

    def ask(self, question: str, product: ProductContext) -> AiAssistantResult:
        clean_question = question.strip()[:1000]
        decision = evaluate_question(clean_question)
        if decision.should_block:
            return assistant_fallback(
                clean_question,
                product,
                reason=decision.risk.value,
            )
        if not self.settings.enabled:
            return assistant_fallback(
                clean_question,
                product,
                reason="gemini_disabled",
            )
        try:
            payload = self._generate(
                schema=AiAssistantPayload,
                system_instruction=ASSISTANT_SYSTEM_PROMPT,
                contents=assistant_contents(clean_question, product),
            )
            validate_generated_text(payload.answer, *payload.suggested_questions)
            data = payload.model_dump()
            data["disclaimer"] = _disclaimer(product)
            return AiAssistantResult(
                **data,
                source="gemini",
                product_id=product.id,
            )
        except Exception as error:
            return assistant_fallback(
                clean_question,
                product,
                reason=type(error).__name__,
            )

    def compare_products(
        self,
        first: ProductContext,
        second: ProductContext,
    ) -> AiComparisonResult:
        if not self.settings.enabled:
            return comparison_fallback(first, second, reason="gemini_disabled")
        try:
            payload = self._generate(
                schema=AiComparisonPayload,
                system_instruction=COMPARISON_SYSTEM_PROMPT,
                contents=comparison_contents(first, second),
            )
            validate_generated_text(payload.summary, *payload.differences)
            data = payload.model_dump()
            data["disclaimer"] = COSMETIC_DISCLAIMER
            return AiComparisonResult(
                **data,
                source="gemini",
                product_ids=[first.id, second.id],
            )
        except Exception as error:
            return comparison_fallback(
                first,
                second,
                reason=type(error).__name__,
            )

    def _generate(
        self,
        *,
        schema: type[SchemaT],
        system_instruction: str,
        contents: str,
    ) -> SchemaT:
        client = self._get_client()
        response = client.models.generate_content(
            model=self.settings.model,
            contents=contents,
            config={
                "system_instruction": system_instruction,
                "response_mime_type": "application/json",
                "response_schema": schema,
                "max_output_tokens": self.settings.max_output_tokens,
                "thinking_config": {
                    "thinking_level": self.settings.thinking_level,
                    "include_thoughts": False,
                },
            },
        )
        parsed = getattr(response, "parsed", None)
        if isinstance(parsed, schema):
            return parsed
        if parsed is not None:
            return schema.model_validate(parsed)
        text = getattr(response, "text", None)
        if not text:
            raise ValueError("Gemini returned an empty response")
        return schema.model_validate_json(text)

    def _get_client(self) -> Any:
        if self._client is not None:
            return self._client
        if not self.settings.api_key:
            raise RuntimeError("Gemini API key is not configured")
        from google import genai

        self._client = genai.Client(api_key=self.settings.api_key)
        return self._client


def _disclaimer(product: ProductContext) -> str:
    return MEDICINE_DISCLAIMER if product.is_medicine else COSMETIC_DISCLAIMER


def _read_int_env(
    name: str,
    *,
    default: int,
    minimum: int,
    maximum: int,
) -> int:
    try:
        value = int(os.getenv(name, str(default)))
    except ValueError:
        return default
    return min(maximum, max(minimum, value))


def _read_thinking_level() -> str:
    value = os.getenv("GEMINI_THINKING_LEVEL", "minimal").casefold()
    return value if value in {"minimal", "low", "medium", "high"} else "minimal"
