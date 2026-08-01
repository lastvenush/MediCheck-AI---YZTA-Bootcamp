from __future__ import annotations

import unittest

from fastapi.testclient import TestClient

from backend.app.ai.gemini_service import GeminiService, GeminiSettings
from backend.app.main import app, get_demo_products, get_gemini_service


class ApiTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.service = GeminiService(settings=GeminiSettings(enabled=False))
        app.dependency_overrides[get_gemini_service] = lambda: cls.service
        get_demo_products.cache_clear()
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

    def test_products_returns_ten_sourced_sunscreens(self) -> None:
        response = self.client.get("/products")

        self.assertEqual(response.status_code, 200)
        payload = response.json()
        self.assertEqual(len(payload), 10)
        self.assertEqual(len({product["id"] for product in payload}), 10)
        self.assertTrue(
            all(product["category"] == "Güneş Kremi" for product in payload)
        )
        self.assertTrue(all(product["sources"] for product in payload))

    def test_product_detail_and_missing_product(self) -> None:
        response = self.client.get("/products/g1")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["id"], "g1")
        self.assertIn("filterTypes", response.json())

        missing_response = self.client.get("/products/unknown")
        self.assertEqual(missing_response.status_code, 404)
        self.assertEqual(missing_response.json()["detail"], "Ürün bulunamadı.")

    def test_medicines_returns_five_reviewed_records(self) -> None:
        response = self.client.get("/medicines")

        self.assertEqual(response.status_code, 200)
        payload = response.json()
        self.assertEqual(len(payload), 5)
        self.assertEqual(len({medicine["id"] for medicine in payload}), 5)
        self.assertTrue(all(medicine["category"] == "İlaç" for medicine in payload))
        self.assertTrue(all(medicine["lastReviewedAt"] for medicine in payload))

    def test_medicine_detail_and_missing_medicine(self) -> None:
        response = self.client.get("/medicines/i1")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json()["id"], "i1")
        self.assertTrue(response.json()["activeIngredients"])

        missing_response = self.client.get("/medicines/unknown")
        self.assertEqual(missing_response.status_code, 404)
        self.assertEqual(missing_response.json()["detail"], "İlaç bulunamadı.")

    def test_openapi_lists_sprint_three_data_endpoints(self) -> None:
        paths = self.client.get("/openapi.json").json()["paths"]

        self.assertIn("/products", paths)
        self.assertIn("/products/{product_id}", paths)
        self.assertIn("/medicines", paths)
        self.assertIn("/medicines/{medicine_id}", paths)

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
