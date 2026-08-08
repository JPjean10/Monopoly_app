import 'package:flutter/material.dart';
import 'package:monopoly_app/servicio/JugadorServicio.dart';

class SubastaController {
  final JugadorServicio _jugadorServicio = JugadorServicio();

  Future<List<dynamic>> cargarJugadores() async {
    final res = await _jugadorServicio.listarJugadores();
    if (res['statusCode'] == 200) {
      return res['data'] ?? [];
    }
    return [];
  }
}
