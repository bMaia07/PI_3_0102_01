import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:html' as html;

import '../game_progress.dart';
import '../2-Biblioteca/biblioteca_fachada.dart';

class TelaH15 extends StatefulWidget {
  @override
  _TelaH15State createState() => _TelaH15State();
}

class _TelaH15State extends State<TelaH15> {
  late VideoPlayerController _videoController;
  late VideoPlayerController _videoEsperaController;
  late AudioPlayer _musicPlayer;

  bool _videoInicializado = false;
  bool _videoEsperaInicializado = false;
  bool _usandoVideoEspera = false;

  String _textoExibido = '';
  String _textoCompleto = '';
  int _indiceChar = 0;
  bool _digitando = false;

  int etapaDialogo = 0;
  bool dialogoFinalizado = false;
  String opcaoEscolhida = '';

  bool _mapaAberto = false;

  double _userLat = -22.834084781581872;
  double _userLng = -47.052650679667536;

  final LatLng _h15 =
      LatLng(-22.834084781581872, -47.052650679667536);

  @override
  void initState() {
    super.initState();
    _inicializarVideos();
    _inicializarAudios();
  }

  void _inicializarVideos() async {
    _videoController =
        VideoPlayerController.asset(
      'assets/videos/videoPingo.mp4',
    );

    await _videoController.initialize();
    _videoController.setLooping(true);

    _videoEsperaController =
        VideoPlayerController.asset(
      'assets/videos/videoPingoEsperando.mp4',
    );

    await _videoEsperaController.initialize();
    _videoEsperaController.setLooping(true);

    setState(() {
      _videoInicializado = true;
      _videoEsperaInicializado = true;
    });

    _mostrarVideoEspera();
  }

  void _inicializarAudios() async {
    _musicPlayer = AudioPlayer();

    await _musicPlayer.play(
      AssetSource('audios/musicaPingo.mp3'),
    );

    await _musicPlayer.setVolume(0.5);

    await _musicPlayer.setReleaseMode(
      ReleaseMode.loop,
    );
  }

  void _mostrarVideoFalando() {
    if (_videoInicializado) {
      _videoEsperaController.pause();
      _videoController.play();

      setState(() {
        _usandoVideoEspera = false;
      });
    }
  }

  void _mostrarVideoEspera() {
    if (_videoEsperaInicializado) {
      _videoController.pause();

      _videoEsperaController.seekTo(Duration.zero);
      _videoEsperaController.play();

      setState(() {
        _usandoVideoEspera = true;
      });
    }
  }

  void _iniciarDigitacao(String novoTexto) {
    _mostrarVideoFalando();

    setState(() {
      _textoCompleto = novoTexto;
      _textoExibido = '';
      _indiceChar = 0;
      _digitando = true;
    });

    _proximoCaractere();
  }

  void _proximoCaractere() {
    if (_indiceChar < _textoCompleto.length) {
      setState(() {
        _textoExibido += _textoCompleto[_indiceChar];
        _indiceChar++;
      });

      Future.delayed(
        Duration(milliseconds: 35),
        () {
          if (mounted) _proximoCaractere();
        },
      );
    } else {
      setState(() {
        _digitando = false;
      });

      _mostrarVideoEspera();
    }
  }

  void _avancarDialogo() {
    if (_digitando) {
      setState(() {
        _textoExibido = _textoCompleto;
        _indiceChar = _textoCompleto.length;
        _digitando = false;
      });

      _mostrarVideoEspera();
    } else {
      setState(() {
        if (etapaDialogo == 0) {
          etapaDialogo = 1;

          _textoExibido = '';
          _textoCompleto = '';
          _indiceChar = 0;
        }
      });
    }
  }

  String get _textoAtualCompleto {
    switch (etapaDialogo) {
      case 0:
        return 'Ei! Você pode me ajudar? Estou com um grande problema...';

      case 1:
        if (opcaoEscolhida == 'ajudar') {
          return 'Sério? Muito obrigado! Eu sabia que podia contar com você!\n\nAcho que outros animais pelo campus podem ter visto algo. Você pode começar procurando na biblioteca.';
        } else {
          return 'Um dos nossos amigos desapareceu, a Capivarilda, a capivara!';
        }

      default:
        return '';
    }
  }

