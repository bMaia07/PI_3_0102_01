import 'package:flutter/material.dart';
import 'corredor_manacas.dart';
import 'package:audioplayers/audioplayers.dart';

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
    setState(() => isMuted = !isMuted);
    if (isMuted) {
      await pausarMusicaManacas();
    } else {
      await retomarMusicaManacas();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      iniciarMusicaManacas().catchError((e) => print("Autoplay bloqueado."));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fundo/Manacas/entrada_manacas.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),

          // Botão MUTE (cores originais)
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: toggleMute,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(38, 23, 23, 1),
                  border: Border.all(color: Color.fromRGBO(65, 26, 26, 1), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Botão VOLTAR (cores originais)
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () async {
                await pararMusicaManacas();
                if (mounted) Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(38, 23, 23, 1),
                  border: Border.all(color: Color.fromRGBO(65, 26, 26, 1), width: 2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black87, blurRadius: 10, offset: Offset(4, 4))],
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text('VOLTAR',
                        style: TextStyle(fontFamily: 'PixelifySans', fontSize: 12, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),

          // Pegadas
          Positioned(
            bottom: 200,
            right: 650,
            child: GestureDetector(
              onTap: () async {
                if (isMuted) toggleMute();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CorredorManacasScreen()),
                );
              },
              child: Image.asset(
                'assets/fundo/Manacas/pegadas.png',
                width: 170,
                height: 130,
              ),
            ),
          ),

          // Caixa de diálogo fixa (estilo novo com cores originais)
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color.fromRGBO(38, 23, 23, 0.95),
                border: Border.all(color: Color.fromRGBO(65, 26, 26, 1), width: 3),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black87, blurRadius: 15, offset: Offset(6, 6))],
              ),
              child: Text(
                "🧑‍🦱 Nossa, o que aconteceu aqui?",
                style: TextStyle(fontFamily: 'PixelifySans', fontSize: 18, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}