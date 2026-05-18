import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '../5-Manacas/entrada_manacas.dart';
import '../game_progress.dart';

class Dialogo {
  final String texto;
  final String personagem;
  final String imagem;
  Dialogo({required this.texto, required this.personagem, required this.imagem});
}

class TelaArquiteturaPOS extends StatefulWidget {
  @override
  _TelaArquiteturaPOSState createState() => _TelaArquiteturaPOSState();
}

class _TelaArquiteturaPOSState extends State<TelaArquiteturaPOS> {
  late AudioPlayer _musicPlayer;
  bool isMuted = false;
  int _currentDialogIndex = 0;
  String _displayedText = '';
  String _fullText = '';
  int _charIndex = 0;
  bool _isTyping = false;

  VideoPlayerController? _videoController;
  bool _videoReady = false;

  List<Dialogo> dialogos = [
    Dialogo(texto: "Você conseguiu?! Deixa eu ver...\nIncrível! Perfeito! Cada ângulo, cada encaixe... você tem talento pra isso!", personagem: "Koda", imagem: ""),
    Dialogo(texto: "Era só questão de lógica.", personagem: "Jogador", imagem: ""),
    Dialogo(texto: "Bom... agora que isso está resolvido... tem algo que está me preocupando muito.", personagem: "Koda", imagem: ""),
    Dialogo(texto: "O que foi?", personagem: "Jogador", imagem: ""),
    Dialogo(texto: "A capivara... ela desapareceu. Simplesmente sumiu sem deixar rastros. E isso não é normal — ela sempre foi cuidadosa, metódica... quase como esses desenhos.", personagem: "Koda", imagem: ""),
    Dialogo(texto: "Onde posso ir em busca dela?", personagem: "Jogador", imagem: ""),
    Dialogo(texto: "Um centro de estudos. Fica não muito longe daqui. Dizem que lá existe uma sala... completamente escura. Ninguém gosta de entrar lá. Pode ser que ela esteja por lá.", personagem: "Koda", imagem: ""),
    Dialogo(texto: "Entendi. Vou dar uma olhada.", personagem: "Jogador", imagem: ""),
    Dialogo(texto: "Espere! Você me ajudou, então... eu também quero ajudar você.", personagem: "Koda", imagem: ""),
    Dialogo(texto: "*O coala remexe em uma gaveta e tira um objeto brilhante*", personagem: "Narrador", imagem: ""),
    Dialogo(texto: "Tome isto — um Esquadro Mágico.\nEle não é apenas uma ferramenta comum... ele pode revelar ângulos ocultos, caminhos invisíveis... e até ajudar em combates, se usado corretamente.", personagem: "Koda", imagem: "assets/personagens/esquadroMagico.png"),
    Dialogo(texto: "Interessante...", personagem: "Jogador", imagem: ""),
    Dialogo(texto: "Guarde bem. Tenho a sensação de que você vai precisar disso na batalha final.\nE... obrigado. De verdade.", personagem: "Koda", imagem: ""),
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
    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
    }
    setState(() => _videoReady = false);
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
    if (_currentDialogIndex < dialogos.length - 1) {
      setState(() {
        _currentDialogIndex++;
        _displayedText = '';
        _fullText = '';
        _charIndex = 0;
        _isTyping = false;
      });

      final newPersonagem = dialogos[_currentDialogIndex].personagem;
      if (newPersonagem == "Koda") {
        await _loadAndPlayVideo();
      } else {
        _stopVideo();
      }

      _startTyping(dialogos[_currentDialogIndex].texto);
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
    Dialogo atual = dialogos[_currentDialogIndex];
    bool acabouDialogo = _currentDialogIndex == dialogos.length - 1;

    if (_displayedText.isEmpty && _fullText.isEmpty && atual.texto.isNotEmpty) {
      if (atual.personagem == "Koda") {
        _loadAndPlayVideo();
      }
      _startTyping(atual.texto);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fundo/Arquitetura/arq-outside-pxl.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.45)),

          // Botão VOLTAR
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () async {
                await _musicPlayer.stop();
                if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => EntradaManacasScreen()));
              },
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

          // Vídeo do Koda
          if (atual.personagem == "Koda" && _videoReady && _videoController != null)
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

          // Imagem do Esquadro
          if (atual.imagem == "assets/personagens/esquadroMagico.png")
            Positioned(
              bottom: 250,
              left: 0,
              right: 0,
              child: Center(child: Image.asset(atual.imagem, height: 240)),
            ),

          // Caixa de diálogo
          Positioned(
            bottom: 20,
            left: 280,
            right: 20,
            child: GestureDetector(
              onTap: acabouDialogo ? null : _nextDialog,
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
                    Text(_displayedText, style: TextStyle(fontFamily: 'PixelifySans', fontSize: 16, color: Colors.white, height: 1.5)),
                    if (!_isTyping && !acabouDialogo)
                      Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text('👆 Toque para continuar...',
                            style: TextStyle(fontFamily: 'PixelifySans', fontSize: 11, color: Color(0xFFFFE817).withOpacity(0.7))),
                      ),
                    if (acabouDialogo)
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            await GameProgress.concluirArquitetura();
                            await _musicPlayer.stop();
                            if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => EntradaManacasScreen()));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: Color(0xFF353535),
                              border: Border.all(color: Color(0xFFFFE817), width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Ir para Manacás', style: TextStyle(fontFamily: 'PixelifySans', fontSize: 12, color: Color(0xFFFFE817))),
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