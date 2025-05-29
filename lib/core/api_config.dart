import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // Untuk web, biasanya langsung ke domain/IP server Anda
      // atau bisa juga menggunakan proxy jika dikonfigurasi di development
      return 'http://localhost:8000/api'; // Sesuaikan jika perlu
    }
    // Deteksi platform untuk mobile
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api'; // Untuk Android Emulator
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'http://localhost:8000/api'; // Untuk iOS Simulator
    } else {
      // Untuk perangkat fisik atau platform lain,
      // GANTI DENGAN IP LOKAL MESIN ANDA YANG TERHUBUNG KE JARINGAN YANG SAMA
      // Pastikan untuk mengganti '192.168.X.X' dengan IP address Anda yang sebenarnya.
      // Anda bisa mendapatkan IP address Anda dengan perintah 'ipconfig' (Windows) atau 'ifconfig' (macOS/Linux).
      print(
          "PERHATIAN: Menggunakan IP fallback untuk API. Pastikan IP ini benar untuk perangkat fisik Anda.");
      return 'http://192.168.1.12:8000/api'; // << GANTI IP_ANDA SESUAI JARINGAN LOKAL
    }
  }

  // Endpoint spesifik bisa ditambahkan di sini atau di controller
  static String get loginUrl => '$baseUrl/login';
  static String get inventoriesUrl => '$baseUrl/inventories';
  // Tambahkan endpoint lain jika ada
}