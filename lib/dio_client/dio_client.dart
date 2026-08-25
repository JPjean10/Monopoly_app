import 'package:dio/dio.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';

class Dioclient {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConst.baseUrl,
      contentType: 'application/json',
      // Permite que Dio siga redirecciones automáticamente
      followRedirects: true,
    ),
  );

  static Dio get dio => _dio;
}
