import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'miniGameKoda.dart';
import 'arquiteturaOUT.dart';
import '../tela_mapa_exploracao.dart';

// 🧠 MODELO DE DIÁLOGO
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

class TelaArquiteturaIN extends StatefulWidget {
  @override
  _TelaArquiteturaINState createState() =>
      _TelaArquiteturaINState();
}

class _TelaArquiteturaINState
    extends State<TelaArquiteturaIN> {

  // 🎵 PLAYER
  final AudioPlayer _player = AudioPlayer();
  bool isMuted = false;

  @override
  void initState() {
    super.initState();
    tocarSom();
  }

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

    await _player.setVolume(isMuted ? 0 : 1);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // 🗣️ DIÁLOGOS
  List<Dialogo> dialogos = [

    Dialogo(
      texto:
          "Ao entrar na sala o jogador vê um coala sobre uma planta arquitetônica...",
      personagem: "Narrador",
      imagem: "",
    ),

    Dialogo(
      texto:
          "Ah! Ei, você! Que bom que apareceu... preciso de ajuda...",
      personagem: "Koda",
      imagem:
          "assets/personagens/koda.png",
    ),

    Dialogo(
      texto:
          "Claro! O que está acontecendo?",
      personagem: "Jogador",
      imagem:
          "assets/personagens/player-masc.png",
    ),

    Dialogo(
      texto:
          "Estou com problemas nesse projeto arquitetônico...",
      personagem: "Koda",
      imagem:
          "assets/personagens/koda.png",
    ),
  ];

  int indiceAtual = 0;

  void proximoDialogo() {
    if (indiceAtual < dialogos.length - 1) {
      setState(() {
        indiceAtual++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    bool acabouDialogo =
        indiceAtual == dialogos.length - 1;

    Dialogo atual = dialogos[indiceAtual];

    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [

          // 🎨 FUNDO
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

          // ESCURECER FUNDO
          Container(
            color: Colors.black.withOpacity(0.35),
          ),

          // 🔙 BOTÃO VOLTAR
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
                        TelaMapaExploracao(),
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

          // 🔈 SOM
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

          // 👤 PERSONAGEM
          if (atual.personagem != "Narrador")
            Align(
              alignment:
                  atual.personagem == "Koda"
                      ? Alignment.bottomLeft
                      : Alignment.bottomRight,

              child: Padding(
                padding: EdgeInsets.only(
                  bottom: 180,

                  left:
                      atual.personagem ==
                              "Jogador"
                          ? 20
                          : 0,

                  right:
                      atual.personagem ==
                              "Koda"
                          ? 20
                          : 0,
                ),

                child: Image.asset(
                  atual.imagem,
                  height: 260,
                  fit: BoxFit.contain,
                ),
              ),
            ),

          // 💬 DIÁLOGO
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

                    // NOME
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

                    // TEXTO
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

                    // BOTÃO
                    if (acabouDialogo)
                      Center(
                        child: GestureDetector(
                          onTap: () async {

                            await _player.stop();

                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        MiniGameKoda (),
                              ),
                            );
                          },

                          child: Container(
                            padding:
                                EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
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
                              'COMEÇAR DESAFIO',

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
                                ).withOpacity(1),
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