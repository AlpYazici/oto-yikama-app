# 🚗 AutoClub Erenköy - İşletme Sahibi Kullanım Rehberi

## 📱 Uygulama Hakkında
AutoClub Erenköy, araç yıkama işletmenizi dijitalleştiren profesyonel bir yönetim sistemidir. Müşteri kuyruğu, SMS bildirimleri, kampanya yönetimi ve gelir analizi gibi tüm ihtiyaçlarınızı karşılar.

---

## 🏠 Ana Ekran (4 Tab)

### 1️⃣ **Yeni Müşteri Sekmesi**
- **Telefon**: Müşterinin telefon numarası (SMS gönderilecek)
- **Plaka**: Araç plakası (otomatik büyük harfe çevrilir)
- **Hizmet**: Sunduğunuz paketlerden birini seçin
- **KAYDET**: Müşteriyi kuyruğa ekler ve SMS gönderir

**💡 İpucu**: Aktif kampanya varsa otomatik indirim uygulanır!

### 2️⃣ **Kuyruk Sekmesi**
- Sıradaki müşterilerin listesi
- Her müşteri için: Plaka, telefon, hizmet, saat bilgisi
- **✅ HAZıR** butonu: Müşteriyi tamamlar ve SMS gönderir
- **🗑️ SİL** butonu: Müşteriyi kuyruktan çıkarır

### 3️⃣ **Gelir Analizi Sekmesi**
- **Bugünkü Gelir**: O günkü toplam ciroyunuz
- **Haftalık Gelir**: Son 7 günün toplamı
- **Grafik**: Günlük gelir analizi
- **Hizmet Sıralaması**: En çok kazandıran hizmetler

### 4️⃣ **Kampanya Yönetimi Sekmesi**
- **Hazır Şablonlar**: 5 farklı kampanya türü
- **SMS Gönder**: Aktif kampanyaları müşterilere duyur
- **Özel Kampanya**: Kendi kampanyanızı oluşturun

---

## 🎯 Kampanya Sistemi

### Kampanya Türleri:
1. **AutoClub Hoşgeldin** - Yeni müşterilere %30 indirim
2. **Hafta Sonu Avantajı** - Cumartesi-Pazar %20 indirim  
3. **Erken Kuş** - Sabah saatleri %25 indirim
4. **Erenköy Sadakat** - Sadık müşterilere %20 indirim
5. **VIP Detay İndirimi** - Premium hizmetlerde %35 indirim

### Kampanya Nasıl Açılır?
1. **Kampanya Yönetimi** sekmesine git
2. İstediğiniz kampanyanın **switch**'ini açın
3. Süre seçin (1, 3, 7 gün)
4. Kampanya otomatik aktif olur

### Kampanya SMS'i Nasıl Gönderilir?
1. En az 1 kampanya aktif olmalı
2. **SMS butonu**na basın (sağ üst)
3. Tüm müşterilere otomatik SMS gider

---

## 💰 Gün Sonu İşlemi

### 🔴 GÜN SONU Düğmesi Ne Yapar?

Ana ekrandaki **turuncu GÜN SONU** düğmesine bastığınızda:

#### 📊 Veri Toplama:
1. O günün tüm müşterilerini tarar
2. Her hizmet için gelir hesaplar
3. Kampanya indirimlerini dahil eder
4. Toplam ciro ve müşteri sayısını bulur

#### 💾 Veri Saklama:
- **Konum**: Telefon hafızası (SharedPreferences)
- **Format**: `revenue_2024-08-22` gibi tarihli key
- **İçerik**: JSON formatında detaylı analiz

#### 📋 Kaydedilen Veriler:
```json
{
  "date": "2024-08-22",
  "totalRevenue": 450.0,
  "totalCustomers": 6,
  "serviceStats": {
    "Ekonomik Paket (60₺)": {
      "count": 2,
      "revenue": 120.0,
      "averagePrice": 60.0
    },
    "VIP Detay Bakım (180₺)": {
      "count": 1,
      "revenue": 180.0,
      "averagePrice": 180.0
    }
  }
}
```

