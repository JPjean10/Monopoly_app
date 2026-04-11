import 'package:flutter/material.dart';

class MensajeHelper {
  static void mostrarResultado(
    BuildContext context,
    Map<String, dynamic> resultado,
  ) {
    // Obtenemos los datos del mapa que viene del servicio
    final int statusCode = resultado['statusCode'] ?? 500;
    final String mensaje = resultado['userMssg'] ?? 'Error desconocido';

    Color colorFondo;

    // Lógica de colores según el código de estado
    if (statusCode == 201) {
      colorFondo = Colors.green; // Éxito
    } else if (statusCode == 401) {
      colorFondo = Colors.orange; // Advertencia (Jugador existe)
    } else {
      colorFondo = Colors.red; // Error crítico
    }

    // Mostramos el SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: colorFondo,
        behavior:
            SnackBarBehavior.floating, // Se ve más moderno, como un flotante
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
