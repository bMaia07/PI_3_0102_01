import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:html' as html;
import '../game_progress.dart';

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
  bool _audioInicializado = false;
  bool _usandoVideoEspera = false;

  String _textoExibido = '';
  String _textoCompleto = '';
  int _indiceChar = 0;
  bool _digitando = false;

  int etapaDialogo = 0;
  bool missaoAceita = false;
  bool dialogoFinalizado = false;
  String opcaoEscolhida = '';

  bool _mapaAberto = false;

  MapController _mapController = MapController();

  double _userLat = -22.834084781581872;
  double _userLng = -47.052650679667536;

  final LatLng _h15 = LatLng(-22.834084781581872, -47.052650679667536);

  @override
  void initState() {
    super.initState();
    _inicializarVideos();
    _inicializarAudios();
  }

  void _inicializarVideos() async {
    _videoController =
        VideoPlayerController.asset('assets/videos/videoPingo.mp4');
    await _videoController.initialize();
    _videoController.setLooping(true);

    _videoEsperaController =
        VideoPlayerController.asset('assets/videos/videoPingoEsperando.mp4');
    await _videoEsperaController.initialize();
    _videoEsperaController.setLooping(true);

    setState(() {
      _videoInicializado = true;
      _videoEsperaInicializado = true;
    });

    _mostrarVideoEspera();
  }

  void _inicializarAudios() async {
    try {
      _musicPlayer = AudioPlayer();

      await _musicPlayer.play(AssetSource('audios/musicaPingo.mp3'));
      await _musicPlayer.setVolume(0.5);
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);

      await _musicPlayer.resume();

      print('✅ Áudios carregados com sucesso!');
      setState(() {
        _audioInicializado = true;
      });
    } catch (e) {
      print('❌ Erro ao carregar áudios: $e');
    }
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
      if (_textoCompleto[_indiceChar] != ' ' &&
          _textoCompleto[_indiceChar] != '\n') {}

      setState(() {
        _textoExibido += _textoCompleto[_indiceChar];
        _indiceChar++;
      });

      Future.delayed(Duration(milliseconds: 35), () {
        if (mounted) _proximoCaractere();
      });
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
          return 'Sério? Muito obrigado! Eu sabia que podia contar com você!\n\nAcho que outros animais pelo campus podem ter visto algo. Você pode começar procurando na biblioteca.\n\nLembre-se, para receber qualquer informação é necessário cumprir desafios, portanto fique atento às pistas e trate bem os outros animais... Qualquer detalhe pode ser importante!';
        } else if (opcaoEscolhida == 'complicado') {
          return 'Eu entendo... mas por favor, pense bem. Nossa amiga pode estar em perigo.';
        } else {
          return 'Um dos nossos amigos desapareceu, a Capivarilda, a capivara!\n\nNinguém sabe exatamente o que aconteceu, mas ela foi vista pela última vez em algum lugar do campus...\n\nEu tentei procurar sozinho, mas esse lugar é grande demais... preciso de ajuda para encontrar pistas.';
        }
      default:
        return '';
    }
  }

  double _calcularDistancia() {
    return Distance().as(
      LengthUnit.Meter,
      LatLng(_userLat, _userLng),
      _h15,
    );
  }

