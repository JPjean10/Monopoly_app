import 'package:dio/dio.dart';
import 'package:monopoly_app/dio_client/DioClient.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';

class Salajugadorservicio {
  Future<Map<String, dynamic>> InsertHistorial(
    int jugadorId,
    int propiedadId,
    String tipoCompra,
    String estado,
  ) async {
    try {
      final response = await Dioclient.dio.post(
        ApiConst.controlador_historial_compra,
        data: {
          'jugadorId': jugadorId,
          'propiedadId': propiedadId,
          'tipoCompra': tipoCompra,
          'estado': estado,
        },
      );
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

  Future<Map<String, dynamic>> ComprarPropiedad(
    int jugadorId,
    int propiedadId,
  ) async {
    try {
      final response = await Dioclient.dio.post(
        ApiConst.controlador_propi_jugador,
        data: {'jugadorId': jugadorId, 'propiedadId': propiedadId},
      );
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

  // Añadir a Salajugadorservicio
  Future<Map<String, dynamic>?> obtenerDetalleJugador(int jugadorId) async {
    try {
      // Usamos el endpoint que definiste en JugadorControlador [source: 7]  'Jugador/buscar/$jugadorId'
      final response = await Dioclient.dio.get(
        "${ApiConst.controlador_jugador}${ApiConst.buscarJugador}/$jugadorId",
      );

      if (response.statusCode == 200) {
        // Como tu DAO retorna una lista [source: 8], tomamos el primer elemento
        List<dynamic> lista = response.data['data'];
        if (lista.isNotEmpty) {
          return lista[0] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      print("Error al refrescar jugador: $e");
      return null;
    }
  }
}
