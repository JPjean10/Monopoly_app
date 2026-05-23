import 'package:flutter/material.dart';
import 'package:monopoly_app/componentes/button/Button_styles.dart';
import 'package:monopoly_app/pantalla/pantalla_escaneo/PantallaEscaneo.dart';
import 'package:monopoly_app/pantalla/pantalla_propiedad/PantallaPropiedades.dart';
import 'package:monopoly_app/pantalla/sala_jugador/PantallaBancarrota.dart';
import 'package:monopoly_app/pantalla/sala_jugador/model/PropiJugadorModel.dart';
import 'package:monopoly_app/pantalla/sala_jugador/servicio/SalaJugadorServicio.dart';
import 'package:monopoly_app/util/helpers/MensajeHelper.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class Salajugador extends StatefulWidget {
  final Map<String, dynamic> datosJugador;

  const Salajugador({super.key, required this.datosJugador});

  @override
  State<Salajugador> createState() => _SalajugadorState();
}

class _SalajugadorState extends State<Salajugador> {
  // Variable para controlar qué pantalla se muestra
  int _indiceActual = 0;
  bool _hayPagosPendientes = false;
  List<Map<String, dynamic>> _solicitudesPendientes = [];
  late HubConnection _hubConnection;
  final Salajugadorservicio _salaServicio = Salajugadorservicio();
  Map<String, dynamic>? _datosJugadorActual;
  List<dynamic> _historialTransacciones = [];
  List<dynamic> _propiedadesJugador = [];
  final List<int> _propiedadesSeleccionadasIds = [];
  int _vueltoCalculado = 0;
  bool _cargandoPropiedades = false;
  int _montoActual = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refrescarDatosJugador();
    });
    _datosJugadorActual = widget.datosJugador;
    _montoActual = widget.datosJugador['monto'] ?? 0;
    _initSignalR();
    _cargarDatosServidor();
    _cargarHistorial();
  }

  void _actualizarVueltoProyectado() {
    int saldoActual =
        _datosJugadorActual?['monto'] ?? widget.datosJugador['monto'] ?? 0;
    int acumuladoVenta = 0;

    for (var item in _propiedadesJugador) {
      final propiedad = item['propiedad'];
      final int propId = item['propiedadId'] ?? 0;
      if (_propiedadesSeleccionadasIds.contains(propId) && propiedad != null) {
        acumuladoVenta += (propiedad['precio'] as int? ?? 0);
      }
    }

    setState(() {
      _vueltoCalculado = saldoActual + acumuladoVenta;
    });
  }

  void _cargarDatosServidor() async {
    setState(() {
      _cargandoPropiedades = true;
    });

    int miId =
        _datosJugadorActual?['jugadorId'] ?? widget.datosJugador['jugadorId'];
    final datosRefresh = await _salaServicio.obtenerDetalleJugador(miId);

    if (datosRefresh != null) {
      setState(() {
        _datosJugadorActual = datosRefresh;
      });
    }

    final propiedades = await _salaServicio.obtenerPropiedadesJugador(miId);
    setState(() {
      _propiedadesJugador = propiedades;
      _cargandoPropiedades = false;
    });
  }

  Future<void> _cargarHistorial() async {
    final lista = await _salaServicio.obtenerHistorialCompras();
    setState(() {
      _historialTransacciones = lista;
    });
  }

  void _initSignalR() async {
    // 1. Inicialización obligatoria
    _hubConnection = HubConnectionBuilder()
        .withUrl(
          "http://192.168.1.100:8080/gamehub",
        ) // Debe coincidir con tu Program.cs
        .build();

    // En el initState de Salajugador:
    _hubConnection.on("nueva_solicitud_compra", (arguments) {
      setState(() {
        _hayPagosPendientes = true;
        _solicitudesPendientes.add({
          'jugadorId': arguments![0] as int,
          'propiedadId': arguments[1] as int,
          'nombreJugador': arguments[2] as String, // Nuevo
          'mensajeSolicitud': arguments[3] as String, // Nuevo
        });
      });
    });

    // LISTENER SIMPLIFICADO: Cuando el backend grita "actualizar_datos_partida"
    _hubConnection.on("actualizar_datos_partida", (List<Object?>? arguments) {
      print("🔔 SignalR: Alerta global recibida (Argumento: $arguments).");

      // No importa quién inició la acción, yo voy a SQL a traer mi saldo actualizado
      print("🔄 Refrescando mis datos locales desde la base de datos...");
      _refrescarDatosJugador();
      _cargarDatosServidor();
      _cargarHistorial();
    });

    _hubConnection.start();
  }

  // --- FUNCIÓN PARA MOSTRAR EL QR (LÓGICA DEL DUEÑO) ---
  void _mostrarQrPropiedad(int propiedadId, int nivel, String nombreProp) {
    // El formato exacto es "COD|propiedadId|nivel"
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

  Future<void> _refrescarDatosJugador() async {
    int miJugadorId = widget.datosJugador['jugadorId'] ?? 0;

    // 1. Llama al endpoint de tu SP sp_ObtenerDetalleJugador
    final nuevosDatos = await _salaServicio.obtenerDetalleJugador(miJugadorId);

    if (nuevosDatos != null) {
      // Convertimos el monto que viene de SQL a un entero de Dart
      int montoObtenido =
          int.tryParse(nuevosDatos!['tarjeta']['monto'].toString()) ?? 0;

      print("💰 Saldo real detectado: $montoObtenido");

      // 2. ¡EL FILTRO DE INTERRUPCIÓN!
      if (montoObtenido < 0) {
        print("🚨 ¡Saldo menor a cero! Interrumpiendo al jugador...");

        // Traemos sus propiedades directo de la base de datos
        List<dynamic> propiedades = await _salaServicio
            .obtenerPropiedadesJugador(miJugadorId);

        if (mounted) {
          // Bloqueamos la interfaz mandándolo OBLIGATORIAMENTE a la otra pantalla
          final bool? solucionado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaBancarrota(
                jugadorId: miJugadorId,
                saldoNegativo: montoObtenido, // Pasa el -200
                propiedadesIniciales: propiedades,
              ),
            ),
          );

          // Si el jugador vende/hipoteca con éxito y sale de números negativos:
          if (solucionado == true) {
            print("✅ Salió de la quiebra. Re-verificando saldo positivo...");
            _refrescarDatosJugador(); // Refresca para pintar su nuevo saldo en el Header
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_datosJugadorActual == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Extraemos de la variable local, NO del widget.datosJugador
    bool esBanco = _datosJugadorActual!['esBanco'] ?? false;
    String nombre = _datosJugadorActual!['nombre'] ?? "Sin nombre";
    var monto = _datosJugadorActual!['tarjeta']?['monto'] ?? 0;
    // --- LÓGICA PARA CAMBIAR DE PANTALLA ---
    // Definimos las pantallas disponibles
    Widget cuerpoPantalla;
    switch (_indiceActual) {
      case 0:
        cuerpoPantalla = _buildInicio(nombre, monto, esBanco);
        break;
      case 1:
        // Si es banco, el índice 1 es Pagos. Si no, es Notificaciones.
        cuerpoPantalla = esBanco ? _buildPagos() : _buildNotificaciones();
        break;
      case 2:
        cuerpoPantalla = _buildNotificaciones();
        break;
      default:
        cuerpoPantalla = _buildInicio(nombre, monto, esBanco);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Monopoly",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF24B9F9),
        actions: [
          PopupMenuButton<int>(
            // Icono del menú
            icon: Image.asset(
              'assets/icon/menu.png',
              width: 30,
              color: Colors.white,
            ),
            // Posición para que baje un poco y no tape el icono
            offset: const Offset(0, 50),
            onSelected: (value) {
              if (value == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PantallaPropiedades(
                      datosJugador:
                          widget.datosJugador, // Pasas los datos que ya tienes
                      value: 1,
                    ),
                  ),
                );
              } else if (value == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PantallaPropiedades(
                      datosJugador:
                          widget.datosJugador, // Pasas los datos que ya tienes
                      value: 0,
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [SizedBox(width: 10), Text("Subir nivel de renta")],
                ),
              ),
              const PopupMenuItem(
                value: 0,
                child: Row(children: [SizedBox(width: 10), Text("propiedad")]),
              ),
            ],
          ),
        ],
      ),
      body: cuerpoPantalla,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (int index) {
          setState(() {
            _indiceActual = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF24B9F9),
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/icon/home_page.png', width: 24),
            label: 'Principal',
          ),
          if (esBanco)
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible:
                    _hayPagosPendientes, // Esta es la propiedad correcta en Material 3
                label: Text(
                  '${_solicitudesPendientes.length}',
                ), // Muestra el número de notificaciones
                child: Image.asset(
                  'assets/icon/payment_confirmation.png',
                  width: 24,
                ),
              ),
              label: 'confirmar pagos',
            ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icon/push_notifications.png', width: 24),
            label: 'Notificaciones',
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE LAS DIFERENTES PANTALLAS ---

  Widget _buildInicio(String nombre, dynamic monto, bool esBanco) {
    return Column(
      children: [
        // Encabezado con Nombre y Monto
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                nombre,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("S/ $monto", style: const TextStyle(fontSize: 24)),
            ],
          ),
        ),

        // Fila de botones de acción
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              // Botón Rent
              IconButton(
                icon: Image.asset('assets/icon/rent.png', width: 30),
                onPressed: () async {
                  // 1. Navegamos a la pantalla de escaneo que ya tienes lista
                  final resultadoQR = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PantallaEscaneo(),
                    ),
                  );

                  // Obtenemos TU ID (el jugador que está escaneando)
                  int miId =
                      _datosJugadorActual?['jugadorId'] ??
                      widget.datosJugador['jugadorId'];

                  // 2. Verificamos que el código tenga el formato esperado "COD|cobradorId|propId|nivel"
                  if (resultadoQR != null &&
                      resultadoQR.toString().startsWith("COD|")) {
                    final partes = resultadoQR.toString().split('|');

                    // Creamos el modelo para enviarlo al backend[cite: 8]
                    final datosPropiedad = PropiJugadorModel(
                      jugadorId: miId, // <--- Aquí pones TU ID (el que escanea)
                      propiedadId: int.parse(partes[1]), // ID de la Propiedad
                      nivelActual: int.parse(
                        partes[2],
                      ), // Nivel de la renta (Casa/Hotel)
                    );

                    // 4. EJECUCIÓN REAL DEL SERVICIO
                    final respuesta = await _salaServicio.enviarCobroRenta(
                      datosPropiedad,
                    );

                    // 5. Manejo de respuesta
                    if (mounted) {
                      MensajeHelper.mostrarResultado(context, respuesta);

                      if (respuesta['statusCode'] == 201) {
                        // Refrescamos datos locales tras el pago exitoso
                        _cargarDatosServidor();
                        _cargarHistorial();
                      }
                    }
                  }
                },
              ),

              // ESPACIO ENTRE RENT Y CARDS (Aumentado)
              const SizedBox(width: 25),

              // Botón Cards
              IconButton(
                icon: Image.asset('assets/icon/cards.png', width: 30),
                onPressed: () {},
              ),

              // Este widget empuja lo que sigue hacia la derecha
              const Spacer(),

              // Botón Bank (Solo si es banco, alineado a la derecha)
              if (esBanco)
                IconButton(
                  icon: Image.asset('assets/icon/bank.png', width: 30),
                  onPressed: () {},
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Expanded(
          child: _propiedadesJugador.isEmpty
              ? const Center(child: Text("No tienes propiedades aún"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: _propiedadesJugador.length,
                  itemBuilder: (context, index) {
                    final prop = _propiedadesJugador[index];

                    // 1. EXTRAER VALORES CON SEGURIDAD (Soporta minúsculas y mayúsculas)
                    final int propId = prop['propiedadId'];
                    final int nivel = prop['nivelActual'];
                    final String nombre = prop['nombre'];
                    final int renta = prop['renta'];
                    final int precioCompra = prop['propiedad']['precio'];

                    return GestureDetector(
                      // AL PRESIONAR: Levantamos el QR de forma segura
                      onTap: () {
                        if (propId != 0) {
                          _mostrarQrPropiedad(propId, nivel, nombre);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Error: ID de propiedad no válido"),
                            ),
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(3, 3),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Text(
                                nombre.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "NIVEL: $nivel",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  Text(
                                    "RENTA: $renta",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPagos() {
    if (_solicitudesPendientes.isEmpty) {
      return const Center(child: Text("No hay pagos pendientes"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: _solicitudesPendientes.length,
      itemBuilder: (context, index) {
        final solicitud = _solicitudesPendientes[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información del Jugador y Propiedad
                Text(
                  solicitud['nombreJugador'] ?? "Jugador",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${solicitud['mensajeSolicitud']}",
                  style: const TextStyle(color: Colors.black87, fontSize: 15),
                ),
                const SizedBox(height: 15), // Espacio antes de los botones
                // FILA DE BOTONES
                Row(
                  children: [
                    // Botón RECHAZAR
                    Expanded(
                      child: Button_styles(
                        text: "cancelar",
                        assetIcon: 'assets/icon/Cancel.png',
                        isEnabled: true,
                        onPressed: () async {
                          // 1. EXTRAER EL TIPO DE COMPRA
                          String mensaje = solicitud['mensajeSolicitud']
                              .toString()
                              .toLowerCase();
                          String tipoCompra = "";

                          if (mensaje.contains("comprar")) {
                            tipoCompra = "comprar";
                          } else if (mensaje.contains("subir nivel")) {
                            tipoCompra = "subir nivel";
                          } else {
                            tipoCompra = "desconocido";
                          }

                          // 2. LLAMAR AL SERVICIO
                          final res = await _salaServicio.InsertHistorial(
                            solicitud['jugadorId'], // Extraído de la solicitud
                            solicitud['propiedadId'], // Extraído de la solicitud
                            tipoCompra, // "comprar" o "subir nivel"
                            "rechazado", // Estado fijo al cancelar
                          );

                          // 3. ACTUALIZAR UI (Quitar de la lista local)
                          if (res['statusCode'] == 201 ||
                              res['status'] == true) {
                            setState(() {
                              _solicitudesPendientes.removeAt(index);
                              if (_solicitudesPendientes.isEmpty) {
                                _hayPagosPendientes = false;
                              }
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Solicitud rechazada e historial guardado",
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10), // Espacio entre botones
                    // Botón APROBAR
                    Expanded(
                      child: Button_styles(
                        text: "aceptar",
                        assetIcon: 'assets/icon/Done.png',
                        isEnabled: true,
                        onPressed: () async {
                          final res = await _salaServicio.ComprarPropiedad(
                            solicitud['jugadorId'],
                            solicitud['propiedadId'],
                          );

                          // 3. ACTUALIZAR UI (Quitar de la lista local)
                          if (res['statusCode'] == 201 ||
                              res['status'] == true) {
                            setState(() {
                              _solicitudesPendientes.removeAt(index);
                              if (_solicitudesPendientes.isEmpty) {
                                _hayPagosPendientes = false;
                                _cargarHistorial();
                              }
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificaciones() {
    if (_historialTransacciones.isEmpty) {
      return const Center(child: Text("No hay actividad reciente"));
    }

    return RefreshIndicator(
      onRefresh:
          _cargarHistorial, // Llamada directa a cargar historial[cite: 18, 19]
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: _historialTransacciones.length,
        itemBuilder: (context, index) {
          final item = _historialTransacciones[index];

          // Mapeo de datos del modelo[cite: 12, 14]
          String tipoEstado = "${item['tipoCompra']}: ${item['estado']}"
              .toLowerCase();
          String propietario = "propietario: ${item['nombreJugador']}"
              .toLowerCase();
          String propiedad = "propiedad: ${item['nombrePropiedad']}"
              .toUpperCase();
          String mensaje = item['mensage'] ?? "";

          return Card(
            elevation: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Bordes redondeados
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tipoEstado,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    propietario,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    propiedad,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                  // Mensaje dinámico debajo de la propiedad
                  if (mensaje.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      "mensaje: $mensaje",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