// ================= GEO LOCALIZAÇÃO =================
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
        _userLat = pos.coords?.latitude?.toDouble() ?? _userLat;
        _userLng = pos.coords?.longitude?.toDouble() ?? _userLng;
      });
    } catch (e) {
      print('❌ ERRO GEO: $e');
    }
  }

  Future<void> _abrirMapa() async {
    if (_mapaAberto) return;
    _mapaAberto = true;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Obtendo localização...')),
    );

    await _pegarLocalizacao();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        final MapController controller = MapController();

        return Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.cyanAccent, width: 2),
          ),
          child: Container(
            height: 500,
            width: 350,
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  'MAPA - SUA LOCALIZAÇÃO',
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    color: Colors.cyanAccent,
                  ),
                ),

                SizedBox(height: 10),

                Expanded(
                  child: FlutterMap(
                    mapController: controller,
                    options: MapOptions(
                      initialCenter: LatLng(_userLat, _userLng),
                      initialZoom: 17,
                      onMapReady: () {
                        controller.move(
                          LatLng(_userLat, _userLng),
                          17,
                        );
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(_userLat, _userLng),
                            width: 40,
                            height: 40,
                            child: Icon(Icons.location_pin,
                                color: Colors.red, size: 40),
                          ),
                          Marker(
                            point: _h15,
                            width: 40,
                            height: 40,
                            child: Icon(Icons.location_on,
                                color: Colors.cyanAccent, size: 30),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                Text(
                  '📍 VERMELHO: Você | CIANO: H15',
                  style: TextStyle(fontSize: 10, color: Colors.white54),
                ),

                SizedBox(height: 10),

                // 🔥 BOTÕES ESTILIZADOS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        controller.move(
                          LatLng(_userLat, _userLng),
                          17,
                        );
                      },
                      child: _botaoPixelMapa('MINHA POSIÇÃO'),
                    ),
                    GestureDetector(
                      onTap: () {
                        double d = _calcularDistancia();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Distância até H15: ${d.toStringAsFixed(0)}m',
                            ),
                          ),
                        );
                      },
                      child: _botaoPixelMapa('DISTÂNCIA'),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: _botaoPixelMapa('FECHAR', cor: Colors.redAccent),
                ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      _mapaAberto = false;
    });
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
                image: AssetImage('assets/fundo/H15/fundo-H15.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          ..._buildPixelDecorations(),

          // Botão do MAPA
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: _abrirMapa,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF1a1f3a),
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.map, color: Colors.cyanAccent, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'MAPA',
                      style: TextStyle(
                        fontFamily: 'PixelifySans',
                        fontSize: 12,
                        color: Colors.cyanAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // VÍDEO DO PINGO
          Positioned(
            left: 20,
            bottom: 0,
            child: Column(
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.basic,
                  child: Container(
                    width: 180,
                    height: 170,
                    decoration: BoxDecoration(
                      color: Color(0xFF1a1f3a),
                      border: Border.all(color: Colors.cyanAccent, width: 4),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.cyan.withOpacity(0.4),
                            blurRadius: 20),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _videoInicializado && _videoEsperaInicializado
                          ? Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SizedBox(
                                    width: 180,
                                    height: 180,
                                    child: OverflowBox(
                                      maxWidth: double.infinity,
                                      maxHeight: double.infinity,
                                      child: FittedBox(
                                        fit: BoxFit.cover,
                                        child: SizedBox(
                                          width: 300,
                                          height: 300,
                                          child: _usandoVideoEspera
                                              ? VideoPlayer(
                                                  _videoEsperaController)
                                              : VideoPlayer(_videoController),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Overlay para bloquear controles do vídeo
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {},
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              color: Color(0xFF0a0e27),
                              child: Center(
                                child: CircularProgressIndicator(
                                    color: Colors.cyanAccent),
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFF0d1230),
                    border: Border.all(color: Colors.cyanAccent, width: 2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PINGO',
                    style: TextStyle(
                        fontFamily: 'PixelifySans',
                        fontSize: 20,
                        color: Colors.cyanAccent),
                  ),
                ),
                Text(
                  'O Pinguim Tecnológico',
                  style: TextStyle(
                      fontFamily: 'PixelifySans',
                      fontSize: 11,
                      color: Colors.white70),
                ),
              ],
            ),
          ),

          // BALÃO DE DIÁLOGO
          Positioned(
            right: 20,
            left: 220,
            bottom: 80,
            child: _buildDialogoPixel(),
          ),

          // BOTÃO VOLTAR
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () {
                _musicPlayer.stop();
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF1a1f3a),
                  border: Border.all(color: Colors.cyanAccent, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back, color: Colors.cyanAccent, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'VOLTAR',
                      style: TextStyle(
                          fontFamily: 'PixelifySans',
                          fontSize: 12,
                          color: Colors.cyanAccent),
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
          color: Color(0xFF0a0e27).withOpacity(0.95),
          border: Border.all(color: Colors.cyanAccent, width: 3),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(8),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black87, blurRadius: 15, offset: Offset(6, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.cyanAccent,
                      borderRadius: BorderRadius.circular(6)),
                  child: Row(
                    children: [
                      Icon(Icons.chat_bubble, color: Colors.black, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'PINGO',
                        style: TextStyle(
                            fontFamily: 'PixelifySans',
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Spacer(),
                if (_digitando)
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                        color: Colors.cyanAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.cyanAccent)),
                        SizedBox(width: 6),
                        Text('DIGITANDO...',
                            style: TextStyle(
                                fontFamily: 'PixelifySans',
                                fontSize: 9,
                                color: Colors.cyanAccent)),
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
                  height: 1.5),
            ),
            if (!_digitando &&
                (etapaDialogo == 0 ||
                    (etapaDialogo == 1 &&
                        opcaoEscolhida.isEmpty &&
                        !dialogoFinalizado)) &&
                _textoExibido == _textoCompleto)
              Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  '👆 Toque para continuar...',
                  style: TextStyle(
                      fontFamily: 'PixelifySans',
                      fontSize: 11,
                      color: Colors.cyanAccent.withOpacity(0.6)),
                  textAlign: TextAlign.center,
                ),
              ),
            if (!_digitando &&
                etapaDialogo == 1 &&
                opcaoEscolhida.isEmpty &&
                !dialogoFinalizado &&
                _textoExibido == _textoCompleto)
              Column(
                children: [
                  SizedBox(height: 16),
                  _buildBotaoResposta('"O que aconteceu?"', () {
                    setState(() {
                      opcaoEscolhida = 'ajudar';
                      dialogoFinalizado = true;
                      _textoExibido = '';
                      _textoCompleto = '';
                    });
                  }),
                  SizedBox(height: 10),
                  _buildBotaoResposta('"Isso parece complicado..."', () {
                    setState(() {
                      opcaoEscolhida = 'complicado';
                    });
                  }),
                ],
              ),
            if (!_digitando &&
                etapaDialogo == 1 &&
                opcaoEscolhida == 'complicado' &&
                !missaoAceita &&
                _textoExibido == _textoCompleto)
              Column(
                children: [
                  SizedBox(height: 16),
                  _buildBotaoResposta('ACEITAR MISSÃO', () {
                    setState(() {
                      opcaoEscolhida = 'ajudar';
                      missaoAceita = true;
                      dialogoFinalizado = true;
                    });
                  }),
                ],
              ),
            if (!_digitando &&
                dialogoFinalizado &&
                _textoExibido == _textoCompleto)
              Column(
                children: [
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      border: Border.all(color: Colors.greenAccent, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.greenAccent, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '✓ Missão: "Em Busca de Capivarilda" iniciada!',
                            style: TextStyle(
                                fontFamily: 'PixelifySans',
                                color: Colors.greenAccent,
                                fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Ao aceitar seguir a missão, libera a biblioteca e abre o mapa
                      // de geolocalização da biblioteca, não a cena interna diretamente.
                      _buildBotaoAcao('IR PARA BIBLIOTECA', () {
                        // Libera o acesso à biblioteca no progresso global do jogo.
                        GameProgress.desbloquearBiblioteca();
                        _musicPlayer.stop();
                        // Abre o mapa/geolocalização da biblioteca em vez de entrar direto.
                        Navigator.pushNamed(context, '/mapa_biblioteca');
                      }),
                      _buildBotaoAcao('EXPLORAR H15', () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Explore o H15!'),
                              backgroundColor: Colors.cyan),
                        );
                      }),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoResposta(String texto, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Color(0xFF1a1f3a),
          border: Border.all(color: Colors.cyanAccent, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          texto,
          style: TextStyle(
              fontFamily: 'PixelifySans',
              fontSize: 13,
              color: Colors.cyanAccent),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildBotaoAcao(String texto, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          gradient:
              LinearGradient(colors: [Color(0xFF2a2f4a), Color(0xFF1a1f3a)]),
          border: Border.all(color: Colors.cyanAccent, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          texto,
          style: TextStyle(
              fontFamily: 'PixelifySans',
              fontSize: 11,
              color: Colors.cyanAccent),
        ),
      ),
    );
  }

  Widget _botaoPixelMapa(String texto, {Color cor = Colors.cyanAccent}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xFF1a1f3a),
        border: Border.all(color: cor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 10,
          color: cor,
        ),
      ),
    );
  }

  List<Widget> _buildPixelDecorations() {
    List<Widget> decos = [];
    final codigos = [
      '01001000 00110001 00110101',
      '01110000 01111001 01110100',
      '01101000 01101111 01101110'
    ];
    for (int i = 0; i < codigos.length; i++) {
      decos.add(Positioned(
        top: 30 + (i * 40),
        right: 10,
        child: Text(codigos[i],
            style: TextStyle(
                fontFamily: 'PixelifySans',
                fontSize: 10,
                color: Colors.cyanAccent.withOpacity(0.2))),
      ));
    }
    return decos;
  }
}