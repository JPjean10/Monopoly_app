import 'package:flutter/material.dart';
import 'package:monopoly_app/componentes/button/button_styles.dart';
import 'package:monopoly_app/componentes/text_field/textfield_styles.dart';
import 'package:monopoly_app/controladores/registro_controller.dart';

class RegistroJugador extends StatefulWidget {
  // Cambia a StatefulWidget para manejar el controlador
  const RegistroJugador({super.key});

  @override
  State<RegistroJugador> createState() => _RegistroJugadorState();
}

class _RegistroJugadorState extends State<RegistroJugador> {
  // 1. Creas el controlador para el nombre
  final TextEditingController nombreText = TextEditingController();
  // 1. Variable para controlar si el botón está habilitado
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    // 2. Escuchar los cambios del TextField
    nombreText.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    // 3. Limpiar el listener y el controlador
    nombreText.removeListener(_onTextChanged);
    nombreText.dispose();
    super.dispose();
  }

  // 4. Función que se ejecuta al escribir
  void _onTextChanged() {
    setState(() {
      // Se habilita si el texto no está vacío (quitando espacios en blanco)
      _isButtonEnabled = nombreText.text.trim().isNotEmpty;
    });
  }

  ButtonCompletoStyles btnButtonCompleto() {
    return ButtonCompletoStyles(
      text: "iniciar juego",
      assetIcon: 'assets/icon/Advance.png',
      isEnabled: _isButtonEnabled, // Usa la variable de estado
      onPressed: () async {
        final nombre = nombreText.text;
        RegistroController.registrarYNavegar(nombre: nombre, context: context);
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
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 5),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // USANDO TU CAJA DE TEXTO PERSONALIZADA
                TextFieldStyles(
                  hintText: 'nombre',
                  icon: Icons.person_add_alt_1,
                  controller: nombreText, // PASAS EL CONTROLADOR AQUÍ
                ),

                const SizedBox(height: 25),

                btnButtonCompleto(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
