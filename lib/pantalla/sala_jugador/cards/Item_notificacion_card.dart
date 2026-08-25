import 'package:flutter/material.dart';

class ItemNotificacionCard extends StatelessWidget {
  final Map<String, dynamic> notificacion;

  const ItemNotificacionCard({super.key, required this.notificacion});

  // Función para verificar si un valor está realmente "vacío" o es cero
  bool _isInvalid(dynamic value) {
    if (value == null) return true;
    final str = value.toString().trim();
    return str.isEmpty || str == '0' || str.toLowerCase() == 'null';
  }

  @override
  Widget build(BuildContext context) {
    // 1. Obtener los datos sin valores por defecto rígidos para evaluar si existen
    final dynamic rawTipo = notificacion['tipoCompra'];
    final dynamic rawEstado = notificacion['estado'];
    final dynamic rawJugador = notificacion['nombreJugador'];
    final dynamic rawPropiedad = notificacion['nombrePropiedad'];
    final dynamic rawMensaje =
        notificacion['mensage'] ?? notificacion['mensaje'];

    // 2. Validar qué datos existen
    final bool hasTipo = !_isInvalid(rawTipo);
    final bool hasEstado = !_isInvalid(rawEstado);
    final bool hasJugador = !_isInvalid(rawJugador);
    final bool hasPropiedad = !_isInvalid(rawPropiedad);
    final bool hasMensaje = !_isInvalid(rawMensaje);

    // 3. Formatear el texto del título (tipoEstado)
    String tipoEstadoText = '';
    if (hasTipo && hasEstado) {
      tipoEstadoText = "$rawTipo: $rawEstado".toLowerCase();
    } else if (hasTipo) {
      tipoEstadoText = rawTipo.toString().toLowerCase();
    } else if (hasEstado) {
      tipoEstadoText = rawEstado.toString().toLowerCase();
    }

    // 4. Formatear la etiqueta del jugador/propietario
    // Si NO hay propiedad, se muestra "jugador:", si SÍ hay propiedad, se muestra "propietario:"
    final String labelJugador = hasPropiedad ? "propietario" : "jugador";
    final String jugadorText = "$labelJugador: $rawJugador".toLowerCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título: Solo si tipo o estado tienen contenido válido
            if (tipoEstadoText.isNotEmpty) ...[
              Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tipoEstadoText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Jugador/Propietario: Solo se muestra si hay nombreJugador válido
            if (hasJugador) ...[
              Text(
                jugadorText,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 4),
            ],

            // Propiedad: Solo se muestra si hay nombrePropiedad válido
            if (hasPropiedad) ...[
              Text(
                "propiedad: $rawPropiedad".toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
            ],

            // Mensaje: Solo si hay un mensaje válido
            if (hasMensaje) ...[
              const SizedBox(height: 4),
              Text(
                "mensaje: $rawMensaje",
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
