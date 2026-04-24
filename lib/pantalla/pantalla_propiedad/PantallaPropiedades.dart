import 'package:flutter/material.dart';
import 'package:monopoly_app/componentes/button/Button_styles.dart';
import 'package:monopoly_app/componentes/text_field/TextField_bucador_num_Styles.dart';
import 'package:monopoly_app/pantalla/pantalla_propiedad/servicio/PropiedadServicio.dart';

class PantallaPropiedades extends StatefulWidget {
  final Map<String, dynamic> datosJugador;

  const PantallaPropiedades({super.key, required this.datosJugador});

  @override
  State<PantallaPropiedades> createState() => _PantallaPropiedadesState();
}

class _PantallaPropiedadesState extends State<PantallaPropiedades> {
  final Propiedadservicio _servicio = Propiedadservicio();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _todasLasPropiedades = [];
  List<dynamic> _propiedadesFiltradas = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _obtenerPropiedades();
  }

  void _obtenerPropiedades() async {
    final res = await _servicio.listarPropiedad();
    if (res['statusCode'] == 200) {
      setState(() {
        _todasLasPropiedades = res['data'];
        _propiedadesFiltradas = _todasLasPropiedades;
        _cargando = false;
      });
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
                  // 3. IMAGEN DE CARTA GRANDE
                  Expanded(
                    child: _propiedadesFiltradas.isEmpty
                        ? const Center(
                            child: Text("No se encontró la propiedad"),
                          )
                        : PageView.builder(
                            itemCount: _propiedadesFiltradas.length,
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
                            text: "REGRESAR",
                            assetIcon: 'assets/icon/Return.png',
                            isEnabled: true,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Button_styles(
                            text: "COMPRAR",
                            assetIcon: 'assets/icon/home_purchase.png',
                            isEnabled: true,
                            onPressed: () {
                              // Lógica de compra
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
