import 'package:flutter/material.dart';
import 'package:monopoly_app/pantalla/registro_jugador/RegistroJugador.dart';
import 'package:monopoly_app/pantalla/sala_jugador/SalaJugador.dart';
import 'package:monopoly_app/servicio/JugadorServicio.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class SalaEsperaController {
  final JugadorServicio _jugadorServicio = JugadorServicio();

  late HubConnection hubConnection;
  final String nombreUsuario;

  SalaEsperaController({required this.nombreUsuario});

  /// Inicializa la conexión de SignalR y define los escuchadores de eventos
  Future<void> initSignalR({
    required VoidCallback onListaActualizada,
    required VoidCallback onPartidaIniciada,
    required VoidCallback onConvertidoEnBanco,
  }) async {
    hubConnection = HubConnectionBuilder().withUrl(ApiConst.ws).build();

    hubConnection.onclose(({error}) => debugPrint("Conexión SignalR perdida"));

    // Evento: actualizar lista
    hubConnection.on("actulizar_lista_jugador", (arguments) async {
      onListaActualizada();
      await verificarNuevoRol(onConvertidoEnBanco);
    });

    // Evento: partida iniciada
    hubConnection.on("partida_iniciada", (arguments) {
      onPartidaIniciada();
    });

    await hubConnection.start();
  }

  /// Carga la lista de jugadores desde el servicio
  Future<List<dynamic>> cargarJugadores() async {
    final res = await _jugadorServicio.listarJugadores();
    if (res['statusCode'] == 200) {
      return res['data'] ?? [];
    }
    return [];
  }

  /// Cancela el registro del jugador y lo regresa a la pantalla de Registro
  Future<void> cancelarRegistro(BuildContext context) async {
    try {
      final res = await _jugadorServicio.listarJugadores();
      if (res['statusCode'] == 200) {
        List lista = res['data'];
        var yo = lista.firstWhere(
          (j) => j['nombre'] == nombreUsuario,
          orElse: () => null,
        );

        if (yo != null) {
          await _jugadorServicio.eliminarJugador(yo['jugadorId']);
        }
      }
    } catch (e) {
      debugPrint("Error al cancelar registro: $e");
    } finally {
      await dispose(); // Apagar la conexión antes de salir
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegistroJugador()),
        );
      }
    }
  }

  /// Invoca el inicio de la partida en el servidor (Solo para el Banco)
  Future<void> iniciarPartida() async {
    try {
      await hubConnection.invoke("IniciarJuego");
    } catch (e) {
      debugPrint("Error al iniciar partida: $e");
    }
  }

  /// Redirecciona al jugador a su tablero de juego principal
  Future<void> navegarASalaJugador(BuildContext context) async {
    final res = await _jugadorServicio.listarJugadores();
    if (res['statusCode'] == 200 && context.mounted) {
      List lista = res['data'];
      var yo = lista.firstWhere(
        (j) => j['nombre'] == nombreUsuario,
        orElse: () => null,
      );
      if (yo != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Salajugador(datosJugador: yo),
          ),
        );
      }
    }
  }

  /// Verifica si el rol actual cambió a Banco para realizar el salto automático
  Future<void> verificarNuevoRol(VoidCallback onConvertidoEnBanco) async {
    final res = await _jugadorServicio.listarJugadores();
    if (res['statusCode'] == 200) {
      List lista = res['data'];
      var yo = lista.firstWhere(
        (j) => j['nombre'] == nombreUsuario,
        orElse: () => null,
      );

      if (yo != null && yo['esBanco'] == true) {
        onConvertidoEnBanco();
      }
    }
  }

  /// Limpia y cierra recursos de SignalR
  Future<void> dispose() async {
    try {
      await hubConnection.stop();
    } catch (e) {
      debugPrint("Error al detener SignalR: $e");
    }
  }
}
