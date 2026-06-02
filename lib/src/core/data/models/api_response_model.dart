class ApiResponseModel<T> {
  final int errorCode;
  final String? errorMessage;
  final bool isSuccess;
  final T data;

  ApiResponseModel({
    required this.errorCode,
    required this.errorMessage,
    required this.isSuccess,
    required this.data,
  });

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    final ok = json['isScusses'] ?? json['isSuccess'] ?? false;
    final details = json['responseDetails'];
    return ApiResponseModel<T>(
      errorCode: (json['errorCode'] as num?)?.toInt() ?? 0,
      errorMessage: json['errorMessage'] as String?,
      isSuccess: ok is bool ? ok : false,
      data: fromJsonT(details),
    );
  }
}
