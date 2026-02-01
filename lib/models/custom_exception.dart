import 'package:dio/dio.dart';

class CloudflareChallengeException extends DioException {
  CloudflareChallengeException({required super.requestOptions, super.message = "Cloudflare Challenge Detected"});
}