import 'package:flutter/material.dart';
import 'package:monopoly_app/controladores/carta_trampa_controlador.dart';
import 'package:monopoly_app/controladores/sala_jugador_controller.dart';
import 'package:monopoly_app/pantalla/pantalla_carta_trampa/pantalla_carta_trampa.dart';
import 'package:monopoly_app/pantalla/pantalla_propiedad/pantalla_propiedades.dart';
import 'package:monopoly_app/pantalla/sala_jugador/cards/Item_Notificacion_card.dart';
import 'package:monopoly_app/pantalla/sala_jugador/cards/item_pago_card.dart';
import 'package:monopoly_app/pantalla/sala_jugador/cards/item_propiedad_card.dart';

class Salajugador extends StatefulWidget {
  final Map<String, dynamic> datosJugador;

  const Salajugador({super.key, required this.datosJugador});

  @override
  State<Salajugador> createState() => _SalajugadorState();
}

class _SalajugadorState extends State<Salajugador> {
  final SalaJugadorController _controller = SalaJugadorController();
  final TextEditingController idONombreText = TextEditingController();

  int _indiceActual = 0;
  bool _hayPagosPendientes = false;
  final List<Map<String, dynamic>> _solicitudesPendientes = [];
  Map<String, dynamic>? _datosJugadorActual;
  List<dynamic> _historialTransacciones = [];
  List<dynamic> _propiedadesJugador = [];

