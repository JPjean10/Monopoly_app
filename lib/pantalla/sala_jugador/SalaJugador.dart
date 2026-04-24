import 'package:flutter/material.dart';
import 'package:monopoly_app/pantalla/pantalla_propiedad/PantallaPropiedades.dart';

class Salajugador extends StatefulWidget {
  final Map<String, dynamic> datosJugador;

  const Salajugador({super.key, required this.datosJugador});

  @override
  State<Salajugador> createState() => _SalajugadorState();
}

class _SalajugadorState extends State<Salajugador> {
  // Variable para controlar qué pantalla se muestra
  int _indiceActual = 0;

  @override
  Widget build(BuildContext context) {
    // Extraemos los datos del widget principal
    bool esBanco = widget.datosJugador['esBanco'] ?? false;
    String nombre = widget.datosJugador['nombre'] ?? "Sin nombre";
    var monto = widget.datosJugador['tarjeta']?['monto'] ?? 0;

    // --- LÓGICA PARA CAMBIAR DE PANTALLA ---
    // Definimos las pantallas disponibles
    Widget cuerpoPantalla;
    switch (_indiceActual) {
      case 0:
        cuerpoPantalla = _buildInicio(nombre, monto, esBanco);
        break;
      case 1:
        // Si es banco, el índice 1 es Pagos. Si no, es Notificaciones.
        cuerpoPantalla = esBanco ? _buildPagos() : _buildNotificaciones();
        break;
      case 2:
        cuerpoPantalla = _buildNotificaciones();
        break;
      default:
        cuerpoPantalla = _buildInicio(nombre, monto, esBanco);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Monopoly"),
        backgroundColor: const Color(0xFF24B9F9),
        actions: [
          PopupMenuButton<int>(
            // Icono del menú
            icon: Image.asset(
              'assets/icon/menu.png',
              width: 30,
              color: Colors.white,
            ),
            // Posición para que baje un poco y no tape el icono
            offset: const Offset(0, 50),
            onSelected: (value) {
              if (value == 1) {
                // Navegar a pantalla de Perfil/Datos
                /*           Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PantallaDatosJugador(datos: widget.datosJugador),
            ),
          ); */
              } else if (value == 2) {
                // Lógica para cerrar sesión o salir
                /*           Navigator.pop(context); */
                // AQUI NAVEGAS A LA NUEVA PANTALLA
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PantallaPropiedades(
                      datosJugador:
                          widget.datosJugador, // Pasas los datos que ya tienes
                    ),
                  ),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [SizedBox(width: 10), Text("Subir nivel de renta")],
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: Row(children: [SizedBox(width: 10), Text("propiedad")]),
              ),
            ],
          ),
        ],
      ),
      body: cuerpoPantalla,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (int index) {
          setState(() {
            _indiceActual = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF24B9F9),
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/icon/home_page.png', width: 24),
            label: 'Principal',
          ),
          if (esBanco)
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/icon/payment_confirmation.png',
                width: 24,
              ),
              label: 'confirmar pagos',
            ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icon/push_notifications.png', width: 24),
            label: 'Notificaciones',
          ),
        ],
      ),
    );
  }

  // --- WIDGETS DE LAS DIFERENTES PANTALLAS ---

  Widget _buildInicio(String nombre, dynamic monto, bool esBanco) {
    return Column(
      children: [
        // Encabezado con Nombre y Monto
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                nombre,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text("S/ $monto", style: const TextStyle(fontSize: 24)),
            ],
          ),
        ),

        // Fila de botones de acción
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            children: [
              // Botón Rent
              IconButton(
                icon: Image.asset('assets/icon/rent.png', width: 30),
                onPressed: () {},
              ),

              // ESPACIO ENTRE RENT Y CARDS (Aumentado)
              const SizedBox(width: 25),

              // Botón Cards
              IconButton(
                icon: Image.asset('assets/icon/cards.png', width: 30),
                onPressed: () {},
              ),

              // Este widget empuja lo que sigue hacia la derecha
              const Spacer(),

              // Botón Bank (Solo si es banco, alineado a la derecha)
              if (esBanco)
                IconButton(
                  icon: Image.asset('assets/icon/bank.png', width: 30),
                  onPressed: () {},
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPagos() {
    return const Center(
      child: Text("Pantalla de Confirmar Pagos (Solo Banco)"),
    );
  }

  Widget _buildNotificaciones() {
    return const Center(child: Text("Pantalla de Notificaciones"));
  }
}
