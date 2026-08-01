# MediCheck AI - Agent Proje Baglami

Bu dosya, repository uzerinde calisacak tum ajanlar icin kalici proje baglamidir. Degisiklik yapmadan once bu dosyayi ve ilgili kaynaklari okuyun. Bu belge mevcut kodu ve Sprint 3 teknik planini ozetler; gercek kod her zaman nihai kaynak kabul edilmelidir.

## Projenin Amaci

MediCheck AI, ilac prospektuslerini ve dermokozmetik urun iceriklerini sade bir dille sunmayi hedefleyen Flutter tabanli bir mobil saglik okuryazarligi uygulamasidir.

Uygulama teshis, tedavi, recete veya doz onerisi vermemelidir. Ilac kararlarinda doktor ya da eczaciya danisma uyarisi; dermokozmetik urunlerde ise kisisel hassasiyet uyarisi gorunur tutulmalidir.

## Repository Yapisi

- `README.md`: Sprint 1 ve Sprint 2 sureci, backlog, kullanici hikayeleri ve QA notlari.
- `MediCheck_AI_Sprint_3_Kesin_Teknik_Plan_Gorev_Dagilimi.pdf`: Sprint 3 kapsam, mimari, gorev dagilimi ve teslim plani.
- `images/`: Sprint board ve Sprint 2 uygulama ekran goruntuleri.
- `medicheck_ai_flutter/`: Flutter uygulamasi.
- `medicheck_ai_flutter/assets/data/products.json`: Yerel demo urun verisi.
- `medicheck_ai_flutter/test/`: Model, mock AI servisi, prompt ve AI analiz karti testleri.
- `backend/app/ai/`: Gemini structured output, guvenlik dogrulamasi ve mock fallback servis katmani.
- `backend/app/main.py`: FastAPI uygulamasi, CORS ve AI endpointleri.
- `backend/tests/`: Ag veya gercek API anahtari kullanmayan servis/API sozlesme testleri.
- `backend/schema.sql`: PostgreSQL icin normalize urun, terim ve kaynak semasi.

Repository'de FastAPI-Gemini entegrasyonu ve PostgreSQL semasi vardir; canli
veritabani baglantisi P2 kapsamindadir.

## Mevcut Teknik Mimari

Temel akis:

`ProviderScope -> MaterialApp.router -> DisclaimerScreen -> HomeScreen -> ProductCard -> ProductDetailScreen -> RemoteAiAnalysisService -> FastAPI -> GeminiService`

Uzak servis basarisiz olursa Flutter tarafinda guvenlik kuralli mock servis kullanilir.

Ana dosyalar:

- `medicheck_ai_flutter/lib/main.dart`: Uygulama girisi ve GoRouter rotalari.
- `medicheck_ai_flutter/lib/features/onboarding/disclaimer_screen.dart`: Uygulama
  acilisinda tanı/tedavi/recete/doz sinirlarini ve doktor/eczaci uyarisini
  gosteren bilgilendirme ekrani.
- `medicheck_ai_flutter/lib/models/product.dart`: Urun modeli ve guvenli JSON okuma yardimcilari.
- `medicheck_ai_flutter/lib/services/product_service.dart`: FastAPI katalog
  endpointlerini kullanir; ag hatasinda asset JSON'a duser, iki kaynak da
  bozuksa acik hata uretir ve basarili sonucu bellek icinde cache'ler.
- `medicheck_ai_flutter/lib/features/home/home_screen.dart`: Arama, kategori/alt filtre, urun listesi ve AI asistan gecisi.
- `medicheck_ai_flutter/lib/features/ai_assistant/`: Uzak ve mock fallback asistan servisleri ile calisan ekran.
- `medicheck_ai_flutter/lib/features/product_comparison/`: Uzak ve mock fallback tarafsiz karsilastirma servisleri.
- `medicheck_ai_flutter/lib/features/home/product_detail_screen.dart`: Urun detaylari, uzak AI analiz karti ve yasal uyari.
- `medicheck_ai_flutter/lib/features/ai_analysis/domain/ai_analysis_result.dart`: Yapilandirilmis analiz sonucu ve `mock`/`gemini` kaynak enum'u.
- `medicheck_ai_flutter/lib/features/ai_analysis/domain/ai_analysis_service.dart`: AI servis arayuzu.
- `medicheck_ai_flutter/lib/features/ai_analysis/data/mock_ai_analysis_service.dart`: Ilac ve gunes kremi icin deterministik mock analiz.
- `medicheck_ai_flutter/lib/features/ai_analysis/constants/ai_safety_prompt.dart`: Guvenli JSON cikti kurallari. Mevcut mock serviste veya gercek model cagrisinda aktif olarak kullanilmiyor.
- `medicheck_ai_flutter/lib/features/ai_analysis/presentation/widgets/ai_analysis_card.dart`: Loading, success, error ve retry durumlari.

## Mevcut Urun Davranisi

