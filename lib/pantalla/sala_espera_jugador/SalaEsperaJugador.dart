import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:monopoly_app/componentes/button/Button_styles.dart';
import 'package:monopoly_app/componentes/text/Text_styles.dart'; // Para manejar JSON

class SalaesperajugadorBanco extends StatefulWidget {
  const SalaesperajugadorBanco({super.key});

  @override
  State<SalaesperajugadorBanco> createState() => _SalaesperajugadorBancoState();
}

class _SalaesperajugadorBancoState extends State<SalaesperajugadorBanco> {
  // Cambiado a true para que se vea azul como en tu imagen de referencia
  bool _isIniciarEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Monopoly",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF24B9F9), // El azul de tus botones
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                30,
              ), // Bordes más redondeados como la imagen
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // El contenedor se ajusta al contenido
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25), // Espacio antes de los botones
                // Fila de botones
                Row(
                  children: [
                    Expanded(
                      child: Button_styles(
                        text: "cancelar",
                        assetIcon: "assets/icon/Close.png",
                        onPressed: () => {},
                      ),
                    ),
                    const SizedBox(height: 25),
                    Expanded(
                      child: Button_styles(
                        text: "Iniciar partida",
                        assetIcon: 'assets/icon/Advance.png',
                        isEnabled: _isIniciarEnabled,
                        onPressed: () => {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Salaesperajugador extends StatefulWidget {
  // Cambia a StatefulWidget para manejar el controlador
  const Salaesperajugador({super.key});

  @override
  State<Salaesperajugador> createState() => _SalaesperajugadorState();
}

class _SalaesperajugadorState extends State<Salaesperajugador> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo limpio como la imagen
      appBar: AppBar(
        title: const Text("Monopoly", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text_styles(text: "Esperando a los jugadores..."),

                const SizedBox(height: 25),

                Button_completo_styles(
                  text: "cancelar",
                  assetIcon: "assets/icon/Close.png",
                  onPressed: () => {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
