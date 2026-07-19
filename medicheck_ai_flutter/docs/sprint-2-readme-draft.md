# Sprint 2 README Taslağı

Bu bölüm, takımın ana README dosyasındaki Sprint 2 alanına taşınmak üzere
hazırlanmıştır. Daily Scrum katılımcıları ve Sprint Board ekran görüntüsü gerçek
takım kayıtlarıyla tamamlanmalıdır.

## Sprint 2 Amacı

Sprint 2'nin amacı, MediCheck AI fikrini çalışan bir mobil prototipe
dönüştürmek; ilaç ve güneş koruyucu verilerini sade biçimde gösteren, güvenli
AI analiz akışını ürün detay ekranına eklemektir.

Pelin Yaşar'ın teknik katkısı kapsamında:

- AI analiz sonuç modeli oluşturuldu.
- Mock ve gelecekteki gerçek servis için ortak sözleşme hazırlandı.
- İlaç ve güneş koruyucu ürünleri ayıran çalışan mock analiz servisi eklendi.
- Tıbbi tavsiye görünümünü engelleyen merkezi prompt ve güvenlik kuralları
  tanımlandı.
- Analiz sonucu mobil detay ekranına loading, success ve error durumlarıyla
  bağlandı.
- Disclaimer metni ürün detayında ve AI sonucunda görünür hale getirildi.
- Model, servis, prompt ve kullanıcı akışı testleri eklendi.

## Sprint 2 Backlog

| İş | Sorumlu/Odak | Durum | Kanıt |
|---|---|---|---|
| AI analiz modeli | Pelin / AI | Tamamlandı | `AiAnalysisResult` |
| AI servis sözleşmesi | Pelin / AI | Tamamlandı | `AiAnalysisService` |
| Güvenli AI promptu | Pelin / AI güvenliği | Tamamlandı | `AiSafetyPrompt` |
| Mock ilaç analizi | Pelin / AI | Tamamlandı | `MockAiAnalysisService` |
| Mock güneş koruyucu analizi | Pelin / AI | Tamamlandı | `MockAiAnalysisService` |
| Mobil AI sonuç alanı | Pelin / Mobile support | Tamamlandı | `AiAnalysisCard` |
| Loading ve hata akışı | Pelin / Mobile support | Tamamlandı | Widget testleri |
| Gerçek Gemini backend'i | Sprint 3 | Backlog | Backend/Cloud Functions |

## Backlog Dağıtma Mantığı

Sprint 2'de öncelik, gerçek bir API anahtarı gerektirmeden demo sırasında
gösterilebilecek güvenli bir uçtan uca akış üretmeye verilmiştir. AI servisi
arayüzle soyutlanmış; böylece mobil uygulama mock servisle çalışırken daha sonra
backend tabanlı Gemini adapter'ına geçebilecek hale getirilmiştir.

## Daily Scrum Notları

Gerçek toplantı kayıtları aşağıdaki şablonla eklenmelidir. Katılmayan ekip
üyeleri katılımcı listesine yazılmamalıdır.

```markdown
### Daily Scrum X

**Tarih:** ...
**Katılımcılar:** ...

- Dün yapılanlar:
- Bugün yapılacaklar:
- Engel / ihtiyaç:
- Alınan kararlar:
```

## Sprint Board Updates

Board üzerinde aşağıdaki kartların güncel duruma taşınması önerilir:

- `AI prompt taslağı` → Done
- `Gemini API denemesi` → Mock AI çıktısı ile Done veya takım kararına göre
  In Progress
- `Mobil AI analiz/result alanı` → Done
- `AI model ve servis altyapısı` → Done
- `AI analiz testleri` → Done
- `Sprint 2 README` → In Progress; takım günlükleri ve board görseli bekleniyor

GitHub Projects kartları ve ekran görüntüsü kullanıcı tarafından manuel olarak
güncellenmelidir.

## Ürün Durumu

Flutter uygulaması şu anda:

- İlaç ve güneş koruyucu ürünlerini listeler.
- Ürün, marka veya etken madde araması yapar.
- Kategori filtrelemesi sunar.
- Ürün detaylarında temel verileri gösterir.
- AI analizini kısa bir loading sonrasında üretir.
- İlaç ve güneş koruyucular için farklı analiz başlıkları kullanır.
- Eksik veride güvenli fallback oluşturur.
- Analiz hatasında uygulamayı çalışır tutar ve tekrar deneme seçeneği sunar.
- Tıbbi ve dermatolojik disclaimer metnini görünür gösterir.

## Sprint Review Taslağı

Sprint 2 sonunda çalışan Flutter prototipi ve güvenli mock AI analiz sistemi
oluşturuldu. Kullanıcı katalogdan bir ilaç veya güneş koruyucu seçerek detay
ekranına ulaşabiliyor ve mevcut ürün verilerinden üretilen sade analizi
inceleyebiliyor.

Gerçek Gemini entegrasyonu bilinçli olarak mobil uygulamaya eklenmedi. API
anahtarının client tarafında korunamayacağı değerlendirildi ve backend tabanlı
entegrasyon Sprint 3'e bırakıldı.

## Sprint Retrospective Taslağı

### İyi gidenler

- AI özelliği servis sözleşmesi üzerinden UI'dan ayrıldı.
- Yeni state management veya gereksiz dependency eklenmedi.
- İlaç ve dermokozmetik ürünler aynı kullanıcı akışında desteklenebildi.
- Güvenlik kuralları prompt, servis ve UI katmanlarında görünür biçimde
  uygulandı.
- Otomatik testler ve mobil görsel kontrol ile akış doğrulandı.

### Geliştirilmesi gerekenler

- Ürün verileri güvenilir ve sürdürülebilir bir kaynağa taşınmalı.
- Gerçek AI çıktısı backend üzerinde JSON schema doğrulamasından geçirilmeli.
- Sağlık içerikleri alan uzmanı tarafından gözden geçirilmeli.
- Erişilebilirlik ve farklı cihaz boyutları için test kapsamı genişletilmeli.

### Sonraki sprint aksiyonları

- Backend veya Firebase Cloud Functions üzerinde Gemini adapter'ı geliştirmek.
- Secret yönetimi, rate limiting ve hata gözlemlenebilirliği eklemek.
- Gerçek ürün veri kaynağını uygulamaya bağlamak.
- Güvenli soru-cevap asistanının ilk sürümünü oluşturmak.

## Teslim Öncesi Kontrol

- [ ] Daily Scrum kayıtları gerçek katılımcılarla eklendi.
- [ ] Güncel Sprint Board ekran görüntüsü alındı.
- [ ] Görsel yolu ana README'de doğrulandı.
- [ ] Takım üyelerinin katkıları board kartlarında görünüyor.
- [x] AI veya mock AI analiz çıktısı bulunuyor.
- [x] Güvenli prompt ve cevap kuralları bulunuyor.
- [x] Sağlık uyarısı uygulamada görünür.
- [x] Flutter analyze ve testler başarılı.
- [ ] Bu taslak ana README'nin Sprint 2 bölümüne taşındı.
