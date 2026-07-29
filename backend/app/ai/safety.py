from __future__ import annotations

import re
import unicodedata
from dataclasses import dataclass
from enum import StrEnum


MEDICINE_DISCLAIMER = (
    "Bu yanıt yalnızca mevcut ürün verilerini açıklar; tanı, tedavi, reçete "
    "veya doz önerisi değildir. İlaçla ilgili kararlar için doktorunuza veya "
    "eczacınıza danışın."
)

COSMETIC_DISCLAIMER = (
    "Bu yanıt genel ürün verilerine dayanır ve dermatolojik değerlendirme "
    "yerine geçmez. Cilt hassasiyeti kişiden kişiye değişebilir."
)


class SafetyRisk(StrEnum):
    NONE = "none"
    DOSAGE = "dosage"
    DIAGNOSIS = "diagnosis"
    TREATMENT = "treatment"
    EMERGENCY = "emergency"


@dataclass(frozen=True)
class SafetyDecision:
    risk: SafetyRisk
    message: str = ""

    @property
    def should_block(self) -> bool:
        return self.risk is not SafetyRisk.NONE


def normalize(value: str) -> str:
    folded = unicodedata.normalize("NFKD", value.casefold())
    return "".join(
        character for character in folded if not unicodedata.combining(character)
    )


def evaluate_question(question: str) -> SafetyDecision:
    text = normalize(question)
    groups: tuple[tuple[SafetyRisk, tuple[str, ...], str], ...] = (
        (
            SafetyRisk.EMERGENCY,
            (
                "nefes alamiyorum",
                "nefes darligi",
                "bayildim",
                "bilinc kaybi",
                "siddetli alerji",
                "gogus agrisi",
            ),
            "Bu soru acil değerlendirme gerektirebilecek bir durum içeriyor. "
            "Uygulama üzerinden yanıt beklemek yerine gecikmeden profesyonel acil yardım alın.",
        ),
        (
            SafetyRisk.DOSAGE,
            (
                "kac tablet",
                "gunde kac",
                "doz",
                "dozaj",
                "ne kadar kullanmaliyim",
                "kac kere kullanmaliyim",
            ),
            "Kişiye özel doz veya kullanım sıklığı öneremem. Resmi kullanım "
            "bilgilerini kontrol edin ve doktorunuza ya da eczacınıza danışın.",
        ),
        (
            SafetyRisk.DIAGNOSIS,
            ("tani koy", "hastaligim ne", "neyim var", "hangi hastalik"),
            "Belirtilerden tanı koyamam. Değerlendirme için bir sağlık profesyoneline başvurun.",
        ),
        (
            SafetyRisk.TREATMENT,
            (
                "hangi ilaci",
                "ne kullanmaliyim",
                "tedavi et",
                "recete yaz",
                "bana uygun mu",
            ),
            "Tedavi, reçete veya kişiye özel ürün uygunluğu öneremem. Yalnızca "
            "seçilen ürünün mevcut bilgilerini açıklayabilirim.",
        ),
    )
    for risk, patterns, message in groups:
        if any(pattern in text for pattern in patterns):
            return SafetyDecision(risk=risk, message=message)
    return SafetyDecision(risk=SafetyRisk.NONE)


_UNSAFE_OUTPUT_PATTERNS = (
    re.compile(r"\bkesinlikle\b", re.IGNORECASE),
    re.compile(r"\bkesin (?:guvenli|uygun)\b", re.IGNORECASE),
    re.compile(r"\brisksiz\b", re.IGNORECASE),
    re.compile(r"\btam koruma\b", re.IGNORECASE),
    re.compile(r"\bgunde\s+\d+", re.IGNORECASE),
    re.compile(r"\b\d+\s+saatte bir\b", re.IGNORECASE),
    re.compile(r"\b\d+\s+tablet (?:alin|kullanin)\b", re.IGNORECASE),
)


def validate_generated_text(*values: str) -> None:
    normalized = normalize(" ".join(values))
    for pattern in _UNSAFE_OUTPUT_PATTERNS:
        if pattern.search(normalized):
            raise ValueError("Gemini output failed medical safety validation")
