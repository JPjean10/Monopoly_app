import 'package:flutter/material.dart';
import 'package:monopoly_app/servicio/propi_jugador_servicio.dart';

class PantallaBancarrota extends StatefulWidget {
  final int jugadorId;
  final int saldoNegativo; // Ejemplo: -70
  final List<dynamic> propiedadesIniciales;

  const PantallaBancarrota({
    super.key,
    required this.jugadorId,
    required this.saldoNegativo,
    required this.propiedadesIniciales,
  });

  @override
  State<PantallaBancarrota> createState() => _PantallaBancarrotaState();
}

class _PantallaBancarrotaState extends State<PantallaBancarrota> {
  final PropiJugadorServicio _propiJugadorServicio = PropiJugadorServicio();

  // Gestión de estados locales (Sin peticiones al servidor al seleccionar)
  final List<int> _propiedadesSeleccionadasIds = [];
  int _balanceSimulado = 0;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    // Iniciamos el balance simulado con la deuda (ej: -70)
    _balanceSimulado = widget.saldoNegativo;
  }

  void _seleccionarTarjeta(int propiedadId, int precioCompra) {
    setState(() {
      if (_propiedadesSeleccionadasIds.contains(propiedadId)) {
        // Deseleccionar: restamos el valor simulado
        _propiedadesSeleccionadasIds.remove(propiedadId);
        _balanceSimulado -= precioCompra;
      } else {
        // Seleccionar: sumamos el precioCompra al balance negativo
        _propiedadesSeleccionadasIds.add(propiedadId);
        _balanceSimulado += precioCompra;
      }
    });
  }

  Future<void> _ejecutarLiquidacionMasiva() async {
    setState(() => _cargando = true);

    // Unimos los IDs seleccionados por comas ej: "3,5"
    String idsString = _propiedadesSeleccionadasIds.join(',');

    final res = await _propiJugadorServicio.enviarVentaMasiva(
      widget.jugadorId,
      idsString,
    );

    setState(() => _cargando = false);

    if (res['status'] == true) {
      // Regresamos a la SalaJugador principal indicando éxito
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${res['userMssg'] ?? 'No se pudo liquidar'}"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Es obligatorio seleccionar más propiedades si el número sigue siendo negativo
    bool puedeFinalizar = _balanceSimulado >= 0;

    return PopScope(
      // Evita que el jugador cierre la pantalla presionando hacia atrás sin pagar
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(
          0xFFFDFDFD,
        ), // CORREGIDO: Formato hexadecimal correcto de 0rectFDFDFD a 0xFFFDFDFD
        appBar: AppBar(
          title: const Text(
            "Liquidación Obligatoria",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue,
          automaticallyImplyLeading: false, // Quitamos flecha de regreso
          actions: [
            // BOTÓN DEL CÍRCULO ROJO EN LA ESQUINA (Oculto si sigue en negativo)
            if (puedeFinalizar)
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: GestureDetector(
                    onTap: _cargando ? null : _ejecutarLiquidacionMasiva,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.red, // Círculo rojo como el diseño
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _cargando
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            // BANNER INFORMATIVO SUPERIOR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: puedeFinalizar ? Colors.cyan.shade50 : Colors.red.shade50,
              child: Column(
                children: [
                  Text(
                    puedeFinalizar ? "VUELTO TOTAL" : "BALANCE DEUDA",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: puedeFinalizar
                          ? Colors.cyan.shade800
                          : Colors.red.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "\$$_balanceSimulado",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: puedeFinalizar ? Colors.cyan : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    puedeFinalizar
                        ? "¡Listo! Ya puedes presionar el botón rojo para confirmar."
                        : "Debes seleccionar más propiedades obligatoriamente.",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // LISTADO DE TARJETAS PROPIAS
            Expanded(
              child: widget.propiedadesIniciales.isEmpty
                  ? const Center(
                      child: Text("No tienes propiedades para liquidar."),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: widget.propiedadesIniciales.length,
                      itemBuilder: (context, index) {
                        final propiedad = widget.propiedadesIniciales[index];
                        final int id = propiedad['propiedadId'] ?? 0;
                        final String nombre =
                            propiedad['nombre'] ?? "Propiedad";
                        // Usamos precioCompra (vuelve 200 por defecto si viene nulo)
                        final int precio =
                            propiedad!['propiedad']?['precio'] ?? 200; //

                        final bool seleccionada = _propiedadesSeleccionadasIds
                            .contains(id);

                        return GestureDetector(
                          onTap: () => _seleccionarTarjeta(id, precio),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              // Cambia a tono azul/cyan si se selecciona
                              color: seleccionada
                                  ? Colors.cyan.shade100
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                // CORREGIDO: Cambiado de BorderSide a Border.all para ser un BoxBorder válido
                                color: seleccionada
                                    ? Colors.cyan
                                    : Colors.grey.shade300,
                                width: 2,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors
                                      .black12, // Suavizado un poco el shadow (estaba en negro puro rígido)
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        nombre,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Valor de devolución: \$$precio",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    seleccionada
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: seleccionada
                                        ? Colors.cyan
                                        : Colors.grey,
                                    size: 26,
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
        ),
      ),
    );
  }
}
