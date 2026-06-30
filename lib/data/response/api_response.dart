import 'package:teacher_app_edubloom/data/response/status.dart';

class APIResponse<T> {
  Status? status;
  T? data;
  String? message;

  APIResponse(this.message, this.data, this.status);

  APIResponse.loading() : status = Status.Loading;

  APIResponse.complete(this.data) : status = Status.Complete;

  APIResponse.error(this.message) : status = Status.Error;

  @override
  String toString() {
    return "Status: $status \n Message $message \n Data: $data";
  }
}
