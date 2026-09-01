import 'package:audioplayers/audioplayers.dart';

class AudioHelper {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> jugadorInsertado() async {
    await _player.play(
      AssetSource('audio/efecto_de_jugador_insertado_monopoly.mp3'),
    );
  }

  static Future<void> descuentoDeDinero() async {
    await _player.play(AssetSource('audio/efecto_de_descuento_de_dinero.mp3'));
  }

  static Future<void> inicioDePartida() async {
    await _player.play(AssetSource('audio/efecto_de_inicio_de_partida.mp3'));
  }

  static Future<void> cobroGo() async {
    await _player.play(AssetSource('audio/efecto_de_cobro_go.mp3'));
  }
}
