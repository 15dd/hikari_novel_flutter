import 'package:dio/dio.dart';

const cloudflareChallengeExceptionMessage = "Cloudflare Challenge Detected";
const cloudflare403ExceptionMessage = "You have been blocked by Cloudflare";

class CloudflareChallengeException extends DioException {
  CloudflareChallengeException({required super.requestOptions, super.message = cloudflareChallengeExceptionMessage});
}

class Cloudflare403Exception extends DioException {
  Cloudflare403Exception({required super.requestOptions, super.message = cloudflare403ExceptionMessage});
}