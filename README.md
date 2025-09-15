# 🏗️ Mimari Teklif Hazırlama Uygulaması

Flutter 3.22+ ile geliştirilmiş, mimarlık şirketleri için profesyonel teklif hazırlama uygulaması.

## ✨ Özellikler

### 🎨 Modern Arayüz
- **Dark/Light Mode:** Göz yormayan tema seçenekleri
- **Responsive Design:** Desktop, tablet ve mobil uyumlu
- **Material 3:** Modern ve temiz tasarım

### 📋 Proje Yönetimi
- **Proje Bilgileri:** Ad, adres ve detay bilgileri
- **Kat Yönetimi:** Dinamik kat ekleme/çıkarma
- **Daire Yönetimi:** Detaylı daire bilgileri
- **Malik Ayrımı:** Müteahhit/Toprak Sahibi kategorileri

### 📊 Dinamik Önizleme
- **Canlı Canvas:** Anlık görsel güncelleme
- **Renk Kodlaması:** Malik türüne göre renklendirme
- **Hesaplama Paneli:** Otomatik alan hesaplamaları
- **Özet Bilgiler:** Toplam alanlar ve dağılım

### 📄 PDF İhracatı
- **Profesyonel Format:** Mimari plan standartlarında
- **Detaylı Tablolar:** Tüm daire bilgileri
- **Firma Bilgileri:** Logo ve şirket detayları
- **Otomatik Adlandırma:** Tarih ile dosya adı

### 💾 Yerel Kayıt
- **Otomatik Kayıt:** SharedPreferences ile
- **Tema Tercihi:** Dark/Light mode hatırlama
- **Proje Verileri:** Son çalışılan proje

## 🚀 Teknolojiler

- **Flutter 3.22+**
- **Riverpod 2.x** - State Management
- **go_router** - Navigasyon
- **Material 3** - UI Framework
- **printing + pdf** - PDF oluşturma
- **shared_preferences** - Yerel kayıt

## 🛠️ Kurulum

```bash
# Repository'yi klonlayın
git clone [repository-url]

# Bağımlılıkları yükleyin
flutter pub get

# Web için çalıştırın
flutter run -d chrome

# Production build
flutter build web --release
```

## 📱 Kullanım

1. **Proje Bilgileri:** Sol panelden proje adı ve adres bilgilerini girin
2. **Kat Ekleme:** "Kat Ekle" butonu ile yeni katlar ekleyin
3. **Daire Yönetimi:** Her kata daireler ekleyip detaylarını düzenleyin
4. **Önizleme:** Sağ panelde canlı önizleme görün
5. **PDF İndir:** Profesyonel PDF raporu alın

## 🎯 Özellik Detayları

### Daire Bilgileri
- **Daire Adı:** Özelleştirilebilir daire isimleri
- **Malik Türü:** Müteahhit/Toprak Sahibi seçimi
- **Eski Brüt:** Mevcut alan bilgisi (m²)
- **Yeni Brüt:** Yeni proje alan bilgisi (m²)
- **5 Haneli Giriş:** 99999 m²'ye kadar alan desteği

### Görsel Özellikler
- **Çatı Alanı:** Göster/gizle seçeneği
- **Otopark:** Göster/gizle seçeneği
- **Renk Kodları:**
  - 🟣 Müteahhit: Pembe tonlar
  - ⬜ Toprak Sahibi: Beyaz/gri tonlar

## 🌙 Dark Mode

Uygulama hem açık hem koyu tema destekler:
- AppBar'daki switch ile hızlı değişim
- Otomatik kayıt ve geri yükleme
- Tüm bileşenler optimize edilmiş renkler

## 📊 Hesaplamalar

- **Toplam İnşaat Alanı:** Tüm katların toplam alanı
- **Müteahhit Toplam:** Müteahhit dairelerinin yeni brüt toplamı
- **Toprak Sahibi Toplam:** Toprak sahibi dairelerinin yeni brüt toplamı

## 🧪 Test

```bash
# Tüm testleri çalıştır
flutter test

# Model testleri
flutter test test/project_model_test.dart

# Widget testleri
flutter test test/widget_test.dart
```

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

---

**Geliştirici:** Claude Code ile geliştirilmiştir
**Versiyon:** 1.0.0
**Son Güncelleme:** Eylül 2025

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
