class LookupModel {
  final int id;
  final int lookupCategoryId;
  final String primaryName;
  final String secondaryName;
  final String code;
  final int? createdBy;
  final DateTime? createdDate;
  final int? updatedBy;
  final DateTime? updatedDate;
  final bool isDeleted;
  final String name;

  const LookupModel({
    required this.id,
    required this.lookupCategoryId,
    required this.primaryName,
    required this.secondaryName,
    required this.code,
    required this.createdBy,
    required this.createdDate,
    required this.updatedBy,
    required this.updatedDate,
    required this.isDeleted,
    required this.name,
  });

  factory LookupModel.fromJson(Map<String, dynamic> json) {
    return LookupModel(
      id: _asInt(json['id']),
      lookupCategoryId: _asInt(json['lookupCategoryId']),
      primaryName: json['primaryName']?.toString() ?? '',
      secondaryName: json['secondaryName']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      createdBy: _asNullableInt(json['createdBy']),
      createdDate: _parseNullableDate(json['createdDate']),
      updatedBy: _asNullableInt(json['updatedBy']),
      updatedDate: _parseNullableDate(json['updatedDate']),
      isDeleted: json['isDeleted'] == true,
      name: json['name']?.toString() ?? '',
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _asNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseNullableDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
