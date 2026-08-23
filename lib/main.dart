import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monopoly_app/modal/CartaTrampaModel.dart';
import 'package:monopoly_app/pantalla/registro_jugador/registro_jugador.dart';
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
List<CartaTrampaModel> listaCartasTrampa = [];

class PantallaPrincipal extends StatefulWidget {
  const PantallaPrincipal({super.key});

  @override
  State<PantallaPrincipal> createState() => _PantallaPrincipalState();
}

class _PantallaPrincipalState extends State<PantallaPrincipal> {
  @override
  void initState() {
    super.initState();
    // Envuelve la carga en un callback para asegurar que el contexto exista
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarDatosIniciales();
    });
  }

  Future<void> _cargarDatosIniciales() async {
    try {
      final servicio = CartasTrampaServicio();
      // Añade un timeout por si el servicio del servidor no responde
      listaCartasTrampa = await servicio.listarCartasTrampa().timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw Exception("Tiempo de espera agotado"),
      );
    } catch (e) {
      debugPrint('Error al cargar datos: $e');
      // Si falla, podrías mostrar un SnackBar o dejarlo así para que el usuario vea el error
    } finally {
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
