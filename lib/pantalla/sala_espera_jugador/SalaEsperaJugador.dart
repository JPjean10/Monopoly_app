import 'package:flutter/material.dart';
import 'package:monopoly_app/componentes/button/Button_styles.dart';
import 'package:monopoly_app/componentes/text/Text_styles.dart';
import 'package:monopoly_app/controladores/sala_espera_controller.dart';

// ==========================================
// PANTALLA: SALA ESPERA JUGADOR BANCO
// ==========================================
class SalaEsperajugadorBanco extends StatefulWidget {
  final String nombreUsuario;
  const SalaEsperajugadorBanco({super.key, required this.nombreUsuario});

  @override
  State<SalaEsperajugadorBanco> createState() => _SalaEsperajugadorBancoState();
}

class _SalaEsperajugadorBancoState extends State<SalaEsperajugadorBanco> {
  late final SalaEsperaController _controller;
  List<dynamic> jugadores = [];
  bool _isIniciarEnabled = false;

  @override
  void initState() {
    super.initState();
    // Instanciamos el controlador delegando el comportamiento
    _controller = SalaEsperaController(nombreUsuario: widget.nombreUsuario);
    _inicializarLogica();
  }

  void _inicializarLogica() async {
    await _controller.initSignalR(
      onListaActualizada: _actualizarPantalla,
      onPartidaIniciada: () => _controller.navegarASalaJugador(context),
      onConvertidoEnBanco: () {}, // Ya es banco, no necesita volver a saltar
    );
    _actualizarPantalla();
  }

  void _actualizarPantalla() async {
    final lista = await _controller.cargarJugadores();
    if (mounted) {
      setState(() {
        jugadores = lista;
        _isIniciarEnabled = jugadores.length >= 2;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Monopoly",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF24B9F9),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                // Lista dinámica de jugadores
                ...jugadores
                    .map(
                      (j) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${j['nombre']} :",
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(
                              "${j['tarjeta']['monto']}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),

                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: Button_styles(
                        text: "cancelar",
                        assetIcon: "assets/icon/Close.png",
                        onPressed: () => _controller.cancelarRegistro(context),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Button_styles(
                        text: "Iniciar partida",
                        assetIcon: 'assets/icon/Advance.png',
                        isEnabled: _isIniciarEnabled,
                        onPressed: () => _controller.iniciarPartida(),
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

// ==========================================
// PANTALLA: SALA ESPERA JUGADOR COMÚN
// ==========================================
class SalaEsperajugador extends StatefulWidget {
  final String nombreUsuario;
  const SalaEsperajugador({super.key, required this.nombreUsuario});

  @override
  State<SalaEsperajugador> createState() => _SalaEsperajugadorState();
}

class _SalaEsperajugadorState extends State<SalaEsperajugador> {
  late final SalaEsperaController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SalaEsperaController(nombreUsuario: widget.nombreUsuario);
    _inicializarLogica();
  }

  void _inicializarLogica() async {
    await _controller.initSignalR(
      onListaActualizada:
          () {}, // No renderiza lista en esta pantalla según tu diseño
      onPartidaIniciada: () => _controller.navegarASalaJugador(context),
      onConvertidoEnBanco: _cambiarABancoAutomatico,
    );
  }

  void _cambiarABancoAutomatico() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SalaEsperajugadorBanco(nombreUsuario: widget.nombreUsuario),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  onPressed: () => _controller.cancelarRegistro(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
