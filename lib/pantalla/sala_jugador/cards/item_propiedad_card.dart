import 'package:flutter/material.dart';

class ItemPropiedadCard extends StatelessWidget {
  final Map<String, dynamic> propiedad;
  final VoidCallback onTap;

  const ItemPropiedadCard({
    super.key,
    required this.propiedad,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String nombreProp = propiedad['nombre'] ?? '';
    final int nivel = propiedad['nivelActual'] ?? 1;
    final int renta = propiedad['renta'] ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            children: [
              Text(
                nombreProp.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("NIVEL: $nivel", style: const TextStyle(fontSize: 20)),
                  Text(
                    "RENTA: S/ $renta",
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
