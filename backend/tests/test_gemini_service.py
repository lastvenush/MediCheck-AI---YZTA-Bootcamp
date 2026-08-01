from __future__ import annotations

import unittest
from types import SimpleNamespace
from typing import Any

from backend.app.ai.gemini_service import GeminiService, GeminiSettings
from backend.app.ai.models import (
    AiAnalysisPayload,
    AiAssistantPayload,
    AiComparisonPayload,
    ProductContext,
)


class _FakeModels:
    def __init__(self, responses: list[Any]) -> None:
        self.responses = responses
        self.calls: list[dict[str, Any]] = []

    def generate_content(self, **kwargs: Any) -> Any:
        self.calls.append(kwargs)
        return SimpleNamespace(parsed=self.responses.pop(0), text=None)


class _FakeClient:
    def __init__(self, responses: list[Any]) -> None:
        self.models = _FakeModels(responses)


class GeminiServiceTest(unittest.TestCase):
    def test_disabled_service_returns_mock_without_api_key(self) -> None:
        service = GeminiService(settings=GeminiSettings(enabled=False))

        result = service.ask("Etken maddesi nedir?", MEDICINE)

        self.assertEqual(result.source, "mock_fallback")
        self.assertIn("Deksketoprofen", result.answer)

    def test_dosage_question_is_blocked_before_gemini_call(self) -> None:
        client = _FakeClient([])
        service = GeminiService(
            settings=GeminiSettings(enabled=True),
            client=client,
        )

        result = service.ask("Günde kaç tablet almalıyım?", MEDICINE)

        self.assertEqual(result.source, "safety_filter")
        self.assertTrue(result.was_blocked)
        self.assertEqual(client.models.calls, [])

    def test_structured_assistant_response_uses_gemini(self) -> None:
        payload = AiAssistantPayload(
            answer="Mevcut veride etken madde deksketoprofen trometamoldür.",
            suggested_questions=["Mevcut uyarılar neler?"],
            disclaimer="Bu yanıt bilgilendirme amaçlıdır.",
        )
        client = _FakeClient([payload])
        service = GeminiService(
            settings=GeminiSettings(enabled=True, model="test-model"),
            client=client,
        )

        result = service.ask("Etken maddesi nedir?", MEDICINE)

        self.assertEqual(result.source, "gemini")
        self.assertEqual(result.product_id, MEDICINE.id)
        call = client.models.calls[0]
        self.assertEqual(call["model"], "test-model")
        self.assertIs(call["config"]["response_schema"], AiAssistantPayload)
        self.assertEqual(call["config"]["max_output_tokens"], 512)
        self.assertEqual(
            call["config"]["thinking_config"]["thinking_level"],
            "minimal",
        )
        self.assertNotIn("temperature", call["config"])
        self.assertNotIn("8 saatte", call["contents"])

    def test_unsafe_gemini_output_falls_back(self) -> None:
        payload = AiAssistantPayload(
            answer="Bu ürün kesinlikle güvenlidir.",
            suggested_questions=[],
            disclaimer="Bilgilendirme.",
        )
        service = GeminiService(
            settings=GeminiSettings(enabled=True),
            client=_FakeClient([payload]),
        )

        result = service.ask("Ürünü özetler misin?", MEDICINE)

        self.assertEqual(result.source, "mock_fallback")
        self.assertEqual(result.fallback_reason, "ValueError")
        self.assertNotIn("kesinlikle", result.answer.casefold())

    def test_analysis_and_comparison_accept_structured_payloads(self) -> None:
        analysis = AiAnalysisPayload(
            short_summary="Mevcut ürün verisinin kısa özeti.",
            usage_purpose="Genel ürün açıklaması.",
            important_ingredients=["Kimyasal filtre"],
            attention_points=["Kişisel hassasiyet değişebilir."],
            common_effects=["Rahatsızlık oluşabilir."],
            disclaimer="Bilgilendirme amaçlıdır.",
        )
        comparison = AiComparisonPayload(
            summary="İki ürün mevcut alanlarına göre karşılaştırılmıştır.",
            differences=["Filtre tipleri farklıdır."],
            disclaimer="Kişisel hassasiyet değişebilir.",
        )
        client = _FakeClient([analysis, comparison])
        service = GeminiService(
            settings=GeminiSettings(enabled=True),
            client=client,
        )

        analysis_result = service.analyze_product(SUNSCREEN)
        comparison_result = service.compare_products(SUNSCREEN, SECOND_SUNSCREEN)

        self.assertEqual(analysis_result.source, "gemini")
        self.assertEqual(comparison_result.source, "gemini")
        self.assertEqual(comparison_result.product_ids, ["g1", "g2"])


MEDICINE = ProductContext(
    id="i2",
    brand="Menarini",
    name="Arveles 25 mg Film Tablet",
    category="İlaç",
    description="Ağrı durumlarında kullanılan bir ilaçtır.",
    ingredients=["Deksketoprofen Trometamol"],
    usageInstructions="8 saatte bir 1 tablet alınır.",
    sideEffects="Mide bulantısı",
    contraindications="Doktor veya eczacıya danışılmalıdır.",
)

SUNSCREEN = ProductContext(
    id="g1",
    brand="Marka A",
    name="Ürün A SPF50+",
    category="Güneş Kremi",
    description="Güneş koruyucu ürün.",
    ingredients=["Kimyasal Filtre"],
    usageInstructions="Yağlı cilt bilgisi.",
    sideEffects="Parfüm içermez.",
    contraindications="Kişisel hassasiyet değişebilir.",
)

SECOND_SUNSCREEN = ProductContext(
    id="g2",
    brand="Marka B",
    name="Ürün B SPF50+",
    category="Güneş Kremi",
    description="Güneş koruyucu ürün.",
    ingredients=["Mineral Filtre"],
    usageInstructions="Hassas cilt bilgisi.",
    sideEffects="Parfüm bilgisi yok.",
    contraindications="Kişisel hassasiyet değişebilir.",
)


if __name__ == "__main__":
    unittest.main()
