from __future__ import annotations

import os
from functools import lru_cache
from pathlib import Path

from dotenv import load_dotenv
from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .ai.gemini_service import GeminiService
from .ai.models import (
    AiAnalysisResult,
    AiAssistantResult,
    AiComparisonResult,
    ApiModel,
    ProductContext,
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
