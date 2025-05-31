import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:percetakan/controllers/order_controller.dart';
import 'package:percetakan/core/app_colors.dart';
import 'package:percetakan/core/app_styles.dart';
import 'package:percetakan/models/pesanan_item.dart';
import 'package:percetakan/pages/components/custom_text_field.dart';
import 'package:file_picker/file_picker.dart'; // Impor file_picker

class EditPesananPage extends StatefulWidget {
  final OrderItem itemToEdit;

  const EditPesananPage({super.key, required this.itemToEdit});

  @override
  State<EditPesananPage> createState() => _EditPesananPageState();
}

class _EditPesananPageState extends State<EditPesananPage> {
  final _formKey = GlobalKey<FormState>();
  final OrderController _orderController = OrderController();
  bool _isLoading = false;

  late TextEditingController _namaPelangganController;
  late TextEditingController _noTeleponController;
  late TextEditingController _jenisProdukController;
  late TextEditingController _qtyController;
  late TextEditingController _jenisKertasController;
  late TextEditingController _ukuranController;
  late TextEditingController _deadlineController;
  late TextEditingController _catatanController;
  late String _selectedStatus;

  // --- BARU --- State untuk manajemen file di halaman edit
  PlatformFile? _newPickedFile;
  bool _removeExistingFile = false;

  final List<String> _statusOptions = [
    'menunggu',
    'diproses',
    'selesai',
    'batal',
  ];

  @override
  void initState() {
    super.initState();
    _namaPelangganController = TextEditingController(
      text: widget.itemToEdit.customerName,
    );
    _noTeleponController = TextEditingController(
      text: widget.itemToEdit.phoneNumber,
    );
    _jenisProdukController = TextEditingController(
      text: widget.itemToEdit.productName,
    );
    _qtyController = TextEditingController(
      text: widget.itemToEdit.quantity.toString(),
    );
    _jenisKertasController = TextEditingController(
      text: widget.itemToEdit.paperType,
    );
    _ukuranController = TextEditingController(text: widget.itemToEdit.size);
    _deadlineController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(widget.itemToEdit.deadline),
    );
    _catatanController = TextEditingController(text: widget.itemToEdit.notes);
    _selectedStatus = widget.itemToEdit.status;
  }

  @override
  void dispose() {
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

  // --- FUNGSI VALIDASI --- (Tidak berubah)
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

  // --- FUNGSI DATE PICKER --- (Tidak berubah)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime.tryParse(_deadlineController.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.primary,
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

  // --- BARU --- FUNGSI UNTUK MEMILIH FILE BARU
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'pdf',
          'doc',
          'docx',
          'zip',
          'rar',
        ],
      );
      if (result != null) {
        setState(() {
          _newPickedFile = result.files.first;
          _removeExistingFile =
              false; // Jika user memilih file baru, batalkan niat menghapus
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saat memilih file: $e')));
    }
  }

  // --- FUNGSI SUBMIT FORM (MODIFIKASI) ---
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final result = await _orderController.updateOrderItem(
        id: int.parse(widget.itemToEdit.id),
        customerName: _namaPelangganController.text,
        phoneNumber: _noTeleponController.text,
        productType: _jenisProdukController.text,
        quantity: int.parse(_qtyController.text),
        paperType: _jenisKertasController.text,
        size: _ukuranController.text,
        deadline: _deadlineController.text,
        status: _selectedStatus,
        notes: _catatanController.text,
        newFile: _newPickedFile,
        removeExistingFile: _removeExistingFile,
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Pesanan berhasil diperbarui!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          final updatedItem = OrderItem(
            id: widget.itemToEdit.id,
            customerName: _namaPelangganController.text,
            phoneNumber: _noTeleponController.text,
            productName: _jenisProdukController.text,
            quantity: int.parse(_qtyController.text),
            paperType: _jenisKertasController.text,
            size: _ukuranController.text,
            deadline: DateFormat('yyyy-MM-dd').parse(_deadlineController.text),
            status: _selectedStatus,
            notes: _catatanController.text,
            createdAt: widget.itemToEdit.createdAt,
            updatedAt:
                DateTime.now(), // Anggap saja waktu update adalah sekarang
            fileUrl:
                widget.itemToEdit.fileUrl, // Gunakan data lama sebagai fallback
            fileName:
                widget
                    .itemToEdit
                    .fileName, // Gunakan data lama sebagai fallback
          );
          Navigator.of(context).pop(updatedItem);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Gagal memperbarui pesanan.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.primary),
        backgroundColor: AppColors.backgroundColor,
        title: const Text('Form Edit Pesanan', style: AppStyles.heading2),
        elevation: 1.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppStyles.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... (Dropdown Status dan form field lainnya tidak berubah)
                  DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    items:
                        _statusOptions.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(
                              status[0].toUpperCase() + status.substring(1),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Status Pesanan',
                      labelStyle: const TextStyle(fontFamily: 'Poppins'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Nama Pelanggan',
                    controller: _namaPelangganController,
                    validator: (v) => _validateNotEmpty(v, 'Nama Pelanggan'),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Nomor Telepon',
                    controller: _noTeleponController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validatePhoneNumber,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Jenis Produk',
                    controller: _jenisProdukController,
                    validator: (v) => _validateNotEmpty(v, 'Jenis Produk'),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Kuantitas (QTY)',
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => _validatePositiveNumber(v, 'Kuantitas'),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Jenis Kertas',
                    controller: _jenisKertasController,
                    validator: (v) => _validateNotEmpty(v, 'Jenis Kertas'),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Ukuran',
                    controller: _ukuranController,
                    validator: (v) => _validateNotEmpty(v, 'Ukuran'),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Deadline',
                    controller: _deadlineController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (v) => _validateNotEmpty(v, 'Deadline'),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Catatan (Opsional)',
                    controller: _catatanController,
                    maxLines: 3,
                  ),

                  // --- BARU --- WIDGET FILE PICKER UNTUK EDIT
                  const SizedBox(height: 20),
                  Text('File Desain', style: AppStyles.label),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.upload_file, size: 16),
                          label: Text(
                            _newPickedFile != null ||
                                    widget.itemToEdit.fileUrl != null
                                ? 'Ganti File'
                                : 'Pilih File',
                          ),
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
                            _newPickedFile?.name ??
                                (_removeExistingFile
                                    ? 'File akan dihapus'
                                    : (widget.itemToEdit.fileName ??
                                        'Tidak ada file')),
                            style: TextStyle(
                              color:
                                  _removeExistingFile
                                      ? Colors.red
                                      : Colors.grey.shade700,
                              fontStyle:
                                  _removeExistingFile
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_newPickedFile !=
                            null) // Tombol clear untuk file baru
                          IconButton(
                            icon: const Icon(Icons.clear, color: Colors.red),
                            onPressed:
                                () => setState(() => _newPickedFile = null),
                          ),
                        if (_newPickedFile == null &&
                            widget.itemToEdit.fileUrl != null &&
                            !_removeExistingFile) // Tombol hapus untuk file lama
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            tooltip: 'Hapus file yang sudah ada',
                            onPressed:
                                () =>
                                    setState(() => _removeExistingFile = true),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
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
                                'Simpan Perubahan',
                                style: AppStyles.button,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
