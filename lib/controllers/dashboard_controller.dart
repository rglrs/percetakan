// lib/controllers/dashboard_controller.dart
// (Buat file baru ini jika belum ada)

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:percetakan/models/dashboard_stats.dart';
import 'package:percetakan/controllers/auth_controller.dart'; // Untuk mengambil token
import 'package:percetakan/core/api_config.dart'; // Diasumsikan ada untuk base URL

class DashboardController {
  // final String _baseUrl = 'http://192.168.8.91:8000/api'; // Ganti dengan ApiConfig jika ada
  final AuthController _authController = AuthController();

  Future<DashboardStats> fetchDashboardStats() async {
    String? token = await _authController.getToken();
    if (token == null) {
      throw Exception('User not authenticated. Token not found.');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/dashboard/stats'), // Menggunakan ApiConfig
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['success'] == true && responseData['data'] != null) {
        return DashboardStats.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load dashboard stats');
      }
    } else if (response.statusCode == 401) {
      // Handle unauthorized access, mungkin logout pengguna atau minta login ulang
      throw Exception('Unauthorized: Sesi Anda mungkin telah berakhir. Silakan login kembali.');
    } else {
      // Handle error lainnya
      final errorData = json.decode(response.body);
      throw Exception('Failed to load dashboard stats: ${errorData['message'] ?? response.reasonPhrase}');
    }
  }
}