  Future<void> _pegarLocalizacao() async {
    try {
      final geo = html.window.navigator.geolocation;

      if (geo == null) return;

      final pos = await geo.getCurrentPosition(
        enableHighAccuracy: true,
        timeout: Duration(milliseconds: 10000),
      );

      if (!mounted) return;

      setState(() {
        _userLat =
            pos.coords?.latitude?.toDouble() ??
                _userLat;

        _userLng =
            pos.coords?.longitude?.toDouble() ??
                _userLng;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _videoEsperaController.dispose();
    _musicPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                  'assets/fundo/H15/fundo-H15.jpeg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          Positioned(
            left: 20,
            bottom: 0,
            child: Column(
              children: [
                Container(
                  width: 180,
                  height: 170,
                  decoration: BoxDecoration(
                    color: Color(0xFF1a1f3a),
                    border: Border.all(
                      color: Colors.cyanAccent,
                      width: 4,
                    ),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child:
                      _videoInicializado &&
                              _videoEsperaInicializado
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(
                                8,
                              ),
                              child:
                                  _usandoVideoEspera
                                      ? VideoPlayer(
                                          _videoEsperaController,
                                        )
                                      : VideoPlayer(
                                          _videoController,
                                        ),
                            )
                          : Center(
                              child:
                                  CircularProgressIndicator(
                                color:
                                    Colors.cyanAccent,
                              ),
                            ),
                ),

                SizedBox(height: 12),

                Text(
                  'PINGO',
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 20,
                    color: Colors.cyanAccent,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 20,
            left: 220,
            bottom: 80,
            child: _buildDialogoPixel(),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogoPixel() {
    if (_textoAtualCompleto.isNotEmpty &&
        _textoCompleto != _textoAtualCompleto &&
        _textoExibido.isEmpty) {
      _iniciarDigitacao(_textoAtualCompleto);
    }

    return GestureDetector(
      onTap: _avancarDialogo,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color:
              Color(0xFF0a0e27).withOpacity(0.95),
          border: Border.all(
            color: Colors.cyanAccent,
            width: 3,
          ),
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _textoExibido,
              style: TextStyle(
                fontFamily: 'PixelifySans',
                fontSize: 16,
                color: Colors.white,
              ),
            ),

            if (!_digitando &&
                etapaDialogo == 1 &&
                opcaoEscolhida.isEmpty)
              Column(
                children: [
                  SizedBox(height: 16),

                  _buildBotaoResposta(
                    '"O que aconteceu?"',
                    () {
                      setState(() {
                        opcaoEscolhida = 'ajudar';
                        dialogoFinalizado = true;
                        _textoExibido = '';
                        _textoCompleto = '';
                      });
                    },
                  ),
                ],
              ),

            if (!_digitando &&
                dialogoFinalizado &&
                _textoExibido == _textoCompleto)
              Column(
                children: [
                  SizedBox(height: 16),

                  _buildBotaoAcao(
                    'IR PARA BIBLIOTECA',
                    () async {
                      // Marca H15 como concluída E desbloqueia a biblioteca.
                      // As duas chamadas são necessárias: concluirH15() libera
                      // o acesso no menu da tela inicial, e desbloquearBiblioteca()
                      // mantém compatibilidade com o restante do jogo.
                      await GameProgress.concluirH15();
                      await GameProgress.desbloquearBiblioteca();

                      await _musicPlayer.stop();

                      if (!mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const BibliotecaFachadaScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoResposta(
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
            color: Colors.cyanAccent,
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
            color: Colors.cyanAccent,
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoAcao(
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
          color: Color(0xFF1a1f3a),
          border: Border.all(
            color: Colors.cyanAccent,
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
            color: Colors.cyanAccent,
          ),
        ),
      ),
    );
  }
}