import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percetakan/core/api_config.dart'; // Import konfigurasi API

class AuthController {
  static const String _authTokenKey = 'auth_token';
  static const String _rememberedEmailKey = 'remembered_email';
  static const String _rememberMeStatusKey = 'remember_me_status';

  Future<Map<String, dynamic>> login(String email, String password, bool rememberMe) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.loginUrl), // Gunakan URL dari ApiConfig
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
            },
            body: jsonEncode(<String, String>{
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (kDebugMode) {
        print('Login URL: ${ApiConfig.loginUrl}');
        print('Response Status: ${response.statusCode}');
        print('Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String? token = responseData['token'];
        // final Map<String, dynamic>? user = responseData['user']; // Bisa digunakan jika perlu data user

        if (token != null && token.isNotEmpty) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString(_authTokenKey, token);

          if (rememberMe) {
            await prefs.setString(_rememberedEmailKey, email);
            await prefs.setBool(_rememberMeStatusKey, true);
          } else {
            await prefs.remove(_rememberedEmailKey);
            await prefs.setBool(_rememberMeStatusKey, false);
          }
          return {'success': true, 'message': 'Login berhasil!', 'token': token};
        } else {
          return {'success': false, 'message': 'Token tidak ditemukan dari server.'};
        }
      } else if (response.statusCode == 422) {
        final Map<String, dynamic> errors = responseData['errors'];
        String errorMessage = "Terjadi kesalahan validasi:\n";
        errors.forEach((key, value) {
          if (value is List) {
            errorMessage += "${value.join('\n')}\n";
          }
        });
        return {'success': false, 'message': errorMessage.trim()};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': responseData['message'] ?? 'Email atau password salah.'};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Terjadi kesalahan: ${response.statusCode}'};
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saat login: $e');
      }
      String errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
      if (e.toString().toLowerCase().contains("socketexception") || e.toString().toLowerCase().contains("handshakeexception")) {
        errorMessage = 'Tidak dapat terhubung ke server. Pastikan server berjalan dan URL benar atau periksa konfigurasi jaringan/IP Anda.';
      } else if (e is FormatException) {
        errorMessage = 'Gagal memproses respons dari server.';
      }
      return {'success': false, 'message': errorMessage};
    }
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    // Anda mungkin ingin menghapus _rememberedEmailKey dan _rememberMeStatusKey juga di sini,
    // tergantung pada bagaimana Anda ingin fitur "remember me" berperilaku setelah logout.
    // Jika ingin email tetap terisi setelah logout (jika "remember me" aktif), jangan hapus.
    // Jika ingin bersih, hapus:
    // await prefs.remove(_rememberedEmailKey);
    // await prefs.setBool(_rememberMeStatusKey, false);
    if (kDebugMode) {
      print('User logged out, token removed.');
    }
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  Future<Map<String, dynamic>> getRememberedUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? rememberMeStatus = prefs.getBool(_rememberMeStatusKey);
    String? rememberedEmail;

    if (rememberMeStatus == true) { // Hanya muat email jika statusnya true
      rememberedEmail = prefs.getString(_rememberedEmailKey);
    }
    return {
      'email': rememberedEmail ?? '',
      'rememberMe': rememberMeStatus ?? false,
    };
  }
}