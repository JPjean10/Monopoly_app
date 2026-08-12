class ApiConst {
  static const String baseUrl = 'http://192.168.1.100:8080';
  static const String ws = 'http://192.168.1.100:8080/gameHub';

  static const String controlador_jugador = '/Jugador';
  static const String controlador_propiedad = '/Propiedad';
  static const String controlador_historial_compra = '/HistorialCompra';
  static const String controlador_propi_jugador = '/PropiJugador';
  static const String controlador_carta_trampa = '/CartaTrampa';
  static const String controlador_carta_trampa_jugador = '/CartaTrampaJugador';

  // endpoints coplementrarios

  // JugadorControlador
  static const String buscarJugador = '/buscar';
  static const String cobrarRenta = '/cobrar-renta';
  static const String listarOpcionBanco = '/listar-opcion-banco';
  static const String venderPropiedades = '/vender-propiedades';
  static const String SubastaPropiedad = '/subasta-propiedad';
}
