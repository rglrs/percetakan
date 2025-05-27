import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF1F5F9);
    const cardBgColor = Colors.white;
    const buttonColor = Color(0xFF1E3A50);
    const textColor = Colors.black;

    Widget buildCard(String title, String count) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                child: const Text('Lihat Detail'),
              ),
            ),
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
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
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
      return const Center(
        child: Text('Daftar Pesanan', style: TextStyle(fontSize: 24)),
      );
    }

    // Settings page content
    Widget settingsPage() {
      return const Center(
        child: Text('Pengaturan', style: TextStyle(fontSize: 24)),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Percetakan Vizada - Sistem Managemen',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        toolbarHeight: 48,
      ),
      body:
          <Widget>[homePage(), ordersPage(), settingsPage()][currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.receipt_long),
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Pesanan',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}
