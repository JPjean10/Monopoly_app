import 'package:flutter/material.dart';
import 'package:monopoly_app/componentes/button/Button_styles.dart';
import 'package:monopoly_app/controladores/carta_trampa_controlador.dart';
import 'package:monopoly_app/main.dart';
import 'package:monopoly_app/modal/CartaTrampaModel.dart';

class PantallaCartaTrampa extends StatefulWidget {
  final int jugador_id;
  final VoidCallback? onContinuar;

  const PantallaCartaTrampa({
    super.key,
    required this.jugador_id,
    this.onContinuar,
  });

  @override
  State<PantallaCartaTrampa> createState() => _PantallaCartaTrampaState();
}

class _PantallaCartaTrampaState extends State<PantallaCartaTrampa> {
  final CartaTrampaController _controller = CartaTrampaController();
  late CartaTrampaModel _cartaSeleccionada;

  @override
  void initState() {
    super.initState();

    final cartas = listaCartasTrampaGlobal;

    if (cartas.isEmpty) {
      _cartaSeleccionada = CartaTrampaModel(
        cartaId: 0,
        titulo: 'Sin cartas',
        descripcion: 'No hay cartas disponibles.',
        peso: 0,
      );
    } else {
      _cartaSeleccionada = _controller.obtenerCartaAleatoriaPorPeso(cartas);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: AppBar(
        title: const Text("Monopoly", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF24B9F9),
        elevation: 0,
        leading: null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 360,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFFE0B44B),
                        width: 4,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 28),
                        Center(
                          child: Image.asset(
                            'assets/carta_trampa.png',
                            width: 220,
                            height: 220,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          _cartaSeleccionada.titulo ?? 'Sin título',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: 90,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _cartaSeleccionada.descripcion ?? 'Sin descripción',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF374151),
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Button_styles(
                  text: "Continuar",
                  assetIcon: 'assets/icon/Advance.png',
                  onPressed: () {
                    widget.onContinuar?.call();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
