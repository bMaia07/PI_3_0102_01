import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'minigame_pracaalimentacao.dart';

class Telapracaalimentacao extends StatefulWidget {
  const Telapracaalimentacao({super.key});

  @override
  State<Telapracaalimentacao> createState() =>
      _TelapracaalimentacaoState();
}

class _TelapracaalimentacaoState
    extends State<Telapracaalimentacao> {

  late VideoPlayerController _videoController;
  late VideoPlayerController _videoEsperaController;

  bool _videoInicializado = false;
  bool _videoEsperaInicializado = false;
  bool _usandoVideoEspera = false;

  final AudioPlayer _player = AudioPlayer();

  bool mutado = false;

  int etapa = 0;

  String _textoExibido = '';
  String _textoCompleto = '';
  int _indiceChar = 0;
  bool _digitando = false;

  @override
  void initState() {
    super.initState();
    tocarAudio();
    inicializarVideos();
  }

  // =========================
  // ÁUDIO
  // =========================

  Future<void> tocarAudio() async {

    await _player.setVolume(1.0);

    await _player.setReleaseMode(
      ReleaseMode.loop,
    );

    await _player.play(
      AssetSource('audios/sompraca.mp3'),
    );
  }

  void alternarMute() async {

    setState(() {
      mutado = !mutado;
    });

    if (mutado) {
      await _player.setVolume(0.0);
    } else {
      await _player.setVolume(1.0);
    }
  }

  // =========================
  // VÍDEOS
  // =========================

  Future<void> inicializarVideos() async {

    _videoController = VideoPlayerController.asset(
      'assets/videos/rato.mp4',
    );

    await _videoController.initialize();
    await _videoController.setLooping(true);

    _videoEsperaController = VideoPlayerController.asset(
      'assets/videos/rato.mp4',
    );

    await _videoEsperaController.initialize();
    await _videoEsperaController.setLooping(true);

    setState(() {

      _videoInicializado = true;
      _videoEsperaInicializado = true;

    });

    mostrarVideoEspera();
  }

 void mostrarVideoFalando() {

  if (_videoInicializado) {

    _videoEsperaController.pause();

    _videoController.seekTo(Duration.zero);

    _videoController.play();

    setState(() {
      _usandoVideoEspera = false;
    });
  }
}

  void mostrarVideoEspera() {

    if (_videoEsperaInicializado) {

      _videoController.pause();

      _videoEsperaController.seekTo(
        Duration.zero,
      );

      _videoEsperaController.play();

      setState(() {
        _usandoVideoEspera = true;
      });
    }
  }

  // =========================
  // TEXTO DIGITANDO
  // =========================

  void iniciarDigitacao(
      String novoTexto,
      ) {

    mostrarVideoFalando();

    setState(() {

      _textoCompleto = novoTexto;
      _textoExibido = '';
      _indiceChar = 0;
      _digitando = true;

    });

    proximoCaractere();
  }

  void proximoCaractere() {

    if (_indiceChar < _textoCompleto.length) {

      setState(() {

        _textoExibido +=
        _textoCompleto[_indiceChar];

        _indiceChar++;

      });

      Future.delayed(

        Duration(milliseconds: 30),

            () {

          if (mounted) {
            proximoCaractere();
          }

        },
      );

    } else {

      setState(() {
        _digitando = false;
      });

      mostrarVideoEspera();
    }
  }

  // =========================
  // TEXTOS
  // =========================

  String get textoAtual {

    switch (etapa) {

      case 0:
        return 'Olá criatura feia, em que posso te ajudar?';

      case 1:
        return 'Você:';

      case 2:
        return 'Ah sim, tenho uma informação útil... mas só direi se completar um desafio!';

      case 3:
        return 'Você:';

      case 4:
        return 'Você terá que fazer três hambúrgueres corretamente seguindo os pedidos!';

      case 5:
        return 'Você:';

      case 6:
        return 'Muito bem! O animal desaparecido foi visto com um hambúrguer, ele pediu um para ele e outro para seu amigo coala...';

      case 7:
        return 'Você:';

      case 8:
        return 'Ele é muito bom em desenhos e prédios, acho que ele quer ser arquiteto.';

      case 9:
        return 'Você:';

      case 10:
        return 'Boa sorte!';

      default:
        return '';
    }
  }

  // =========================
  // AVANÇAR
  // =========================

  void avancar() {

    if (_digitando) {

      setState(() {

        _textoExibido = _textoCompleto;

        _indiceChar =
            _textoCompleto.length;

        _digitando = false;

      });

      mostrarVideoEspera();

      return;
    }

    setState(() {

      if (
      etapa == 1 ||
          etapa == 3 ||
          etapa == 5 ||
          etapa == 7 ||
          etapa == 9 ||
          etapa == 10
      ) {
        return;
      }

      etapa++;

      _textoExibido = '';
      _textoCompleto = '';

    });
  }

  // =========================
  // OPÇÕES
  // =========================

  Widget buildOpcoes() {

    if (etapa == 1) {

      return Column(
        children: [

          botaoPixel(

            'Estou a procura de um animal desaparecido no Campus, ele está com você?',

                () {

              setState(() {

                etapa = 2;

                _textoExibido = '';
                _textoCompleto = '';

              });

            },
          ),
        ],
      );
    }

    if (etapa == 3) {

      return Column(
        children: [

          botaoPixel(

            'Vamos nessa!',

                () async {

              final venceu =
              await Navigator.push(

                context,

                MaterialPageRoute(
                  builder: (_) =>
                  const MinigamePracaAlimentacao(),
                ),
              );

              if (venceu == true) {

                setState(() {

                  etapa = 6;

                  _textoExibido = '';
                  _textoCompleto = '';

                });
              }
            },
          ),

          SizedBox(height: 10),

          botaoPixel(

            'Como é este desafio?',

                () {

              setState(() {

                etapa = 4;

                _textoExibido = '';
                _textoCompleto = '';

              });

            },
          ),
        ],
      );
    }

    if (etapa == 5) {

      return botaoPixel(

        'Vamos nessa',

            () async {

          final venceu =
          await Navigator.push(

            context,

            MaterialPageRoute(
              builder: (_) =>
              const MinigamePracaAlimentacao(),
            ),
          );

          if (venceu == true) {

            setState(() {

              etapa = 6;

              _textoExibido = '';
              _textoCompleto = '';

            });
          }
        },
      );
    }

    if (etapa == 7) {

      return Column(
        children: [

          botaoPixel(

            'Onde encontro o Coala?',

                () {

              setState(() {

                etapa = 8;

                _textoExibido = '';
                _textoCompleto = '';

              });

            },
          ),

          SizedBox(height: 10),

          botaoPixel(

            'Vou em busca do coala!',

                () {

              setState(() {

                etapa = 10;

                _textoExibido = '';
                _textoCompleto = '';

              });

            },
          ),
        ],
      );
    }

    if (etapa == 9) {

      return Column(
        children: [

          botaoPixel(

            'Obrigada pela ajuda!',

                () {

              setState(() {

                etapa = 10;

                _textoExibido = '';
                _textoCompleto = '';

              });

            },
          ),
        ],
      );
    }

    return const SizedBox();
  }

  // =========================
  // BOTÃO PIXEL
  // =========================

  Widget botaoPixel(
      String texto,
      VoidCallback onTap,
      ) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        width: double.infinity,

        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),

        decoration: BoxDecoration(

          color: Color(0xFF1a1f3a),

          border: Border.all(
            color: Colors.redAccent,
            width: 2,
          ),

          borderRadius:
          BorderRadius.circular(8),
        ),

        child: Text(

          texto,

          textAlign: TextAlign.center,

          style: TextStyle(
            fontFamily: 'PixelifySans',
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // =========================
  // BOTÃO AÇÃO
  // =========================

  Widget botaoAcao(
      String texto,
      VoidCallback onTap,
      ) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        padding: EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 14,
        ),

        decoration: BoxDecoration(

          gradient: LinearGradient(
            colors: [
              Color(0xFF2a2f4a),
              Color(0xFF1a1f3a),
            ],
          ),

          border: Border.all(
            color: Colors.redAccent,
            width: 2,
          ),

          borderRadius:
          BorderRadius.circular(8),
        ),

        child: Text(

          texto,

          style: TextStyle(
            fontFamily: 'PixelifySans',
            fontSize: 11,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // =========================
  // DIÁLOGO
  // =========================

  Widget buildDialogo() {

    if (
    textoAtual.isNotEmpty &&
        _textoCompleto != textoAtual &&
        _textoExibido.isEmpty
    ) {

      iniciarDigitacao(textoAtual);
    }

    return GestureDetector(

      onTap: avancar,

      child: Container(

        padding: EdgeInsets.all(20),

        decoration: BoxDecoration(

          color: Color(0xFF0a0e27)
              .withOpacity(0.95),

          border: Border.all(
            color: Colors.redAccent,
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

          crossAxisAlignment:
          CrossAxisAlignment.start,

          mainAxisSize: MainAxisSize.min,

          children: [

            Row(
              children: [

                Container(

                  padding: EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius:
                    BorderRadius.circular(6),
                  ),

                  child: Row(
                    children: [

                      Icon(
                        Icons.chat_bubble,
                        color: Colors.black,
                        size: 16,
                      ),

                      SizedBox(width: 8),

                      Text(

                        etapa == 1 ||
                            etapa == 3 ||
                            etapa == 5 ||
                            etapa == 7 ||
                            etapa == 9
                            ? 'VOCÊ'
                            : 'DON RATATONI',

                        style: TextStyle(
                          fontFamily: 'PixelifySans',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                Spacer(),

                if (_digitando)

                  Container(

                    padding: EdgeInsets.all(6),

                    decoration: BoxDecoration(
                      color: Colors.redAccent
                          .withOpacity(0.15),

                      borderRadius:
                      BorderRadius.circular(6),
                    ),

                    child: Row(
                      children: [

                        SizedBox(

                          width: 12,
                          height: 12,

                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.redAccent,
                          ),
                        ),

                        SizedBox(width: 6),

                        Text(

                          'DIGITANDO...',

                          style: TextStyle(
                            fontFamily: 'PixelifySans',
                            fontSize: 9,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            SizedBox(height: 16),

            Text(

              _textoExibido,

              style: TextStyle(
                fontFamily: 'PixelifySans',
                fontSize: 16,
                color: Colors.white,
                height: 1.5,
              ),
            ),

            if (
            !_digitando &&
                etapa != 1 &&
                etapa != 3 &&
                etapa != 5 &&
                etapa != 7 &&
                etapa != 9 &&
                etapa != 10
            )

              Padding(

                padding:
                EdgeInsets.only(top: 12),

                child: Text(

                  '👆 Toque para continuar...',

                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 11,
                    color: Colors.redAccent
                        .withOpacity(0.7),
                  ),
                ),
              ),

            SizedBox(height: 16),

            buildOpcoes(),

            if (
            !_digitando &&
                etapa == 10
            )

              Row(

                mainAxisAlignment:
                MainAxisAlignment.end,

                children: [

                  botaoAcao(

                    'VOLTAR AO MAPA',

                        () {

                      Navigator.pop(context);

                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // =========================
  // DECORAÇÕES
  // =========================

  List<Widget> buildPixelDecorations() {

    List<Widget> decos = [];

    final codigos = [

      '01010010 01000001 01010100',
      '01000001 01010100 01001111',
      '01001110 01001001'

    ];

    for (int i = 0; i < codigos.length; i++) {

      decos.add(

        Positioned(

          top: 30 + (i * 40),
          right: 10,

          child: Text(

            codigos[i],

            style: TextStyle(
              fontFamily: 'PixelifySans',
              fontSize: 10,
              color: Colors.redAccent
                  .withOpacity(0.2),
            ),
          ),
        ),
      );
    }

    return decos;
  }

  @override
  void dispose() {

    _videoController.dispose();

    _videoEsperaController.dispose();

    _player.dispose();

    super.dispose();
  }

  // =========================
  // BUILD
  // =========================

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
                  'assets/fundo/Praca/pracaalimentacao.jpg',
                ),

                fit: BoxFit.cover,
              ),
            ),
          ),

          // ESCURECER FUNDO
          Container(
            color: Colors.black
                .withOpacity(0.4),
          ),

          // DECORAÇÕES
          ...buildPixelDecorations(),

          // BOTÃO VOLTAR
          Positioned(

            top: 50,
            left: 20,

            child: GestureDetector(

              onTap: () {

                _player.stop();

                Navigator.pop(context);

              },

              child: Container(

                padding: EdgeInsets.all(10),

                decoration: BoxDecoration(

                  color: Color(0xFF1a1f3a),

                  border: Border.all(
                    color: Colors.redAccent,
                    width: 2,
                  ),

                  borderRadius:
                  BorderRadius.circular(8),
                ),

                child: Row(
                  children: [

                    Icon(
                      Icons.arrow_back,
                      color: Colors.redAccent,
                      size: 18,
                    ),

                    SizedBox(width: 6),

                    Text(

                      'VOLTAR',

                      style: TextStyle(
                        fontFamily: 'PixelifySans',
                        fontSize: 12,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // BOTÃO MUTE
          Positioned(

            top: 50,
            right: 20,

            child: GestureDetector(

              onTap: alternarMute,

              child: Container(

                padding: EdgeInsets.all(10),

                decoration: BoxDecoration(

                  color: Color(0xFF1a1f3a),

                  border: Border.all(
                    color: Colors.redAccent,
                    width: 2,
                  ),

                  borderRadius:
                  BorderRadius.circular(8),
                ),

                child: Row(
                  children: [

                    Icon(

                      mutado
                          ? Icons.volume_off
                          : Icons.volume_up,

                      color: Colors.redAccent,
                      size: 18,
                    ),

                    SizedBox(width: 6),

                    Text(

                      'AUDIO',

                      style: TextStyle(
                        fontFamily: 'PixelifySans',
                        fontSize: 12,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // VÍDEO
          Positioned(

            left: 20,
            bottom: 0,

            child: Column(

              children: [

                Container(

                  width: 190,
                  height: 185,

                  decoration: BoxDecoration(

                    color: Color(0xFF1a1f3a),

                    border: Border.all(
                      color: Colors.redAccent,
                      width: 4,
                    ),

                    borderRadius:
                    BorderRadius.circular(12),

                    boxShadow: [

                      BoxShadow(
                        color: Colors.red
                            .withOpacity(0.4),

                        blurRadius: 20,
                      ),
                    ],
                  ),

                  child: ClipRRect(

                    borderRadius:
                    BorderRadius.circular(8),

                    child:
                    _videoInicializado &&
                        _videoEsperaInicializado

                        ? Stack(

                      children: [

                        ClipRRect(

                          borderRadius:
                          BorderRadius.circular(8),

                          child: SizedBox(

                            width: 190,
                            height: 185,

                            child: OverflowBox(

                              maxWidth: double.infinity,
                              maxHeight: double.infinity,

                              child: FittedBox(

                                fit: BoxFit.cover,

                                child: SizedBox(

                                  width: 350,
                                  height: 500,

                                  child:
                                  Transform.translate(

                                    offset: Offset(23, 0),

                                    child:
                                    _usandoVideoEspera

                                        ? VideoPlayer(
                                      _videoEsperaController,
                                    )

                                        : VideoPlayer(
                                      _videoController,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned.fill(

                          child: Material(

                            color: Colors.transparent,

                            child: InkWell(
                              onTap: () {},
                              splashColor:
                              Colors.transparent,
                              highlightColor:
                              Colors.transparent,
                            ),
                          ),
                        ),
                      ],
                    )

                        : Container(

                      color: Color(0xFF0a0e27),

                      child: Center(

                        child:
                        CircularProgressIndicator(
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // DIÁLOGO
          Positioned(

            right: 40,
            left: 200,
            bottom: 10,

            child: buildDialogo(),
          ),
        ],
      ),
    );
  }
}