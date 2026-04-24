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
      return e.response?.data ??
          {'status': false, 'userMssg': 'Error al eliminar'};
    }
  }
}
