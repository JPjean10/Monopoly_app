import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monopoly_app/modal/CartaTrampaModel.dart';
import 'package:monopoly_app/pantalla/registro_jugador/RegistroJugador.dart';
import 'dart:async';

import 'package:monopoly_app/servicio/CartasTrampaServicio.dart';

void main() async {
  // 2. ASEGURA LA INICIALIZACIÓN DE LOS BINDINGS
  WidgetsFlutterBinding.ensureInitialized();

  // 3. BLOQUEA LA ORIENTACIÓN A VERTICAL
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const MaterialApp(
      home: PantallaPrincipal(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

// Variable global o singleton si necesitas acceder a las cartas desde cualquier lugar
List<CartaTrampaModel> listaCartasTrampaGlobal = [];

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  @override
  void initState() {
    super.initState();
    // En lugar del Timer, llamamos a la función de carga inicial
    _cargarDatosIniciales();
  }

  Future<void> _cargarDatosIniciales() async {
    try {
      // 1. Instanciamos el servicio y traemos los datos
      final servicio = CartasTrampaServicio();
      listaCartasTrampaGlobal = await servicio.listarCartasTrampa();

      print(
        'Cartas trampa cargadas con éxito: ${listaCartasTrampaGlobal.length}',
      );
    } catch (e) {
      print('Error al cargar datos en el Splash: $e');
      // Opcional: Manejar error (por ejemplo, reintentar o mostrar alerta)
    } finally {
      // 2. Transición a la siguiente pantalla solo cuando la carga finalice
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RegistroJugador()),
        );
      }
    }
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
