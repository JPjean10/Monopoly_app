import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class AudioHelper {
  static final AudioPlayer _player = AudioPlayer();

  // Función privada genérica para reproducir y esperar a que termine el audio
  static Future<void> _playAndWait(String path) async {
    final player = AudioPlayer();
    final completer = Completer<void>();

    // Escuchamos los cambios de estado del reproductor
    final subscription = player.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.completed) {
        completer.complete(); // Avisamos que el audio terminó
      }
    });

    await player.play(AssetSource(path));

    // Esperamos a que el completer se resuelva (cuando termine el audio)
    await completer.future;

    // Limpiamos recursos
    await subscription.cancel();
    await player.dispose();
  }

  static Future<void> jugadorInsertado() async {
    // Usamos _playAndWait en lugar de _player.play
    await _playAndWait('audio/efecto_de_jugador_insertado_monopoly.mp3');
  }

  static Future<void> descuentoDeDinero() async {
    await _playAndWait('audio/efecto_de_descuento_de_dinero.mp3');
  }

  static Future<void> inicioDePartida() async {
    await _playAndWait('audio/efecto_de_inicio_de_partida.mp3');
  }

  static Future<void> cobroGo() async {
    await _playAndWait('audio/efecto_de_cobro_go.mp3');
  }

  static Future<void> pagarCarcel() async {
    await _playAndWait('audio/efecto_de_celda.mp3');
  }

  static Future<void> pagarViaje() async {
    await _playAndWait('audio/efecto_de_viaje.mp3');
  }
}