#### 📈 Görüntüleme:
- **Gelir Analizi** sekmesinde görünür
- Son 7 günün grafik ve istatistikleri
- En çok kazandıran hizmet sıralaması
- Haftalık trends ve karşılaştırmalar

---

## 📱 SMS Sistemi

### SMS Türleri:
1. **Sıraya Alındı**: "Merhaba! ABC123 sıraya alındı. Auto Club Erenkoy"
2. **Kampanya Dahil**: "...KAMPANYA: Hoşgeldin. Indirimli Fiyat: 90 TL..."
3. **Hazır**: "Merhaba! ABC123 hazır. Teşekkürler! Auto Club Erenkoy"
4. **Kampanya Duyuru**: "AUTO CLUB ERENKOY KAMPANYA! Hoşgeldin %30 INDIRIM..."

### SMS Özellikleri:
- ✅ Türkçe karakter destekli
- ✅ Emoji kullanılmaz (uyumluluk için)
- ✅ Tek satır formatı
- ✅ Otomatik gönderim
- ✅ Hata toleranslı

---

## 🎨 Hizmet Paketleri

1. **Ekonomik Paket (60₺)** - Temel yıkama
2. **Standart Paket (85₺)** - Standart temizlik
3. **AutoClub Premium (130₺)** - Premium hizmet
4. **VIP Detay Bakım (180₺)** - En kapsamlı
5. **Kış Özel Bakım (110₺)** - Mevsimsel

---

## 🔧 Teknik Bilgiler

### Veri Yedekleme:
- **Müşteri Listesi**: `customers` key'i ile telefonda
- **Kampanyalar**: `campaigns` key'i ile telefonda  
- **Günlük Analizler**: `revenue_YYYY-MM-DD` formatında
- **Veri Kalıcı**: Uygulama silinene kadar korunur

### Performans:
- Hafif ve hızlı
- Çevrimdışı çalışır
- SMS permission gerekli
- Android ve iOS uyumlu

---

## 🆘 Sorun Giderme

### SMS Gitmiyor?
1. Telefon SMS izni vermiş mi kontrol edin
2. Telefon numarası doğru mu?
3. Operatör sorunu olabilir, tekrar deneyin

### Kampanya Çalışmıyor?
1. Kampanya switch'i açık mı?
2. Kampanya süresi bitti mi?
3. Müşteri listesi boş mu?

### Veriler Kayboldu?
1. Uygulama silinmişse veriler gider
2. Telefonun hafızası dolu olabilir
3. Gün sonu düğmesine basılmış mı?

---

## 👨‍💼 İşletme Sahibi İpuçları

### Günlük Rutin:
1. **Sabah**: Önceki gün verilerini kontrol et
2. **Gün İçi**: Müşterileri kaydet, SMS'leri takip et
3. **Akşam**: Gün sonu düğmesine bas
4. **Haftalık**: Gelir analizi ve kampanya planla

### Karlılık İçin:
- En çok kazandıran hizmeti tespit et
- Hafta sonu kampanyaları çalıştır
- Müşteri sadakatini ödüllendir
- Detaylı istatistikleri takip et

### Müşteri Memnuniyeti:
- SMS'leri zamanında gönder
- Kampanya fırsatlarını duyur
- Kuyruk sürelerini optimize et
- Hizmet kalitesini artır

---

## 📞 İletişim & Destek

**AutoClub Erenköy Digital Solutions**
- 📧 E-mail: [Destek e-postası]
- 📱 WhatsApp: [Destek numarası]
- 🌐 Web: [Website adresi]

---

*Bu rehber AutoClub Erenköy uygulamasının v1.0 sürümü içindir. Güncellenen özellikler için yeni sürüm notlarını takip edin.*

**🚀 Başarılı işletme yönetimi dileriz!**
