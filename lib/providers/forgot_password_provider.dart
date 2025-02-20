import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:iqacs/constants/dio_constant.dart';
import 'package:iqacs/models/model_forgot_password.dart';
import 'package:logger/logger.dart';
import 'package:iqacs/constants/api_constant.dart';

final logger = Logger();

final loadingProvider = StateProvider<bool>((ref) => false);

final forgotPasswordProvider =
    FutureProvider.family<ForgotPassword, String>((ref, noTelfon) async {
  final dio = ref.watch(dioProviderConstant);

  try {
    final response = await dio.post(
      ApiConstants.lupaPasswordEndpoint,
      data: {'no_telfon': noTelfon},
      options: Options(
        validateStatus: (status) {
          return status != null &&
              (status >= 200 && status < 300 || status == 302);
        },
      ),
    );

    logger.d('Response status: ${response.statusCode}');
    logger.d('Response data: ${response.data}');

    if (response.statusCode == 200 || response.statusCode == 302) {
      if (response.data is Map<String, dynamic>) {
        return ForgotPassword.fromJson(response.data);
      } else if (response.data is String) {
        return ForgotPassword(status: 'error', message: response.data);
      } else {
        return ForgotPassword(
            status: 'error', message: 'Format respons tidak dikenal');
      }
    }
    return ForgotPassword(
        status: 'error',
        message: 'Gagal memproses permintaan: ${response.statusCode}');
  } on DioException catch (e) {
    logger.e('Dio Error occurred: $e');
    if (e.response != null) {
      if (e.response!.data is Map<String, dynamic>) {
        return ForgotPassword.fromJson(e.response!.data);
      } else {
        return ForgotPassword(
            status: 'error',
            message: e.message ?? 'Terjadi kesalahan tidak dikenal');
      }
    }

    return ForgotPassword(
        status: 'error', message: e.message ?? 'Terjadi kesalahan jaringan');
  } catch (e) {
    logger.e('Unexpected error occurred: $e');

    return ForgotPassword(
        status: 'error', message: 'Terjadi kesalahan tidak terduga: $e');
  }
});
