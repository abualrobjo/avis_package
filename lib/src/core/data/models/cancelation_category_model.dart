/// One cancel reason from GetCancelationCategories API responseDetails.
class CancelationCategoryModel {
  final int id;
  final int lookupCategoryId;
  final String? primaryName;
  final String? secondaryName;
  final String? code;
  final bool isDeleted;
  final String? name;

  const CancelationCategoryModel({
    required this.id,
    this.lookupCategoryId = 0,
    this.primaryName,
    this.secondaryName,
    this.code,
    this.isDeleted = false,
    this.name,
  });

  String get displayName =>
      primaryName ?? secondaryName ?? name ?? '';

  factory CancelationCategoryModel.fromJson(Map<String, dynamic> json) {
    return CancelationCategoryModel(
      id: (json['id'] as num).toInt(),
      lookupCategoryId: (json['lookupCategoryId'] as num?)?.toInt() ?? 0,
      primaryName: json['primaryName'] as String?,
      secondaryName: json['secondaryName'] as String?,
      code: json['code'] as String?,
      isDeleted: json['isDeleted'] as bool? ?? false,
      name: json['name'] as String?,
    );
  }
}
