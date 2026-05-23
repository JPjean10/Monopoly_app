import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class PantallaEscaneo extends StatefulWidget {
  const PantallaEscaneo({super.key});

  @override
  State<PantallaEscaneo> createState() => _PantallaEscaneoState();
}

class _PantallaEscaneoState extends State<PantallaEscaneo> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _yaEscaneado = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. LA CÁMARA (Fondo total)
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              if (_yaEscaneado) return;

              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                _yaEscaneado = true;
                await cameraController.stop();

                if (mounted) {
                  Navigator.pop(context, barcodes.first.rawValue);
                }
              }
            },
          ),

          // 2. OVERLAY OSCURO ULTRA-LIGERO (Compatible con todos los motores gráficos)
          Positioned.fill(
            child: CustomPaint(
              painter: ScannerOverlayPainter(
                rectWidth: 250,
                rectHeight: 200,
                borderRadius: 10,
              ),
            ),
          ),

          // 3. MARCO BLANCO Y TEXTO (Visual)
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 250,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Coloque el código adentro del recuadro",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),

          // 4. BARRA AZUL SUPERIOR
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                top: 40,
                left: 15,
                right: 15,
                bottom: 10,
              ),
              color: const Color(0xFF00B4FF),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Monopoly",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  IconButton(
                    icon: const Icon(Icons.undo, color: Colors.white),
                    onPressed: () async {
                      await cameraController.stop();
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // 5. ICONO INFERIOR
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const Icon(
                  Icons.view_headline,
                  color: Color(0xFF00B4FF),
                  size: 40,
                ),
                const Text(
                  "Código QR",
                  style: TextStyle(color: Color(0xFF00B4FF)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// PINTOR PERSONALIZADO: Dibuja el fondo oscuro y "recorta" el agujero del centro sin saturar la GPU
class ScannerOverlayPainter extends CustomPainter {
  final double rectWidth;
  final double rectHeight;
  final double borderRadius;

  ScannerOverlayPainter({
    required this.rectWidth,
    required this.rectHeight,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.7);

    // Región del agujero central
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: rectWidth,
      height: rectHeight,
    );

    // Recortamos la zona del centro para que sea transparente
    canvas.clipPath(
      Path()
        ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)))
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
        ..fillType = PathFillType.evenOdd,
    );

    // Pintamos el resto de la pantalla de negro transparente
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
