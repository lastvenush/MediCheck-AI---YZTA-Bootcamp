from __future__ import annotations

import unittest

from fastapi.testclient import TestClient

from backend.app.ai.gemini_service import GeminiService, GeminiSettings
from backend.app.main import app, get_gemini_service


class ApiTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.service = GeminiService(settings=GeminiSettings(enabled=False))
        app.dependency_overrides[get_gemini_service] = lambda: cls.service
        cls.client = TestClient(app)

    @classmethod
    def tearDownClass(cls) -> None:
        app.dependency_overrides.clear()

    def test_health_does_not_expose_api_key(self) -> None:
        response = self.client.get("/health")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["status"], "ok")
        self.assertNotIn("apiKey", response.json())

    def test_analyze_uses_camel_case_contract(self) -> None:
        response = self.client.post("/ai/analyze", json={"product": PRODUCT})

        self.assertEqual(response.status_code, 200)
        payload = response.json()
        self.assertEqual(payload["source"], "mock_fallback")
        self.assertEqual(payload["importantIngredients"], ["Etken madde 10 mg"])
        self.assertEqual(payload["usagePurpose"], "Genel belirti bilgisi")

    def test_ask_blocks_dosage_before_provider_call(self) -> None:
        response = self.client.post(
            "/ai/ask",
            json={"question": "Günde kaç tablet almalıyım?", "product": PRODUCT},
        )

        self.assertEqual(response.status_code, 200)
        payload = response.json()
        self.assertEqual(payload["source"], "safety_filter")
        self.assertTrue(payload["wasBlocked"])

    def test_compare_requires_both_products(self) -> None:
        response = self.client.post(
            "/ai/compare-products",
            json={"firstProduct": PRODUCT},
        )

        self.assertEqual(response.status_code, 422)


PRODUCT = {
    "id": "i-test",
    "brand": "Test",
    "name": "Test İlaç",
    "category": "İlaç",
    "description": "Kaynaklı ürün açıklaması.",
    "ingredients": ["Eski alan"],
    "activeIngredients": ["Etken madde 10 mg"],
    "indications": ["Genel belirti bilgisi"],
    "warnings": ["Sağlık profesyoneline danışılmalıdır."],
}


if __name__ == "__main__":
    unittest.main()
