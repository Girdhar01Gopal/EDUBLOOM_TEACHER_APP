/// Har API call ka standard result wrapper.
class ApiResult {
  final bool isSuccess;
  final bool isDuplicate;
  final int statusCode;
  final String message;
  final dynamic data;

  const ApiResult({
    required this.isSuccess,
    required this.isDuplicate,
    required this.statusCode,
    required this.message,
    this.data,
  });

  @override
  String toString() =>
      'ApiResult(isSuccess: $isSuccess, isDuplicate: $isDuplicate, '
          'statusCode: $statusCode, message: $message)';
}

/// Multipart (image/file) upload ke liye input model.
class MultipartFileInput {
  final String fieldName;
  final String filePath;
  final String? filename;

  const MultipartFileInput({
    required this.fieldName,
    required this.filePath,
    this.filename,
  });
}