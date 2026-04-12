import 'package:flutter/material.dart';

class Button_completo_styles extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // 1. Cambiado a opcional (nullable)
  final String assetIcon;
  final bool isEnabled; // 2. Nueva propiedad para controlar el estado

  const Button_completo_styles({
    super.key,
    required this.text,
    required this.onPressed,
    required this.assetIcon,
    this.isEnabled = true, // Por defecto está habilitado
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
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

class Button_styles extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed; // 1. Cambiado a opcional (nullable)
  final String assetIcon;
  final bool isEnabled; // 2. Nueva propiedad para controlar el estado

  const Button_styles({
    super.key,
    required this.text,
    required this.onPressed,
    required this.assetIcon,
    this.isEnabled = true, // Por defecto está habilitado
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF24B9F9),
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ), // Padding interno reducido
        ),
        onPressed: isEnabled ? onPressed : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Usamos Flexible para que el texto se ajuste si es muy largo
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis, // Si no cabe, pone "..."
                style: TextStyle(
                  color: isEnabled ? Colors.white : Colors.grey,
                  fontSize: 13, // Bajamos un poco el tamaño para que quepa bien
                ),
              ),
            ),
            const SizedBox(width: 4),
            Image.asset(
              assetIcon,
              width: 20, // Icono un poco más pequeño para dar aire
              height: 20,
              color: isEnabled ? Colors.white : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
