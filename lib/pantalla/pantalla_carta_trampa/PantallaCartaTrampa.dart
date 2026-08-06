import 'package:flutter/material.dart';
import 'package:monopoly_app/componentes/button/Button_styles.dart';
import 'package:monopoly_app/controladores/carta_trampa_controlador.dart';
import 'package:monopoly_app/main.dart';
import 'package:monopoly_app/modal/CartaTrampaModel.dart';

class PantallaCartaTrampa extends StatefulWidget {
  final int? jugador_id;
  final VoidCallback? onContinuar;
  final bool mostrarInventario;

  const PantallaCartaTrampa({
    super.key,
    this.jugador_id,
    this.onContinuar,
    this.mostrarInventario = false,
  });

  @override
  State<PantallaCartaTrampa> createState() => _PantallaCartaTrampaState();
}

class _PantallaCartaTrampaState extends State<PantallaCartaTrampa> {
  final CartaTrampaController _controller = CartaTrampaController();
  final PageController _pageController = PageController(viewportFraction: 0.95);

  late List<CartaTrampaModel> _cartasMostradas;
  int _paginaActual = 0;

  @override
  void initState() {
    super.initState();
    _inicializarCartas();
  }

  void _inicializarCartas() {
    if (widget.mostrarInventario) {
      _cartasMostradas = listaCartasTrampaJugador
          .map((cartaJugador) => cartaJugador.cartaTrampaModel)
          .toList();
    } else {
      if (listaCartasTrampa.isEmpty) {
        _cartasMostradas = [];
      } else {
        _cartasMostradas = [
          _controller.obtenerCartaAleatoriaPorPeso(listaCartasTrampa),
        ];
      }
    }

    if (_cartasMostradas.isEmpty) {
      _cartasMostradas = [
        CartaTrampaModel(
          cartaId: 0,
          titulo: 'Sin cartas',
          descripcion: widget.mostrarInventario
              ? 'Aún no tienes cartas trampa en tu inventario.'
              : 'No hay cartas disponibles.',
          peso: 0,
        ),
      ];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildCarta(CartaTrampaModel carta) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFE0B44B), width: 4),
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
            carta.titulo ?? 'Sin título',
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
              carta.descripcion ?? 'Sin descripción',
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final tieneVarias = _cartasMostradas.length > 1;

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
                if (tieneVarias)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Desliza para ver más cartas',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                    ),
                  ),
                SizedBox(
                  height: 500,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _cartasMostradas.length,
                    onPageChanged: (index) {
                      setState(() {
                        _paginaActual = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildCarta(_cartasMostradas[index]),
                      );
                    },
                  ),
                ),
                if (tieneVarias) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _cartasMostradas.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _paginaActual == index ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _paginaActual == index
                              ? const Color(0xFF24B9F9)
                              : Colors.grey[400],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                Button_styles(
                  text: "Continuar",
                  assetIcon: 'assets/icon/Advance.png',
                  onPressed: () async {
                    if (widget.jugador_id != null) {
                      await _controller.listarCartasTrampaJugador(
                        widget.jugador_id!,
                      );
                    }
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
