class PropiJugadorModel {
  int? propiedadJugadorId;
  int jugadorId; // ID del dueño (cobrador)
  int propiedadId;
  String? nombre;
  int nivelActual;
  int? renta;

  PropiJugadorModel({
    this.propiedadJugadorId,
    required this.jugadorId,
    required this.propiedadId,
    this.nombre,
    required this.nivelActual,
    this.renta,
  });

  Map<String, dynamic> toJson() => {
    "jugadorId": jugadorId,
    "propiedadId": propiedadId,
    "nivelActual": nivelActual,
  };
}
