import 'package:monopoly_app/dio_client/DioClient.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';

class Propiedadservicio {
  Future<Map<String, dynamic>> listarPropiedad() async {
    try {
      final response = await Dioclient.dio.get(ApiConst.controlador_propiedad);
      return response.data;
    } catch (e) {
      return {'status': false, 'userMssg': 'Error al obtener lista'};
    }
  }
}
