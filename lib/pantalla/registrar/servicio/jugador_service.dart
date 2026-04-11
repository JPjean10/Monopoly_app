import 'package:dio/dio.dart';
import 'package:monopoly_app/dio_client/DioClient.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';

class JugadorService {
  // Asegúrate de que el método esté DENTRO de las llaves de la clase
  Future<Map<String, dynamic>> insertarJugador(String nombre) async {
    try {
      final response = await Dioclient.dio.post(
        ApiConst.controlador_jugador,
        data: {'nombre': nombre},
      );

      // Si llega aquí, es un 200 o el código que configuraste en validateStatus
      return response.data;
    } on DioException catch (e) {
      // Si el servidor responde (ej. 401 Unauthorized), devolvemos su JSON real
      if (e.response != null && e.response?.data != null) {
        return e.response?.data;
      }
      // Error de red o servidor apagado
      return {'status': false, 'userMssg': 'Error de conexión con el servidor'};
    } catch (e) {
      // Cualquier otro error inesperado
      return {'status': false, 'userMssg': 'Error inesperado: $e'};
    }
  }
}
