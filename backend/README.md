# MediCheck AI Backend

Sprint 3 demo backend'i; Flutter uygulamasinin kullandigi ortak, kaynakli 10 gunes kremi + 5 ilac veri setini sunar ve guvenli AI gecidi saglar.

## Kurulum

Repository kokunde:

```bash
python3 -m pip install -r backend/requirements.txt
cp backend/.env.example backend/.env
python3 -m uvicorn backend.app.main:app --reload
```

Gercek API anahtarini yalnizca ignored `backend/.env` dosyasinda tutun. Anahtari Flutter koduna veya Git'e eklemeyin.

## Endpointler

- `GET /health`: Servis ve Gemini yapilandirma durumunu dondurur; API anahtarini gostermez.
- `GET /products`: Kaynakli 10 gunes kremini listeler.
- `GET /products/{id}`: Tek gunes kremi kaydini dondurur.
- `GET /medicines`: Kaynakli 5 ilaci listeler.
- `GET /medicines/{id}`: Tek ilac kaydini dondurur.
- `POST /ai/analyze`: Urun veya ilac icin yapilandirilmis analiz sonucu dondurur.
- `POST /ai/ask`: Urun baglamli, guvenlik filtreli asistan cevabi dondurur.
- `POST /ai/compare-products`: Iki gunes koruyucu icin tarafsiz karsilastirma sonucu dondurur.

Swagger UI: `http://127.0.0.1:8000/docs`

OpenAPI JSON: `http://127.0.0.1:8000/openapi.json`

## Demo verisi

Varsayilan veri kaynagi:

`medicheck_ai_flutter/assets/data/products.json`

Bu sayede Flutter ve FastAPI ayni demo kayitlarini kullanir. Farkli bir dosya kullanmak icin repository kokune gore veya mutlak yol olarak `MEDICHECK_DATA_FILE` ortam degiskenini ayarlayin.

## Test

Repository kokunde:

```bash
python3 -m unittest discover -s backend/tests -v
```

Testler ag baglantisi veya gercek Gemini anahtari gerektirmez. Veri liste/detay sayilari, 404 cevaplari, OpenAPI rotalari, AI guvenlik filtresi ve Gemini fallback sozlesmeleri kontrol edilir.

## Flutter baglantisi

Flutter varsayilan olarak `http://127.0.0.1:8000` adresini kullanir. Android emulatoru icin:

```bash
flutter run --dart-define=MEDICHECK_API_BASE_URL=http://10.0.2.2:8000
```

Fiziksel cihazda gelistirme bilgisayarinin yerel ag adresi, release ortaminda ise HTTPS backend adresi kullanilmalidir.
