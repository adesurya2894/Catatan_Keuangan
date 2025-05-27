# 💰 Catatan Keuangan

Aplikasi Flutter sederhana untuk membantu pengguna mencatat pemasukan dan pengeluaran bulanan secara praktis dan efisien.


---

## 🚀 Fitur Utama

- Tambah transaksi pemasukan dan pengeluaran
- Kategori transaksi terpisah berdasarkan jenis
- Ringkasan bulanan: pemasukan, pengeluaran, dan selisih
- Riwayat transaksi terbaru (maks. 10 transaksi)
- Penyimpanan lokal dengan SharedPreferences
- Ikon launcher dan AppBar khusus

---

## 📱 Teknologi yang Digunakan

- **Flutter SDK**
- **Dart**
- **Shared Preferences** (penyimpanan lokal)
- **HTTP** (komunikasi dengan API)
- **intl** (format mata uang & tanggal)
- **Flutter Launcher Icons** (ikon aplikasi)

---

## 🛠 Cara Instalasi

1. Clone repositori ini:
   ```bash
   git clone https://github.com/adesuryadi2894/catatan_keuangan.git
   cd catatan_keuangan
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Jalankan di emulator atau device:
   ```bash
   flutter run
   ```

---

## 🧱 Struktur Folder

```
lib/
├── models/
│   ├── transaction_model.dart
│   └── user_model.dart
│
├── pages/
│   ├── edit_profil_page.dart
│   ├── home_page.dart
│   ├── login_page.dart
│   ├── profil_page.dart
│   ├── register_page.dart
│   ├── riwayat_detail_page.dart
│   ├── riwayat_page.dart
│   └── setting_page.dart
│
├── providers/
│   └── theme_notifier.dart
│
├── services/
│   ├── transaction_service.dart
│   └── user_service.dart
│
├── widgets/
│   ├── custom_appbar.dart
│   ├── custom_drawer.dart
│   └── custom_bottom_nav.dart
│
└── main.dart

```

---

## 📦 Build APK (Opsional)

Untuk membuat file APK:

```bash
flutter build apk --release
```

---

## 🤝 Kontribusi

Kontribusi terbuka untuk siapa saja. Fork repo ini, buat fitur baru atau perbaikan, lalu buat pull request.

---

## 📄 Lisensi

MIT License © 2025 [Loker Digital Vision](https://divinesia.co.id)
