# Kasir App

Aplikasi kasir sederhana berbasis Flutter (Android) — tugas akhir mata kuliah Mobile Programming.

## Fitur

- Autentikasi: register, login, profil (SQLite + `shared_preferences`)
- CRUD produk dengan kategori
- Transaksi penjualan + cetak struk
- Grafik ringkasan penjualan (`fl_chart`)

## Teknologi

Flutter (Dart), SQLite (`sqflite`), `fl_chart`, `intl`. Tanpa backend — semua data lokal di perangkat.

## Menjalankan

```bash
flutter pub get
flutter run
```

## Struktur

```
lib/
├── main.dart
├── database/database_helper.dart   # skema & CRUD SQLite
├── models/                          # product, transaction, user
└── screens/                         # splash, auth, produk, transaksi, struk, profil
```
