# 🚗 AutoClub Erenköy - Profesyonel Araç Yıkama Yönetim Sistemi

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

AutoClub Erenköy için özel olarak geliştirilmiş, modern ve kullanıcı dostu araç yıkama işletme yönetim uygulaması.

## 🌟 Özellikler

### 📋 Müşteri Yönetimi
- **Kuyruk Sistemi**: Müşterileri sıraya alma ve takip etme
- **Otomatik SMS**: Sıraya alındı ve hazır bildirimleri  
- **Plaka Takibi**: Araç plakası ile müşteri tanımlama
- **Zaman Damgası**: Her işlem için otomatik tarih/saat

### 💰 Gelir Analizi
- **Günlük Raporlar**: O günün detaylı gelir analizi
- **Haftalık Trendler**: 7 günlük performans grafikleri
- **Hizmet Sıralaması**: En karlı hizmetlerin analizi
- **Otomatik Hesaplama**: Kampanya indirimleri dahil

### 🎯 Kampanya Yönetimi
- **5 Farklı Kampanya Türü**: Hoşgeldin, Hafta Sonu, Erken Kuş, Sadakat, VIP
- **Esnek Süre Seçimi**: 1, 3, 7 veya özel gün seçenekleri
- **Otomatik Uygulama**: Uygun müşterilere otomatik indirim
- **Toplu SMS**: Tüm müşterilere kampanya duyurusu

### 📱 SMS Entegrasyonu
- **Native SMS**: Android native SMS sistemi
- **Türkçe Destek**: Tam Türkçe karakter desteği
- **Hata Toleransı**: SMS gönderilemezse uygulama kırılmaz
- **Temiz Format**: Emoji'siz, operatör uyumlu mesajlar

### 🎨 Modern Arayüz
- **Orange-Black Tema**: AutoClub marka renkleri
- **Material Design 3**: Modern ve kullanıcı dostu
- **Responsive**: Tüm ekran boyutlarında mükemmel görünüm
- **Gradient Efektler**: Premium hissiyat

## 🛠️ Teknik Özellikler

### Framework & Dil
- **Flutter**: Cross-platform mobil development
- **Dart**: Performanslı ve modern programlama dili
- **Material Design 3**: Google'ın en yeni tasarım sistemi

### Veri Yönetimi
- **SharedPreferences**: Local storage çözümü
- **JSON Serialization**: Güvenli veri formatı
- **Real-time Updates**: Anlık veri senkronizasyonu

### Platform Desteği
- ✅ **Android** (API 21+)
- ✅ **iOS** (iOS 12+)
- ✅ **Çevrimdışı Çalışma**
- ✅ **Native Performance**

## 📦 Kurulum

### Gereksinimler
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / VS Code
- Android SDK / Xcode

### Klonlama
```bash
git clone https://github.com/[username]/oto-yikama-app.git
cd oto-yikama-app
```

### Dependencies
```bash
flutter pub get
```

### Çalıştırma
```bash
# Debug mode
flutter run

# Release build
flutter build apk --release
flutter build ios --release
```

## 📱 APK İndirme

En son sürümü indirmek için [Releases](https://github.com/[username]/oto-yikama-app/releases) sayfasını ziyaret edin.

**Son Sürüm**: AutoClub-Erenkoy-TARIH-FIXED.apk (48.5MB)

## 📖 Kullanım Rehberi

Detaylı kullanım talimatları için [KULLANIM_REHBERI.md](./KULLANIM_REHBERI.md) dosyasını inceleyin.

### Hızlı Başlangıç
1. **Uygulamayı açın** ve SMS izinlerini verin
2. **Yeni müşteri** ekleyin (telefon, plaka, hizmet)
3. **Gün sonunda** "Gün Sonu" düğmesine basın
4. **Gelir Analizi** sekmesinde performansınızı görün
5. **Kampanya** açıp müşterilerinize SMS gönderin

## 🎯 Gün Sonu Düğmesi

### Ne Yapar?
- O günün tüm müşterilerini analiz eder
- Hizmet bazında gelir hesaplar
- Kampanya indirimlerini dahil eder
- Verileiri telefon hafızasında saklar

### Veri Formatı
```json
{
  "date": "2024-08-22",
  "totalRevenue": 450.0,
  "totalCustomers": 6,
  "serviceStats": {
    "VIP Detay Bakım": {
      "count": 1,
      "revenue": 180.0,
      "averagePrice": 180.0
    }
  }
}
```

### Saklama Konumu
- **Platform**: SharedPreferences (Android/iOS)
- **Key Format**: `revenue_YYYY-MM-DD`
- **Retention**: Uygulama silinene kadar kalıcı
- **Görüntüleme**: Gelir Analizi sekmesinde

## 🔧 Geliştirici Notları

### Proje Yapısı
```
lib/
├── main.dart                 # Ana uygulama
├── models/                   # Veri modelleri
│   ├── campaign_model.dart   # Kampanya modeli
│   └── revenue_model.dart    # Gelir modeli
├── screens/                  # Ekranlar
│   ├── campaign_management_screen.dart
│   └── revenue_analysis_screen.dart
└── utils/                    # Yardımcı sınıflar
    └── data_manager.dart     # Veri yönetimi
```

### Key Dependencies
```yaml
dependencies:
  flutter: sdk
  cupertino_icons: ^1.0.8
  permission_handler: ^12.0.1
  shared_preferences: ^2.5.3
  intl: ^0.19.0

dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

### SMS Sistemi
Native Android SMS API kullanır:
- `MethodChannel` ile Flutter-Android köprüsü
- `SmsManager` ile SMS gönderimi
- Permission handling ile güvenlik

## 🚀 Versiyon Geçmişi

### v1.0.0 (Mevcut)
- ✅ Müşteri kuyruk sistemi
- ✅ SMS entegrasyonu
- ✅ Kampanya yönetimi
- ✅ Gelir analizi
- ✅ Modern UI/UX
- ✅ Türkçe lokalizasyon

### Gelecek Özellikler
- 🔄 Cloud sync (Firebase)
- 📊 Gelişmiş raporlama
- 👥 Çoklu kullanıcı desteği
- 💳 Ödeme entegrasyonu
- 📷 Fotoğraf ekleme

## 🤝 Katkıda Bulunma

1. Repository'yi fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📄 Lisans

Bu proje AutoClub Erenköy için özel olarak geliştirilmiştir.

## 📞 İletişim & Destek

- 🏢 **AutoClub Erenköy**
- 📧 **E-mail**: [iletisim@autocluberenkoy.com]
- 📱 **Telefon**: [+90 XXX XXX XX XX]
- 🌐 **Website**: [www.autocluberenkoy.com]

---

## 🏆 Özel Teşekkürler

Bu uygulama, modern araç yıkama işletmeciliğinin ihtiyaçlarını karşılamak için geliştirilmiştir. AutoClub Erenköy ekibinin vizyonu ve geri bildirimleri ile mükemmelleştirilmiştir.

**💫 Dijital dönüşümle geleceğe hazır olun!**

---

*© 2024 AutoClub Erenköy. Tüm hakları saklıdır.*