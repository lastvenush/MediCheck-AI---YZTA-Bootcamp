from __future__ import annotations

import unicodedata
from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


def _to_camel(value: str) -> str:
    first, *rest = value.split("_")
    return first + "".join(part.capitalize() for part in rest)


def _normalize(value: str) -> str:
    folded = unicodedata.normalize("NFKD", value.casefold())
    return "".join(
        character for character in folded if not unicodedata.combining(character)
    )


class ApiModel(BaseModel):
    model_config = ConfigDict(
        alias_generator=_to_camel,
        populate_by_name=True,
        str_strip_whitespace=True,
    )


class ProductContext(ApiModel):
    id: str
    brand: str = ""
    name: str
    category: str
    description: str = ""
    ingredients: list[str] = Field(default_factory=list)
    usage_instructions: str = ""
    side_effects: str = ""
    contraindications: str = ""
    manufacturer: str = ""
    active_ingredients: list[str] = Field(default_factory=list)
    indications: list[str] = Field(default_factory=list)
    warnings: list[str] = Field(default_factory=list)
    filter_types: list[str] = Field(default_factory=list)
    skin_types: list[str] = Field(default_factory=list)
    contains_alcohol: bool | None = None
    contains_fragrance: bool | None = None

    @property
    def is_medicine(self) -> bool:
        return _normalize(self.category) == _normalize("ilaç")

    @property
    def is_sunscreen(self) -> bool:
        return _normalize(self.category) == _normalize("güneş kremi")

    def grounded_payload(self) -> dict[str, object]:
        payload = self.model_dump(by_alias=True)
        if self.is_medicine:
            payload["usageInstructions"] = (
                "Doz güvenliği nedeniyle model bağlamına dahil edilmedi."
            )
        return {key: _limit_context_value(value) for key, value in payload.items()}

    @property
    def primary_ingredients(self) -> list[str]:
        if self.is_medicine and self.active_ingredients:
            return self.active_ingredients
        if self.is_sunscreen and self.filter_types:
            return self.filter_types
        return self.ingredients

    @property
    def attention_points(self) -> list[str]:
        if self.warnings:
            return self.warnings
        return [self.contraindications] if self.contraindications else []


class ProductSource(ApiModel):
    title: str
    url: str


class ProductRecord(ProductContext):
    ai_analysis: str = ""
    is_safe: bool = False
    image_url: str = ""
    sources: list[ProductSource] = Field(default_factory=list)
    last_reviewed_at: str = ""


class AiAnalysisPayload(ApiModel):
    short_summary: str
    usage_purpose: str
    important_ingredients: list[str]
    attention_points: list[str]
    common_effects: list[str]
    disclaimer: str


class AiAssistantPayload(ApiModel):
    answer: str
    suggested_questions: list[str] = Field(default_factory=list)
    disclaimer: str


class AiComparisonPayload(ApiModel):
    summary: str
    differences: list[str]
    disclaimer: str


AiSource = Literal["gemini", "mock_fallback", "safety_filter"]


class AiAnalysisResult(AiAnalysisPayload):
    source: AiSource
    fallback_reason: str | None = None


class AiAssistantResult(AiAssistantPayload):
    source: AiSource
    product_id: str | None = None
    was_blocked: bool = False
    fallback_reason: str | None = None


class AiComparisonResult(AiComparisonPayload):
    source: AiSource
    product_ids: list[str]
    fallback_reason: str | None = None


def _limit_context_value(value: object) -> object:
    if isinstance(value, str):
        return value[:600]
    if isinstance(value, list):
        return [str(item)[:120] for item in value[:12]]
    return value
