// lib/pages/main_screen.dart
// (Modifikasi file yang sudah ada)

import 'package:flutter/material.dart';
import 'package:percetakan/core/app_colors.dart';
import 'package:percetakan/core/app_styles.dart';
import 'package:percetakan/pages/persediaan/persediaan_page.dart';
import 'package:percetakan/pages/pesanan.dart';
import 'package:percetakan/models/dashboard_stats.dart'; // <-- IMPORT BARU
import 'package:percetakan/controllers/dashboard_controller.dart'; // <-- IMPORT BARU
import 'package:percetakan/pages/login_page.dart'; // Untuk navigasi jika token tidak valid

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentPageIndex = 0;

  // State untuk data dashboard
  DashboardStats? _dashboardStats;
  bool _isLoadingStats = true;
  String? _statsError;

  final DashboardController _dashboardController = DashboardController();

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() {
      _isLoadingStats = true;
      _statsError = null;
    });
    try {
      final stats = await _dashboardController.fetchDashboardStats();
      if (mounted) {
        setState(() {
          _dashboardStats = stats;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statsError = e.toString();
          _isLoadingStats = false;
        });
        // Jika error karena Unauthorized, arahkan ke login
        if (e.toString().contains('Unauthorized')) {
            ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_statsError ?? 'Terjadi kesalahan autentikasi.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
      }
    }
  }

  Widget buildCard(String title, String count, {bool isLoading = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppStyles.cardShadow,
      ),
      width: double.infinity,
      child: Column(
        children: [
          Text(title, style: AppStyles.heading3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            )
          else
            Text(
              count,
              style: const TextStyle(
                color: AppColors.textColor,
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Home page content
  Widget homePage() {
    if (_isLoadingStats) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Memuat data dashboard...', style: AppStyles.body),
          ],
        ),
      );
    }

    if (_statsError != null && !_statsError!.contains('Unauthorized')) { // Jangan tampilkan error Unauthorized di sini karena sudah dinavigasi
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat data dashboard:',
                style: AppStyles.heading3.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _statsError!,
                style: AppStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadDashboardStats,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              )
            ],
          ),
        ),
      );
    }

    // Jika tidak loading dan tidak ada error (atau error Unauthorized sudah ditangani)
    return RefreshIndicator( // Tambahkan RefreshIndicator
      onRefresh: _loadDashboardStats,
      child: SingleChildScrollView( // Pastikan bisa di-scroll jika konten banyak
        physics: const AlwaysScrollableScrollPhysics(), // Agar RefreshIndicator selalu aktif
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            const Text(
              'Beranda',
              style: AppStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            buildCard(
              'Pesanan Hari Ini',
              _dashboardStats?.pesananHariIni.toString() ?? '0',
            ),
            buildCard(
              'Dalam Produksi',
              _dashboardStats?.dalamProduksi.toString() ?? '0',
            ),
            buildCard(
              'Siap Kirim',
              _dashboardStats?.siapKirim.toString() ?? '0',
            ),
          ],
        ),
      ),
    );
  }

  // Orders page content
  Widget ordersPage() {
    return const PesananPage();
  }

  // Settings page content
  Widget settingsPage() {
    return const PersediaanPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Percetakan Vizada - Sistem Managemen',
          style: AppStyles.heading,
        ),
        toolbarHeight: 48,
      ),
      body: IndexedStack( // Menggunakan IndexedStack untuk menjaga state halaman
        index: currentPageIndex,
        children: <Widget>[
          homePage(),
          ordersPage(),
          settingsPage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        indicatorColor: AppColors.primary.withOpacity(0.1), // Warna indikator lebih lembut
        destinations: <Widget>[
          NavigationDestination(
            selectedIcon: const Icon(Icons.home, color: AppColors.primary),
            icon: const Icon(Icons.home_outlined, color: AppColors.primary),
            label: 'Beranda',
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.article, color: AppColors.primary),
            icon: const Icon(Icons.article_outlined, color: AppColors.primary),
            label: 'Pesanan',
          ),
          NavigationDestination(
            selectedIcon: const Icon(Icons.folder, color: AppColors.primary),
            icon: const Icon(Icons.folder_outlined, color: AppColors.primary),
            label: 'Persediaan',
          ),
        ],
      ),
    );
  }
}
