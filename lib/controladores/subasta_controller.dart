import 'package:flutter/material.dart';
import 'package:monopoly_app/servicio/jugador_servicio.dart';
import 'package:monopoly_app/servicio/propi_jugador_servicio.dart';
import 'package:monopoly_app/util/helpers/mensaje_helper.dart';

class SubastaController {
  final JugadorServicio _jugadorServicio = JugadorServicio();
  final PropiJugadorServicio _propiJugadorServicio = PropiJugadorServicio();

  Future<List<dynamic>> cargarJugadores() async {
    final res = await _jugadorServicio.listarJugadores();
    if (res['statusCode'] == 200) {
      return res['data'] ?? [];
    }
    return [];
  }

  // --- ACCIONES Y BOTONES ---
  Future<void> procesarSubasta({
    required BuildContext context,
    required int jugadorId,
    required int propiedadId,
    required int precio,
  }) async {
    final res = await _propiJugadorServicio.procesarSubasta(
      jugadorId,
      propiedadId,
      precio,
    );

    if (!context.mounted) return;

    if (res['statusCode'] == 201) {
      MensajeHelper.mostrarResultado(context, res);
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      MensajeHelper.mostrarResultado(context, res);
    }
  }
}
