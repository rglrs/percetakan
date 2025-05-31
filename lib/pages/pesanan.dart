import 'package:flutter/material.dart';
import 'package:percetakan/core/app_colors.dart';
import 'package:percetakan/core/app_styles.dart';
import 'package:percetakan/pages/pesanan/detail_pesanan_page.dart';
import 'package:percetakan/pages/pesanan/edit_pesanan_page.dart';
import 'package:percetakan/pages/pesanan/tambah_pesanan_page.dart';
import 'package:percetakan/models/pesanan_item.dart';
import 'package:percetakan/controllers/order_controller.dart';
import 'package:percetakan/pages/login_page.dart';
import 'package:percetakan/pages/components/dialog_utils.dart';
import 'package:intl/intl.dart';

class PesananPage extends StatefulWidget {
  const PesananPage({super.key});

  @override
  State<PesananPage> createState() => _PesananPageState();
}

class _PesananPageState extends State<PesananPage> {
  final OrderController _orderController =
      OrderController(); // Instansiasi controller pesanan

  late Future<List<OrderItem>> _orderFuture; // Untuk FutureBuilder

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    setState(() {
      _orderFuture = _orderController.fetchOrders();
    });
  }

  // Fungsi untuk menangani error, termasuk navigasi ke login jika 401
  void _handleFetchError(Object error) {
    if (!mounted) return;

    String errorMessage = 'Terjadi kesalahan: $error';
    if (error.toString().contains('Unauthorized') ||
        error.toString().contains('401')) {
      errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
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

  Future<void> _refreshOrders() async {
    _loadOrders();
  }

  void _navigateToAddPesananPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddPesananPage(),
      ), // GANTI: Halaman tambah pesanan
    );
    if (result == true && mounted) {
      _refreshOrders(); // Refresh list jika ada penambahan berhasil
    }
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

  Widget _buildOrderCard(OrderItem item) {
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
                      Text(
                        item.customerName,
                        style: AppStyles.heading2,
                      ), // GANTI: nama pelanggan
                      const SizedBox(height: 6),
                      Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Produk: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            TextSpan(
                              text: item.productName, // GANTI: nama produk
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
                              text: 'QTY: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            TextSpan(
                              text: '${item.quantity}', // GANTI: kuantitas
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
                              text: 'Deadline: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                            TextSpan(
                              text: DateFormat('d MMMM yyyy', 'id_ID').format(
                                item.deadline.toLocal(),
                              ), // GANTI: deadline
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildStatusChip(item.status), // GANTI: status pesanan
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => EditPesananPage(
                              itemToEdit: item,
                            ), // GANTI: Halaman edit pesanan
                      ),
                    );
                    if (result == true || result is OrderItem) {
                      _refreshOrders();
                    }
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit', style: AppStyles.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
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
                    final bool? confirmed =
                        await showAppDeleteConfirmationDialog(
                          context: context,
                          itemName: 'pesanan untuk ${item.customerName}',
                          itemTypeSingular: "item pesanan",
                        );

                    if (confirmed == true && mounted) {
                      final resultController = await _orderController
                          .deleteOrderItem(item.id);
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
                        if (resultController['success']) {
                          _refreshOrders();
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Hapus', style: AppStyles.button),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => DetailPesananPage(
                          initialItem: item,
                        ), // GANTI: Halaman detail pesanan
                  ),
                );
                if (result == true) {
                  _refreshOrders();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
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
        title: const Text('Pesanan', style: AppStyles.heading2),
        centerTitle: true,
        toolbarHeight: 70.0,
        backgroundColor: Colors.white,
        elevation: 1.0,
        iconTheme: const IconThemeData(color: Color(0xFF1C3A57)),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: FutureBuilder<List<OrderItem>>(
          future: _orderFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _handleFetchError(snapshot.error!);
              });
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
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
                        onPressed: _refreshOrders,
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
                      'Tidak ada data pesanan.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _refreshOrders,
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
                padding: const EdgeInsets.all(16.0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return _buildOrderCard(items[index]);
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1C3A57),
        onPressed: _navigateToAddPesananPage,
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
