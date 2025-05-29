import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:percetakan/models/persediaan_item.dart'; // Pastikan path model benar
import 'package:percetakan/core/api_config.dart'; // Import konfigurasi API
import 'package:shared_preferences/shared_preferences.dart'; // Untuk mengambil token

class InventoryController {
  static const String _authTokenKey =
      'auth_token'; // Sebaiknya konsisten dengan AuthController

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  // Fetch inventories
  Future<List<PersediaanItem>> fetchInventories() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('User not authenticated. Token not found.');
    }

    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.inventoriesUrl), // Gunakan URL dari ApiConfig
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token', // Tambahkan token ke header
            },
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        print('Inventories URL: ${ApiConfig.inventoriesUrl}');
        print('Inventories Response Status: ${response.statusCode}');
        // print('Inventories Response Body: ${response.body}'); // Hati-hati jika respons besar
      }

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => PersediaanItem.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        // Token mungkin tidak valid atau sudah expired
        throw Exception(
          'Unauthorized: Token may be invalid or expired. (${response.statusCode})',
        );
      } else {
        throw Exception(
          'Failed to load inventories: ${response.statusCode} - ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      if (kDebugMode) print('ClientException fetching inventories: $e');
      throw Exception(
        'Network error: Failed to connect to server. Please check your internet connection.',
      );
    } on FormatException catch (e) {
      if (kDebugMode) print('FormatException fetching inventories: $e');
      throw Exception('Data format error: Failed to parse server response.');
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching inventories: $e');
      }
      throw Exception('Failed to load inventories: $e');
    }
  }

  // TODO: Tambahkan method untuk add, update, delete inventory jika diperlukan
  // Add
  Future<Map<String, dynamic>> addInventoryItem({
    required String itemName,
    required String unit,
    required int quantity,
    required int threshold,
  }) async {
    final token = await _getToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'User not authenticated. Token not found.',
      };
    }

    try {
      final response = await http
          .post(
            Uri.parse(
              ApiConfig.inventoriesUrl,
            ), // Endpoint POST ke /api/inventories
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(<String, dynamic>{
              'item_name': itemName,
              'unit': unit,
              'quantity': quantity,
              'threshold': threshold,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        print('Add Inventory URL: ${ApiConfig.inventoriesUrl}');
        print(
          'Add Inventory Request Body: ${jsonEncode({'item_name': itemName, 'unit': unit, 'quantity': quantity, 'threshold': threshold})}',
        );
        print('Add Inventory Response Status: ${response.statusCode}');
        print('Add Inventory Response Body: ${response.body}');
      }

      if (response.statusCode == 201) {
        // 201 Created adalah status sukses standar untuk POST
        // final responseData = jsonDecode(response.body); // Jika API mengembalikan data item baru
        return {
          'success': true,
          'message': 'Item persediaan berhasil ditambahkan.',
        };
      } else if (response.statusCode == 422) {
        // Error validasi
        final responseData = jsonDecode(response.body);
        String errorMessage = "Gagal menambahkan item:\n";
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
              'Gagal menambahkan item. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding inventory item: $e');
      }
      String errorMessage =
          'Terjadi kesalahan jaringan atau server tidak merespons.';
      if (e is SocketException) {
        errorMessage = 'Tidak dapat terhubung ke server. Periksa koneksi Anda.';
      }
      return {'success': false, 'message': errorMessage};
    }
  }

  // Update
  Future<bool> updateInventoryItem(PersediaanItem item) async {
    final token = await _getToken();
    if (token == null) {
      if (kDebugMode) print('Token not found for update operation.');
      return false; // atau throw Exception('User not authenticated.');
    }

    // Endpoint API untuk update, biasanya PUT /api/inventories/{id}
    final String updateUrl = '${ApiConfig.inventoriesUrl}/${item.id}';

    try {
      final response = await http
          .put(
            Uri.parse(updateUrl),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(<String, dynamic>{
              // Sesuaikan body dengan yang diharapkan backend
              'item_name': item.itemName,
              'unit': item.unit,
              'quantity': item.quantity,
              'threshold': item.threshold,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        print('Update Inventory URL: $updateUrl');
        print('Update Response Status: ${response.statusCode}');
        print('Update Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 204 No Content juga sering untuk update
        return true;
      } else {
        // Handle error spesifik jika perlu (misal, item not found 404, validation error 422)
        if (kDebugMode) print('Failed to update item: ${response.body}');
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating inventory item: $e');
      }
      return false;
    }
  }

  // Delete
  Future<Map<String, dynamic>> deleteInventoryItem(int itemId) async {
    final token = await _getToken();
    if (token == null) {
      return {
        'success': false,
        'message': 'User not authenticated. Token not found.',
      };
    }

    final String deleteUrl =
        '${ApiConfig.inventoriesUrl}/$itemId';

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
        print('Delete Inventory URL: $deleteUrl');
        print('Delete Inventory Response Status: ${response.statusCode}');
        print('Delete Inventory Response Body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 204 No Content juga OK untuk DELETE
        return {
          'success': true,
          'message': 'Item persediaan berhasil dihapus.',
        };
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Item tidak ditemukan.'};
      } else {
        final responseData = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              responseData['message'] ??
              'Gagal menghapus item. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting inventory item: $e');
      }
      return {
        'success': false,
        'message': 'Terjadi kesalahan jaringan atau server tidak merespons.',
      };
    }
  }
}
