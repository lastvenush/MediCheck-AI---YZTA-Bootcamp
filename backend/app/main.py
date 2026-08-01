from __future__ import annotations

import json
import os
from functools import lru_cache
from pathlib import Path

from dotenv import load_dotenv
from fastapi import Depends, FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import ValidationError

from .ai.gemini_service import GeminiService
from .ai.models import (
    AiAnalysisResult,
    AiAssistantResult,
    AiComparisonResult,
    ApiModel,
    ProductContext,
    ProductRecord,
)

load_dotenv(Path(__file__).resolve().parents[1] / ".env")


class AnalyzeRequest(ApiModel):
    product: ProductContext


class AskRequest(ApiModel):
    question: str
    product: ProductContext


class CompareProductsRequest(ApiModel):
    first_product: ProductContext
    second_product: ProductContext


@lru_cache(maxsize=1)
def get_gemini_service() -> GeminiService:
    return GeminiService()


def _allowed_origins() -> list[str]:
    raw_value = os.getenv(
        "CORS_ALLOWED_ORIGINS",
        "http://localhost:3000,http://localhost:5000,http://localhost:8080",
    )
    return [origin.strip() for origin in raw_value.split(",") if origin.strip()]


def _demo_data_path() -> Path:
    configured_path = os.getenv("MEDICHECK_DATA_FILE")
    if configured_path:
        path = Path(configured_path).expanduser()
        return path if path.is_absolute() else Path.cwd() / path
    repository_root = Path(__file__).resolve().parents[2]
    return repository_root / "medicheck_ai_flutter/assets/data/products.json"


@lru_cache(maxsize=1)
def get_demo_products() -> tuple[ProductRecord, ...]:
    try:
        decoded = json.loads(_demo_data_path().read_text(encoding="utf-8"))
        if not isinstance(decoded, list):
            raise ValueError("Demo veri dosyasının kökü liste olmalıdır.")
        return tuple(ProductRecord.model_validate(item) for item in decoded)
    except (OSError, json.JSONDecodeError, ValidationError, ValueError) as error:
        raise RuntimeError("Demo veri seti yüklenemedi.") from error


def _products_by_category(category: str) -> list[ProductRecord]:
    try:
        return [
            product for product in get_demo_products() if product.category == category
        ]
    except RuntimeError as error:
        raise HTTPException(status_code=500, detail=str(error)) from error


def _find_product(product_id: str, category: str) -> ProductRecord:
    match = next(
        (
            product
            for product in _products_by_category(category)
            if product.id == product_id
        ),
        None,
    )
    if match is None:
        label = "İlaç" if category == "İlaç" else "Ürün"
        raise HTTPException(status_code=404, detail=f"{label} bulunamadı.")
    return match


app = FastAPI(
    title="MediCheck AI Backend",
    version="0.1.0",
    description="MediCheck Flutter istemcisi için güvenli Gemini geçidi.",
)
app.add_middleware(
    CORSMiddleware,
    allow_origins=_allowed_origins(),
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type"],
)


@app.get("/health")
def health(service: GeminiService = Depends(get_gemini_service)) -> dict[str, object]:
    return {
        "status": "ok",
        "geminiEnabled": service.settings.enabled,
        "model": service.settings.model,
    }


@app.get("/products", response_model=list[ProductRecord], tags=["Products"])
def products() -> list[ProductRecord]:
    return _products_by_category("Güneş Kremi")


@app.get(
    "/products/{product_id}",
    response_model=ProductRecord,
    tags=["Products"],
)
def product_detail(product_id: str) -> ProductRecord:
    return _find_product(product_id, "Güneş Kremi")


@app.get("/medicines", response_model=list[ProductRecord], tags=["Medicines"])
def medicines() -> list[ProductRecord]:
    return _products_by_category("İlaç")


@app.get(
    "/medicines/{medicine_id}",
    response_model=ProductRecord,
    tags=["Medicines"],
)
def medicine_detail(medicine_id: str) -> ProductRecord:
    return _find_product(medicine_id, "İlaç")


@app.post("/ai/analyze", response_model=AiAnalysisResult)
def analyze(
    request: AnalyzeRequest,
    service: GeminiService = Depends(get_gemini_service),
) -> AiAnalysisResult:
    return service.analyze_product(request.product)


@app.post("/ai/ask", response_model=AiAssistantResult)
def ask(
    request: AskRequest,
    service: GeminiService = Depends(get_gemini_service),
) -> AiAssistantResult:
    return service.ask(request.question, request.product)


@app.post("/ai/compare-products", response_model=AiComparisonResult)
def compare_products(
    request: CompareProductsRequest,
    service: GeminiService = Depends(get_gemini_service),
) -> AiComparisonResult:
    return service.compare_products(request.first_product, request.second_product)
