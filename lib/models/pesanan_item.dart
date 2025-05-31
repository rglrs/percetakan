// lib/models/order_item.dart

class OrderItem {
  final String id;
  final String customerName;
  final String phoneNumber;
  final String? fileUrl;
  final String? fileName;
  final String
  productName; // Menggunakan productName untuk konsistensi dengan UI
  final int quantity;
  final String paperType;
  final String size;
  final String status;
  final DateTime deadline;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderItem({
    required this.id,
    required this.customerName,
    required this.phoneNumber,
    this.fileUrl,
    this.fileName,
    required this.productName,
    required this.quantity,
    required this.paperType,
    required this.size,
    required this.status,
    required this.deadline,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor untuk membuat instance OrderItem dari map (JSON).
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      // PERBAIKAN: Ambil 'id' sebagai int/num, lalu konversi ke String.
      // Pastikan 'id' selalu ada dan merupakan angka dari API Anda.
      id:
          (json['id'] as num)
              .toString(), // Mengambil sebagai num dan konversi ke String
      customerName: json['customer_name'] as String,
      phoneNumber: json['phone_number'] as String,
      fileUrl: json['file_url'] as String?,
      fileName: json['file_name'] as String?,
      productName: json['product_type'] as String,
      quantity: json['quantity'] as int,
      paperType: json['paper_type'] as String,
      size: json['size'] as String,
      status: json['status'] as String,
      // Pastikan 'deadline' dari API adalah string tanggal yang valid (YYYY-MM-DD)
      // Jika API mengembalikan null untuk deadline, Anda perlu menanganinya:
      deadline: DateTime.parse(json['deadline'] as String),
      notes: json['notes'] as String?,
      // Pastikan 'created_at' dan 'updated_at' adalah string timestamp yang valid
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
