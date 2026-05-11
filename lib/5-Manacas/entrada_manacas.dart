import 'package:flutter/material.dart';
import 'corredor_manacas.dart';
import 'package:audioplayers/audioplayers.dart';

// Áudio global (compartilhado com as outras telas)
final AudioPlayer _manacasPlayer = AudioPlayer();

Future<void> iniciarMusicaManacas() async {
  await _manacasPlayer.setReleaseMode(ReleaseMode.loop);
  await _manacasPlayer.play(AssetSource('audios/sommanacas.mp3'));
  await _manacasPlayer.setVolume(0.5);
}

Future<void> pararMusicaManacas() async {
  await _manacasPlayer.stop();
}

Future<void> pausarMusicaManacas() async {
  await _manacasPlayer.pause();
}

Future<void> retomarMusicaManacas() async {
  await _manacasPlayer.resume();
}

class EntradaManacasScreen extends StatefulWidget {
  const EntradaManacasScreen({super.key});

  @override
  State<EntradaManacasScreen> createState() => _EntradaManacasScreenState();
}

class _EntradaManacasScreenState extends State<EntradaManacasScreen> {
  bool isMuted = false;

  void toggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    if (isMuted) {
      await pausarMusicaManacas();
    } else {
      await retomarMusicaManacas();
    }
  }

  @override
  void initState() {
    super.initState();
    // Tenta iniciar a música (pode ser bloqueado por autoplay no Chrome)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      iniciarMusicaManacas().catchError((e) {
        print("Autoplay bloqueado. Clique em algum lugar para ativar som.");
      });
    });
  }

  @override
  void dispose() {
    // Não para a música ao sair da tela, pois ela continua no corredor/sala
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fundo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fundo/Manacas/entrada_manacas.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay escuro (igual ao H15)
          Container(color: Colors.black.withOpacity(0.3)),

          // Botão MUTE (padronizado)
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: toggleMute,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF1a1f3a),
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.cyanAccent,
                  size: 24,
                ),
              ),
            ),
          ),

          // Botão VOLTAR (padronizado)
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () async {
                await pararMusicaManacas();
                if (mounted) Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF1a1f3a),
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.cyanAccent, size: 18),
                    SizedBox(width: 6),
                    Text('VOLTAR',
                        style: TextStyle(
                            fontFamily: 'PixelifySans',
                            fontSize: 12,
                            color: Colors.cyanAccent)),
                  ],
                ),
              ),
            ),
          ),

          // Pegadas para avançar
          Positioned(
            bottom: 150,
            right: 90,
            child: GestureDetector(
              onTap: () async {
                // Garante que a música esteja tocando
                if (isMuted) toggleMute();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CorredorManacasScreen()),
                );
              },
              child: Image.asset(
                'assets/fundo/Manacas/pegadas.png',
                width: 120,
                height: 80,
              ),
            ),
          ),
        ],
      ),
    );
  }
}