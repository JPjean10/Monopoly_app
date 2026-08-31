import 'package:flutter/material.dart';
import 'package:monopoly_app/servicio/propi_jugador_servicio.dart';
import 'package:monopoly_app/servicio/propiedad_servicio.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';
import 'package:monopoly_app/util/helpers/mensaje_helper.dart';
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
    required int descuento,
  }) async {
    final int idConsulta = (isComprar == true) ? 0 : jugadorId;
    final res = await _servicio.listarPropiedad(idConsulta, descuento);

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
    required int descuento,
    required int idDescuento,
  }) async {
    final int jugadorId = datosJugador['jugadorId'];
    final String nombreJugador = datosJugador['nombre'] ?? '';
    final int propiedadId = propiedadActual['propiedadId'];
    final String nombrePropiedad = propiedadActual['nombre'] ?? '';
    final String mensajeSolicitud = "solicita comprar $nombrePropiedad";

    if (hubConnection.state != HubConnectionState.Connected) {
      await hubConnection.start();
    }
    if (hubConnection.state == HubConnectionState.Connected) {
      await hubConnection.invoke(
        "EnviarSolicitudCompra",
        args: [
          jugadorId,
          propiedadId,
          nombreJugador,
          mensajeSolicitud,
          descuento,
          idDescuento,
        ],
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
    required int descuento,
  }) async {
    final res = await _propiJugadorServicio.adquirirOMejorarPropiedad(
      jugadorId,
      propiedadId,
      descuento,
    );

    if (!context.mounted) return;

    if (res['statusCode'] == 201) {
      MensajeHelper.mostrarResultado(context, res);
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      MensajeHelper.mostrarResultado(context, res);
    }
  }
}
