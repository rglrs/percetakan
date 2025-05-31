import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percetakan/controllers/order_controller.dart';
import 'package:percetakan/core/app_colors.dart';
import 'package:percetakan/core/app_styles.dart';
import 'package:percetakan/models/pesanan_item.dart';
import 'package:percetakan/pages/components/dialog_utils.dart';
import 'package:percetakan/pages/pesanan/edit_pesanan_page.dart';
// --- IMPOR YANG DIBUTUHKAN ---
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailPesananPage extends StatefulWidget {
  final OrderItem initialItem;

  const DetailPesananPage({super.key, required this.initialItem});

  @override
  State<DetailPesananPage> createState() => _DetailPesananPageState();
}

class _DetailPesananPageState extends State<DetailPesananPage> {
  final OrderController _orderController = OrderController();
  late OrderItem _currentItem;
  bool _dataWasUpdated = false;

  @override
  void initState() {
    super.initState();
    _currentItem = widget.initialItem;
  }

  // GANTIKAN FUNGSI _buildStatusChip DI KEDUA FILE DENGAN KODE INI

  Widget _buildStatusChip(String status) {
    Color statusColor;
    Color statusTextColor;
    String statusText;

    // Logika status yang sudah disamakan
    switch (status.toLowerCase()) {
      case 'selesai':
        statusColor = const Color(0xFFD6F8E3); // Hijau
        statusTextColor = const Color(0xFF00873D);
        statusText = 'Selesai';
        break;
      case 'diproses':
        statusColor = const Color(0xFFFFF3CD); // Kuning
        statusTextColor = const Color(0xFFB76E00);
        statusText = 'Diproses';
        break;
      case 'menunggu':
        statusColor = const Color(0xFFD1E9FF); // Biru
        statusTextColor = const Color(0xFF0D63C4);
        statusText = 'Menunggu';
        break;
      case 'batal':
        statusColor = const Color(0xFFFDD8D8); // Merah
        statusTextColor = const Color(0xFFB70000);
        statusText = 'Batal';
        break;
      default:
        statusColor = Colors.grey[200]!; // Abu-abu
        statusTextColor = Colors.grey[800]!;
        statusText = status; // Tampilkan status asli jika tidak dikenali
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
    );
  }

