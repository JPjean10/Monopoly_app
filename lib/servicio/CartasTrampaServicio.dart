import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:monopoly_app/dio_client/DioClient.dart';
import 'package:monopoly_app/modal/CartaTrampaModel.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';

class CartasTrampaServicio {
  final Dio _dio = Dioclient.dio; // O tu instancia configurada de Dio

  Future<List<CartaTrampaModel>> listarCartasTrampa() async {
    try {
      final response = await _dio.get(
        '${ApiConst.baseUrl}${ApiConst.controlador_carta_trampa}',
      );

      if (response.statusCode == 200 && response.data != null) {
        // Accedemos a la clave 'data' de la respuesta JSON
        final List<dynamic> listaData = response.data['data'] ?? [];

        // Mapeamos cada objeto JSON a la clase Dart
        return listaData
            .map(
              (item) => CartaTrampaModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Error al obtener cartas trampa: $e');
      rethrow;
    }
  }
}
