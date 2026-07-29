from __future__ import annotations

from .models import (
    AiAnalysisResult,
    AiAssistantResult,
    AiComparisonResult,
    ProductContext,
)
from .safety import (
    COSMETIC_DISCLAIMER,
    MEDICINE_DISCLAIMER,
    evaluate_question,
    validate_generated_text,
)


def analysis_fallback(
    product: ProductContext,
    *,
    reason: str,
) -> AiAnalysisResult:
    disclaimer = _disclaimer(product)
    summary = _safe_value(
        product.description,
        fallback="Bu ürün için güvenli bir özet bilgi bulunamadı.",
    )
    purpose = " • ".join(product.indications) or (
        "Ürün verisindeki genel açıklamaya bakınız."
        if product.is_medicine
        else product.usage_instructions or "Kullanım amacı bilgisi bulunamadı."
    )
    return AiAnalysisResult(
        short_summary=summary,
        usage_purpose=purpose,
        important_ingredients=product.primary_ingredients,
        attention_points=product.attention_points
        or ["Kişisel durum için bir sağlık profesyoneline danışılmalıdır."],
        common_effects=[
            _safe_value(
                product.side_effects,
                fallback="Mevcut veride etki/hassasiyet bilgisi bulunmuyor.",
            )
        ],
        disclaimer=disclaimer,
        source="mock_fallback",
        fallback_reason=reason,
    )


def assistant_fallback(
    question: str,
    product: ProductContext,
    *,
    reason: str,
) -> AiAssistantResult:
    decision = evaluate_question(question)
    if decision.should_block:
        return AiAssistantResult(
            answer=decision.message,
            suggested_questions=_suggestions(product),
            disclaimer=_disclaimer(product),
            source="safety_filter",
            product_id=product.id,
            was_blocked=True,
            fallback_reason=decision.risk.value,
        )

    normalized = question.casefold()
    if any(term in normalized for term in ("içerik", "icerik", "etken", "filtre")):
        ingredients = ", ".join(product.primary_ingredients) or "bilgi bulunmuyor"
        answer = f"Mevcut ürün verisindeki önemli içerikler: {ingredients}."
    elif any(term in normalized for term in ("uyarı", "uyari", "dikkat")):
        answer = (
            "Mevcut ürün verisindeki dikkat notu: "
            f"{_safe_value(' • '.join(product.attention_points), fallback='bilgi bulunmuyor')}."
        )
    else:
        answer = _safe_value(
            product.description,
            fallback="Bu ürün için güvenli bir özet bulunmuyor.",
        )

    return AiAssistantResult(
        answer=answer,
        suggested_questions=_suggestions(product),
        disclaimer=_disclaimer(product),
        source="mock_fallback",
        product_id=product.id,
        fallback_reason=reason,
    )


def comparison_fallback(
    first: ProductContext,
    second: ProductContext,
    *,
    reason: str,
) -> AiComparisonResult:
    if not first.is_sunscreen or not second.is_sunscreen:
        summary = (
            "Demo karşılaştırması yalnızca iki güneş koruyucu için kullanılabilir."
        )
        differences: list[str] = []
    elif first.id == second.id:
        summary = "Karşılaştırma için iki farklı ürün seçilmelidir."
        differences = []
    else:
        summary = (
            f"{first.name} ve {second.name} yalnızca mevcut ürün alanlarına göre "
            "karşılaştırılmıştır; kişisel uygunluk kararı verilmez."
        )
        differences = [
            _difference(
                "İçerik/filtre",
                first.primary_ingredients,
                second.primary_ingredients,
            ),
            _difference(
                "Cilt tipi bilgisi",
                first.skin_types or [first.usage_instructions],
                second.skin_types or [second.usage_instructions],
            ),
            _difference(
                "Dikkat notu",
                first.attention_points,
                second.attention_points,
            ),
        ]
    return AiComparisonResult(
        summary=summary,
        differences=differences,
        disclaimer=COSMETIC_DISCLAIMER,
        source="mock_fallback",
        product_ids=[first.id, second.id],
        fallback_reason=reason,
    )


def _difference(label: str, first: list[str], second: list[str]) -> str:
    first_text = _safe_value(
        ", ".join(value for value in first if value),
        fallback="bilgi bulunmuyor",
    )
    second_text = _safe_value(
        ", ".join(value for value in second if value),
        fallback="bilgi bulunmuyor",
    )
    return f"{label}: İlk ürün '{first_text}', ikinci ürün '{second_text}'."


def _disclaimer(product: ProductContext) -> str:
    return MEDICINE_DISCLAIMER if product.is_medicine else COSMETIC_DISCLAIMER


def _suggestions(product: ProductContext) -> list[str]:
    if product.is_medicine:
        return ["Etken maddesi nedir?", "Mevcut uyarılar neler?"]
    return ["Filtre tipi nedir?", "Hassasiyet notları neler?"]


def _safe_value(value: str, *, fallback: str) -> str:
    clean_value = value.strip()
    if not clean_value:
        return fallback
    try:
        validate_generated_text(clean_value)
    except ValueError:
        return fallback
    return clean_value
