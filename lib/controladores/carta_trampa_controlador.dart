import 'package:flutter/material.dart';
import 'package:monopoly_app/modal/CartaTrampaJugadorModel.dart';
import 'dart:math';
import 'package:monopoly_app/modal/CartaTrampaModel.dart';
import 'package:monopoly_app/servicio/CartasTrampaJugadorServicio.dart';
import 'package:monopoly_app/util/helpers/MensajeHelper.dart';

List<CartaTrampaJugadorModel> listaCartasTrampaJugador = [];

class CartaTrampaController {
  final CartasTrampaJugadorServicio _cartasTrampaJugadorServicio =
      CartasTrampaJugadorServicio();

  CartaTrampaModel obtenerCartaAleatoriaPorPeso(
    List<CartaTrampaModel> listaCartas,
  ) {
    if (listaCartas.isEmpty) {
      throw Exception("La lista de cartas trampa está vacía.");
    }

    // 1. Calcular la suma total de todos los pesos
    int sumaPesosTotal = listaCartas.fold(0, (sum, carta) => sum + carta.peso);

    // 2. Generar un número aleatorio entre 0 y sumaPesosTotal
    int numeroRandom = Random().nextInt(sumaPesosTotal);

    // 3. Recorrer las cartas e ir restando el peso hasta encontrar la elegida
    for (var carta in listaCartas) {
      if (numeroRandom < carta.peso) {
        return carta; // ¡Esta es la carta seleccionada según probabilidad!
      }
      numeroRandom -= carta.peso;
    }

    return listaCartas.first; // Fallback por seguridad
  }

  Future<void> listarCartasTrampaJugador(int jugadorId) async {
    try {
      listaCartasTrampaJugador =
          await _cartasTrampaJugadorServicio.ListarCartasTrampaJugador(
            jugadorId,
          );
    } catch (e) {
      listaCartasTrampaJugador = [];
      print('Error al listar las cartas trampa del jugador: $e');
    }
  }

  // --- ACCIONES Y BOTONES ---
  Future<bool> procesarCartaTrampa({
    required BuildContext context,
    required int jugadorId,
    required String codigoAccion,
    required Function()
    onInversionExpress, // Callback para activar animación y botones en la UI
  }) async {
    try {
      // Si la carta es "INVERSÍON_EXPRESS", ignoramos el backend y activamos la lógica de UI
      if (codigoAccion == "INVERSÍON_EXPRESS") {
        onInversionExpress();
        return false; // Indica que se debe manejar la interfaz especial
      }

      // --- Si no es Inversión Express, procesa normalmente con el backend ---
      final resultado = await _cartasTrampaJugadorServicio.ProcesarCartaTrampa(
        jugadorId,
        codigoAccion,
      );

      final String? mensaje = resultado['userMssg'] as String?;
      if (mensaje != null && mensaje.trim().isNotEmpty) {
        MensajeHelper.mostrarResultado(context, resultado);
      }

      if (resultado['statusCode'] == 201) {
        listarCartasTrampaJugador(jugadorId);
      }

      return true; // Ejecución normal terminada
    } catch (e) {
      print('Error al procesar la carta trampa: $e');
      return false;
    }
  }
}
