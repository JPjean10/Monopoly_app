import 'package:monopoly_app/modal/carta_trampa_model.dart';

class CartaTrampaJugadorModel {
  final int cartaJugadorId;
  final int jugadorId;
  final int cartaId;
  final CartaTrampaModel cartaTrampaModel;

  CartaTrampaJugadorModel({
    required this.cartaJugadorId,
    required this.jugadorId,
    required this.cartaId,
    required this.cartaTrampaModel,
  });

  factory CartaTrampaJugadorModel.fromJson(Map<String, dynamic> json) {
    return CartaTrampaJugadorModel(
      cartaJugadorId: json['cartaJugadorId'] as int,
      jugadorId: json['jugadorId'] as int,
      cartaId: json['cartaId'] as int,
      cartaTrampaModel: CartaTrampaModel.fromJson(
        json['cartaTrampaModel'] as Map<String, dynamic>,
      ),
    );
  }
}
