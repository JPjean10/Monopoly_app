import 'package:flutter/material.dart';
import 'package:monopoly_app/pantalla/sala_jugador/SalaJugador.dart';
import 'package:monopoly_app/servicio/PropiedadServicio.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class PropiedadesController {
  final Propiedadservicio _servicio = Propiedadservicio();
  late HubConnection hubConnection;

  // --- INICIALIZAR SIGNALR ---
  void initSignalR() {
    hubConnection = HubConnectionBuilder().withUrl(ApiConst.ws).build();
    hubConnection.start();
  }

  // --- OBTENER PROPIEDADES SEGÚN MODO ---
  Future<List<dynamic>> obtenerPropiedades({
    required int value,
    required int jugadorId,
  }) async {
    final int idConsulta = (value == 1) ? jugadorId : 0;
    final res = await _servicio.listarPropiedad(idConsulta);

    if (res['statusCode'] == 200 && res['data'] != null) {
      return res['data'];
    }
    return [];
  }

  // --- LÓGICA DE FILTRADO ---
  List<dynamic> filtrarPorId({
    required String query,
    required List<dynamic> listaOriginal,
  }) {
    if (query.trim().isEmpty) {
      return listaOriginal;
    }
    return listaOriginal
        .where((p) => p['propiedadId'].toString() == query.trim())
        .toList();
  }

  // --- ENVIAR SOLICITUD AL BANCO ---
  Future<void> solicitarCompraONivel({
    required BuildContext context,
    required Map<String, dynamic> datosJugador,
    required Map<String, dynamic> propiedadActual,
  }) async {
    final int jugadorId = datosJugador['jugadorId'];
    final String nombreJugador = datosJugador['nombre'] ?? '';
    final int propiedadId = propiedadActual['propiedadId'];
    final String nombrePropiedad = propiedadActual['nombre'] ?? '';
    final String mensajeSolicitud = "solicita comprar $nombrePropiedad";

    if (hubConnection.state == HubConnectionState.Connected) {
      await hubConnection.invoke(
        "EnviarSolicitudCompra",
        args: [jugadorId, propiedadId, nombreJugador, mensajeSolicitud],
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Solicitud enviada al banco...")),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sin conexión con el servidor de la partida."),
          ),
        );
      }
    }
  }
}
