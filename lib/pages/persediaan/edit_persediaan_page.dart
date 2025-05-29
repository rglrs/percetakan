import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percetakan/core/app_colors.dart';
import 'package:percetakan/core/app_styles.dart';
import 'package:percetakan/pages/components/custom_text_field.dart';
import 'package:percetakan/models/persediaan_item.dart'; // Import model
import 'package:percetakan/controllers/inventory_controller.dart'; // Import controller

class EditPersediaanPage extends StatefulWidget {
  final PersediaanItem itemToEdit; // Item yang akan diedit

  const EditPersediaanPage({super.key, required this.itemToEdit});

  @override
  State<EditPersediaanPage> createState() => _EditPersediaanPageState();
}

class _EditPersediaanPageState extends State<EditPersediaanPage> {
  final _formKey = GlobalKey<FormState>();
  final InventoryController _inventoryController =
      InventoryController(); // Controller
  bool _isLoading = false;

  late TextEditingController _namaItemController;
  late TextEditingController _unitController;
  late TextEditingController _qtyController;
  late TextEditingController _batasMinimalController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data dari itemToEdit
    _namaItemController = TextEditingController(
      text: widget.itemToEdit.itemName,
    );
    _unitController = TextEditingController(text: widget.itemToEdit.unit);
    _qtyController = TextEditingController(
      text: widget.itemToEdit.quantity.toString(),
    );
    _batasMinimalController = TextEditingController(
      text: widget.itemToEdit.threshold.toString(),
    );
  }

  @override
  void dispose() {
    _namaItemController.dispose();
    _unitController.dispose();
    _qtyController.dispose();
    _batasMinimalController.dispose();
    super.dispose();
  }

  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  String? _validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    final n = int.tryParse(value);
    if (n == null) {
      return '$fieldName harus berupa angka';
    }
    // if (n <= 0) { // Opsional: jika ingin angka harus > 0
    //   return '$fieldName harus lebih besar dari 0';
    // }
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Membuat objek PersediaanItem dengan data yang diupdate
      // ID dan createdAt tidak diubah, updatedAt akan diupdate oleh backend
      PersediaanItem updatedItem = PersediaanItem(
        id: widget.itemToEdit.id, // Gunakan ID dari item yang diedit
        itemName: _namaItemController.text,
        unit: _unitController.text,
        quantity: int.parse(_qtyController.text),
        threshold: int.parse(_batasMinimalController.text),
        createdAt: widget.itemToEdit.createdAt, // createdAt tetap
        updatedAt:
            DateTime.now(), // updatedAt bisa diset di client atau dihandle backend
      );

      // TODO: Panggil method update dari InventoryController
      bool success = await _inventoryController.updateInventoryItem(
        updatedItem,
      );

      // --- Simulasi Panggil API (GANTI DENGAN PEMANGGILAN CONTROLLER SEBENARNYA) ---
      print('--- MENGUPDATE ITEM ---');
      print('ID Item: ${updatedItem.id}');
      print('Nama Item: ${updatedItem.itemName}');
      print('Unit: ${updatedItem.unit}');
      print('QTY: ${updatedItem.quantity}');
      print('Batas Minimal: ${updatedItem.threshold}');
      await Future.delayed(
        const Duration(seconds: 1),
      ); // Simulasi delay network
      // --- AKHIR SIMULASI ---

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data persediaan berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(updatedItem);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal memperbarui data persediaan.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form tidak valid. Mohon periksa input Anda.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text('Form Edit Persediaan', style: AppStyles.heading2),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          color: AppColors.secondary,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(context).viewInsets.bottom +
                  20, // Tambah padding bawah
              left: 20,
              right: 20,
              top: 20, // Tambah padding atas
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Menghilangkan Container luar dengan border radius karena sudah full page
                  Container(
                    // Card untuk form fields
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppStyles.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                          label: 'Nama Item',
                          controller: _namaItemController,
                          hintText: 'Masukkan nama item',
                          validator:
                              (value) => _validateNotEmpty(value, 'Nama Item'),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: 'Unit',
                          controller: _unitController,
                          hintText: 'Masukkan unit (cth: lembar, rim, pcs)',
                          validator:
                              (value) => _validateNotEmpty(value, 'Unit'),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: 'QTY',
                          controller: _qtyController,
                          hintText: 'Masukkan jumlah kuantitas',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator:
                              (value) => _validatePositiveNumber(value, 'QTY'),
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          label: 'Batas Minimal',
                          controller: _batasMinimalController,
                          hintText: 'Masukkan batas minimal kuantitas',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator:
                              (value) => _validatePositiveNumber(
                                value,
                                'Batas Minimal',
                              ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 50, // Tinggi tombol disamakan
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1C3A57),
                              foregroundColor:
                                  Colors.white, // Untuk warna teks & ikon
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                              ), // Disesuaikan
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2, // Sedikit elevasi
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                    : const Text(
                                      'Simpan Perubahan', // Teks tombol diubah
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        fontFamily: 'Sans',
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(height: 30), // Dihapus karena padding bawah sudah diatur
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
