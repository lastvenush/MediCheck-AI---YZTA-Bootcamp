# Gemini AI Servis Katmani

Bu klasor Pelin'in AI ve entegrasyon sorumlulugundaki servis katmanidir. FastAPI endpointleri Yusuf'un backend katmani tarafindan bu servisi cagiracaktir.

## Guvenlik Mimarisi

1. Mobil istemci demo urununun yapisal alanlarini ve kullanici sorusunu backend'e yollar.
2. Backend gelen veriyi Pydantic semasi ve alan/uzunluk sinirlariyla dogrular. Kalici backend urun deposu eklendiginde istemciden yalnizca urun ID alinmalidir.
3. Doz, tani, tedavi, kisisel uygunluk ve acil durum sorulari Gemini cagrisindan once kontrol edilir.
4. Ilac doz metni Gemini baglamina dahil edilmez.
5. Gemini Pydantic tabanli structured output uretir.
6. Uygulama model ciktisini ikinci kez tibbi guvenlik kurallariyla denetler.
7. API kapaliysa, anahtar yoksa, istek basarisizsa veya cikti guvensizse mock fallback doner.

## Ortam Degiskenleri

`.env.example` dosyasini referans alin. Gercek anahtari `.env`, kaynak kod, Flutter uygulamasi veya Git gecmisine eklemeyin.

- `GEMINI_ENABLED=true`: Gercek Gemini cagrisini acar.
- `GEMINI_API_KEY`: Backend tarafindaki Gemini API anahtari. Kod resmi `GOOGLE_API_KEY` degiskenini de destekler.
- `GEMINI_MODEL`: Varsayilan `gemini-3.5-flash-lite`; deploy ortami icin acikca ayarlanabilir.
- `GEMINI_MAX_OUTPUT_TOKENS=512`: Kisa structured output icin cikti maliyetini ve gecikmeyi sinirlar.
- `GEMINI_THINKING_LEVEL=minimal`: Gemini 3.5 Flash-Lite icin en dusuk dusunme seviyesini kullanir.
- `MEDICHECK_DATA_FILE`: Demo veri dosyasinin yolu. Varsayilan olarak Flutter asset'indeki ortak 10 gunes kremi + 5 ilac verisi okunur.

Maliyet/gecikme profili bilincli olarak kisa urun analizi icin ayarlanmistir: urun baglami alan bazinda sinirlanir, kullanici sorusu en fazla 1000 karakter olarak islenir, cikti 512 tokenla sinirlanir ve modelin dusunme seviyesi `minimal` tutulur. Yeni Gemini 3.5 modellerinde kullanimi kaldirilan `temperature`, `top_p` ve `top_k` parametreleri gonderilmez. Daha karmasik gelecek senaryolarda bu degerler ortam degiskeniyle kontrollu olarak artirilabilir.

## FastAPI Sozlesmesi

`backend.app.main` icinde su endpointler hazirdir:

- `GET /health`
- `GET /products`
- `GET /products/{id}`
- `GET /medicines`
- `GET /medicines/{id}`
- `POST /ai/analyze`
- `POST /ai/ask`
- `POST /ai/compare-products`

Sonuclar `source` alaninda `gemini`, `mock_fallback` veya `safety_filter` degeri tasir. Mobil istemci bu alani debug/QA icin kullanabilir; kullaniciya model kaynagini tibbi guven isareti gibi sunmamalidir.

## Calistirma

Repository kokunde:

```bash
python3 -m pip install -r backend/requirements.txt
cp backend/.env.example backend/.env
python3 -m uvicorn backend.app.main:app --reload
```

Swagger arayuzu `http://127.0.0.1:8000/docs`, saglik kontrolu `http://127.0.0.1:8000/health` adresindedir. Flutter varsayilan olarak `http://127.0.0.1:8000` adresini kullanir. Farkli cihaz veya emulator icin:

```bash
flutter run --dart-define=MEDICHECK_API_BASE_URL=http://10.0.2.2:8000
```

Android emulatorunde `10.0.2.2`, gelistirme bilgisayarinin localhost adresine yonlenir. Fiziksel cihazda bilgisayarin yerel ag IP adresi kullanilmalidir.

## Test

Repository kokunden:

```bash
python3 -m unittest discover -s backend/tests -v
```

Testler gercek API anahtari veya ag cagrisina ihtiyac duymaz; sahte Gemini istemcisi kullanir.
