import 'package:flutter/material.dart';
import 'package:monopoly_app/pantalla/sala_jugador/SalaJugador.dart';
import 'package:monopoly_app/servicio/PropiJugadorServicio.dart';
import 'package:monopoly_app/servicio/PropiedadServicio.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';
import 'package:monopoly_app/util/helpers/MensajeHelper.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class PropiedadesController {
  final Propiedadservicio _servicio = Propiedadservicio();
  final PropiJugadorServicio _propiJugadorServicio = PropiJugadorServicio();
  late HubConnection hubConnection;

  // --- INICIALIZAR SIGNALR ---
  void initSignalR() {
    hubConnection = HubConnectionBuilder().withUrl(ApiConst.ws).build();
    hubConnection.start();
  }

  // --- OBTENER PROPIEDADES SEGÚN MODO ---
  Future<List<dynamic>> obtenerPropiedades({
    required bool isComprar,
    required int jugadorId,
  }) async {
    final int idConsulta = (isComprar == true) ? 0 : jugadorId;
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
    final int precio = propiedadActual['precio'] ?? 0;

    if (hubConnection.state != HubConnectionState.Connected) {
      await hubConnection.start();
    }

    if (hubConnection.state == HubConnectionState.Connected) {
      await hubConnection.invoke(
        "EnviarSolicitudCompra",
        args: [jugadorId, propiedadId, nombreJugador, precio, mensajeSolicitud],
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

  // --- ACCIONES Y BOTONES ---
  Future<void> adquirirOMejorarPropiedad({
    required BuildContext context,
    required int jugadorId,
    required int propiedadId,
    required int precio,
  }) async {
    final res = await _propiJugadorServicio.AdquirirOMejorarPropiedad(
      jugadorId,
      propiedadId,
      precio,
    );

    if (res['statusCode'] == 201) {
      MensajeHelper.mostrarResultado(context, res);
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      MensajeHelper.mostrarResultado(context, res);
    }
  }
}
