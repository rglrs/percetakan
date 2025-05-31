import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:percetakan/controllers/order_controller.dart';
import 'package:percetakan/core/app_colors.dart';
import 'package:percetakan/core/app_styles.dart';
import 'package:percetakan/pages/components/custom_text_field.dart';
import 'package:file_picker/file_picker.dart'; // --- BARU --- Impor file_picker

class AddPesananPage extends StatefulWidget {
  const AddPesananPage({super.key});

  @override
  State<AddPesananPage> createState() => _AddPesananPageState();
}

class _AddPesananPageState extends State<AddPesananPage> {
  final _formKey = GlobalKey<FormState>();
  final OrderController _orderController = OrderController();
  bool _isLoading = false;

  // Controllers untuk setiap field form pesanan
  final TextEditingController _namaPelangganController =
      TextEditingController();
  final TextEditingController _noTeleponController = TextEditingController();
  final TextEditingController _jenisProdukController =
      TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _jenisKertasController =
      TextEditingController();
  final TextEditingController _ukuranController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();

  // --- BARU --- State untuk menyimpan file yang dipilih
  PlatformFile? _pickedFile;


  @override
  void dispose() {
    // Pastikan semua controller di-dispose
    _namaPelangganController.dispose();
    _noTeleponController.dispose();
    _jenisProdukController.dispose();
    _qtyController.dispose();
    _jenisKertasController.dispose();
    _ukuranController.dispose();
    _deadlineController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  // --- FUNGSI VALIDASI --- (Tidak ada perubahan di sini)
  String? _validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor Telepon tidak boleh kosong';
    }
    if (value.length < 9) {
      return 'Nomor Telepon tidak valid';
    }
    return null;
  }

  String? _validatePositiveNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    final n = int.tryParse(value);
    if (n == null || n <= 0) {
      return '$fieldName harus berupa angka lebih dari 0';
    }
    return null;
  }

  // --- FUNGSI DATE PICKER --- (Tidak ada perubahan di sini)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.primary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _deadlineController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // --- BARU --- FUNGSI UNTUK MEMILIH FILE
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'zip', 'rar'],
      );

      if (result != null) {
        setState(() {
          _pickedFile = result.files.first;
        });
      } else {
        // User membatalkan pemilihan file
      }
    } catch (e) {
      // Handle error jika terjadi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saat memilih file: $e')),
      );
    }
  }

  // --- FUNGSI SUBMIT FORM (DIMODIFIKASI) ---
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // --- BARU --- Panggil controller dengan menyertakan file
      final result = await _orderController.addOrderItem(
        customerName: _namaPelangganController.text,
        phoneNumber: _noTeleponController.text,
        productType: _jenisProdukController.text,
        quantity: int.parse(_qtyController.text),
        paperType: _jenisKertasController.text,
        size: _ukuranController.text,
        deadline: _deadlineController.text,
        notes: _catatanController.text,
        file: _pickedFile, // <- Kirim file ke controller
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(result['message'] ?? 'Pesanan berhasil ditambahkan!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text(result['message'] ?? 'Gagal menambahkan pesanan.'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form tidak valid. Mohon periksa kembali input Anda.'),
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
        iconTheme: const IconThemeData(color: AppColors.primary),
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Form Tambah Pesanan', style: AppStyles.heading2),
        elevation: 1.0,
      ),
      body: SingleChildScrollView(
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
                      // ... Field form lainnya (Nama, Telepon, dll.) ...
                      // (Tidak ada perubahan dari Nama Pelanggan s/d Catatan)
                      CustomTextField(
                        label: 'Nama Pelanggan',
                        controller: _namaPelangganController,
                        hintText: 'Masukkan nama pelanggan',
                        validator: (value) =>
                            _validateNotEmpty(value, 'Nama Pelanggan'),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Nomor Telepon',
                        controller: _noTeleponController,
                        hintText: 'Masukkan nomor telepon',
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: _validatePhoneNumber,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Jenis Produk',
                        controller: _jenisProdukController,
                        hintText: 'Cth: Banner, Stiker, Kartu Nama',
                        validator: (value) =>
                            _validateNotEmpty(value, 'Jenis Produk'),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Kuantitas (QTY)',
                        controller: _qtyController,
                        hintText: 'Masukkan jumlah pesanan',
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (value) =>
                            _validatePositiveNumber(value, 'Kuantitas'),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Jenis Kertas',
                        controller: _jenisKertasController,
                        hintText: 'Cth: Art Paper 150gr, Stiker Vinyl',
                        validator: (value) =>
                            _validateNotEmpty(value, 'Jenis Kertas'),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Ukuran',
                        controller: _ukuranController,
                        hintText: 'Cth: A4, 10x15 cm, 1x2 meter',
                        validator: (value) =>
                            _validateNotEmpty(value, 'Ukuran'),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Deadline',
                        controller: _deadlineController,
                        hintText: 'Pilih tanggal deadline',
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        validator: (value) =>
                            _validateNotEmpty(value, 'Deadline'),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Catatan (Opsional)',
                        controller: _catatanController,
                        hintText: 'Masukkan catatan tambahan',
                        maxLines: 3,
                      ),
                      
                      // --- BARU --- WIDGET UNTUK FILE PICKER
                      const SizedBox(height: 20),
                      Text('File Desain (Opsional)', style: AppStyles.label),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.upload_file, size: 16),
                              label: const Text('Pilih File'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade100,
                                foregroundColor: Colors.black87,
                                elevation: 0,
                              ),
                              onPressed: _pickFile,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _pickedFile?.name ?? 'Tidak ada file dipilih',
                                style: TextStyle(color: Colors.grey.shade700),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_pickedFile != null)
                              IconButton(
                                icon: const Icon(Icons.clear, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _pickedFile = null;
                                  });
                                },
                              )
                          ],
                        ),
                      ),
                      // --- AKHIR WIDGET FILE PICKER ---

                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : const Text('Simpan Pesanan',
                                  style: AppStyles.button),
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
    );
  }
}