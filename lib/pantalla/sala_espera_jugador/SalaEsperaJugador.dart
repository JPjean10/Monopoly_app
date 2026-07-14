import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:monopoly_app/componentes/button/Button_styles.dart';
import 'package:monopoly_app/componentes/text/Text_styles.dart';
import 'package:monopoly_app/pantalla/registro_jugador/RegistroJugador.dart';
import 'package:monopoly_app/servicio/jugador_service.dart';
import 'package:monopoly_app/servicio/SalaEsperaServicio.dart';
import 'package:monopoly_app/pantalla/sala_jugador/SalaJugador.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart'; // Para manejar JSON

class SalaEsperajugadorBanco extends StatefulWidget {
  final String nombreUsuario; // Agrega esto
  const SalaEsperajugadorBanco({super.key, required this.nombreUsuario});

  @override
  State<SalaEsperajugadorBanco> createState() => _SalaEsperajugadorBancoState();
}

class _SalaEsperajugadorBancoState extends State<SalaEsperajugadorBanco> {
  final JugadorService _jugadorService = JugadorService();
  final SalaEsperaServicio _salaEsperaServicio = SalaEsperaServicio();
  List<dynamic> jugadores = [];
  late HubConnection _hubConnection;
  // Cambiado a true para que se vea azul como en tu imagen de referencia
  bool _isIniciarEnabled = false;

  @override
  void initState() {
    super.initState();
    _initSignalR();
    _cargarJugadores();
  }

  void _initSignalR() async {
    // Cambia la IP por la de tu servidor
    _hubConnection = HubConnectionBuilder()
        .withUrl(ApiConst.ws) // Usando la constante de ApiConst
        .build();

    _hubConnection.onclose(({error}) => print("Conexión perdida"));

    // Escuchar el evento que enviamos desde C#
    _hubConnection.on("actulizar_lista_jugador", (arguments) {
      _cargarJugadores();
      _verificarNuevoRol();
    });

    _hubConnection.on("partida_iniciada", (arguments) async {
      await _cargarJugadores();
      _navegarASalaJugador();
    });

    await _hubConnection.start();
  }

  Future<void> _cargarJugadores() async {
    final res = await _jugadorService.listarJugadores();
    if (res['statusCode'] == 200) {
      setState(() {
        jugadores = res['data'];
        // Habilitar botón si hay 2 o más jugadores
        _isIniciarEnabled = jugadores.length >= 2;
      });
    }
  }

  void _navegarASalaJugador() {
    try {
      var yo = jugadores.firstWhere(
        (j) => j['nombre'] == widget.nombreUsuario,
        orElse: () => null,
      );
      if (yo != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Salajugador(datosJugador: yo),
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  void _verificarNuevoRol() async {
    final res = await _jugadorService.listarJugadores();
    if (res['statusCode'] == 200) {
      List lista = res['data'];
      // Busco mis datos actuales en la nueva lista
      var yo = lista.firstWhere(
        (j) => j['nombre'] == widget.nombreUsuario,
        orElse: () => null,
      );

      if (yo != null && yo['esBanco'] == true) {
        // ¡Ahora soy el Banco! Cambio de pantalla automáticamente
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
    }
  }

  void _cancelarRegistro() async {
    final res = await _jugadorService.listarJugadores();

    var yo = res['data'].firstWhere((j) => j['nombre'] == widget.nombreUsuario);

    await _salaEsperaServicio.eliminarJugador(yo['jugadorId']);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegistroJugador()),
    );
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
                // Lista dinámica de jugadores con su monto (basado en tu imagen)
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
                const SizedBox(height: 25), // Espacio antes de los botones
                // Fila de botones
                Row(
                  children: [
                    Expanded(
                      child: Button_styles(
                        text: "cancelar",
                        assetIcon: "assets/icon/Close.png",
                        onPressed: _cancelarRegistro,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Button_styles(
                        text: "Iniciar partida",
                        assetIcon: 'assets/icon/Advance.png',
                        isEnabled: _isIniciarEnabled,
                        onPressed: () async => {
                          await _hubConnection.invoke("IniciarJuego"),
                        },
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

  @override
  void dispose() {
    _hubConnection.stop();
    super.dispose();
  }
}

class SalaEsperajugador extends StatefulWidget {
  final String nombreUsuario;
  // Cambia a StatefulWidget para manejar el controlador
  const SalaEsperajugador({super.key, required this.nombreUsuario});

  @override
  State<SalaEsperajugador> createState() => _SalaEsperajugadorState();
}

class _SalaEsperajugadorState extends State<SalaEsperajugador> {
  late HubConnection _hubConnection;
  final JugadorService _jugadorService = JugadorService();
  final SalaEsperaServicio _salaEsperaServicio = SalaEsperaServicio();

  @override
  void initState() {
    super.initState();
    _initSignalR(); // <--- IMPORTANTE: Conectar al entrar
  }

  void _initSignalR() async {
    _hubConnection = HubConnectionBuilder()
        .withUrl("http://192.168.1.100:8080/gameHub")
        .build();

    // 1. ESCUCHAR CAMBIOS EN LA LISTA (Para detectar si ahora soy Banco)
    _hubConnection.on("actulizar_lista_jugador", (arguments) async {
      await _verificarSiSoyNuevoBanco();
    });

    // ESCUCHAR EL INICIO DE PARTIDA
    _hubConnection.on("partida_iniciada", (arguments) async {
      print("Señal de inicio recibida en jugador normal");

      // 1. Obtener la lista actualizada para buscar mis datos
      _IniciarPartida();
    });

    await _hubConnection.start();
  }

  // 3. NUEVA FUNCIÓN PARA CAMBIO DE ROL AUTOMÁTICO
  Future<void> _verificarSiSoyNuevoBanco() async {
    final res = await _jugadorService.listarJugadores();
    if (res['statusCode'] == 200) {
      List lista = res['data'];

      // Busco mis datos en la lista actualizada
      var yo = lista.firstWhere(
        (j) => j['nombre'] == widget.nombreUsuario,
        orElse: () => null,
      );

      // Si el servidor dice que ahora soy banco, salto de pantalla
      if (yo != null && yo['esBanco'] == true) {
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
    }
  }

  Future<void> _IniciarPartida() async {
    // 1. Obtener la lista actualizada para buscar mis datos
    final res = await _jugadorService.listarJugadores();
    if (res['statusCode'] == 200) {
      List jugadores = res['data'];

      // 2. Buscar mis datos (puedes pasar el nombre por constructor desde el login)
      var yo = jugadores.firstWhere(
        (j) => j['nombre'] == widget.nombreUsuario,
        orElse: () => null,
      );

      if (yo != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Salajugador(datosJugador: yo),
          ),
        );
      }
    }
  }

  void _cancelarRegistro() async {
    final res = await _jugadorService.listarJugadores();

    var yo = res['data'].firstWhere((j) => j['nombre'] == widget.nombreUsuario);

    await _salaEsperaServicio.eliminarJugador(yo['jugadorId']);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RegistroJugador()),
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
                Text_styles(text: "Esperando a los jugadores..."),

                const SizedBox(height: 25),

                Button_completo_styles(
                  text: "cancelar",
                  assetIcon: "assets/icon/Close.png",
                  onPressed: _cancelarRegistro,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hubConnection.stop(); // Limpiar conexión al salir
    super.dispose();
  }
}
