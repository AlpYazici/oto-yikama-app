# 🚗 Oto Yıkama Uygulaması

Flutter ile geliştirilmiş modern oto yıkama yönetim uygulaması.

## ✨ Özellikler

- 📱 **Müşteri Kaydı**: Telefon numarası ve araç plakası ile hızlı kayıt
- 🚗 **Yıkama Paketleri**: Farklı fiyat seçenekleri (50₺ - 150₺)
- 💬 **Otomatik SMS**: Müşterilere otomatik bilgilendirme mesajları
- 💾 **Kalıcı Veri**: SharedPreferences ile müşteri bilgileri saklanır
- 🕐 **Zaman Takibi**: Her işlem için otomatik zaman kaydı
- 📋 **Müşteri Listesi**: Günlük müşteri takibi ve yönetimi

## 📱 APK İndirme

En son sürümü indirmek için:

1. [Releases](../../releases) sayfasına gidin
2. En son sürümü indirin
3. APK dosyasını telefonunuza kurun

## 🛠️ Geliştirme

### Gereksinimler
- Flutter SDK
- Android Studio / VS Code
- Android SDK

### Kurulum
```bash
git clone https://github.com/AlpYazici/oto-yikama-app.git
cd oto-yikama-app
flutter pub get
flutter run
```

### APK Oluşturma
```bash
flutter build apk --release
```

## 📦 Kullanılan Paketler

- `permission_handler`: SMS izinleri için
- `shared_preferences`: Veri saklama için
- `flutter/material`: UI bileşenleri için

## 🎯 Kullanım

1. **Yeni Müşteri Ekle**: Telefon, plaka ve yıkama paketi seçin
2. **SMS Gönder**: Otomatik olarak müşteriye bilgi mesajı gönderilir
3. **İşlem Takibi**: Müşteri listesinde işlemleri takip edin
4. **Tamamlama**: "Hazır" butonuyla müşteriye tamamlama mesajı gönderin

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 👨‍💻 Geliştirici

Alp Yazıcı - [@AlpYazici](https://github.com/AlpYazici)