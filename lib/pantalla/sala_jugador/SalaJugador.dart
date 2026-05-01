import 'package:flutter/material.dart';
import 'package:monopoly_app/componentes/button/Button_styles.dart';
import 'package:monopoly_app/pantalla/pantalla_propiedad/PantallaPropiedades.dart';
import 'package:monopoly_app/pantalla/sala_jugador/servicio/SalaJugadorServicio.dart';
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

  @override
  void initState() {
    super.initState();
    _datosJugadorActual = widget.datosJugador;
    _initSignalR();
    _cargarDatosServidor();
  }

  // MÉTODO PARA CARGAR/REFRESCAR DESDE EL PROCEDIMIENTO ALMACENADO
  Future<void> _cargarDatosServidor() async {
    int id =
        _datosJugadorActual?['jugadorId'] ?? widget.datosJugador['jugadorId'];
    final nuevosDatos = await _salaServicio.obtenerDetalleJugador(id);
    if (nuevosDatos != null) {
      setState(() {
        _datosJugadorActual = nuevosDatos;
      });
    }
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

    // LISTENER PARA RECARGAR DATOS TRAS COMPRA EXITOSA
    _hubConnection.on("actualizar_datos_partida", (arguments) {
      int idComprador = arguments![0] as int;
      int miId =
          _datosJugadorActual?['jugadorId'] ?? widget.datosJugador['jugadorId'];

      // Si yo compré, recargo para ver mi nuevo saldo
      if (idComprador == miId) {
        _cargarDatosServidor();
      }
    });
    _hubConnection.start();
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
                // Navegar a pantalla de Perfil/Datos
                /*           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaDatosJugador(datos: widget.datosJugador),
            ),
          ); */
              } else if (value == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PantallaPropiedades(
                      datosJugador:
                          widget.datosJugador, // Pasas los datos que ya tienes
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
                value: 2,
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
                onPressed: () {},
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
    return const Center(child: Text("Pantalla de Notificaciones"));
  }
}
