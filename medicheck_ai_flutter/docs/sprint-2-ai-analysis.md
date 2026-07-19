# Sprint 2 AI Analizi - Teknik Not

## Amaç

Bu özellik, ürün detay ekranındaki ilaç veya güneş koruyucu verilerini sade
Türkçe ile özetler. Çıktılar yalnızca bilgilendirme amaçlıdır; tanı, tedavi,
reçete, doz veya kişisel uygunluk önerisi vermez.

## Teknik akış

1. Kullanıcı katalogdan bir ürün seçer.
2. `ProductDetailPage`, seçilen ürünü `AiAnalysisCard` bileşenine iletir.
3. Bileşen, `AiAnalysisService.analyzeProduct` metodunu çağırır.
4. Varsayılan `MockAiAnalysisService`, ürün tipine göre ilaç veya güneş
   koruyucu analizi üretir.
5. UI loading, success veya error durumunu gösterir.
6. Her başarılı sonuç görünür bir disclaimer ile tamamlanır.

Mock servis mevcut ürün verisinden runtime çıktı üretir. Eksik açıklama, içerik,
uyarı veya etki alanları güvenli genel metinlerle tamamlanır. Böylece null ya da
boş veri UI'da exception oluşturmaz.

## Desteklenen ürün tipleri

### İlaç

- Kısa prospektüs özeti
- Kullanım amacı
- Etken maddeler
- Dikkat noktaları
- Yaygın etkiler
- Doktor/eczacı yönlendirmesi içeren tıbbi bilgilendirme notu

### Güneş koruyucu

- Kısa ürün özeti
- SPF
- Filtre tipi
- Hedef cilt tipi
- Alkol ve parfüm durumu
- Potansiyel hassasiyet noktaları
- Dermatolojik değerlendirme uyarısı

## Güvenlik kuralları

Merkezi sistem promptu
`lib/features/ai_analysis/constants/ai_safety_prompt.dart` içinde tutulur.

Kurallar:

- Tıbbi tanı koyma.
- Tedavi veya reçete önerme.
- İlaç dozu belirleme ya da doz değişikliği önerme.
- Bir ürünü kesinlikle uygun veya güvenli ilan etme.
- Yalnızca verilen ürün verisini kullanma.
- Eksik bilgiyi açıkça belirtme.
- İlaç kararlarında doktor veya eczacıya yönlendirme.
- Dermokozmetik hassasiyetinin kişiden kişiye değişebileceğini belirtme.
- Her cevapta bilgilendirme uyarısı gösterme.
- Gerçek AI çıktısını yapılandırılmış JSON olarak isteme.

Mock servis de aynı kurallara uygun sabit disclaimer metinleri üretir. Uyarı,
hem ürün detayının üst kısmında hem AI analiz sonucunda görünür.

## Neden gerçek Gemini çağrısı yok?

Mobil uygulamaya gömülen API anahtarı uygulama paketinden çıkarılabilir ve
yetkisiz kullanıma açıktır. Bu nedenle Sprint 2 sürümüne Google AI anahtarı veya
başka bir client-side secret eklenmemiştir.

Gelecekte backend ya da Firebase Cloud Functions:

1. Mobil uygulamadan doğrulanmış ürün verisini almalı.
2. Sunucu tarafında saklanan secret ile Gemini'ı çağırmalı.
3. Merkezi promptu ve JSON şemasını uygulamalı.
4. Dönen JSON'u doğrulamalı ve güvenli fallback oluşturmalı.
5. Sonucu `AiAnalysisResult` biçiminde mobile döndürmelidir.

Bu servis, `AiAnalysisService` sözleşmesini uygulayan bir backend adapter'ı ile
mock servisin yerine geçirilebilir.

## Oluşturulan ve değiştirilen dosyalar

- `lib/app.dart`: Uygulama kökü ve servis enjeksiyonu.
- `lib/core/theme/app_theme.dart`: Material 3 renk ve tipografi sistemi.
- `lib/features/catalog/`: Ürün modeli, demo veri, katalog ve detay ekranları.
- `lib/features/ai_analysis/domain/`: Sonuç modeli ve servis sözleşmesi.
- `lib/features/ai_analysis/data/mock_ai_analysis_service.dart`: Runtime mock
  analiz üretimi.
- `lib/features/ai_analysis/constants/ai_safety_prompt.dart`: Merkezi güvenlik
  promptu.
- `lib/features/ai_analysis/presentation/`: Loading/success/error destekli analiz
  kartı.
- `test/`: Model, servis, prompt ve kullanıcı akışı testleri.

## Manuel kontrol

1. `flutter run` ile uygulamayı açın.
2. Arama alanında ürün veya etken madde arayın.
3. İlaçlar ve güneş koruyucular filtrelerini ayrı ayrı seçin.
4. Bir ilaç detayını açın; loading sonrasında analiz başlıklarını ve tıbbi
   uyarıyı kontrol edin.
5. Geri dönüp bir güneş koruyucu açın; SPF, filtre, cilt tipi, alkol/parfüm ve
   hassasiyet alanlarını kontrol edin.
6. Küçük ekranlarda uzun metinlerin taşmadığını ve sayfanın kaydırılabildiğini
   doğrulayın.

## Sprint 3 için kalanlar

- Backend/Firebase Cloud Functions üzerinde güvenli Gemini adapter'ı
- Sunucu tarafı schema doğrulaması, rate limiting ve gözlemlenebilirlik
- Gerçek ürün veri kaynağı ve içerik doğrulama süreci
- Kullanıcı sorularını kapsayan, yine güvenli kurallara bağlı AI asistanı
