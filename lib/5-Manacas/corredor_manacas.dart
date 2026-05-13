import 'package:flutter/material.dart';
import 'sala_principal_manacas.dart';
import 'entrada_manacas.dart';

class CorredorManacasScreen extends StatefulWidget {
  const CorredorManacasScreen({super.key});

  @override
  State<CorredorManacasScreen> createState() => _CorredorManacasScreenState();
}

class _CorredorManacasScreenState extends State<CorredorManacasScreen> {
  bool isMuted = false;

  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
    });
    if (isMuted) {
      pausarMusicaManacas();
    } else {
      retomarMusicaManacas();
    }
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
                image: AssetImage('assets/fundo/Manacas/corredor_manacas.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),

          // Botão MUTE
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: toggleMute,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(38, 23, 23, 1),
                  border: Border.all(color: Color.fromRGBO(65, 26, 26, 1), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Botão VOLTAR
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(38, 23, 23, 1),
                  border: Border.all(color: Color.fromRGBO(65, 26, 26, 1), width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Color.fromRGBO(65, 26, 26, 1), size: 18),
                    SizedBox(width: 6),
                    Text('VOLTAR',
                        style: TextStyle(fontFamily: 'PixelifySans', fontSize: 12, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),

          // Pegadas
          Positioned(
            bottom: 60,
            left: 400,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalaPrincipalManacasScreen()),
                );
              },
              child: Image.asset(
                'assets/fundo/Manacas/pegadas.png',
                width: 170,
                height: 130,
              ),
            ),
          ),

          // Caixa de diálogo FIXA na parte inferior
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
              ),
              child: Text(
                "🧑‍🦱 Está tudo diferente… Que estranho...",
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