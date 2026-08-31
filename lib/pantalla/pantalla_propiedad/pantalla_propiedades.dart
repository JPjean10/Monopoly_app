import 'package:flutter/material.dart';
import 'package:monopoly_app/componentes/button/button_styles.dart';
import 'package:monopoly_app/componentes/text_field/textfield_bucador_num_styles.dart';
import 'package:monopoly_app/controladores/propiedades_controller.dart';
import 'package:monopoly_app/pantalla/pantalla_subasta/pantalla_subasta.dart';

class PantallaPropiedades extends StatefulWidget {
  final Map<String, dynamic> datosJugador;
  final int descuento;
  final bool isComprar;
  final bool isSolicitud;
  final bool? isSubasta;
  final int? idDescuento;

  const PantallaPropiedades({
    super.key,
    required this.datosJugador,
    required this.descuento,
    required this.isComprar,
    required this.isSolicitud,
    this.isSubasta,
    this.idDescuento,
  });

  @override
  State<PantallaPropiedades> createState() => _PantallaPropiedadesState();
}

class _PantallaPropiedadesState extends State<PantallaPropiedades> {
  final PropiedadesController _controller = PropiedadesController();
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();

  List<dynamic> _todasLasPropiedades = [];
  List<dynamic> _propiedadesFiltradas = [];
  bool _cargando = true;
  int _indiceActual = 0;

  @override
  void initState() {
    super.initState();
    _controller.initSignalR();
    _cargarPropiedades();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _cargarPropiedades() async {
    final int jugadorId = widget.datosJugador['jugadorId'] ?? 0;
    final int descuento = widget.descuento;
    final propiedades = await _controller.obtenerPropiedades(
      isComprar: widget.isComprar,
      jugadorId: jugadorId,
      descuento: descuento,
    );

    if (mounted) {
      setState(() {
        _todasLasPropiedades = propiedades;
        _propiedadesFiltradas = propiedades;
        _cargando = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _propiedadesFiltradas = _controller.filtrarPorId(
        query: query,
        listaOriginal: _todasLasPropiedades,
      );
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
                    child: TextFieldBuscadorNumStyles(
                      hintText: "Escribe el ID de la propiedad...",
                      controller: _searchController,
                      onChanged: _onSearchChanged,
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
                            controller: _pageController,
                            itemCount: _propiedadesFiltradas.length,
                            onPageChanged: (index) {
                              setState(() {
                                _indiceActual = index;
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
                                      padding: const EdgeInsets.all(20),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                              spreadRadius: 2,
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
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
                                      color: Colors.blue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: widget.descuento > 0
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "S/ ${prop['precio']}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey,
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                "VALOR: S/ ${prop['precio_descuento']}",
                                                style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(
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
                      bottom: 10.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: ButtonStyles(
                            text: "regresar",
                            assetIcon: 'assets/icon/Return.png',
                            isEnabled: true,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: ButtonStyles(
                            text: widget.isComprar == true
                                ? "comprar"
                                : "subir nivel",
                            assetIcon: widget.isComprar == true
                                ? 'assets/icon/home_purchase.png'
                                : 'assets/icon/dwelling-level-up.png',
                            isEnabled: true,
                            onPressed: () {
                              if (_propiedadesFiltradas.isNotEmpty) {
                                final propActual =
                                    _propiedadesFiltradas[_indiceActual];
                                final int propiedadId =
                                    _propiedadesFiltradas[_indiceActual]['propiedadId'] ??
                                    0;
                                final int jugadorId =
                                    widget.datosJugador['jugadorId'] ?? 0;

                                if (widget.isSolicitud == true) {
                                  _controller.solicitarCompraONivel(
                                    context: context,
                                    datosJugador: widget.datosJugador,
                                    propiedadActual: propActual,
                                    descuento: widget.descuento,
                                    idDescuento: widget.idDescuento ?? 0,
                                  );
                                } else if (widget.isSubasta == true) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PantallaSubasta(
                                        datosJugador: widget.datosJugador,
                                        propieadadId: propiedadId,
                                        nombrePropiedad:
                                            _propiedadesFiltradas[_indiceActual]['nombre'],
                                      ),
                                    ),
                                  );
                                } else {
                                  _controller.adquirirOMejorarPropiedad(
                                    context: context,
                                    jugadorId: jugadorId,
                                    propiedadId: propiedadId,
                                    descuento: widget.descuento,
                                  );
                                }
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
}
