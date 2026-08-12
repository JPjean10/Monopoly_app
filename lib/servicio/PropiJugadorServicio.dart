import 'package:dio/dio.dart';
import 'package:monopoly_app/dio_client/DioClient.dart';
import 'package:monopoly_app/pantalla/sala_jugador/model/PropiJugadorModel.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';

class PropiJugadorServicio {
  Future<Map<String, dynamic>> AdquirirOMejorarPropiedad(
    int jugadorId,
    int propiedadId,
    int precio,
  ) async {
    try {
      final response = await Dioclient.dio.post(
        ApiConst.controlador_propi_jugador,
        data: {
          'jugadorId': jugadorId,
          'propiedadId': propiedadId,
          "propiedad": {"precio": precio},
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

  Future<List<dynamic>> obtenerPropiedadesJugador(int jugadorId) async {
    try {
      // Llama al endpoint GET /PropiJugador/{jugadorId}[cite: 23]
      final response = await Dioclient.dio.get(
        "${ApiConst.controlador_propi_jugador}/$jugadorId",
      );

      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      print("Error al obtener propiedades: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> enviarCobroRenta(
    PropiJugadorModel datosPropiedad,
  ) async {
    try {
      // Enviamos el objeto en el body y nuestro ID en la URL
      final response = await Dioclient.dio.post(
        "${ApiConst.controlador_propi_jugador}${ApiConst.cobrarRenta}",
        data: datosPropiedad.toJson(),
      );

      return response.data;
    } catch (e) {
      print("Error al cobrar renta: $e");
      return {'status': false, 'userMssg': 'Error al cobrar renta'};
    }
  }

  Future<Map<String, dynamic>> enviarVentaMasiva(
    int jugadorId,
    String propiedadesIds,
  ) async {
    try {
      final response = await Dioclient.dio.post(
        "${ApiConst.controlador_propi_jugador}${ApiConst.venderPropiedades}",
        data: {
          'jugadorId': jugadorId,
          'propiedadesIds':
              propiedadesIds, // Pasa la cadena de texto armada con comas
        },
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null)
        return e.response?.data;
      return {'statusCode': 500, 'userMssg': 'Error de red en la transacción'};
    } catch (e) {
      return {'statusCode': 500, 'userMssg': 'Error inesperado: $e'};
    }
  }
}
