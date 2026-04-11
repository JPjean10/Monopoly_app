import 'package:flutter/material.dart';

// --- CAJA DE TEXTO PERSONALIZADA ---
class TextField_styles extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final IconData? icon;
  final String? assetIcon;

  const TextField_styles({
    super.key,
    required this.hintText,
    required this.controller,
    this.icon, // Ahora no llevan "required"
    this.assetIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        // Lógica para decidir qué icono mostrar en el prefijo
        prefixIcon: _buildPrefixIcon(),
        labelText: hintText,
        labelStyle: const TextStyle(color: Colors.black54),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.cyan, width: 2),
        ),
      ),
    );
  }

  // Función auxiliar para construir el icono
  Widget? _buildPrefixIcon() {
    if (assetIcon != null) {
      return Padding(
        padding: const EdgeInsets.all(12.0), // Ajuste para que no quede pegado
        child: Image.asset(assetIcon!, width: 24, height: 24),
      );
    } else if (icon != null) {
      return Icon(icon, size: 30, color: Colors.black87);
    }
    return null; // Si no mandas nada, el campo no tendrá icono
  }
}
