import 'dart:math';
import 'package:flutter/material.dart';

class MiniGameKoda extends StatefulWidget {
  @override
  _MiniGameKodaState createState() => _MiniGameKodaState();
}

class _MiniGameKodaState extends State<MiniGameKoda> {

  // ================= PEÇAS =================

  // Cada peça começa com uma rotação aleatória.
  // Valores possíveis:
  // 0 = posição correta
  // 1 = 90°
  // 2 = 180°
  // 3 = 270°

  List<int> rotacoes = [];

  bool puzzleCompleto = false;

  @override
  void initState() {
    super.initState();
    iniciarPuzzle();
  }

  void iniciarPuzzle() {
    Random random = Random();

    rotacoes = List.generate(
      9,
      (index) => random.nextInt(4),
    );
  }

  // ================= GIRAR PEÇA =================

  void girarPeca(int index) {
    if (puzzleCompleto) return;

    setState(() {
      rotacoes[index] = (rotacoes[index] + 1) % 4;
    });

    verificarVitoria();
  }

  // ================= VERIFICAR VITÓRIA =================

  void verificarVitoria() {
    bool venceu = rotacoes.every((rotacao) => rotacao == 0);

    if (venceu) {
      setState(() {
        puzzleCompleto = true;
      });

      Future.delayed(Duration(milliseconds: 300), () {
        mostrarDialogoVitoria();
      });
    }
  }

  // ================= DIALOGO FINAL =================

  void mostrarDialogoVitoria() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Color(0xFF353535),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Color.fromARGB(255, 255, 232, 24),
              width: 3,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Icon(
                  Icons.home,
                  color: Color.fromARGB(255, 255, 232, 24),
                  size: 60,
                ),

                SizedBox(height: 16),

                Text(
                  'PROJETO CONCLUÍDO!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 22,
                    color: Color.fromARGB(255, 255, 232, 24),
                  ),
                ),

                SizedBox(height: 16),

                Text(
                  'Você conseguiu reorganizar a planta arquitetônica da casa.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: 24),

                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 92, 92, 92),
                      border: Border.all(
                        color: Color.fromARGB(255, 255, 232, 24),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'FINALIZAR',
                      style: TextStyle(
                        fontFamily: 'PixelifySans',
                        fontSize: 14,
                        color: Color.fromARGB(255, 228, 186, 0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [

          // FUNDO
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/fundo/Arquitetura/sala-arq-pxl.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ESCURECER
          Container(
            color: Colors.black.withOpacity(0.55),
          ),

          // TÍTULO
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [

                Text(
                  'DESAFIO ARQUITETÔNICO',
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 28,
                    color: Color.fromARGB(255, 255, 232, 24),
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  'Gire as peças até formar a planta completa.',
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // TABULEIRO
          Center(
            child: Container(
              width: 330,
              height: 330,
              padding: EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: Color.fromARGB(255, 54, 54, 54),
                border: Border.all(
                  color: Color.fromARGB(255, 171, 172, 171),
                  width: 4,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black87,
                    blurRadius: 20,
                    offset: Offset(6, 6),
                  ),
                ],
              ),

              child: GridView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: 9,
                gridDelegate:
                    SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => girarPeca(index),
                    child: AnimatedRotation(
                      duration: Duration(milliseconds: 250),
                      turns: rotacoes[index] / 4,

                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Color.fromARGB(
                              255,
                              255,
                              232,
                              24,
                            ),
                            width: 2,
                          ),
                        ),

                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(4),
                          child: Image.asset(
                            'assets/fundo/Arquitetura/puzzle_arq${index + 1}.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // TEXTO INFERIOR
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 54, 54, 54)
                    .withOpacity(0.95),
                border: Border.all(
                  color: Color.fromARGB(255, 171, 172, 171),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Cada peça representa parte da planta técnica da casa. Toque nelas para girar até reconstruir o projeto corretamente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PixelifySans',
                  fontSize: 13,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}