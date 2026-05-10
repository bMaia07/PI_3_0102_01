import 'package:flutter/material.dart';
import 'corredor.dart';

class EntradaScreen extends StatelessWidget {
  const EntradaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Positioned(
            bottom: 250,
            right: 930,
            child: GestureDetector(
              onTap: () async {
                // Tenta iniciar a música, mas não impede a navegação
                try {
                  await iniciarMusicaGlobal();
                } catch (e) {
                  print("Erro no áudio: $e");
                }
                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CorredorScreen()),
                );
              },
              child: Image.asset(
                'assets/fundo/Manacas/pegadas.png',
                width: 300,
                height: 200,
              ),
            ),
          ),
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