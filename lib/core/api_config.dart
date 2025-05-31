import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      // Untuk web, biasanya langsung ke domain/IP server Anda
      // atau bisa juga menggunakan proxy jika dikonfigurasi di development
      return 'http://localhost:8000/api'; // Sesuaikan jika perlu
    }
    // Deteksi platform untuk mobile
    print('Platform: ${defaultTargetPlatform.toString()}');
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.8.91:8000/api'; // Untuk Android Emulator
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'http://localhost:8000/api'; // Untuk iOS Simulator
    } else {
      const String physicalDeviceIp =
          '192.168.8.91'; // << GANTI IP INI DENGAN IP LOKAL KOMPUTER ANDA

      if (kDebugMode) {
        print("------------------------------------------------------------");
        print("API CONFIG: Menggunakan IP untuk perangkat fisik.");
        print("Pastikan IP '$physicalDeviceIp' adalah IP lokal komputer Anda");
        print("dan perangkat terhubung ke jaringan Wi-Fi yang sama.");
        print("Pastikan juga network_security_config.xml mengizinkan IP ini.");
        print("------------------------------------------------------------");
      }
      return 'http://$physicalDeviceIp:8000/api';
    }
  }

  // Endpoint spesifik bisa ditambahkan di sini atau di controller
  static String get loginUrl => '$baseUrl/login';
  static String get inventoriesUrl => '$baseUrl/inventories';
  static String get ordersUrl => '$baseUrl/orders';
  // Tambahkan endpoint lain jika ada
}
