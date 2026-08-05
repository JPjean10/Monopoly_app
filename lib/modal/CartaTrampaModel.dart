class CartaTrampaModel {
  final int cartaId;
  final String? titulo;
  final String? descripcion;
  final int? monto;
  final String? codigoAccion;
  final int peso;

  CartaTrampaModel({
    required this.cartaId,
    this.titulo,
    this.descripcion,
    this.monto,
    this.codigoAccion,
    required this.peso,
  });

  factory CartaTrampaModel.fromJson(Map<String, dynamic> json) {
    return CartaTrampaModel(
      cartaId: json['carta_id'] as int,
      titulo: json['titulo'] as String?,
      descripcion: json['descripcion'] as String?,
      monto: json['monto'] as int?,
      codigoAccion: json['codigoAccion'] as String?,
      peso: json['peso'] as int,
    );
  }
}
