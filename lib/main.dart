import 'package:flutter/material.dart';
import 'package:monopoly_app/pantalla/registrar/RegistroJugador.dart';
import 'dart:async';

void main() {
  runApp(
    const MaterialApp(
      home: PantallaPrincipal(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  @override
  void initState() {
    super.initState();
    // Cambiamos a la siguiente pantalla después de 5 segundos
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RegistroJugador()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos Stack para poner la imagen al fondo y cualquier widget encima
      body: Stack(
        children: [
          // IMAGEN DE FONDO COMPLETA
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fondo.png'), // <-- TU IMAGEN AQUÍ
                fit: BoxFit
                    .fill, // Esto hace que la imagen cubra toda la pantalla
              ),
            ),
          ),

          // CAPA OPCIONAL: Si quieres poner algún botón o texto encima del fondo,
          // lo puedes poner aquí. Si el diseño ya lo tiene la imagen, deja esto vacío.
          const Center(
            child: CircularProgressIndicator(
              color: Colors.white70,
            ), // Indicador de carga opcional
          ),
        ],
      ),
    );
  }
}
