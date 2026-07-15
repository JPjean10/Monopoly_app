import 'package:flutter/material.dart';
import 'package:monopoly_app/pantalla/pantalla_escaneo/PantallaEscaneo.dart';
import 'package:monopoly_app/pantalla/sala_jugador/PantallaBancarrota.dart';
import 'package:monopoly_app/pantalla/sala_jugador/model/PropiJugadorModel.dart';
import 'package:monopoly_app/servicio/SalaJugadorServicio.dart';
import 'package:monopoly_app/servicio/jugador_service.dart';
import 'package:monopoly_app/util/consts/ApiConst.dart';
import 'package:monopoly_app/util/helpers/MensajeHelper.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class SalaJugadorController {
  final Salajugadorservicio salaServicio = Salajugadorservicio();
  late HubConnection hubConnection;

  // --- SIGNALR ---
  void initSignalR({
    required Function(Map<String, dynamic> nuevaSolicitud) onNuevaSolicitud,
    required VoidCallback onActualizarDatos,
  }) {
    hubConnection = HubConnectionBuilder().withUrl(ApiConst.ws).build();

    hubConnection.onclose(({error}) => debugPrint("Conexión SignalR perdida"));

    hubConnection.on("nueva_solicitud_compra", (arguments) {
      if (arguments != null) {
        onNuevaSolicitud({
          'jugadorId': arguments[0] as int,
          'propiedadId': arguments[1] as int,
          'nombreJugador': arguments[2] as String,
          'mensajeSolicitud': arguments[3] as String,
        });
      }
    });

    hubConnection.on("actualizar_datos_partida", (arguments) {
      onActualizarDatos();
    });

    hubConnection.start();
  }

  // --- CARGA DE DATOS ---
  Future<Map<String, dynamic>?> refrescarDatosJugador({
    required BuildContext context,
    required int jugadorId,
  }) async {
    final nuevosDatos = await salaServicio.obtenerDetalleJugador(jugadorId);

    if (nuevosDatos != null) {
      int montoObtenido =
          int.tryParse(nuevosDatos['tarjeta']?['monto']?.toString() ?? '0') ??
          0;

      if (montoObtenido < 0 && context.mounted) {
        List<dynamic> propiedades = await salaServicio
            .obtenerPropiedadesJugador(jugadorId);

        final bool? solucionado = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaBancarrota(
              jugadorId: jugadorId,
              saldoNegativo: montoObtenido,
              propiedadesIniciales: propiedades,
            ),
          ),
        );

        if (solucionado == true && context.mounted) {
          return await refrescarDatosJugador(
            context: context,
            jugadorId: jugadorId,
          );
        }
      }
    }
    return nuevosDatos;
  }

  Future<List<dynamic>> cargarPropiedades(int jugadorId) async {
    return await salaServicio.obtenerPropiedadesJugador(jugadorId);
  }

  Future<List<dynamic>> cargarHistorial() async {
    return await salaServicio.obtenerHistorialCompras();
  }

  // --- ACCIONES Y BOTONES ---
  Future<void> procesarCobroRenta({
    required BuildContext context,
    required int jugadorId,
    required VoidCallback onSuccess,
  }) async {
    final resultadoQR = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PantallaEscaneo()),
    );

    if (resultadoQR != null && resultadoQR.toString().startsWith("COD|")) {
      final partes = resultadoQR.toString().split('|');

      final datosPropiedad = PropiJugadorModel(
        jugadorId: jugadorId,
        propiedadId: int.parse(partes[1]),
        nivelActual: int.parse(partes[2]),
      );

      final respuesta = await salaServicio.enviarCobroRenta(datosPropiedad);

      if (context.mounted) {
        MensajeHelper.mostrarResultado(context, respuesta);
        if (respuesta['statusCode'] == 201) {
          onSuccess();
        }
      }
    }
  }

  Future<bool> rechazarSolicitud({
    required Map<String, dynamic> solicitud,
  }) async {
    String mensaje = solicitud['mensajeSolicitud'].toString().toLowerCase();
    String tipoCompra = "desconocido";

    if (mensaje.contains("comprar")) {
      tipoCompra = "COMPRA";
    } else if (mensaje.contains("subir nivel")) {
      tipoCompra = "SUBIR NIVEL";
    }

    final res = await salaServicio.InsertHistorial(
      solicitud['jugadorId'],
      solicitud['propiedadId'],
      tipoCompra,
      "rechazado",
    );

    return res['statusCode'] == 201 || res['status'] == true;
  }

  Future<bool> aceptarSolicitud({
    required Map<String, dynamic> solicitud,
  }) async {
    final res = await salaServicio.ComprarPropiedad(
      solicitud['jugadorId'],
      solicitud['propiedadId'],
    );

    return res['statusCode'] == 201 ||
        res['statusCode'] == 401 ||
        res['status'] == true;
  }

  // --- VISTAS EMERGENTES ---
  void mostrarQrPropiedad(
    BuildContext context,
    int propiedadId,
    int nivel,
    String nombreProp,
  ) {
    final String qrData = "COD|$propiedadId|$nivel";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          "COBRAR RENTA\n${nombreProp.toUpperCase()}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: SizedBox(
          width: 220,
          height: 220,
          child: Center(
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              size: 200.0,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF24B9F9),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "CERRAR",
              style: TextStyle(color: Color(0xFF24B9F9)),
            ),
          ),
        ],
      ),
    );
  }

  // --- ACCIONES DE BANCO ---
  Future<bool> ejecutarAccionBanco({
    required String accion,
    required int jugadorDestinoId,
  }) async {
    // Agrega la llamada a tus endpoints según la acción seleccionada
    debugPrint("Ejecutando acción '$accion' para jugador $jugadorDestinoId");
    return true;
  }

  // --- OBTENER JUGADORES ---
  Future<List<Map<String, dynamic>>> obtenerListaJugadores() async {
    final response = await JugadorService().listarJugadores();
    if (response['statusCode'] == 200 && response['data'] != null) {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }
}
