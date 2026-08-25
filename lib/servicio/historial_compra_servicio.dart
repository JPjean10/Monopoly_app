import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:monopoly_app/dio_client/dio_client.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';

class HistorialCompraServicio {
  Future<Map<String, dynamic>> insertHistorial(
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

  Future<List<dynamic>> obtenerHistorialCompras() async {
    try {
      final response = await Dioclient.dio.get(
        ApiConst.controlador_historial_compra,
      );
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint("Error al obtener historial: $e");
      return [];
    }
  }
}
