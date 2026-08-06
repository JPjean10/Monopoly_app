import 'package:dio/dio.dart';
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
      print("Error al obtener cartas del jugador: $e");
      rethrow;
    }
  }
}
