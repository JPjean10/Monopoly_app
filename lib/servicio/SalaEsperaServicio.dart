import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:monopoly_app/dio_client/DioClient.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';

class SalaEsperaServicio {
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
}
