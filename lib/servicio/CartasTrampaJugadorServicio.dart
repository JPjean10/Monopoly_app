import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:monopoly_app/dio_client/DioClient.dart';
import 'package:monopoly_app/modal/CartaTrampaJugadorModel.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';

class CartasTrampaJugadorServicio {
  final Dio _dio = Dioclient.dio; // O tu instancia configurada de Dio

  Future<List<CartaTrampaJugadorModel>> ListarCartasTrampaJugador(
    int jugadorId,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiConst.baseUrl}${ApiConst.controlador_carta_trampa_jugador}/$jugadorId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> listaData = response.data['data'] ?? [];

        return listaData
            .map(
              (item) => CartaTrampaJugadorModel.fromJson(
                item as Map<String, dynamic>,
              ),
            )
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint("Error al obtener cartas del jugador: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> ProcesarCartaTrampa(
    int jugadorId,
    String codigoAccion,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiConst.baseUrl}${ApiConst.controlador_carta_trampa_jugador}',
        data: {
          'jugadorId': jugadorId,
          'cartaTrampaModel': {'codigoAccion': codigoAccion},
        },
      );

      return response.data;
    } catch (e) {
      debugPrint("Error al usar carta trampa: $e");
      return {'status': false, 'userMssg': 'Error al usar carta trampa'};
    }
  }

  Future<Map<String, dynamic>> ProcesarCartaInventarioJugador(
    int cartaJugadorId,
    int jugadorId,
    String codigoAccion,
  ) async {
    try {
      final response = await _dio.delete(
        '${ApiConst.baseUrl}${ApiConst.controlador_carta_trampa_jugador}',
        data: {
          'cartaJugadorId': cartaJugadorId,
          'jugadorId': jugadorId,
          'cartaTrampaModel': {'codigoAccion': codigoAccion},
        },
      );

      return response.data;
    } catch (e) {
      debugPrint("Error al usar carta trampa: $e");
      return {'status': false, 'userMssg': 'Error al usar carta trampa'};
    }
  }
}
