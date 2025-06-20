# 15 Günlük Challenge Uygulaması

Kişisel gelişim, alışkanlık takibi ve hedef odaklı ilerleme için hazırlanmış bir Flutter uygulaması. Kullanıcılar kendi 15 günlük challenge'larını oluşturabilir, günlük görevler ekleyebilir ve ilerlemelerini takip edebilir.

## Özellikler

- **Challenge Oluşturma:** Başlık, açıklama, kategori ve 15 günlük görev listesi ile yeni challenge ekleyin.
- **Görev Takibi:** Her gün için görevlerinizi işaretleyin, düzenleyin veya silin.
- **Aylık Rapor:** O ayki tüm challenge'larınızın istatistiklerini ve ilerlemenizi görün.
- **Modern Arayüz:** Şık ve kullanıcı dostu tasarım, koyu ve açık tema desteği.
- **Firebase Firestore Entegrasyonu:** Tüm veriler bulutta saklanır.

## Ekran Görüntüleri

Aşağıda uygulamanın bazı ekran görüntülerini bulabilirsiniz. Kendi ekran görüntülerinizi `screenshots/` klasörüne ekleyip, aşağıdaki gibi gösterim sağlayabilirsiniz:

```markdown
![Ana Ekran](screenshots/Screenshots_1.png)
![Challenge Ekle](screenshots/Screenshots_2.png)
```

Örnek:

![Ana Ekran](screenshots/app_main.png)

## Ekranlar

- **Challenge Listesi:** Tüm challenge'larınızı ve ilerlemenizi görün, detaylara geçiş yapın.
- **Challenge Detayı:** 15 günlük görevlerinizi işaretleyin, düzenleyin veya silin.
- **Aylık Rapor:** Tamamlanan challenge ve görev sayısı, ortalama ilerleme gibi istatistikler.

## Kurulum

### 1. Gerekli Araçlar
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Dart SDK](https://dart.dev/get-dart) (Flutter ile birlikte gelir)
- [Android Studio](https://developer.android.com/studio) veya [VS Code](https://code.visualstudio.com/) (Flutter eklentisiyle)

### 2. Projeyi Klonla
```sh
git clone <repo-url>
cd challenge
```

### 3. Bağımlılıkları Yükle
```sh
flutter pub get
```

### 4. Firebase Kurulumu
1. [Firebase Console](https://console.firebase.google.com/) üzerinden yeni bir proje oluştur.
2. Android/iOS/Web uygulamanı ekle.
3. Gerekli `google-services.json` (Android) ve/veya `GoogleService-Info.plist` (iOS) dosyalarını indirip ilgili klasörlere koy:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
4. Terminalde:
```sh
flutterfire configure
```
Bu komut `lib/firebase_options.dart` dosyasını oluşturur/günceller.

### 5. Uygulamayı Çalıştır
```sh
flutter run
```

## Kullanılan Başlıca Paketler
- [firebase_core](https://pub.dev/packages/firebase_core)
- [cloud_firestore](https://pub.dev/packages/cloud_firestore)
- [google_fonts](https://pub.dev/packages/google_fonts)
- [lottie](https://pub.dev/packages/lottie)
- [provider](https://pub.dev/packages/provider)

## Katkı Sağlamak
- Kod stilini korumak için `flutter_lints` kuralları uygulanır.
- PR göndermeden önce `flutter analyze` ve `flutter test` çalıştırmanız önerilir.

## Lisans
MIT

---

Herhangi bir sorunla karşılaşırsanız veya katkı sağlamak isterseniz, lütfen bir issue açın veya PR gönderin!
