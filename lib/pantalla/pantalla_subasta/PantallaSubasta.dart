import 'dart:async';

import 'package:flutter/material.dart';
import 'package:monopoly_app/componentes/button/Button_styles.dart';
import 'package:monopoly_app/controladores/subasta_controller.dart';

class PantallaSubasta extends StatefulWidget {
  final Map<String, dynamic> datosJugador;

  const PantallaSubasta({super.key, required this.datosJugador});

  @override
  State<PantallaSubasta> createState() => _PantallaSubastaState();
}

class _PantallaSubastaState extends State<PantallaSubasta> {
  SubastaController _controller = SubastaController();

  final Color _primaryColor = const Color(0xFF24B9F9);
  int _ofertaActual = 0;
  int _jugadorSeleccionado = 1;
  Timer? _repeatTimer;

  List<dynamic> _jugadores = [];

  @override
  void initState() {
    super.initState();
    // Se inicializa en initState() envolviendo el Map dentro de una lista de jugadores
    _actualizarPantalla();
  }

  // Método asíncrono para obtener los jugadores y refrescar la pantalla
  void _actualizarPantalla() async {
    final lista = await _controller.cargarJugadores();
    if (mounted) {
      setState(() {
        _jugadores = lista;
      });
    }
  }

  int _obtenerMaximaOferta() {
    if (_jugadores.isEmpty) return 5000;

    int maxMonto = 0;
    for (final jugador in _jugadores) {
      final monto = jugador['tarjeta']?['monto'];
      int valor = 0;

      if (monto is int) {
        valor = monto;
      } else if (monto is num) {
        valor = monto.toInt();
      }

      if (valor > maxMonto) {
        maxMonto = valor;
      }
    }

    return maxMonto > 0 ? maxMonto : 5000;
  }

  void _cambiarOferta(int delta) {
    final maxOferta = _obtenerMaximaOferta();
    setState(() {
      _ofertaActual = (_ofertaActual + delta).clamp(0, maxOferta);
    });
  }

  void _seleccionarJugador(int index) {
    setState(() {
      _jugadorSeleccionado = index;
    });
  }

  void _startRepeating(int delta) {
    _cambiarOferta(delta);
    _repeatTimer?.cancel();
    _repeatTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (_) => _cambiarOferta(delta),
    );
  }

  void _stopRepeating() {
    _repeatTimer?.cancel();
    _repeatTimer = null;
  }

  @override
  void dispose() {
    _repeatTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int maxOferta = _obtenerMaximaOferta();
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Monopoly", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF24B9F9),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              const Text(
                'AVENIDA INDIA',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF4FF),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 28,
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    Text(
                      _formatearCantidad(_ofertaActual),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 18,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _cambiarOferta(-1),
                          onLongPressStart: (_) => _startRepeating(-1),
                          onLongPressEnd: (_) => _stopRepeating(),
                          child: Icon(
                            Icons.remove_circle_outline,
                            color: _primaryColor,
                            size: 32,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _ofertaActual.toDouble(),
                            min: 0,
                            max: maxOferta.toDouble(),
                            divisions: maxOferta > 0 ? maxOferta : 1,
                            activeColor: _primaryColor,
                            inactiveColor: _primaryColor.withOpacity(0.2),
                            label: _ofertaActual.toString(),
                            onChanged: (value) {
                              setState(() {
                                _ofertaActual = value.round();
                              });
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _cambiarOferta(1),
                          onLongPressStart: (_) => _startRepeating(1),
                          onLongPressEnd: (_) => _stopRepeating(),
                          child: Icon(
                            Icons.add_circle_outline,
                            color: _primaryColor,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Button_styles(
                      text: 'SUBASTAR',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Subasta iniciada con ${_formatearCantidad(_ofertaActual)}',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      child: Text(
                        'JUGADORES',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 1,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Divider(height: 0),
                    ..._jugadores.asMap().entries.map((entry) {
                      final index = entry.key;
                      final jugador = entry.value;
                      return InkWell(
                        onTap: () => _seleccionarJugador(index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _jugadorSeleccionado == index,
                                activeColor: _primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                onChanged: (_) => _seleccionarJugador(index),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${jugador['nombre']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                              Text(
                                'Saldo: ${_formatearCantidad(jugador!['tarjeta']?['monto'] ?? 0 as int)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatearCantidad(int cantidad) {
    final valor = cantidad.toString();
    final regExp = RegExp(r'\B(?=(\d{3})+(?!\d))');
    return valor.replaceAllMapped(regExp, (match) => ',');
  }
}
