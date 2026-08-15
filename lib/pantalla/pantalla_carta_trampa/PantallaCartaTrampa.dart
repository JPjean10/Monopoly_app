import 'package:flutter/material.dart';
import 'package:monopoly_app/componentes/button/Button_styles.dart';
import 'package:monopoly_app/controladores/carta_trampa_controlador.dart';
import 'package:monopoly_app/main.dart';
import 'package:monopoly_app/modal/CartaTrampaModel.dart';
import 'package:monopoly_app/pantalla/pantalla_propiedad/PantallaPropiedades.dart';
import 'package:monopoly_app/pantalla/pantalla_subasta/PantallaSubasta.dart';

class PantallaCartaTrampa extends StatefulWidget {
  final Map<String, dynamic> datosJugador;
  final VoidCallback? onContinuar;
  final bool mostrarInventario;

  const PantallaCartaTrampa({
    super.key,
    required this.datosJugador,
    this.onContinuar,
    this.mostrarInventario = false,
  });

  @override
  State<PantallaCartaTrampa> createState() => _PantallaCartaTrampaState();
}

class _PantallaCartaTrampaState extends State<PantallaCartaTrampa>
    with SingleTickerProviderStateMixin {
  final CartaTrampaController _controller = CartaTrampaController();
  final PageController _pageController = PageController(viewportFraction: 0.95);

  late List<CartaTrampaModel> _cartasMostradas;
  int _paginaActual = 0;
  late AnimationController _animController;
  late Animation<double> _rotation;

  bool _mostrarOpcionesInversion = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _rotation = Tween<double>(begin: 0, end: 1).animate(_animController);
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
    _animController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Función para revertir el giro y regresar al frente de la carta
  void _voltearAlFrente() async {
    await _animController.reverse();
    setState(() {
      _mostrarOpcionesInversion = false;
    });
  }

  Widget _buildCarta(CartaTrampaModel carta) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(_rotation.value * 3.1416),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _mostrarOpcionesInversion
            ? _buildOpcionesInversion()
            : _buildFrenteCarta(carta),
      ),
    );
  }

  // Sub-widget para mostrar las opciones de inversión con el icono para regresar
  Widget _buildOpcionesInversion() {
    return Container(
      key: const ValueKey('opciones'),
      padding: const EdgeInsets.all(16),
      decoration: _estiloCarta(),
      child: Stack(
        children: [
          // Botón de icono en la esquina superior derecha para voltear la carta de vuelta
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: const Icon(
                Icons.rotate_left_rounded,
                color: Color(0xFF24B9F9),
                size: 28,
              ),
              tooltip: 'Volver a ver la carta',
              onPressed: _voltearAlFrente,
            ),
          ),
          // Opciones/Botones dentro de la carta
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Button_styles(
                  text: "Compra propiedad",
                  assetIcon: 'assets/icon/home_purchase.png',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PantallaPropiedades(
                          datosJugador: widget.datosJugador!,
                          isComprar: true,
                          isSolicitud:
                              false, // Indica que es una compra directa
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Button_styles(
                  text: "Subir nivel de renta",
                  assetIcon: 'assets/icon/dwelling-level-up.png',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PantallaPropiedades(
                          datosJugador: widget.datosJugador!,
                          isComprar: false,
                          isSolicitud:
                              false, // Indica que es una solicitud de subir nivel
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Button_styles(
                  text: "Subastar propiedad",
                  icon: Icons.gavel_outlined,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PantallaPropiedades(
                          datosJugador: widget.datosJugador!,
                          isComprar: true,
                          isSolicitud:
                              false, // Indica que es una solicitud de subir nivel
                          isSubasta: true,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Sub-widget para el frente de la carta
  Widget _buildFrenteCarta(CartaTrampaModel carta) {
    return Container(
      key: const ValueKey('frente'),
      padding: const EdgeInsets.all(16),
      decoration: _estiloCarta(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/carta_trampa.png',
            height: 120,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            carta.titulo ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            carta.descripcion ?? '',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Estilo visual del contenedor principal
  BoxDecoration _estiloCarta() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE0B44B), width: 4),
      boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tieneVarias = _cartasMostradas.length > 1;

    return Scaffold(
      backgroundColor: const Color(0xFFE5E7EB),
      appBar: AppBar(
        leading: widget.mostrarInventario
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : null,
        automaticallyImplyLeading: false,
        title: const Text("Monopoly", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF24B9F9),
        elevation: 0,
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
                    physics: _mostrarOpcionesInversion
                        ? const NeverScrollableScrollPhysics() // Bloquea deslizamiento mientras muestra opciones
                        : const BouncingScrollPhysics(),
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
                if (tieneVarias && !_mostrarOpcionesInversion) ...[
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

                // Se oculta el botón inferior cuando _mostrarOpcionesInversion es true
                if (!_mostrarOpcionesInversion)
                  Button_styles(
                    text: widget.mostrarInventario ? 'Usar' : 'Continuar',
                    icon: widget.mostrarInventario
                        ? Icons.inventory_2_outlined
                        : null,
                    assetIcon: widget.mostrarInventario
                        ? null
                        : 'assets/icon/Advance.png',
                    onPressed: () async {
                      if (!widget.mostrarInventario) {
                        final cartaActual = _cartasMostradas[_paginaActual];
                        bool esProcesoNormal = await _controller
                            .procesarCartaTrampa(
                              context: context,
                              jugadorId: widget.datosJugador['jugadorId']!,
                              // codigoAccion: cartaActual.codigoAccion ?? '',
                              codigoAccion: 'INVERSION_EXPRESS',
                              onInversionExpress: () async {
                                setState(() {
                                  _mostrarOpcionesInversion = true;
                                });
                                await _animController.forward();
                              },
                            );
                        if (esProcesoNormal) {
                          widget.onContinuar?.call();
                        }
                      } else {
                        print('Inventario abierto');
                      }
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
