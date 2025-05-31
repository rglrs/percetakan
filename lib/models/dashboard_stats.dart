class DashboardStats {
  final int pesananHariIni;
  final int dalamProduksi;
  final int siapKirim;

  DashboardStats({
    required this.pesananHariIni,
    required this.dalamProduksi,
    required this.siapKirim,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      // Menggunakan null-aware operator dan default value jika key tidak ada atau null
      pesananHariIni: json['pesanan_hari_ini'] as int? ?? 0,
      dalamProduksi: json['dalam_produksi'] as int? ?? 0,
      siapKirim: json['siap_kirim'] as int? ?? 0,
    );
  }
}
