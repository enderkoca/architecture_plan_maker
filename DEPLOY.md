# 🚀 Deploy Talimatları

## 📦 Hazır Build Dosyaları

Build dosyaları `build/web` klasöründe hazır durumda.

## 🌐 Netlify ile Deploy (Önerilen)

1. **Netlify'e Git:** https://app.netlify.com/drop
2. **Drag & Drop:** `build/web` klasörünü sayfaya sürükleyin
3. **Deploy:** Otomatik olarak deploy edilecek
4. **Custom Domain:** İsteğe bağlı özel domain ekleyebilirsiniz

## 🔗 Vercel ile Deploy

1. **Terminal:**
   ```bash
   cd build/web
   vercel --prod
   ```
2. **Login:** Vercel hesabınızla giriş yapın
3. **Deploy:** Otomatik deploy

## 📄 GitHub Pages

1. **GitHub'da Repo Oluşturun:** architecture-plan-maker
2. **Push:**
   ```bash
   git remote add origin https://github.com/USERNAME/architecture-plan-maker.git
   git branch -M main
   git push -u origin main
   ```
3. **Settings > Pages:** Source olarak GitHub Actions seçin
4. **Auto Deploy:** Workflow dosyası mevcut (.github/workflows/pages.yml)

## 🔥 Firebase Hosting

1. **Firebase Console:** https://console.firebase.google.com
2. **Yeni Proje:** architecture-plan-maker
3. **Terminal:**
   ```bash
   firebase login
   firebase init hosting
   firebase deploy
   ```

## 📱 Test URL'leri

Deployment sonrası test edilecek özellikler:
- ✅ Dark/Light mode switch
- ✅ Responsive design (mobil/desktop)
- ✅ Proje formu
- ✅ Kat ve daire yönetimi
- ✅ PDF indirme
- ✅ Yerel veri kayıt

## 🎯 Production Ready

- ✅ Flutter 3.22+ uyumlu
- ✅ Optimized build (tree-shaking)
- ✅ PWA ready
- ✅ Mobile responsive
- ✅ Cross-browser compatible

---

**Not:** En hızlı deploy için Netlify Drop önerilir (sadece drag & drop)