- Veri seti kaynakli 10 gunes kremi ve 5 ilactan olusur.
- Kullanici katalogdan once tibbi bilgilendirme ekranini gorur ve devam eder.
- Ana sayfa ad, marka, uretici, icerik, etken madde ve filtre tipine gore arama yapar.
- Kategoriler `Tumu`, `Gunes Kremi` ve `Ilac` olarak gorunur.
- Alt filtreler veri alanlarina acik kurallarla eslenir; arayuzde yalnizca mevcut
  Sprint 3 veri setinde karsiligi olan filtreler gosterilir.
- Detay ekrani cache'lenmis katalogdan ID ile urunu bulur; yukleme hatasinda retry sunar.
- On bes urunun gorseli `assets/images/products/` altinda yerel olarak tutulur;
  kart ve detay ekranlari asset/network ayrimini yapar ve hata fallback'i vardir.
- AI analiz karti FastAPI uzerinden Gemini'yi kullanir; ag/API hatasinda guvenli mock sonuc uretir.
- AI asistan ekrani urun secimi, soru, loading, guvenli cevap, disclaimer ve ornek soru akislariyla calisir.
- Karsilastirma ekrani ana ekrandaki ikonla acilir; iki gunes kremi icin yapisal tablo ve AI yorum karti gosterir.
- Katalog FastAPI'den yuklenir; sunucu erisilemezse yerel demo verisi ve gorunur uyari kullanilir.
- FastAPI ve gercek Gemini entegrasyonu vardir; PostgreSQL semasi hazirdir.

## Paket ve Mimari Notlari

- `go_router` urun rotalarinda kullanilir.
- AI asistan gecisi klasik `Navigator.push` kullanir; navigasyon yaklasimlari karisiktir.
- `AiSafetyGuard`, doz/tani/tedavi/acil durum sorularini siniflandirir ve guvenli yonlendirme uretir.
- `RemoteProductComparisonService`, FastAPI karsilastirma ucunu kullanir; hata halinde `MockProductComparisonService` tarafsiz yorum uretir.
- `backend.app.ai.GeminiService`, analiz/asistan/karsilastirma icin Pydantic structured output, cikti guvenlik kontrolu ve mock fallback uygular.
- Gemini varsayilan olarak kapalidir; `GEMINI_ENABLED=true` ve backend ortaminda API anahtari olmadan gercek cagri yapilmaz.
- Varsayilan Gemini modeli `gemini-3.5-flash-lite`tir. Dusuk maliyet/gecikme profili icin `thinking_level=minimal`, `max_output_tokens=512` ve sinirli urun baglami kullanilir. Gemini 3.5 isteklerinde `temperature`, `top_p` ve `top_k` gonderilmez.
- `flutter_riverpod` yalnizca kokte `ProviderScope` icin kullanilir; tanimli provider yoktur.
- `dio`, analiz/asistan/karsilastirma uzak servislerinde kullanilir. API adresi `MEDICHECK_API_BASE_URL` dart-define degeriyle degistirilebilir.
- `GoRouter` su anda `MediCheckApp.build` icinde olusturulur.
- Ana ekran ve AI analiz widget dosyalari buyuktur; yeni ozelliklerde daha kucuk bileşenlere ayirma tercih edilmelidir.

## Dogrulanmis Durum

1 Agustos 2026 tarihinde su kontroller basarili olmustur:

- `flutter analyze`: sorun bulunmadi.
- `flutter test`: 34/34 test basarili.
- `flutter build web`: web build basarili; Wasm dry run da basarili.
- `python3 -m unittest discover -s backend/tests -v`: 14/14 backend AI/API testi basarili.
- `python3 -m compileall -q backend/app`: basarili.
- 29 Temmuz 2026 gercek `gemini-3.5-flash-lite` HTTP smoke testi basarili: `/health` ve `/ai/ask` 200 dondu, sonuc `source=gemini`; API anahtari ignored `backend/.env` icinde tutulur.

Ilk checkout'ta `.dart_tool` olmadigi icin dogrudan `--no-pub` kullanmak paket bulunamadi hatalari uretir. Temiz ortamda once `flutter pub get` calistirin. Flutter SDK surumu degistiginde `pub get`, `pubspec.lock` icindeki gecisli paketleri guncelleyebilir; bu degisikligi bilincsizce commit etmeyin.

Mevcut test kapsami:

- Product modelinde eksik/gecersiz alanlar.
- AI sonuc modelinin JSON donusumu ve fallback degerleri.
- Guvenli promptta temel tibbi kurallar.
- Ilac ve gunes kremi mock analizleri.
- Bos urun verisinde fallback.
- AI kartinda loading, success, error ve retry.
- AI guvenlik filtresinde doz, tani ve kesinlik kontrolleri.
- Urun baglamli mock AI asistan cevaplari ve guvensiz soru reddi.
- Iki gunes kremi icin tarafsiz mock karsilastirma sonucu.
- Bes ilaclik kaynakli asset veri seti.
- Dio uzak analiz, asistan ve karsilastirma yanit eslemeleri.
- FastAPI health, analiz, soru ve karsilastirma sozlesmeleri.
- FastAPI urun/ilac liste ve detay endpointleri ile 404 sozlesmeleri.
- FastAPI katalog ve yerel asset fallback davranisi.
- Acilis bilgilendirme, ana sayfa etken madde aramasi, ilac alt filtresi ve
  bulunamayan urun rotasi widget akislari.

