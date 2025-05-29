import 'package:flutter/material.dart';
import 'package:percetakan/core/app_colors.dart';
// import 'package:http/http.dart' as http; // Tidak lagi dibutuhkan di sini
// import 'dart:convert'; // Tidak lagi dibutuhkan di sini

import 'package:percetakan/core/app_styles.dart';
import 'package:percetakan/pages/persediaan/detail_persediaan_page.dart';
import 'package:percetakan/pages/persediaan/edit_persediaan_page.dart';
import 'package:percetakan/pages/persediaan/tambah_persediaan.dart';
import 'package:percetakan/models/persediaan_item.dart';
import 'package:percetakan/controllers/inventory_controller.dart'; // Import controller
import 'package:percetakan/pages/login_page.dart';
import 'package:percetakan/pages/components/dialog_utils.dart';
import 'package:intl/intl.dart';

class PersediaanPage extends StatefulWidget {
  const PersediaanPage({super.key});

  @override
  State<PersediaanPage> createState() => _PersediaanPageState();
}

class _PersediaanPageState extends State<PersediaanPage> {
  final InventoryController _inventoryController =
      InventoryController(); // Instansiasi controller

  late Future<List<PersediaanItem>> _inventoryFuture; // Untuk FutureBuilder

  @override
  void initState() {
    super.initState();
    _loadInventories();
  }

  void _loadInventories() {
    setState(() {
      _inventoryFuture = _inventoryController.fetchInventories();
    });
  }

