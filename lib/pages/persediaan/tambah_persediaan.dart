import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:percetakan/controllers/inventory_controller.dart';
import 'package:percetakan/core/app_colors.dart';
import 'package:percetakan/core/app_styles.dart';
import 'package:percetakan/pages/components/custom_text_field.dart';

class AddModalPersediaan extends StatefulWidget {
  const AddModalPersediaan({super.key});

  @override
  State<AddModalPersediaan> createState() => _AddModalPersediaanState();
}

class _AddModalPersediaanState extends State<AddModalPersediaan> {
  final _formKey = GlobalKey<FormState>();
  final InventoryController _inventoryController = InventoryController();
  bool _isLoading = false;

  final TextEditingController _namaItemController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _batasMinimalController = TextEditingController();

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
    return null;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final result = await _inventoryController.addInventoryItem(
        itemName: _namaItemController.text,
        unit: _unitController.text,
        quantity: int.parse(_qtyController.text),
        threshold: int.parse(_batasMinimalController.text),
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Item berhasil ditambahkan!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal menambahkan item.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
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
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        title: const Padding(
          padding: EdgeInsets.symmetric(vertical: 20.0),
          child: Text(
            'Form Tambah Persediaan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Sans',
              color: Colors.black,
            ),
          ),
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
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 10,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 20),
                  Container(
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
                          maxLength: 30,
                          validator:
                              (value) => _validateNotEmpty(value, 'Nama Item'),
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          label: 'Unit',
                          controller: _unitController,
                          hintText: 'Masukkan unit',
                          maxLength: 20,
                          validator:
                              (value) => _validateNotEmpty(value, 'Unit'),
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          label: 'QTY',
                          controller: _qtyController,
                          hintText: 'Masukkan QTY',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          maxLength: 10,
                          validator:
                              (value) => _validatePositiveNumber(value, 'QTY'),
                        ),
                        const SizedBox(height: 20),

                        CustomTextField(
                          label: 'Batas Minimal',
                          controller: _batasMinimalController,
                          hintText: 'Masukkan Batas Minimal',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          maxLength: 10,
                          validator:
                              (value) => _validatePositiveNumber(
                                value,
                                'Batas Minimal',
                              ),
                        ),
                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1C3A57),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
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
                                      'Simpan',
                                      style: AppStyles.button,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
