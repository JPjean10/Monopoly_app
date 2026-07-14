import 'package:flutter/material.dart';
import 'dart:convert'; // Para manejar JSON
import 'package:monopoly_app/componentes/button/Button_styles.dart';
import 'package:monopoly_app/componentes/text_field/TextField_styles.dart';
import 'package:monopoly_app/controladores/registro_controller.dart';
import 'package:monopoly_app/servicio/jugador_service.dart';
import 'package:monopoly_app/pantalla/sala_espera_jugador/SalaEsperaJugador.dart';
import 'package:monopoly_app/util/helpers/MensajeHelper.dart';

class RegistroJugador extends StatefulWidget {
  // Cambia a StatefulWidget para manejar el controlador
  const RegistroJugador({super.key});

  @override
  State<RegistroJugador> createState() => _RegistroJugadorState();
}

class _RegistroJugadorState extends State<RegistroJugador> {
  // 1. Creas el controlador para el nombre
  final TextEditingController nombre_text = TextEditingController();
  // 1. Variable para controlar si el botón está habilitado
  bool _isButtonEnabled = false;
  final JugadorService _jugadorService = JugadorService();

  @override
  void initState() {
    super.initState();
    // 2. Escuchar los cambios del TextField
    nombre_text.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // 3. Limpiar el listener y el controlador
    nombre_text.removeListener(_onTextChanged);
    nombre_text.dispose();
    super.dispose();
  }

  // 4. Función que se ejecuta al escribir
  void _onTextChanged() {
    setState(() {
      // Se habilita si el texto no está vacío (quitando espacios en blanco)
      _isButtonEnabled = nombre_text.text.trim().isNotEmpty;
    });
  }

  Button_completo_styles btn_ButtonCompleto() {
    return Button_completo_styles(
      text: "iniciar juego",
      assetIcon: 'assets/icon/Advance.png',
      isEnabled: _isButtonEnabled, // Usa la variable de estado
      onPressed: () async {
        final nombre = nombre_text.text;
        RegistroController.registrarYNavegar(
          nombre: nombre_text.text,
          context: context,
        );
      },
    );
  }

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
                // USANDO TU CAJA DE TEXTO PERSONALIZADA
                TextField_styles(
                  hintText: 'nombre',
                  icon: Icons.person_add_alt_1,
                  controller: nombre_text, // PASAS EL CONTROLADOR AQUÍ
                ),

                const SizedBox(height: 25),

                btn_ButtonCompleto(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
