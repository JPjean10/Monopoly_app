import 'package:audioplayers/audioplayers.dart';

class AudioHelper {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> jugadorInsertado() async {
    await _player.play(
      AssetSource('audio/efecto_de_jugador_insertado_monopoly.mp3'),
    );
  }
}
