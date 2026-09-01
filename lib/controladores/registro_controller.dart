import 'package:flutter/material.dart';
import 'package:monopoly_app/pantalla/sala_espera_jugador/sala_espera_jugador.dart';
import 'package:monopoly_app/servicio/jugador_servicio.dart';
import 'package:monopoly_app/util/helpers/audio_helper.dart';
import 'package:monopoly_app/util/helpers/mensaje_helper.dart';

class RegistroController {
  static final JugadorServicio _jugadorServicio = JugadorServicio();

  /// Ejecuta el registro de un jugador y realiza la navegación según su rol
  static Future<void> registrarYNavegar({
    required String nombre,
    required BuildContext context,
  }) async {
    if (nombre.trim().isEmpty) {
      // Validación básica antes de mandar a la API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un nombre válido.')),
      );
      return;
    }

    // 1. Llamamos al servicio
    final resultado = await _jugadorServicio.insertarJugador(nombre, context);

    if (resultado['statusCode'] == 201) {
      // Leemos el campo 'esBanco' que el servicio inyectó en el mapa
      bool esBanco = resultado['esBanco'] ?? false;

      if (context.mounted) {
        if (esBanco) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SalaEsperajugadorBanco(nombreUsuario: nombre),
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SalaEsperajugador(nombreUsuario: nombre),
            ),
          );
        }
      }
    }

    // Mostramos el mensaje final usando tu helper
    if (context.mounted) {
      MensajeHelper.mostrarResultado(context, resultado);
      await AudioHelper.jugadorInsertado(); // Reproducir el efecto de sonido
    }
  }
}
