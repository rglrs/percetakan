import 'package:flutter/material.dart';
import 'package:percetakan/controllers/inventory_controller.dart';
import 'package:percetakan/core/app_colors.dart';
import 'package:percetakan/core/app_styles.dart';
import 'package:percetakan/models/persediaan_item.dart';
import 'package:percetakan/pages/components/dialog_utils.dart';
import 'package:percetakan/pages/persediaan/edit_persediaan_page.dart';

class DetailPersediaanPage extends StatefulWidget {
  final PersediaanItem initialItem;

  const DetailPersediaanPage({super.key, required this.initialItem});

  @override
  State<DetailPersediaanPage> createState() => _DetailPersediaanPageState();
}

class _DetailPersediaanPageState extends State<DetailPersediaanPage> {
  final InventoryController _inventoryController = InventoryController();

  late PersediaanItem _currentItem;
  bool _dataWasUpdated = false;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.initialItem;
  }

  @override
  Widget build(BuildContext context) {
    bool isStockLow = _currentItem.quantity <= _currentItem.threshold;
    // Menggunakan logika status stok yang sama seperti di halaman list
    Color statusColor =
        isStockLow ? const Color(0xFFFDD8D8) : const Color(0xFFD6F8E3);
    Color statusTextColor =
        isStockLow ? const Color(0xFFB70000) : const Color(0xFF00873D);
    // Teks status disesuaikan dengan logika stok, bukan "Selesai" dari mockup
    // karena "Selesai" kurang relevan untuk detail item persediaan.
    // Jika Anda tetap ingin "Selesai", ganti baris di bawah ini.
    String statusText = isStockLow ? 'Stok Menipis' : 'Stok Aman';
    // Jika ingin tetap "Selesai" seperti mockup:
    // String statusText = 'Selesai';
    // Color statusColor = const Color(0xFFD6F8E3); // Warna hijau muda untuk "Selesai"
    // Color statusTextColor = const Color(0xFF00873D); // Warna hijau tua untuk teks "Selesai"

    return Scaffold(
      backgroundColor: AppColors.secondary, // Background color seperti list
      appBar: AppBar(
        title: const Text(
          'Detail Persediaan', // Judul lebih sesuai
          style: AppStyles.heading2,
        ),
        backgroundColor: AppColors.backgroundColor,
        elevation: 1.0,
        iconTheme: const IconThemeData(
          color: AppColors.primary, // Warna ikon back
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(_dataWasUpdated),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              print('Edit item ID: ${_currentItem.id}');
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => EditPersediaanPage(itemToEdit: _currentItem),
                ),
              );

              if (result != null && result is PersediaanItem) {
                setState(() {
                  _currentItem = result;
                  _dataWasUpdated = true;
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFF1C3A57)),
            onPressed: () async {
              // BUAT ASYNC
              // Panggil dialog reusable
              final bool? confirmed = await showAppDeleteConfirmationDialog(
                context: context,
                itemName: _currentItem.itemName,
                itemTypeSingular: "item persediaan",
              );

              if (confirmed == true && mounted) {
                // Jika user menekan "Hapus"
                // Opsional: tampilkan loading indicator sementara
                // ScaffoldMessenger.of(context).showSnackBar(
                //   const SnackBar(content: Text('Menghapus item...'), duration: Duration(milliseconds: 800)),
                // );

                final resultController = await _inventoryController
                    .deleteInventoryItem(_currentItem.id);

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
                    // Jika delete berhasil, pop halaman Detail dan kirim 'true'
                    // agar halaman PersediaanPage bisa refresh
                    Navigator.of(context).pop(true);
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
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 2.0,
          color: Colors.white,
          margin:
              EdgeInsets
                  .zero, // Hapus margin default Card jika padding sudah di SingleChildScrollView
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nama Item',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontFamily: 'Sans',
                        fontWeight: FontWeight.w600,
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
                          fontFamily: 'Sans',
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  _currentItem.itemName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFamily: 'Sans',
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Unit', _currentItem.unit),
                _buildDetailRow('QTY', _currentItem.quantity.toString()),
                _buildDetailRow(
                  'Batas Minimal',
                  _currentItem.threshold.toString(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontFamily: 'Sans',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              fontFamily: 'Sans',
            ),
          ),
        ],
      ),
    );
  }
}
