import 'package:flutter/material.dart';

class ItemNotificacionCard extends StatelessWidget {
  final Map<String, dynamic> notificacion;

  const ItemNotificacionCard({super.key, required this.notificacion});

  @override
  Widget build(BuildContext context) {
    // 1. Mapeamos las propiedades reales que vienen en el backend/historial
    final String tipoEstado =
        "${notificacion['tipoCompra'] ?? 'Transacción'}: ${notificacion['estado'] ?? ''}"
            .toLowerCase();
    final String propietario =
        "propietario: ${notificacion['nombreJugador'] ?? 'N/A'}".toLowerCase();
    final String propiedad =
        "propiedad: ${notificacion['nombrePropiedad'] ?? 'N/A'}".toUpperCase();
    final String mensaje =
        notificacion['mensage'] ?? notificacion['mensaje'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
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
            Row(
              children: [
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tipoEstado,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              propietario,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              propiedad,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            if (mensaje.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                "mensaje: $mensaje",
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