  @override
  void initState() {
    super.initState();
    _datosJugadorActual = widget.datosJugador;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarTodo();
    });

    _controller.initSignalR(
      onNuevaSolicitud: (nuevaSolicitud) {
        setState(() {
          _hayPagosPendientes = true;
          _solicitudesPendientes.add(nuevaSolicitud);
        });
      },
      onActualizarDatos: () {
        _cargarTodo();
      },
      onActualizarCartasTrampaJugador: () {
        _controller.listarCartasTrampaJugador(widget.datosJugador['jugadorId']);
      },
    );
  }

  @override
  void dispose() {
    idONombreText.dispose();
    super.dispose();
  }

  void _cargarTodo() async {
    int miId =
        _datosJugadorActual?['jugadorId'] ?? widget.datosJugador['jugadorId'];

    final nuevosDatos = await _controller.refrescarDatosJugador(
      context: context,
      jugadorId: miId,
    );
    final props = await _controller.cargarPropiedades(miId);
    final hist = await _controller.cargarHistorial();

    if (mounted) {
      setState(() {
        if (nuevosDatos != null) _datosJugadorActual = nuevosDatos;
        _propiedadesJugador = props;
        _historialTransacciones = hist;
      });
    }
  }

  void _onPropiedadTap(Map<String, dynamic> prop) {
    final int propId = prop['propiedadId'] ?? 0;
    if (propId != 0) {
      _controller.mostrarQrPropiedad(
        context,
        propId,
        prop['nivelActual'] ?? 1,
        prop['nombre'] ?? '',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: ID de propiedad no válido")),
      );
    }
  }

  void _mostrarOpcionesBanco(BuildContext context) {
    int? opcionBancoIdSeleccionada;
    String? nombreOpcionSeleccionada;
    List<Map<String, dynamic>> listaJugadores = [];
    bool cargandoJugadores = false;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            void seleccionarAccion(int opcionId, String nombreOpcion) async {
              setModalState(() {
                opcionBancoIdSeleccionada = opcionId;
                nombreOpcionSeleccionada = nombreOpcion;
                cargandoJugadores = true;
              });

              final jugadores = await _controller.obtenerListaJugadores();

              setModalState(() {
                listaJugadores = jugadores;
                cargandoJugadores = false;
              });
            }

            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- CABECERA CON BOTÓN REGRESAR ---
                  Row(
                    children: [
                      if (opcionBancoIdSeleccionada != null)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            setModalState(() {
                              opcionBancoIdSeleccionada = null;
                              nombreOpcionSeleccionada = null;
                            });
                          },
                        ),
                      Expanded(
                        child: Text(
                          opcionBancoIdSeleccionada == null
                              ? "Opciones de Banco"
                              : "Seleccionar Jugador ($nombreOpcionSeleccionada)",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // --- PASO 1: VISTA DE OPCIONES DE BANCO DINÁMICAS ---
                  if (opcionBancoIdSeleccionada == null)
                    FutureBuilder<Map<String, dynamic>>(
                      future: _controller.obtenerOpcionesBanco(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (!snapshot.hasData ||
                            snapshot.data?['status'] != true) {
                          return const Center(
                            child: Text("Error al cargar opciones"),
                          );
                        }

                        final List<dynamic> opciones =
                            snapshot.data!['data'] ?? [];

                        if (opciones.isEmpty) {
                          return const Center(
                            child: Text("No hay opciones disponibles"),
                          );
                        }

                        return Column(
                          children: opciones.map((opcion) {
                            final int opcionId = opcion['opcionBancoId'] ?? 0;
                            final String nombreOpcion =
                                opcion['nombre'] ?? opcion['titulo'] ?? '';

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: _buildOpcionBanco(
                                context: context,
                                icon: _controller.obtenerIconoOpcion(
                                  nombreOpcion,
                                ),
                                texto: nombreOpcion,
                                onTap: () =>
                                    seleccionarAccion(opcionId, nombreOpcion),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    )
                  // --- PASO 2: VISTA DE SELECCIÓN DE JUGADOR ---
                  else ...[
                    if (cargandoJugadores)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (listaJugadores.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text("No hay jugadores disponibles"),
                      )
                    else
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          itemCount: listaJugadores.length,
                          itemBuilder: (context, index) {
                            final jugador = listaJugadores[index];
                            final int jugadorId = jugador['jugadorId'] ?? 0;
                            final String nombreJugador =
                                jugador['nombre'] ?? 'Sin nombre';

                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: Text(nombreJugador),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                              ),
                              onTap: () async {
                                Navigator.pop(context);

                                await _controller.ejecutarAccionBanco(
                                  opcionBancoId: opcionBancoIdSeleccionada!,
                                  jugadorDestinoId: jugadorId,
                                  context: context,
                                );
                                _cargarTodo();
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarOpcionesCartasTrampa(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TÍTULO
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Color(0xFFD0D0D0), width: 1),
                  ),
                ),
                child: const Text(
                  "cartas trampa",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
              ),

              ListTile(
                title: const Text(
                  "Ver inventario",
                  style: TextStyle(fontSize: 18),
                ),
                trailing: const Icon(Icons.inventory_2_outlined),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PantallaCartaTrampa(
                        datosJugador: _datosJugadorActual!,
                        mostrarInventario: true,
                        onContinuar: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              ),

              // OPCIÓN: CASUALIDAD
              ListTile(
                title: const Text("casualidad", style: TextStyle(fontSize: 18)),
                trailing: Image.asset('assets/icon/cards.png', width: 30),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PantallaCartaTrampa(
                        datosJugador: _datosJugadorActual!,
                        onContinuar: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 5),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOpcionBanco({
    required BuildContext context,
    required IconData icon,
    required String texto,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[700], size: 22),
            const SizedBox(width: 16),
            Text(
              texto,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_datosJugadorActual == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    bool esBanco = _datosJugadorActual!['esBanco'] ?? false;
    String nombre = _datosJugadorActual!['nombre'] ?? "Sin nombre";
    var monto = _datosJugadorActual!['tarjeta']?['monto'] ?? 0;

    Widget cuerpoPantalla;
    switch (_indiceActual) {
      case 0:
        cuerpoPantalla = _buildInicio(nombre, monto, esBanco);
        break;
      case 1:
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
            icon: Image.asset(
              'assets/icon/menu.png',
              width: 30,
              color: Colors.white,
            ),
            offset: const Offset(0, 50),
            onSelected: (value) {
              bool isComprar = value == 1 ? true : false;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaPropiedades(
                    datosJugador: _datosJugadorActual!,
                    descuento: 0,
                    isComprar: isComprar,
                    isSolicitud:
                        true, // Indica que es una solicitud de subir nivel
                  ),
                ),
              );
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Row(
                  children: [SizedBox(width: 10), Text("Subir nivel de renta")],
                ),
              ),
              const PopupMenuItem(
                value: 1,
                child: Row(children: [SizedBox(width: 10), Text("propiedad")]),
              ),
            ],
          ),
        ],
      ),
      body: cuerpoPantalla,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (int index) => setState(() => _indiceActual = index),
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
                isLabelVisible: _hayPagosPendientes,
                label: Text('${_solicitudesPendientes.length}'),
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

  Widget _buildInicio(String nombre, dynamic monto, bool esBanco) {
    int miId =
        _datosJugadorActual?['jugadorId'] ?? widget.datosJugador['jugadorId'];

    return Column(
      children: [
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              IconButton(
                icon: Image.asset('assets/icon/rent.png', width: 30),
                onPressed: () {
                  _controller.procesarCobroRenta(
                    context: context,
                    jugadorId: miId,
                    onSuccess: _cargarTodo,
                  );
                },
              ),
              const SizedBox(width: 25),
              IconButton(
                icon: Image.asset('assets/icon/cards.png', width: 30),
                onPressed: () => _mostrarOpcionesCartasTrampa(context),
              ),
              const Spacer(),
              if (esBanco)
                IconButton(
                  icon: Image.asset('assets/icon/bank.png', width: 30),
                  onPressed: () => _mostrarOpcionesBanco(context),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const SizedBox(height: 20),
        Expanded(
          child: _propiedadesJugador.isEmpty
              ? const Center(child: Text("No tienes propiedades aún"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  itemCount: _propiedadesJugador.length,
                  itemBuilder: (context, i) => ItemPropiedadCard(
                    propiedad: _propiedadesJugador[i],
                    onTap: () => _onPropiedadTap(_propiedadesJugador[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPagos() {
    if (_solicitudesPendientes.isEmpty) {
      return const Center(child: Text("No solicitudes pendientes"));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      itemCount: _solicitudesPendientes.length,
      itemBuilder: (context, index) {
        final solicitud = _solicitudesPendientes[index];
        return ItemPagoCard(
          solicitud: solicitud,
          onCancelar: () async {
            bool exito = await _controller.rechazarSolicitud(
              solicitud: solicitud,
            );

            if (exito && mounted) {
              setState(() {
                _solicitudesPendientes.removeAt(index);
                if (_solicitudesPendientes.isEmpty) {
                  _hayPagosPendientes = false;
                }
              });
              _controller.cargarHistorial().then((hist) {
                if (mounted) setState(() => _historialTransacciones = hist);
              });
            }
          },
          onAceptar: () async {
            bool exito = await _controller.aceptarSolicitud(
              solicitud: solicitud,
            );

            if (exito && mounted) {
              setState(() {
                _solicitudesPendientes.removeAt(index);
                if (_solicitudesPendientes.isEmpty) {
                  _hayPagosPendientes = false;
                }
              });
              _controller.cargarHistorial().then((hist) {
                if (mounted) setState(() => _historialTransacciones = hist);
              });
            }
          },
        );
      },
    );
  }

  Widget _buildNotificaciones() {
    if (_historialTransacciones.isEmpty) {
      return const Center(child: Text("No hay actividad reciente"));
    }

    return RefreshIndicator(
      onRefresh: () async {
        final hist = await _controller.cargarHistorial();
        if (mounted) setState(() => _historialTransacciones = hist);
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        itemCount: _historialTransacciones.length,
        itemBuilder: (context, index) =>
            ItemNotificacionCard(notificacion: _historialTransacciones[index]),
      ),
    );
  }
}
