import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'miniGameKoda.dart';

class Dialogo {
  final String texto;
  final String personagem;
  Dialogo({required this.texto, required this.personagem});
}

class TelaArquiteturaIN extends StatefulWidget {
  @override
  _TelaArquiteturaINState createState() => _TelaArquiteturaINState();
}

class _TelaArquiteturaINState extends State<TelaArquiteturaIN> {
  late AudioPlayer _musicPlayer;
  bool isMuted = false;
  int _currentDialogIndex = 0;
  String _displayedText = '';
  String _fullText = '';
  int _charIndex = 0;
  bool _isTyping = false;

  VideoPlayerController? _videoController;
  bool _videoReady = false;

  List<Dialogo> dialogs = [
    Dialogo(texto: "Ao entrar na sala o jogador vê um coala sobre uma planta arquitetônica...", personagem: "Narrador"),
    Dialogo(texto: "Ah! Ei, você! Que bom que apareceu... preciso de ajuda...", personagem: "Koda"),
    Dialogo(texto: "Claro! O que está acontecendo?", personagem: "Jogador"),
    Dialogo(texto: "Estou com problemas nesse projeto arquitetônico...", personagem: "Koda"),
  ];

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  void _initAudio() async {
    _musicPlayer = AudioPlayer();
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('audios/background_music_arq.mp3'));
    await _musicPlayer.setVolume(0.5);
  }

  void toggleMute() async {
    setState(() => isMuted = !isMuted);
    await _musicPlayer.setVolume(isMuted ? 0 : 0.5);
  }

  Future<void> _loadAndPlayVideo() async {
    // Se já existe um controller, descarta antes de criar outro
    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
    }
    setState(() => _videoReady = false); // esconde o vídeo enquanto carrega

    final controller = VideoPlayerController.asset('assets/videos/coala.mp4');
    await controller.initialize();
    controller.setLooping(true);
    await controller.play();
    setState(() {
      _videoController = controller;
      _videoReady = true;
    });
  }

  void _stopVideo() {
    if (_videoController != null && _videoController!.value.isPlaying) {
      _videoController!.pause();
    }
  }

  void _startTyping(String text) {
    setState(() {
      _fullText = text;
      _displayedText = '';
      _charIndex = 0;
      _isTyping = true;
    });
    _nextChar();
  }

  void _nextChar() {
    if (_charIndex < _fullText.length) {
      setState(() {
        _displayedText += _fullText[_charIndex];
        _charIndex++;
      });
      Future.delayed(Duration(milliseconds: 35), () {
        if (mounted) _nextChar();
      });
    } else {
      setState(() => _isTyping = false);
    }
  }

  void _nextDialog() async {
    if (_isTyping) {
      setState(() {
        _displayedText = _fullText;
        _charIndex = _fullText.length;
        _isTyping = false;
      });
      return;
    }
    if (_currentDialogIndex < dialogs.length - 1) {
      setState(() {
        _currentDialogIndex++;
        _displayedText = '';
        _fullText = '';
        _charIndex = 0;
        _isTyping = false;
      });

      final newPersonagem = dialogs[_currentDialogIndex].personagem;
      if (newPersonagem == "Koda") {
        await _loadAndPlayVideo();
      } else {
        _stopVideo();
      }

      _startTyping(dialogs[_currentDialogIndex].texto);
    }
  }

  @override
  void dispose() {
    _musicPlayer.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Dialogo current = dialogs[_currentDialogIndex];
    bool isLast = _currentDialogIndex == dialogs.length - 1;

    if (_displayedText.isEmpty && _fullText.isEmpty && current.texto.isNotEmpty) {
      if (current.personagem == "Koda") {
        _loadAndPlayVideo();
      }
      _startTyping(current.texto);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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

          // Vídeo do Koda – só aparece quando ready e personagem é Koda
          if (current.personagem == "Koda" && _videoReady && _videoController != null)
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
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text('KODA', style: TextStyle(fontFamily: 'PixelifySans', fontSize: 20, color: Color(0xFFFFE817))),
                ],
              ),
            ),

          // Caixa de diálogo
          Positioned(
            bottom: 20,
            left: 280,
            right: 20,
            child: GestureDetector(
              onTap: isLast ? null : _nextDialog,
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
                          Text(current.personagem.toUpperCase(),
                              style: TextStyle(fontFamily: 'PixelifySans', fontWeight: FontWeight.bold, color: Colors.black, fontSize: 14)),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(_displayedText, style: TextStyle(fontFamily: 'PixelifySans', fontSize: 16, color: Colors.white, height: 1.5)),
                    if (!_isTyping && !isLast)
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text('👆 Toque para continuar...',
                            style: TextStyle(fontFamily: 'PixelifySans', fontSize: 11, color: Color(0xFFFFE817).withOpacity(0.7))),
                      ),
                    if (isLast)
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