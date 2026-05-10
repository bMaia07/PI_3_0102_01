import 'package:flutter/material.dart';
import 'salaPrincipal.dart';
import 'package:audioplayers/audioplayers.dart';

// ========== ÁUDIO GLOBAL COMPARTILHADO ==========
final AudioPlayer _globalPlayer = AudioPlayer();

Future<void> iniciarMusicaGlobal() async {
  await _globalPlayer.setReleaseMode(ReleaseMode.loop);
  await _globalPlayer.play(AssetSource('audios/manacas_background_music.mp3'));
}

Future<void> pararMusicaGlobal() async {
  await _globalPlayer.stop();
}

Future<void> pausarMusicaGlobal() async {
  await _globalPlayer.pause();
}

Future<void> retomarMusicaGlobal() async {
  await _globalPlayer.resume();
}
// ================================================

class CorredorScreen extends StatefulWidget {
  const CorredorScreen({super.key});

  @override
  _CorredorScreenState createState() => _CorredorScreenState();
}

class _CorredorScreenState extends State<CorredorScreen> {
  bool isMuted = false;

  Future<void> toggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    if (isMuted) {
      await pausarMusicaGlobal();
    } else {
      await retomarMusicaGlobal();
    }
  }

  @override
  void dispose() {
    // Não destrói o player global aqui
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fundo/Manacas/corredor_manacas.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Botão de mute (canto superior direito)
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(
                isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
                size: 32,
              ),
              onPressed: toggleMute,
            ),
          ),
          // Botão para iniciar música (caso a web bloqueie autoplay)
          Positioned(
            top: 100,
            right: 20,
            child: ElevatedButton(
              onPressed: iniciarMusicaGlobal,
              child: const Text("Tocar Música"),
            ),
          ),
          // Pegadas para avançar
          Positioned(
            bottom: 80,
            right: 50,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalaPrincipalScreen()),
                );
              },
              child: Image.asset(
                'assets/fundo/Manacas/pegadas.png',
                width: 120,
                height: 80,
              ),
            ),
          ),
          // Botão "Tela Inicial" - para a música e volta
          Positioned(
            top: 20,
            left: 20,
            child: ElevatedButton.icon(
              onPressed: () async {
                await pararMusicaGlobal();
                if (!context.mounted) return;
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: const Icon(Icons.home),
              label: const Text("Tela Inicial"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white70,
                foregroundColor: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}