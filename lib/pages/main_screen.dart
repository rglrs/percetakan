import 'package:flutter/material.dart';
import 'package:percetakan/core/app_colors.dart';
import 'package:percetakan/core/app_styles.dart';
import 'package:percetakan/pages/persediaan/persediaan_page.dart';
import 'package:percetakan/pages/pesanan.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget buildCard(String title, String count) {
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
            // SizedBox(
            //   width: double.infinity,
            //   child: ElevatedButton(
            //     onPressed: () {},
            //     style: ElevatedButton.styleFrom(
            //       backgroundColor: AppColors.primary,
            //       shape: RoundedRectangleBorder(
            //         borderRadius: AppStyles.borderRadiusMedium,
            //       ),
            //       padding: const EdgeInsets.symmetric(vertical: 12),
            //       textStyle: const TextStyle(
            //         fontSize: 14,
            //         fontWeight: FontWeight.w400,
            //       ),
            //     ),
            //     child: const Text('Lihat Detail', style: AppStyles.button),
            //   ),
            // ),
          ],
        ),
      );
    }

    // Home page content
    Widget homePage() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            const Text(
              'Beranda',
              style: AppStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            buildCard('Pesanan Hari Ini', '12'),
            buildCard('Dalam Produksi', '8'),
            buildCard('Siap Kirim', '4'),
          ],
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
      body:
          <Widget>[homePage(), ordersPage(), settingsPage()][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,

        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        indicatorColor: const Color.fromARGB(255, 143, 146, 149),
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home, color: AppColors.primary),
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.article, color: AppColors.primary),
            icon: Icon(Icons.article_outlined),
            label: 'Pesanan',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.folder, color: AppColors.primary),
            icon: Icon(Icons.folder_outlined),
            label: 'Persediaan',
          ),
        ],
      ),
    );
  }
}
