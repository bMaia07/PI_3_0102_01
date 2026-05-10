import 'package:flutter/material.dart';
import 'corredor.dart'; // importa funções de áudio

class SalaPrincipalScreen extends StatelessWidget {
  const SalaPrincipalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fundo/Manacas/sala_principal_cap.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Imagem do personagem
          Positioned(
            top: 300,
            left: 600,
            child: SizedBox(
              width: 900,
              height: 550,
              child: FittedBox(
                fit: BoxFit.fill,
                child: Image.asset('assets/personagens/capivarilda_atacada.png'),
              ),
            ),
          ),
          // Botão "Reiniciar Fase" (volta para a Entrada, mas mantém a música)
          Positioned(
            bottom: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: const Text('Reiniciar Fase'),
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