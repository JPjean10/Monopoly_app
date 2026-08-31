import 'package:flutter/material.dart';
import 'package:monopoly_app/servicio/propi_jugador_servicio.dart';

class PantallaBancarrota extends StatefulWidget {
  final int jugadorId;
  final int saldoNegativo;
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

  final List<int> _propiedadesSeleccionadasIds = [];
  int _balanceSimulado = 0;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _balanceSimulado = widget.saldoNegativo;
  }

  void _seleccionarTarjeta(int propiedadId, int precioCompra) {
    if (_cargando) return; // Si está procesando, bloquea selecciones
    setState(() {
      if (_propiedadesSeleccionadasIds.contains(propiedadId)) {
        _propiedadesSeleccionadasIds.remove(propiedadId);
        _balanceSimulado -= precioCompra;
      } else {
        _propiedadesSeleccionadasIds.add(propiedadId);
        _balanceSimulado += precioCompra;
      }
    });
  }

  Future<void> _ejecutarLiquidacionMasiva() async {
    if (_cargando) return;

    setState(() => _cargando = true);

    String idsString = _propiedadesSeleccionadasIds.join(',');

    final res = await _propiJugadorServicio.enviarVentaMasiva(
      widget.jugadorId,
      idsString,
    );

    if (!mounted) return;

    if (res['status'] == true) {
      // Éxito: Cierra la pantalla devolviendo true
      Navigator.pop(context, true);
    } else {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${res['userMssg'] ?? 'No se pudo liquidar'}"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool puedeFinalizar = _balanceSimulado >= 0;

    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: const Color(0xFFFDFDFD),
            appBar: AppBar(
              title: const Text(
                "Liquidación Obligatoria",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.blue,
              automaticallyImplyLeading: false,
              actions: [
                if (puedeFinalizar)
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Center(
                      child: GestureDetector(
                        onTap: _cargando ? null : _ejecutarLiquidacionMasiva,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
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
                  color: puedeFinalizar
                      ? Colors.cyan.shade50
                      : Colors.red.shade50,
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
                            final propiedad =
                                widget.propiedadesIniciales[index];
                            final int id = propiedad['propiedadId'] ?? 0;
                            final String nombre =
                                propiedad['nombre'] ?? "Propiedad";
                            final int precio =
                                propiedad!['propiedad']?['precio'] ?? 200;

                            final bool seleccionada =
                                _propiedadesSeleccionadasIds.contains(id);

                            return GestureDetector(
                              onTap: () => _seleccionarTarjeta(id, precio),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: seleccionada
                                      ? Colors.cyan.shade100
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: seleccionada
                                        ? Colors.cyan
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
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

          // OVERLAY BLOQUEADOR Y CÍRCULO DE CARGA
          if (_cargando)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 4,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Procesando liquidación...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
