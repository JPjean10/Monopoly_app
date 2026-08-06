import 'package:flutter/material.dart';
import 'package:monopoly_app/modal/CartaTrampaJugadorModel.dart';
import 'dart:math';
import 'package:monopoly_app/modal/CartaTrampaModel.dart';
import 'package:monopoly_app/servicio/CartasTrampaJugadorServicio.dart';

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
}