  // --- FUNGSI BARU UNTUK MENAMPILKAN DIALOG PREVIEW (SUDAH DIMODIFIKASI) ---
  Future<void> _showPreviewDialog(
    BuildContext context,
    String fileUrl,
    String fileName,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // Bisa ditutup dengan tap di luar dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // --- PERUBAHAN DI SINI ---
          backgroundColor: Colors.white, // 1. Mengubah warna latar belakang
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 24.0,
          ), // 2. Membuat dialog lebih lebar
          // --- AKHIR PERUBAHAN ---
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Preview: $fileName',
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Mengatur agar konten tidak terlalu besar dan bisa scroll
          content: SingleChildScrollView(child: _buildPreviewContent(fileUrl)),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Tutup',
                style: TextStyle(color: AppColors.primary),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Menutup dialog
              },
            ),
          ],
        );
      },
    );
  }

  // --- WIDGET UNTUK KONTEN DI DALAM DIALOG ---
  Widget _buildPreviewContent(String fileUrl) {
    print('File URL: $fileUrl');
    final fileExtension = fileUrl.split('.').last.toLowerCase();

    if (['jpg', 'jpeg', 'png', 'gif'].contains(fileExtension)) {
      // Preview untuk GAMBAR
      return Image.network(
        fileUrl,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder:
            (context, error, stackTrace) => const Text(
              'Gagal memuat gambar',
              style: TextStyle(color: Colors.red),
            ),
      );
    } else if (fileExtension == 'pdf') {
      // Preview untuk PDF
      print(
        'Mencoba memuat PDF dengan SfPdfViewer: $fileUrl',
      ); // Untuk debugging
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.6,
        child: SfPdfViewer.network(
          fileUrl,
          onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
            // --- TAMBAHKAN INI UNTUK MELIHAT ERROR SPESIFIK ---
            print('GAGAL MEMUAT PDF: ${details.error}');
            print('DESKRIPSI ERROR PDF: ${details.description}');
            // Anda bisa menampilkan pesan error di UI jika mau
          },
          onDocumentLoaded: (PdfDocumentLoadedDetails details) {
            print('PDF berhasil dimuat.');
          },
        ),
      );
    } else {
      // Teks untuk tipe file lain
      return Text(
        'Preview tidak tersedia untuk tipe file .$fileExtension. Silakan buka file secara eksternal.',
      );
    }
  }

  // --- WIDGET UNTUK TOMBOL BUKA FILE ---
  Widget _buildOpenFileButton(String fileUrl, String fileName) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.visibility_outlined, size: 18),
        label: const Text('Lihat File Desain'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () {
          _showPreviewDialog(context, fileUrl, fileName);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(_dataWasUpdated);
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.secondary,
        appBar: AppBar(
          title: const Text('Detail Pesanan', style: AppStyles.heading2),
          backgroundColor: AppColors.backgroundColor,
          elevation: 1.0,
          iconTheme: const IconThemeData(color: AppColors.primary),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_dataWasUpdated),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => EditPesananPage(itemToEdit: _currentItem),
                  ),
                );
                if (result != null && result is OrderItem) {
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
                final bool? confirmed = await showAppDeleteConfirmationDialog(
                  context: context,
                  itemName:
                      'pesanan untuk "${_currentItem.customerName}" (${_currentItem.productName})',
                  itemTypeSingular: "item pesanan",
                );
                if (confirmed == true && mounted) {
                  final resultController = await _orderController
                      .deleteOrderItem(_currentItem.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          resultController['message'] ??
                              (resultController['success']
                                  ? 'Pesanan berhasil dihapus!'
                                  : 'Gagal menghapus pesanan.'),
                        ),
                        backgroundColor:
                            resultController['success']
                                ? Colors.green
                                : Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    if (resultController['success'] == true) {
                      Navigator.of(context).pop(true);
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
            margin: EdgeInsets.zero,
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
                      Expanded(
                        child: Text(
                          _currentItem.customerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            fontFamily: 'Poppins',
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(_currentItem.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kontak: ${_currentItem.phoneNumber}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Produk', _currentItem.productName),
                  _buildDetailRow(
                    'Kuantitas',
                    _currentItem.quantity.toString(),
                  ),
                  _buildDetailRow('Jenis Kertas', _currentItem.paperType),
                  _buildDetailRow('Ukuran', _currentItem.size),
                  _buildDetailRow(
                    'Deadline',
                    DateFormat(
                      'EEEE, d MMMM yyyy',
                      'id_ID',
                    ).format(_currentItem.deadline.toLocal()),
                  ),
                  if (_currentItem.notes != null &&
                      _currentItem.notes!.isNotEmpty)
                    _buildDetailRow('Catatan', _currentItem.notes!),

                  // --- PERUBAHAN DI SINI ---
                  if (_currentItem.fileUrl != null &&
                      _currentItem.fileUrl!.isNotEmpty) ...[
                    const Divider(height: 32, thickness: 1),
                    _buildOpenFileButton(
                      _currentItem.fileUrl!,
                      _currentItem.fileName ?? 'File Desain',
                    ),
                  ],

                  // --- AKHIR PERUBAHAN ---
                  const Divider(height: 32, thickness: 1),
                  _buildTimestampInfo('Dibuat pada', _currentItem.createdAt),
                  _buildTimestampInfo(
                    'Diperbarui pada',
                    _currentItem.updatedAt,
                  ),
                ],
              ),
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
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w600,
            ),
          ),
          if (value.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontFamily: 'Poppins',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimestampInfo(String label, DateTime dateTime) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Text(
        '$label: ${DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dateTime.toLocal())}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
