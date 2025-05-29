import 'package:flutter/material.dart';
import 'package:percetakan/core/app_colors.dart';

Future<bool?> showAppDeleteConfirmationDialog({
  required BuildContext context,
  required String itemName,
  String itemTypeSingular = 'item', // "item", "data", "catatan", dll.
  String title = "Konfirmasi Hapus",
  String? customMessage, // Untuk pesan yang lebih spesifik jika diperlukan
}) async {
  return showDialog<bool>( // Mengembalikan Future<bool?>
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
        contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
        actionsPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
        title: Text(
          title,
          // Jika AppStyles.heading2 terlalu besar atau tidak sesuai, gunakan TextStyle kustom
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor, // Warna gelap untuk judul
            fontFamily: 'Poppins', // Sesuaikan dengan font Anda
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            customMessage ?? 'Apakah Anda yakin ingin menghapus $itemTypeSingular "$itemName"? Tindakan ini tidak dapat dibatalkan.',
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontFamily: 'Poppins', // Sesuaikan dengan font Anda
              height: 1.4,
            ),
          ),
        ),
        actions: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false); // Mengembalikan false jika batal
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    foregroundColor: const Color(0xFF1C3A57),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    "Batal",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins', // Sesuaikan dengan font Anda
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true); // Mengembalikan true jika hapus
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Hapus",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins', // Sesuaikan dengan font Anda
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}