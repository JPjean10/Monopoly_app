import 'package:flutter/material.dart';

class Button_styles extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final String assetIcon;

  const Button_styles({
    super.key,
    required this.text,
    required this.onPressed,
    required this.assetIcon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF24B9F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(width: 10),
            Image.asset(assetIcon, width: 30, height: 30, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class Button_disabled_styles extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // 1. Cambiado a opcional (nullable)
  final String assetIcon;
  final bool isEnabled; // 2. Nueva propiedad para controlar el estado

  const Button_disabled_styles({
    super.key,
    required this.text,
    required this.onPressed,
    required this.assetIcon,
    this.isEnabled = false, // Por defecto está habilitado
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF24B9F9),
          // Color cuando está deshabilitado (opcional, Flutter pone uno por defecto)
          disabledBackgroundColor: Colors.grey.shade300,
          disabledForegroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        // 3. Si isEnabled es false, pasamos null a onPressed
        onPressed: isEnabled ? onPressed : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                // Cambiamos el color del texto si está deshabilitado
                color: isEnabled ? Colors.white : Colors.grey,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 10),
            Image.asset(
              assetIcon,
              width: 30,
              height: 30,
              // Cambiamos el color del icono si está deshabilitado
              color: isEnabled ? Colors.white : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
