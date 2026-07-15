import 'package:flutter/material.dart';

class ItemNotificacionCard extends StatelessWidget {
  final Map<String, dynamic> notificacion;

  const ItemNotificacionCard({super.key, required this.notificacion});

  @override
  Widget build(BuildContext context) {
    final String titulo = notificacion['titulo'] ?? 'NOTIFICACIÓN';
    final String desc =
        notificacion['descripcion'] ?? notificacion['monto']?.toString() ?? '';
    final String fecha = notificacion['fecha'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
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
                const Icon(Icons.notifications_active, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    titulo.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 20,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 15),
              Text(desc, style: const TextStyle(fontSize: 16)),
            ],
            if (fecha.isNotEmpty) ...[
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  fecha,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
