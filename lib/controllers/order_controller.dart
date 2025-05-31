import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:percetakan/models/pesanan_item.dart'; // Ganti ke model pesanan
import 'package:percetakan/core/api_config.dart'; // Import konfigurasi API
import 'package:shared_preferences/shared_preferences.dart'; // Untuk mengambil token

class OrderController {
  static const String _authTokenKey = 'auth_token';

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // Fetch orders
  Future<List<OrderItem>> fetchOrders() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated. Token not found.');
    }

    try {
      final response = await http
          .get(
            Uri.parse(
              ApiConfig.ordersUrl,
            ), // Gunakan URL pesanan dari ApiConfig
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        print('Orders URL: ${ApiConfig.ordersUrl}');
        print('Orders Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        // Menggunakan OrderItem.fromJson
        return data.map((item) => OrderItem.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        throw Exception(
          'Unauthorized: Token may be invalid or expired. (${response.statusCode})',
        );
      } else {
        throw Exception(
          'Failed to load orders: ${response.statusCode} - ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      if (kDebugMode) print('ClientException fetching orders: $e');
      throw Exception(
        'Network error: Failed to connect to server. Please check your internet connection.',
      );
    } on FormatException catch (e) {
      if (kDebugMode) print('FormatException fetching orders: $e');
      throw Exception('Data format error: Failed to parse server response.');
    } catch (e) {
      if (kDebugMode) print('Error fetching orders: $e');
      throw Exception('Failed to load orders: $e');
    }
  }

  // Add order
  Future<Map<String, dynamic>> addOrderItem({
    required String customerName,
    required String phoneNumber,
    required String productType,
    required int quantity,
    required String paperType,
    required String size,
    required String deadline, // Format 'YYYY-MM-DD'
    String? notes,
    PlatformFile? file, // fileUrl tidak lagi diperlukan di sini
  }) async {
    final token = await _getToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'User not authenticated. Token not found.',
      };
    }

    try {
      // 1. Buat Multipart Request, bukan http.post
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.ordersUrl), // Endpoint POST ke /api/orders
      );

      // 2. Tambahkan headers ke request
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // 3. Tambahkan semua field teks ke request.fields
      request.fields.addAll({
        'customer_name': customerName,
        'phone_number': phoneNumber,
        'product_type': productType,
        'quantity': quantity.toString(), // Ubah int ke String
        'paper_type': paperType,
        'size': size,
        'deadline': deadline,
        'notes': notes ?? '', // Beri string kosong jika null
      });

      // 4. Tambahkan file ke request.files jika ada
      if (file != null && file.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'design_file', // Nama field untuk file di backend (pastikan sesuai!)
            file.path!,
          ),
        );
      }

      // 5. Kirim request dan dapatkan respons
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      var response = await http.Response.fromStream(streamedResponse);

      // --- Logika penanganan respons (sebagian besar tetap sama) ---

      if (kDebugMode) {
        print('Add Order URL: ${ApiConfig.ordersUrl}');
        print('Add Order Response Status: ${response.statusCode}');
        print('Add Order Response Body: ${response.body}');
      }

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': 'Pesanan baru berhasil ditambahkan.',
        };
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        String errorMessage = "Gagal menambahkan pesanan:\n";
        if (responseData.containsKey('errors') &&
            responseData['errors'] is Map) {
          (responseData['errors'] as Map).forEach((key, value) {
            if (value is List) {
              errorMessage += "- ${value.join('\n  ')}\n";
            }
          });
        } else if (responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }
        return {'success': false, 'message': errorMessage.trim()};
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Gagal menambahkan pesanan. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      if (kDebugMode) print('Error adding order item: $e');
      String errorMessage =
          'Terjadi kesalahan jaringan atau server tidak merespons.';
      if (e is SocketException) {
        errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi Anda.';
      }
      return {'success': false, 'message': errorMessage};
    }
  }

  // Update order status or other details
  Future<Map<String, dynamic>> updateOrderItem({
    required int id,
    required String customerName,
    required String phoneNumber,
    required String productType,
    required int quantity,
    required String paperType,
    required String size,
    required String deadline,
    required String status,
    String? notes,
    PlatformFile? newFile,
    bool removeExistingFile = false,
  }) async {
    final token = await _getToken();
    if (token == null) {
      return {'success': false, 'message': 'User not authenticated'};
    }

    try {
      // URL untuk update, biasanya /api/orders/{id}
      var request = http.MultipartRequest(
        'POST', // Gunakan POST untuk multipart
        Uri.parse('${ApiConfig.ordersUrl}/$id'),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Tambahkan field untuk mensimulasikan metode PUT/PATCH
      request.fields['_method'] = 'PUT';

      // Tambahkan semua field teks
      request.fields.addAll({
        'customer_name': customerName,
        'phone_number': phoneNumber,
        'product_type': productType,
        'quantity': quantity.toString(),
        'paper_type': paperType,
        'size': size,
        'deadline': deadline,
        'status': status,
        'notes': notes ?? '',
        'remove_existing_file':
            removeExistingFile.toString(), // Kirim flag penghapusan
      });

      // Tambahkan file baru jika ada
      if (newFile != null && newFile.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file', // Nama field file di backend
            newFile.path!,
          ),
        );
      }

      // Kirim request
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('Update Order URL: ${request.url}');
        print('Update Order Response Status: ${response.statusCode}');
        print('Update Order Response Body: ${response.body}');
      }

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Pesanan berhasil diperbarui.'};
      } else {
        // (Salin logika penanganan error dari method addOrderItem Anda di sini)
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Gagal memperbarui. Status: ${response.statusCode}',
              
        };
      }
    } catch (e) {
      if (kDebugMode) print('Error updating order item: $e');
      return {'success': false, 'message': 'Terjadi kesalahan jaringan.'};
    }
  }

  // Delete order
  Future<Map<String, dynamic>> deleteOrderItem(String itemId) async {
    final token = await _getToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'User not authenticated. Token not found.',
      };
    }

    final String deleteUrl = '${ApiConfig.ordersUrl}/$itemId';

    try {
      final response = await http
          .delete(
            Uri.parse(deleteUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        print('Delete Order URL: $deleteUrl');
        print('Delete Order Response Status: ${response.statusCode}');
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {'success': true, 'message': 'Pesanan berhasil dihapus.'};
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Pesanan tidak ditemukan.'};
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Gagal menghapus pesanan. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      if (kDebugMode) print('Error deleting order item: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan jaringan atau server tidak merespons.',
      };
    }
  }
}
