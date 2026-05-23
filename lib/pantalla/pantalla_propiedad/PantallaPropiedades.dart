import 'package:flutter/material.dart';
import 'package:monopoly_app/componentes/button/Button_styles.dart';
import 'package:monopoly_app/componentes/text_field/TextField_bucador_num_Styles.dart';
import 'package:monopoly_app/pantalla/pantalla_propiedad/servicio/PropiedadServicio.dart';
import 'package:signalr_netcore/hub_connection.dart';
import 'package:signalr_netcore/hub_connection_builder.dart';

class PantallaPropiedades extends StatefulWidget {
  final Map<String, dynamic> datosJugador;
  final int value; // Agregamos el nuevo parámetro

  const PantallaPropiedades({
    super.key,
    required this.datosJugador,
    required this.value,
  });

  @override
  State<PantallaPropiedades> createState() => _PantallaPropiedadesState();
}

class _PantallaPropiedadesState extends State<PantallaPropiedades> {
  final Propiedadservicio _servicio = Propiedadservicio();
  final TextEditingController _searchController = TextEditingController();
  late HubConnection _hubConnection;
  List<dynamic> _todasLasPropiedades = [];
  List<dynamic> _propiedadesFiltradas = [];
  bool _cargando = true;
  final PageController _pageController = PageController();
  int _indiceActual = 0; // Esta variable guardará el índice real

  @override
  void initState() {
    super.initState();
    _initSignalR();
    _obtenerPropiedades();
  }

  void _initSignalR() {
    _hubConnection = HubConnectionBuilder()
        .withUrl(
          "http://192.168.1.100:8080/gamehub",
        ) // Usa la ruta de tu Program.cs
        .build();
    _hubConnection.start();
  }

  void _obtenerPropiedades() async {
    if (widget.value == 1) {
      // Si venimos de "Subir nivel de renta", filtramos solo las propiedades del jugador
      final int jugadorId = widget.datosJugador['jugadorId'];
      final res = await _servicio.listarPropiedad(jugadorId);
      if (res['statusCode'] == 200) {
        setState(() {
          _todasLasPropiedades = res['data'];
          _propiedadesFiltradas = _todasLasPropiedades;
          _cargando = false;
        });
      }
    } else {
      // Si venimos de "propiedad", mostramos todas las propiedades
      final res = await _servicio.listarPropiedad(0);
      if (res['statusCode'] == 200) {
        setState(() {
          _todasLasPropiedades = res['data'];
          _propiedadesFiltradas = _todasLasPropiedades;
          _cargando = false;
        });
      }
    }
  }

  void _filtrarPorId(String query) {
    setState(() {
      if (query.isEmpty) {
        _propiedadesFiltradas = _todasLasPropiedades;
      } else {
        _propiedadesFiltradas = _todasLasPropiedades
            .where((p) => p['propiedadId'].toString() == query)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String nombre = widget.datosJugador['nombre'] ?? "";
    final dynamic monto = widget.datosJugador['tarjeta']?['monto'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Propiedades", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF24B9F9),
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,
      ),
      // --- SOLUCIÓN: Envolver todo el body en un SafeArea ---
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  // 1. INFO JUGADOR
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          "Saldo: S/ $monto",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. BUSCADOR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField_bucador_num_Styles(
                      hintText: "Escribe el ID de la propiedad...",
                      controller: _searchController,
                      onChanged: _filtrarPorId,
                      assetIcon: 'assets/icon/search.png',
                    ),
                  ),

                  // 3. IMAGEN DE CARTA GRANDE
                  Expanded(
                    child: _propiedadesFiltradas.isEmpty
                        ? const Center(
                            child: Text("No se encontró la propiedad"),
                          )
                        : PageView.builder(
                            controller:
                                _pageController, // Asigna el controlador
                            itemCount: _propiedadesFiltradas.length,
                            onPageChanged: (index) {
                              setState(() {
                                _indiceActual =
                                    index; // Actualiza el índice cuando cambie la página
                              });
                            },
                            itemBuilder: (context, index) {
                              final prop = _propiedadesFiltradas[index];
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Imagen maximizada con SOMBRA
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                        20,
                                      ), // Espacio para que la sombra no se corte
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ), // Color de la sombra
                                              spreadRadius:
                                                  2, // Cuánto se extiende
                                              blurRadius:
                                                  15, // Qué tan difusa es
                                              offset: const Offset(
                                                0,
                                                8,
                                              ), // Posición (x, y)
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ), // Opcional: redondea bordes si la imagen tiene
                                          child: Image.asset(
                                            prop['direccion'],
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Precio resaltado abajo
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      "VALOR: S/ ${prop['precio']}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),

                  // 4. BOTONES DE ACCIÓN
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20.0,
                      top: 10.0,
                      bottom: 10.0, // Ajustamos el padding inferior
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Button_styles(
                            text: "regresar",
                            assetIcon: 'assets/icon/Return.png',
                            isEnabled: true,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Button_styles(
                            text: widget.value == 1 ? "subir nivel" : "comprar",
                            assetIcon: widget.value == 1
                                ? 'assets/icon/dwelling-level-up.png'
                                : 'assets/icon/home_purchase.png',
                            isEnabled: true,
                            onPressed: () async {
                              final propActual =
                                  _propiedadesFiltradas[_indiceActual];

                              // Extraemos los nombres además de los IDs
                              final int jugadorId =
                                  widget.datosJugador['jugadorId'];
                              final String nombreJugador = widget
                                  .datosJugador['nombre']; // Nombre del que compra
                              final int propiedadId = propActual['propiedadId'];
                              final String nombrePropiedad =
                                  propActual['nombre']; // Nombre de la avenida
                              final String mensajeSolicitud =
                                  "solicita comprar $nombrePropiedad";

                              if (_hubConnection.state ==
                                  HubConnectionState.Connected) {
                                // Enviamos 4 argumentos en lugar de 2
                                await _hubConnection.invoke(
                                  "EnviarSolicitudCompra",
                                  args: [
                                    jugadorId,
                                    propiedadId,
                                    nombreJugador,
                                    mensajeSolicitud,
                                  ],
                                );

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Solicitud enviada al banco...",
                                    ),
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
