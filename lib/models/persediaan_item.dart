import 'dart:convert';

List<PersediaanItem> persediaanItemFromJson(String str) =>
    List<PersediaanItem>.from(
      json.decode(str).map((x) => PersediaanItem.fromJson(x)),
    );

String persediaanItemToJson(List<PersediaanItem> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PersediaanItem {
  final int id;
  final String itemName;
  final String unit;
  final int quantity;
  final int threshold;
  final DateTime createdAt;
  final DateTime updatedAt;

  PersediaanItem({
    required this.id,
    required this.itemName,
    required this.unit,
    required this.quantity,
    required this.threshold,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PersediaanItem.fromJson(Map<String, dynamic> json) => PersediaanItem(
    id: json["id"],
    itemName: json["item_name"],
    unit: json["unit"],
    quantity: json["quantity"],
    threshold: json["threshold"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "item_name": itemName,
    "unit": unit,
    "quantity": quantity,
    "threshold": threshold,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}