Eksik test alanlari:

- Tam uygulama seviyesinde widget/integration testi.

## Bilinen Riskler ve Teknik Borclar

### Saglik ve veri guvenligi

- On gunes kremi ve bes ilac kaydi resmî urun/uretici sayfalariyla kaynaklandirildi.
- `isSafe` geriye uyumluluk icin modelde kalir ancak arayuzde kullanilmaz; tum eski cagri noktalarindan tasindiktan sonra kaldirilmalidir.
- Detay ekrani ham `usageInstructions` verisini gosterir; disclaimer tek basina kaynak ve klinik dogruluk sorununun yerine gecmez.
- API anahtari yalnizca ignored `backend/.env` icindedir; Flutter istemcisine eklenmemelidir.
- Demo endpointleri urun baglamini istemciden alir. Kalici backend veri deposu eklendiginde istemci yalnizca urun ID gondermeli ve guvenilir baglam backend'de yuklenmelidir.

### Islevsel sorunlar

- Android ana manifestinde `INTERNET` izni vardir. Yerel HTTP backend erisimi sadece debug/profile manifestlerinde aciktir; release backend HTTPS kullanmalidir.

### Repository ve urunlestirme

- Android application ID ve release imzalama yapisi henuz urunlestirilmemistir.
- Uygulamada kimlik dogrulama, kalici kullanici verisi, telemetry veya hata raporlama yoktur.

## Sprint 3 Kesin Oncelikleri

Sprint 3 teknik planina gore P0 sirasiyla:

1. Demo verisini 10 gunes kremi ve 5 ilaca genisletmek.
2. Saglik dilini yumusatmak ve veri kaynaklarini eklemek.
3. Iki gunes kreminin secilip karsilastirilabildigi ekran ve AI yorum alani eklemek.
4. Urun/prospektus baglamli, guvenli ve calisan mock AI asistan akisi eklemek.
5. AI analiz cevaplarini ve promptlari final hale getirmek.
6. Favoriler, QR ve profil gibi calismayan placeholder kontrollerini kaldirmak veya pasiflestirmek.
7. Network image fallback ve duzgun bos/hata durumlari eklemek.
8. Analyzer, test ve web build kontrollerini tekrar calistirmak.
9. README, Sprint Board, final ekran goruntuleri ve en fazla 3 dakikalik demo videosunu tamamlamak.

P1 hedefleri:

- Minimal `backend/` FastAPI projesi.
- `GET /health`.
- `GET /products` ve `GET /products/{id}`.
- `GET /medicines` ve `GET /medicines/{id}`.
- `POST /ai/ask` guvenli mock endpointi.
- `POST /ai/compare-products` mock endpointi.
- Swagger kaniti ve backend calistirma dokumani.
- Canli PostgreSQL yetismezse en azindan `schema.sql`.

P2/gelecek surum: canli PostgreSQL, Alembic, gercek Gemini, favoriler, QR, profil ve barkod/OCR.

## Degisiklik Yaparken Kurallar

- Saglikla ilgili yeni metinlerde teshis, tedavi, recete, doz degisikligi veya kesin guvenlik iddiasi uretmeyin.
- Mevcut kesin saglik ifadelerini kopyalamak yerine daha temkinli ve kaynaklanabilir dile cevirin.
- Ilac kararlarinda doktor/eczaci uyarisini; dermokozmetik sonuclarda kisisel hassasiyet uyarisini koruyun.
- Gercek model/API eklendiginde anahtari Flutter istemcisine veya repository'ye koymayin.
- Kullaniciya gorunen calismayan kontrol birakmayin.
- Network ve veri hatalarini bos liste gibi gostermek yerine ayri loading/empty/error durumlariyla ele alin.
- Yeni davranislar icin test ekleyin ve en az `flutter analyze`, `flutter test` ve ilgili build'i calistirin.
- Kullaniciya ait ilgisiz degisiklikleri ve untracked dosyalari koruyun.
- README'deki tamamlandi iddialarini yalnizca gercekten dogrulanan sonuclarla guncelleyin.

## Definition of Done

Bir Sprint 3 ozelligi tamamlanmis sayilmak icin:

- Kullanici akisinda erisilebilir ve demo edilebilir olmali.
- Loading, empty ve error durumlari ele alinmali.
- Saglik uyari dili gorunur ve temkinli olmali.
- Ilgili testler eklenip basarili olmali.
- Analyzer temiz gecmeli.
- Uygulama web/demo hedefinde derlenmeli.
- README ve gerekiyorsa ekran goruntuleri gercek durumu yansitmali.
