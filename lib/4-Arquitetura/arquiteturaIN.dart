import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'miniGameKoda.dart';

class Dialogo {
  final String texto;
  final String personagem;
  final String imagem;
  Dialogo({required this.texto, required this.personagem, required this.imagem});
}

class TelaArquiteturaIN extends StatefulWidget {
  @override
  _TelaArquiteturaINState createState() => _TelaArquiteturaINState();
}

class _TelaArquiteturaINState extends State<TelaArquiteturaIN> {
  late VideoPlayerController _videoController;
  late AudioPlayer _musicPlayer;
  bool _videoInicializado = false;
  bool isMuted = false;
  String? ultimoPersonagem; // para saber quando o personagem muda

  List<Dialogo> dialogos = [
    Dialogo(texto: "Ao entrar na sala o jogador vê um coala sobre uma planta arquitetônica...", personagem: "Narrador", imagem: ""),
    Dialogo(texto: "Ah! Ei, você! Que bom que apareceu... preciso de ajuda...", personagem: "Koda", imagem: ""),
    Dialogo(texto: "Claro! O que está acontecendo?", personagem: "Jogador", imagem: ""),
    Dialogo(texto: "Estou com problemas nesse projeto arquitetônico...", personagem: "Koda", imagem: ""),
  ];
  int indiceAtual = 0;

  String _textoExibido = '';
  String _textoCompleto = '';
  int _indiceChar = 0;
  bool _digitando = false;

  @override
  void initState() {
    super.initState();
    _inicializarVideo();
    _inicializarAudio();
  }

  void _inicializarVideo() async {
    _videoController = VideoPlayerController.asset('assets/videos/coala.mp4');
    await _videoController.initialize();
    _videoController.setLooping(true);
    setState(() {
      _videoInicializado = true;
    });
  }

  void _inicializarAudio() async {
    _musicPlayer = AudioPlayer();
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('audios/background_music_arq.mp3'));
    await _musicPlayer.setVolume(0.5);
  }

  void toggleMute() async {
    setState(() => isMuted = !isMuted);
    await _musicPlayer.setVolume(isMuted ? 0 : 0.5);
  }

  void _iniciarDigitacao(String novoTexto) {
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
      Future.delayed(Duration(milliseconds: 35), () {
        if (mounted) _proximoCaractere();
      });
    } else {
      setState(() => _digitando = false);
    }
  }

  void _avancarDialogo() {
    if (_digitando) {
      setState(() {
        _textoExibido = _textoCompleto;
        _indiceChar = _textoCompleto.length;
        _digitando = false;
      });
    } else {
      if (indiceAtual < dialogos.length - 1) {
        setState(() {
          indiceAtual++;
          _textoExibido = '';
          _textoCompleto = '';
          _indiceChar = 0;
          _digitando = false;
        });
        _iniciarDigitacao(dialogos[indiceAtual].texto);
      }
    }
  }

  // Controle do vídeo: reinicia e toca se personagem for Koda, pausa caso contrário
  void _controlarVideo() {
    if (!_videoInicializado) return;
    Dialogo atual = dialogos[indiceAtual];
    bool ehKoda = atual.personagem == "Koda";
    if (ehKoda) {
      if (ultimoPersonagem != "Koda") {
        _videoController.seekTo(Duration.zero);
        _videoController.play();
      } else if (!_videoController.value.isPlaying) {
        _videoController.play();
      }
    } else {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
      }
    }
    ultimoPersonagem = atual.personagem;
  }

  @override
  void dispose() {
    _videoController.dispose();
    _musicPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Dialogo atual = dialogos[indiceAtual];
    bool acabouDialogo = indiceAtual == dialogos.length - 1;

    // Controle do vídeo a cada build
    _controlarVideo();

    if (_textoCompleto.isEmpty && _textoExibido.isEmpty && atual.texto.isNotEmpty) {
      _iniciarDigitacao(atual.texto);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fundo
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fundo/Arquitetura/sala-arq-pxl.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.35)),

          // Botão VOLTAR
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFF353535).withOpacity(0.95),
                  border: Border.all(color: Color(0xFFFFE817), width: 2),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black87, blurRadius: 10, offset: Offset(4, 4))],
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Color(0xFFFFE817), size: 18),
                    SizedBox(width: 8),
                    Text('VOLTAR', style: TextStyle(fontFamily: 'PixelifySans', fontSize: 12, color: Color(0xFFFFE817))),
                  ],
                ),
              ),
            ),
          ),

          // Botão MUTE
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: toggleMute,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF353535).withOpacity(0.95),
                  border: Border.all(color: Color(0xFFFFE817), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(isMuted ? Icons.volume_off : Icons.volume_up, color: Color(0xFFFFE817), size: 24),
              ),
            ),
          ),

          // Vídeo do Koda (aparece apenas quando a fala é dele)
          if (_videoInicializado && atual.personagem == "Koda")
            Positioned(
              left: 20,
              bottom: 20,
              child: Column(
                children: [
                  Container(
                    width: 240,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Color(0xFFFFE817), width: 4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: VideoPlayer(_videoController),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('KODA', style: TextStyle(fontFamily: 'PixelifySans', fontSize: 20, color: Color(0xFFFFE817))),
                ],
              ),
            ),

          // Caixa de diálogo (à direita)
          Positioned(
            bottom: 20,
            left: 280,
            right: 20,
            child: GestureDetector(
              onTap: acabouDialogo ? null : _avancarDialogo,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF353535).withOpacity(0.95),
                  border: Border.all(color: Color(0xFFFFE817), width: 3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(8),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black87, blurRadius: 15, offset: Offset(6, 6))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: Color(0xFFFFE817), borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble, color: Colors.black, size: 16),
                          SizedBox(width: 8),
                          Text(atual.personagem.toUpperCase(),
                              style: TextStyle(fontFamily: 'PixelifySans', fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14)),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(_textoExibido, style: TextStyle(fontFamily: 'PixelifySans', fontSize: 16, color: Colors.white, height: 1.5)),
                    if (!_digitando && !acabouDialogo)
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text('👆 Toque para continuar...',
                            style: TextStyle(fontFamily: 'PixelifySans', fontSize: 11, color: Color(0xFFFFE817).withOpacity(0.7))),
                      ),
                    if (acabouDialogo)
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            await _musicPlayer.stop();
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MiniGameKoda()));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFF353535),
                              border: Border.all(color: Color(0xFFFFE817), width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('COMEÇAR DESAFIO', style: TextStyle(fontFamily: 'PixelifySans', fontSize: 12, color: Color(0xFFFFE817))),
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