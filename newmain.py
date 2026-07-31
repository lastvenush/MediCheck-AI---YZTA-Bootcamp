"""
MediCheck AI - Minimal FastAPI Backend
Sprint 3 P1 kapsamı - Yusuf Emre Sucu (Backend Support / QA / Repo Cleanup)

Bu dosya, Flutter mobil uygulamasının bağlanabileceği minimal bir demo
backend'i sağlar. Veriler JSON seed dosyalarından okunur (PostgreSQL
canlı bağlantısı Sprint 3 P2 kapsamında opsiyoneldir, bkz. schema.sql).

Önemli: Bu API tıbbi tanı, tedavi veya reçete önerisi sunmaz.
Tüm AI yanıtları güvenli, bilgilendirme amaçlı mock içeriklerdir.
"""

import json
from pathlib import Path
from typing import Optional

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "data"

app = FastAPI(
    title="MediCheck AI Backend",
    description=(
        "MediCheck AI için minimal demo backend'i. "
        "İlaç ve dermokozmetik ürün bilgilerini sunar; "
        "tıbbi tanı, tedavi veya doz önerisi vermez."
    ),
    version="0.1.0-sprint3",
)

# Flutter web/mobile demo istemcilerinin bağlanabilmesi için CORS açık.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def _load_json(filename: str) -> list:
    path = DATA_DIR / filename
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


# ---------------------------------------------------------------------------
# /health
# ---------------------------------------------------------------------------
@app.get("/health", tags=["System"])
def health_check():
    """Backend'in ayakta olup olmadığını kontrol eder."""
    return {"status": "ok"}


# ---------------------------------------------------------------------------
# /products
# ---------------------------------------------------------------------------
@app.get("/products", tags=["Products"])
def get_products():
    """Tüm dermokozmetik ürünleri (güneş kremleri) listeler."""
    return _load_json("products.json")


@app.get("/products/{product_id}", tags=["Products"])
def get_product_detail(product_id: int):
    """Tek bir ürünün detayını döndürür."""
    products = _load_json("products.json")
    for product in products:
        if product["id"] == product_id:
            return product
    raise HTTPException(status_code=404, detail="Ürün bulunamadı.")


# ---------------------------------------------------------------------------
# /medicines
# ---------------------------------------------------------------------------
@app.get("/medicines", tags=["Medicines"])
def get_medicines():
    """Tüm ilaçları listeler."""
    return _load_json("medicines.json")


@app.get("/medicines/{medicine_id}", tags=["Medicines"])
def get_medicine_detail(medicine_id: int):
    """Tek bir ilacın detayını döndürür."""
    medicines = _load_json("medicines.json")
    for medicine in medicines:
        if medicine["id"] == medicine_id:
            return medicine
    raise HTTPException(status_code=404, detail="İlaç bulunamadı.")


# ---------------------------------------------------------------------------
# /ai/ask (mock)
# ---------------------------------------------------------------------------
class AskRequest(BaseModel):
    question: str
    product_id: Optional[int] = None
    medicine_id: Optional[int] = None


SAFE_DISCLAIMER = (
    "Bu yanıt yalnızca bilgilendirme amaçlıdır; tıbbi tanı, tedavi veya "
    "doz önerisi içermez. Kişisel sağlık kararları için doktor veya "
    "eczacıya danışmanız önerilir."
)


@app.post("/ai/ask", tags=["AI Assistant (Mock)"])
def ai_ask(payload: AskRequest):
    """
    AI asistan demo endpointi.

    Gerçek Gemini entegrasyonu yetişmediği durumda güvenli, kural tabanlı
    bir mock yanıt üretir. Yanıt hiçbir zaman tanı, tedavi veya doz önerisi
    içermez.
    """
    context_name = None
    context_type = None
    context_image_url = None

    if payload.medicine_id is not None:
        medicines = _load_json("medicines.json")
        match = next((m for m in medicines if m["id"] == payload.medicine_id), None)
        if match:
            context_name = match["name"]
            context_type = "ilac"
            context_image_url = match.get("image_url")

    if payload.product_id is not None:
        products = _load_json("products.json")
        match = next((p for p in products if p["id"] == payload.product_id), None)
        if match:
            context_name = match["name"]
            context_type = "gunes_kremi"
            context_image_url = match.get("image_url")

    if context_name:
        answer = (
            f"{context_name} ile ilgili sorunuzu aldım. Genel bilgilere göre, "
            "bu ürün/ilacın içerik ve kullanım bilgileri detay ekranında yer "
            "almaktadır. Yan etki, alerji veya kullanım şüpheleriniz varsa "
            "lütfen doktor veya eczacınıza danışın."
        )
    else:
        answer = (
            "Sorunuzu aldım. Size en doğru ve güvenli bilgiyi verebilmem için "
            "bir ürün veya ilaç seçmenizi öneririm. Sağlıkla ilgili kesin "
            "kararlar için lütfen bir sağlık uzmanına danışın."
        )

    return {
        "question": payload.question,
        "context": context_name,
        "context_type": context_type,
        "context_image_url": context_image_url,
        "answer": answer,
        "disclaimer": SAFE_DISCLAIMER,
        "source": "mock_ai",
    }


# ---------------------------------------------------------------------------
# /ai/compare-products (mock)
# ---------------------------------------------------------------------------
class CompareRequest(BaseModel):
    product_id_1: int
    product_id_2: int


@app.post("/ai/compare-products", tags=["AI Assistant (Mock)"])
def ai_compare_products(payload: CompareRequest):
    """İki dermokozmetik ürünü karşılaştıran güvenli mock AI yorumu üretir."""
    products = _load_json("products.json")
    p1 = next((p for p in products if p["id"] == payload.product_id_1), None)
    p2 = next((p for p in products if p["id"] == payload.product_id_2), None)

    if not p1 or not p2:
        raise HTTPException(status_code=404, detail="Ürünlerden biri veya her ikisi bulunamadı.")

    comparison_lines = [
        f"{p1['name']} filtre tipi: {p1['filter_type']}; {p2['name']} filtre tipi: {p2['filter_type']}.",
        f"{p1['name']} önerilen cilt tipi: {p1['skin_type']}; {p2['name']} önerilen cilt tipi: {p2['skin_type']}.",
        f"{p1['name']} alkol içerir mi: {'Hayır' if p1['alcohol_free'] else 'Evet'}; "
        f"{p2['name']} alkol içerir mi: {'Hayır' if p2['alcohol_free'] else 'Evet'}.",
        f"{p1['name']} parfüm içerir mi: {'Hayır' if p1['fragrance_free'] else 'Evet'}; "
        f"{p2['name']} parfüm içerir mi: {'Hayır' if p2['fragrance_free'] else 'Evet'}.",
    ]

    return {
        "product_1": p1["name"],
        "product_1_brand": p1["brand"],
        "product_1_image_url": p1["image_url"],
        "product_2": p2["name"],
        "product_2_brand": p2["brand"],
        "product_2_image_url": p2["image_url"],
        "comparison": comparison_lines,
        "ai_comment": (
            "Bu karşılaştırma, ürünlerin içerik ve kullanım özelliklerine dayalı "
            "genel bir özet sunar; hangi ürünün cildinize daha uygun olduğuna "
            "karar vermeden önce bir dermatoloğa danışmanız önerilir."
        ),
        "disclaimer": SAFE_DISCLAIMER,
        "source": "mock_ai",
    }
