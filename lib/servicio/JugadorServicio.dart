import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:monopoly_app/dio_client/DioClient.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';

class JugadorServicio {
  // Método para obtener la lista de jugadores (usando tu sp_ListarJugadores)
  Future<Map<String, dynamic>> listarJugadores() async {
    try {
      final response = await Dioclient.dio.get(ApiConst.controlador_jugador);
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

  // Asegúrate de que el método esté DENTRO de las llaves de la clase
  Future<Map<String, dynamic>> insertarJugador(
    String nombre,
    BuildContext context,
  ) async {
    try {
      final response = await Dioclient.dio.post(
        ApiConst.controlador_jugador,
        data: {'nombre': nombre},
      );

      Map<String, dynamic> resultadoInsert = response.data;

      // 2. Si la inserción fue exitosa, consultamos la lista para saber el rol
      if (resultadoInsert['statusCode'] == 201) {
        final resLista = await listarJugadores();

        if (resLista['statusCode'] == 200) {
          List jugadores = resLista['data'];

          // Buscamos el registro que acabamos de insertar por el nombre
          var miRegistro = jugadores.firstWhere(
            (j) => j['nombre'] == nombre,
            orElse: () => null,
          );

          if (miRegistro != null) {
            // Agregamos la información del rol al mapa de respuesta
            resultadoInsert['esBanco'] = miRegistro['esBanco'];
            resultadoInsert['jugadorId'] = miRegistro['jugadorId'];
          }
        }
      }

      // Si llega aquí, es un 201 o el código que configuraste en validateStatus
      return resultadoInsert;
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

  Future<Map<String, dynamic>> eliminarJugador(int jugadorId) async {
    try {
      final response = await Dioclient.dio.delete(
        "${ApiConst.controlador_jugador}/$jugadorId", // Esto coincide con [HttpDelete("{jugadorId}")]
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
