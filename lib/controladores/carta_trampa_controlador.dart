import 'package:flutter/material.dart';
import 'package:monopoly_app/modal/carta_trampa_jugador_model.dart';
import 'dart:math';
import 'package:monopoly_app/modal/carta_trampa_model.dart';
import 'package:monopoly_app/servicio/cartas_trampa_jugador_servicio.dart';
import 'package:monopoly_app/util/helpers/mensaje_helper.dart';

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
      listaCartasTrampaJugador = await _cartasTrampaJugadorServicio
          .listarCartasTrampaJugador(jugadorId);
    } catch (e) {
      listaCartasTrampaJugador = [];
      debugPrint('Error al listar las cartas trampa del jugador: $e');
    }
  }

  // --- ACCIONES Y BOTONES ---
  Future<bool> procesarCartaTrampaOInversionExpress({
    required BuildContext context,
    required int jugadorId,
    required String codigoAccion,
    required Function()
    onInversionExpress, // Callback para activar animación y botones en la UI
  }) async {
    try {
      // Si la carta es "INVERSÍON_EXPRESS", ignoramos el backend y activamos la lógica de UI
      if (codigoAccion == "INVERSION_EXPRESS") {
        onInversionExpress();
        return false; // Indica que se debe manejar la interfaz especial
      }

      // --- Si no es Inversión Express, procesa normalmente con el backend ---
      final resultado = await _cartasTrampaJugadorServicio.procesarCartaTrampa(
        jugadorId,
        codigoAccion,
      );

      if (!context.mounted) return false;

      final String? mensaje = resultado['userMssg'] as String?;
      if (mensaje != null && mensaje.trim().isNotEmpty) {
        MensajeHelper.mostrarResultado(context, resultado);
      }

      if (resultado['statusCode'] == 201) {
        listarCartasTrampaJugador(jugadorId);
      }

      return true; // Ejecución normal terminada
    } catch (e) {
      debugPrint('Error al procesar la carta trampa: $e');
      return false;
    }
  }

  Future<bool> procesarCartaTrampaJugadorODescuentoMejora({
    required BuildContext context,
    required int cartaJugadorId,
    required int jugadorId,
    required String codigoAccion,
    required Function()
    onInversionExpress, // Callback para activar animación y botones en la UI
  }) async {
    try {
      // Si la carta es "DESCUENTO_MEJORA", ignoramos el backend y activamos la lógica de UI
      if (codigoAccion == "DESCUENTO_MEJORA") {
        onInversionExpress();
        return false; // Indica que se debe manejar la interfaz especial
      }

      // --- Si no es Inversión Express, procesa normalmente con el backend ---
      final resultado = await _cartasTrampaJugadorServicio
          .procesarCartaInventarioJugador(cartaJugadorId);

      if (!context.mounted) return false;

      final String? mensaje = resultado['userMssg'] as String?;
      if (mensaje != null && mensaje.trim().isNotEmpty) {
        MensajeHelper.mostrarResultado(context, resultado);
      }

      // --- AQUÍ ESTABA EL PROBLEMA: AGREGAR ESTO ---
      if (resultado['statusCode'] == 201) {
        await listarCartasTrampaJugador(jugadorId);
      }

      return true; // Ejecución normal terminada
    } catch (e) {
      debugPrint('Error al procesar la carta trampa: $e');
      return false;
    }
  }
}
