import 'package:monopoly_app/dio_client/DioClient.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';

class Propiedadservicio {
  Future<Map<String, dynamic>> listarPropiedad(int jugadorId) async {
    try {
      final response = await Dioclient.dio.get(
        "${ApiConst.controlador_propiedad}/$jugadorId",
      );
      return response.data;
    } catch (e) {
      return {'status': false, 'userMssg': 'Error al obtener lista'};
    }
  }
}
