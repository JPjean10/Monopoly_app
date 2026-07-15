import 'package:flutter/material.dart';
import 'package:monopoly_app/componentes/button/Button_styles.dart';

class ItemPagoCard extends StatelessWidget {
  final Map<String, dynamic> solicitud;
  final VoidCallback onAceptar;
  final VoidCallback onCancelar;

  const ItemPagoCard({
    super.key,
    required this.solicitud,
    required this.onAceptar,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              solicitud['nombreJugador'] ?? "Jugador",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              "${solicitud['mensajeSolicitud']}",
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Button_styles(
                    text: "cancelar",
                    assetIcon: 'assets/icon/Cancel.png',
                    isEnabled: true,
                    onPressed: onCancelar,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Button_styles(
                    text: "aceptar",
                    assetIcon: 'assets/icon/Done.png',
                    isEnabled: true,
                    onPressed: onAceptar,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
