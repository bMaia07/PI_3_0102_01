import 'package:flutter/material.dart';

class Creditos extends StatelessWidget {
  const Creditos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text('CRÉDITOS'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center, // centraliza horizontalmente
            children: [

              // TÍTULO
              Text(
                'ARQUIVO CAPIVARA',
                textAlign: TextAlign.center, // <<< importante
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 28,
                  color: Colors.cyanAccent,
                ),
              ),

              const SizedBox(height: 30),

              // SUBTÍTULO
              Text(
                'CRÉDITOS:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 15),

              // NOMES DAS IAS 
              Text(
                'Chat GPT - para gerar imagens e auxílio nos códigos\n'
                'Dramina IA - para pixelar imagens\n'
                'Adobe Firefly - para gerar vídeos\n',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

               Text(
                'ALUNOS ENVOLVIDOS:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'Ana Clara Chaves\n'
                'Brenda Maia\n'
                'Caio Cantarim\n'
                'João Pedro Rocha\n'
                'João Victor Pensado\n', 
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              // RODAPÉ
              Text(
                'PUC-Campinas - 2026',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 40),

              // BOTÃO
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 35,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'VOLTAR',
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}