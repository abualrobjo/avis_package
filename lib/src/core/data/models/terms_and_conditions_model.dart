/// One terms-and-conditions record from TermsAndConditions_GetAll responseDetails.
class TermsAndConditionsModel {
  const TermsAndConditionsModel({
    this.termsAndConditionsPdfUrl,
    this.hasPdf = false,
    this.contentType,
  });

  final String? termsAndConditionsPdfUrl;
  final bool hasPdf;
  final String? contentType;

  bool get isPdfContent =>
      hasPdf &&
      contentType?.toLowerCase() == 'pdf' &&
      termsAndConditionsPdfUrl != null &&
      termsAndConditionsPdfUrl!.trim().isNotEmpty;

  factory TermsAndConditionsModel.fromJson(Map<String, dynamic> json) {
    final hasPdfValue = json['hasPdf'] ?? json['hasPd'];
    return TermsAndConditionsModel(
      termsAndConditionsPdfUrl: json['termsAndConditionsPdfUrl'] as String?,
      hasPdf: hasPdfValue is bool ? hasPdfValue : false,
      contentType: json['contentType'] as String?,
    );
  }
}
