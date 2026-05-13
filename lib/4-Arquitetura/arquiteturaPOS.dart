import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../5-Manacas/entrada_manacas.dart';
import '../game_progress.dart';

class TelaArquiteturaPOS extends StatefulWidget {
  @override
  _TelaArquiteturaPOSState createState() =>
      _TelaArquiteturaPOSState();
}

// ================= CLASSE DIALOGO =================

class Dialogo {
  final String texto;
  final String personagem;
  final String imagem;

  Dialogo({
    required this.texto,
    required this.personagem,
    required this.imagem,
  });
}

class _TelaArquiteturaPOSState
    extends State<TelaArquiteturaPOS> {

  // ================= PLAYER =================

  final AudioPlayer _player = AudioPlayer();

  bool isMuted = false;

  // ================= INIT =================

  @override
  void initState() {
    super.initState();

    tocarSom();
  }

  // ================= SOM =================

  void tocarSom() async {
    await _player.setReleaseMode(ReleaseMode.loop);

    await _player.play(
      AssetSource('audios/background_music_arq.mp3'),
    );
  }

  void toggleSom() async {
    setState(() {
      isMuted = !isMuted;
    });

    await _player.setVolume(
      isMuted ? 0 : 1,
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // ================= DIÁLOGOS =================

  List<Dialogo> dialogos = [

    Dialogo(
      texto:
          "Você conseguiu?! Deixa eu ver...\nIncrível! Perfeito! Cada ângulo, cada encaixe... você tem talento pra isso!",
      personagem: "Koda",
      imagem:
          "assets/personagens/koda.png",
    ),

    Dialogo(
      texto:
          "Era só questão de lógica.",
      personagem: "Jogador",
      imagem:
          "",
    ),

    Dialogo(
      texto:
          "Bom... agora que isso está resolvido... tem algo que está me preocupando muito.",
      personagem: "Koda",
      imagem:
          "assets/personagens/koda.png",
    ),

    Dialogo(
      texto:
          "O que foi?",
      personagem: "Jogador",
      imagem:
          "",
    ),

    Dialogo(
      texto:
          "A capivara... ela desapareceu. Simplesmente sumiu sem deixar rastros. E isso não é normal — ela sempre foi cuidadosa, metódica... quase como esses desenhos.",
      personagem: "Koda",
      imagem:
          "assets/personagens/koda.png",
    ),

    Dialogo(
      texto:
          "Onde posso ir em busca dela?",
      personagem: "Jogador",
      imagem:
          "",
    ),

    Dialogo(
      texto:
          "Um centro de estudos. Fica não muito longe daqui. Dizem que lá existe uma sala... completamente escura. Ninguém gosta de entrar lá. Pode ser que ela esteja por lá.",
      personagem: "Koda",
      imagem:
          "assets/personagens/koda.png",
    ),

    Dialogo(
      texto:
          "Entendi. Vou dar uma olhada.",
      personagem: "Jogador",
      imagem:
          "",
    ),

    Dialogo(
      texto:
          "Espere! Você me ajudou, então... eu também quero ajudar você.",
      personagem: "Koda",
      imagem:
          "assets/personagens/koda.png",
    ),

    Dialogo(
      texto:
          "*O coala remexe em uma gaveta e tira um objeto brilhante*",
      personagem: "Narrador",
      imagem: "",
    ),

    Dialogo(
      texto:
          "Tome isto — um Esquadro Mágico.\nEle não é apenas uma ferramenta comum... ele pode revelar ângulos ocultos, caminhos invisíveis... e até ajudar em combates, se usado corretamente.",
      personagem: "Koda",
      imagem:
          "assets/personagens/esquadroMagico.png",
    ),

    Dialogo(
      texto:
          "Interessante...",
      personagem: "Jogador",
      imagem:
          "",
    ),

    Dialogo(
      texto:
          "Guarde bem. Tenho a sensação de que você vai precisar disso na batalha final.\nE... obrigado. De verdade.",
      personagem: "Koda",
      imagem:
          "assets/personagens/koda.png",
    ),
  ];

  int indiceAtual = 0;

  // ================= PRÓXIMO DIÁLOGO =================

  void proximoDialogo() {
    if (indiceAtual < dialogos.length - 1) {
      setState(() {
        indiceAtual++;
      });
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {

    Dialogo atual = dialogos[indiceAtual];

    bool acabouDialogo =
        indiceAtual == dialogos.length - 1;

    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [

          // ================= FUNDO =================

          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/fundo/Arquitetura/arq-outside-pxl.png',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // ================= ESCURECER =================

          Container(
            color: Colors.black.withOpacity(0.45),
          ),

          // ================= BOTÃO VOLTAR =================

          Positioned(
            top: 40,
            left: 20,

            child: GestureDetector(
              onTap: () async {

                await _player.stop();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EntradaManacasScreen(),
                  ),
                );
              },

              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),

                decoration: BoxDecoration(
                  color: Color.fromARGB(
                    255,
                    54,
                    54,
                    54,
                  ).withOpacity(0.95),

                  border: Border.all(
                    color: const Color.fromARGB(
                      255,
                      171,
                      172,
                      171,
                    ),
                    width: 2,
                  ),

                  borderRadius:
                      BorderRadius.circular(10),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black87,
                      blurRadius: 10,
                      offset: Offset(4, 4),
                    ),
                  ],
                ),

                child: Row(
                  children: [

                    Icon(
                      Icons.arrow_back,
                      color:
                          const Color.fromARGB(
                        255,
                        255,
                        232,
                        24,
                      ),
                      size: 18,
                    ),

                    SizedBox(width: 8),

                    Text(
                      'VOLTAR',

                      style: TextStyle(
                        fontFamily:
                            'PixelifySans',
                        fontSize: 12,
                        color:
                            const Color.fromARGB(
                          255,
                          228,
                          186,
                          0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ================= BOTÃO DE SOM =================

          Positioned(
            top: 40,
            right: 20,

            child: IconButton(
              icon: Icon(
                isMuted
                    ? Icons.volume_off
                    : Icons.volume_up,

                color: Colors.white,
                size: 30,
              ),

              onPressed: toggleSom,
            ),
          ),

          // ================= PERSONAGENS =================

          if (atual.imagem.isNotEmpty)

            // ================= KODA =================
            if (
              atual.personagem == "Koda" &&
              atual.imagem !=
                  "assets/personagens/esquadroMagico.png"
            )
              Positioned(
                bottom: 220,
                left: 30,

                child: Image.asset(
                  atual.imagem,
                  height: 300,
                ),
              )

            // ================= JOGADOR =================
            //else if (atual.personagem == "Jogador")
            //  Positioned(
            //    bottom: 220,
            /*    right: 30,

                child: Image.asset(
                  atual.imagem,
                  height: 300,
                ),
              )
            */
            // ================= ESQUADRO =================
            else
              Positioned(
                bottom: 250,
                left: 0,
                right: 0,

                child: Center(
                  child: Image.asset(
                    atual.imagem,
                    height: 240,
                  ),
                ),
              ),

          // ================= CAIXA DE DIÁLOGO =================

          Positioned(
            left: 40,
            right: 40,
            bottom: 40,

            child: GestureDetector(
              onTap: acabouDialogo
                  ? null
                  : proximoDialogo,

              child: Container(
                padding: EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Color.fromARGB(
                    255,
                    54,
                    54,
                    54,
                  ).withOpacity(0.95),

                  border: Border.all(
                    color: const Color.fromARGB(
                      255,
                      171,
                      172,
                      171,
                    ),
                    width: 3,
                  ),

                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(8),
                  ),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black87,
                      blurRadius: 15,
                      offset: Offset(6, 6),
                    ),
                  ],
                ),

                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    // ================= NOME =================

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color:
                            const Color.fromARGB(
                          255,
                          245,
                          224,
                          41,
                        ),

                        borderRadius:
                            BorderRadius.circular(6),
                      ),

                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min,

                        children: [

                          Icon(
                            Icons.chat_bubble,
                            color: Colors.black,
                            size: 16,
                          ),

                          SizedBox(width: 8),

                          Text(
                            atual.personagem
                                .toUpperCase(),

                            style: TextStyle(
                              fontFamily:
                                  'PixelifySans',

                              fontWeight:
                                  FontWeight.bold,

                              color: Colors.black,

                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16),

                    // ================= TEXTO =================

                    Text(
                      atual.texto,

                      style: TextStyle(
                        fontFamily:
                            'PixelifySans',

                        fontSize: 16,

                        color: Colors.white,

                        height: 1.5,
                      ),
                    ),

                    SizedBox(height: 14),

                    // ================= CONTINUAR =================

                    if (!acabouDialogo)
                      Text(
                        '👆 Toque para continuar...',

                        style: TextStyle(
                          fontFamily:
                              'PixelifySans',

                          fontSize: 11,

                          color:
                              const Color.fromARGB(
                                255,
                                255,
                                232,
                                24,
                              ).withOpacity(0.7),
                        ),
                      ),

                    // ================= BOTÃO FINAL =================
                    // Aqui é o ponto de conclusão da fase inteira.
                    // Salva arquiteturaConcluida = true antes de voltar ao mapa.

                    if (acabouDialogo)
                      Center(
                        child: GestureDetector(
                          onTap: () async {

                            // Salva que a fase de arquitetura foi concluída
                            await GameProgress.concluirArquitetura();

                            await _player.stop();

                            Navigator.pushReplacement(
                              context,

                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        EntradaManacasScreen(),
                              ),
                            );
                          },

                          child: Container(
                            padding:
                                EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),

                            decoration:
                                BoxDecoration(
                              color: Color.fromARGB(
                                255,
                                92,
                                92,
                                92,
                              ).withOpacity(0.95),

                              border: Border.all(
                                color:
                                    const Color.fromARGB(
                                  255,
                                  255,
                                  232,
                                  24,
                                ),
                                width: 2,
                              ),

                              borderRadius:
                                  BorderRadius
                                      .circular(8),
                            ),

                            child: Text(
                              'Ir para Manacas',

                              style: TextStyle(
                                fontFamily:
                                    'PixelifySans',

                                fontSize: 12,

                                color:
                                    const Color.fromARGB(
                                  255,
                                  228,
                                  186,
                                  0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