  // Fungsi untuk menangani error, termasuk navigasi ke login jika 401
  void _handleFetchError(Object error) {
    if (!mounted) return;

    String errorMessage = 'Terjadi kesalahan: $error';
    if (error.toString().contains('Unauthorized') ||
        error.toString().contains('401')) {
      errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
      // Tambahan: Navigasi ke halaman login setelah beberapa saat atau user tap
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          // Cek lagi karena ada delay
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ), // Pastikan nama halaman login benar
            (Route<dynamic> route) => false,
          );
        }
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _refreshInventories() async {
    // Tidak perlu setState secara eksplisit untuk _isLoading karena FutureBuilder menanganinya
    // Cukup panggil ulang _loadInventories untuk memperbarui _inventoryFuture
    _loadInventories();
  }

  void _navigateToAddPersediaanPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddModalPersediaan()),
    );
    if (result == true && mounted) {
      _refreshInventories(); // Refresh list jika ada penambahan berhasil
    }
  }

  Widget _buildInventoryCard(PersediaanItem item) {
    // Pastikan outputnya adalah DateTime yang valid, contoh: 2025-05-29 12:30:00.000
    bool isStockLow = item.quantity <= (item.threshold * 1.25);
    Color statusColor =
        isStockLow ? const Color(0xFFFDD8D8) : const Color(0xFFD6F8E3);
    Color statusTextColor =
        isStockLow ? const Color(0xFFB70000) : const Color(0xFF00873D);
    String statusText = isStockLow ? 'Stok Menipis' : 'Stok Aman';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppStyles.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: 'Poppins',
                    height: 1.5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.itemName, style: AppStyles.heading2),
                      const SizedBox(height: 6),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Kuantitas: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            TextSpan(
                              text: '${item.quantity} ${item.unit}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Batas Min.: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            TextSpan(
                              text: '${item.threshold} ${item.unit}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Terakhir Update: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            TextSpan(
                              text: DateFormat(
                                'd MMMM yyyy',
                                'id_ID',
                              ).format(item.updatedAt.toLocal()), // FORMAT BARU
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                                // fontFamily: 'Poppins', // Sesuaikan dengan font yang Anda gunakan
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // PASTIKAN INI ASYNC
                    print(
                      '[PersediaanPage] Navigating to EditPersediaanPage for item ID: ${item.id}',
                    );
                    final result = await Navigator.push(
                      // GUNAKAN AWAIT
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EditPersediaanPage(itemToEdit: item),
                      ),
                    );

                    print(
                      '[PersediaanPage] Returned from EditPersediaanPage with result: $result',
                    );

                    // Periksa apakah result adalah instance dari PersediaanItem
                    if (result != null && result is PersediaanItem) {
                      print(
                        '[PersediaanPage] Edit successful (received PersediaanItem), calling _refreshInventories().',
                      );
                      _refreshInventories();
                    } else if (result == true) {
                      // Fallback jika EditPersediaanPage (versi lama) mungkin pop 'true'
                      print(
                        '[PersediaanPage] Edit successful (received true), calling _refreshInventories().',
                      );
                      _refreshInventories();
                    } else {
                      print(
                        '[PersediaanPage] Edit not confirmed or no valid data returned (result: $result), not refreshing.',
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.edit,
                    size: 16,
                  ), // Warna ikon akan diambil dari foregroundColor
                  label: const Text('Edit', style: AppStyles.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white, // Warna untuk teks dan ikon
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // BUAT ASYNC
                    // Panggil dialog reusable
                    final bool? confirmed =
                        await showAppDeleteConfirmationDialog(
                          context: context,
                          itemName: item.itemName,
                          itemTypeSingular: "item persediaan",
                        );

                    if (confirmed == true && mounted) {
                      final resultController = await _inventoryController
                          .deleteInventoryItem(item.id);

                      if (mounted) {
                        // Cek mounted lagi setelah await
                        if (resultController['success'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                resultController['message'] ??
                                    'Item berhasil dihapus!',
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          _refreshInventories(); // Refresh daftar setelah berhasil hapus
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                resultController['message'] ??
                                    'Gagal menghapus item.',
                              ),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 16,
                  ), // Warna ikon akan diambil dari foregroundColor
                  label: const Text('Hapus', style: AppStyles.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white, // Warna untuk teks dan ikon
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 12,
          ), // Jarak antara baris tombol Edit/Hapus dan tombol Lihat Detail
          SizedBox(
            // Widget SizedBox untuk membuat tombol full-width
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                // PASTIKAN INI ASYNC
                print(
                  '[PersediaanPage] Navigating to DetailPersediaanPage for item: ${item.itemName}',
                );
                final result = await Navigator.push(
                  // GUNAKAN AWAIT
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => DetailPersediaanPage(initialItem: item),
                  ),
                );

                print(
                  '[PersediaanPage] Returned from DetailPersediaanPage with result: $result',
                );

                // Periksa apakah result adalah true (dikirim dari DetailPersediaanPage setelah delete/edit sukses)
                if (result == true) {
                  print(
                    '[PersediaanPage] Result is true, calling _refreshInventories()',
                  );
                  _refreshInventories();
                } else {
                  print(
                    '[PersediaanPage] Result is not true (value: $result), not refreshing via this path.',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ), // Sesuaikan padding jika perlu
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Poppins',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text('Lihat Detail', style: AppStyles.button),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Persediaan', style: AppStyles.heading2),
        centerTitle: true,
        toolbarHeight: 70.0,
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: const IconThemeData(color: Color(0xFF1C3A57)),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshInventories,
        child: FutureBuilder<List<PersediaanItem>>(
          future: _inventoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Panggil _handleFetchError di sini agar bisa menangani navigasi jika 401
              // Namun, FutureBuilder akan rebuild terus menerus jika error.
              // Jadi, kita tampilkan pesan error dan tombol retry.
              // _handleFetchError dipanggil secara terpisah jika diperlukan navigasi.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleFetchError(snapshot.error!);
              });
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 16.0,
                    left: 16.0,
                    bottom: 16.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Gagal memuat data: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _refreshInventories,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C3A57),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Tidak ada data persediaan.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _refreshInventories,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Data'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C3A57),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final items = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.only(
                  right: 16.0,
                  left: 16.0,
                  bottom: 16.0,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildInventoryCard(items[index]);
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1C3A57),
        onPressed: _navigateToAddPersediaanPage,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
