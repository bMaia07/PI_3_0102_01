// -----------------------------------------------------------------------------
// Mapa de exploração principal. Recebe e mantém dados do jogador, como nome do
// personagem e sprite, para serem usados nos mapas e diálogos.
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// -----------------------------------------------------------------------------
// ARQUIVO: tela_mapa_exploracao.dart
// COMENTÁRIOS DO MAPA PRINCIPAL:
// - Mostra o jogador andando pelo campus.
// - Usa PlayerData.personagem para mostrar o sprite escolhido.
// - A entrada no H15 depende da distância entre jogador e marcador do Pingo/H15.
// -----------------------------------------------------------------------------
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'player_data.dart';

class TelaMapaExploracao extends StatefulWidget {
  @override
  _TelaMapaExploracaoState createState() => _TelaMapaExploracaoState();
}

class _TelaMapaExploracaoState extends State<TelaMapaExploracao> {
  final MapController _mapController = MapController();

  Map? save;

  double _userLat = -22.834084781581872;
  double _userLng = -47.052650679667536;

  bool _primeiraLocalizacao = true;

  double _zoomAtual = 17;

  final LatLng _h15 = LatLng(-22.834084781581872, -47.052650679667536);

  List<LatLng> _rota = [];

  // 🔥 NOVO: dados do jogador
  String _personagem = 'assets/personagens/player-masc.png';
  String _nome = 'Jogador';
  String _nomeSave = 'Save';
  bool _dadosCarregados = false;

  // Impede navegação dupla caso o GPS dispare dois eventos seguidos dentro do raio.
  bool _entrandoNoH15 = false;

  // Raio de liberação: o jogador precisa estar até 25m do Pingo para entrar.
  static const double _distanciaMinimaEntrada = 25;

  // 🔥 GEOLOCALIZAÇÃO
  StreamSubscription<html.Geoposition>? _geoSubscription;

  double _calcularTamanho(double base) {
    double fator = (20 - _zoomAtual) / 3;
    fator = fator.clamp(0.5, 2.5);
    return base * fator;
  }

  @override
  void initState() {
    super.initState();
    _iniciarLocalizacaoTempoReal();
  }

  // ================= 📡 LOCALIZAÇÃO =================
  void _iniciarLocalizacaoTempoReal() {
    final geo = html.window.navigator.geolocation;

    if (geo == null) return;

    _geoSubscription = geo
        .watchPosition(
      enableHighAccuracy: true,
    )
        .listen((event) {
      if (!mounted) return;

      final pos = event as html.Geoposition;

      final lat = pos.coords?.latitude?.toDouble();
      final lng = pos.coords?.longitude?.toDouble();

      if (lat != null && lng != null) {
        setState(() {
          _userLat = lat;
          _userLng = lng;
        });

        if (_primeiraLocalizacao) {
          _mapController.move(
            LatLng(_userLat, _userLng),
            _mapController.camera.zoom,
          );
          _primeiraLocalizacao = false;
        }

      }
    });
  }

  // ================= 📏 DISTÂNCIA =================
  double _calcularDistancia() {
    return Distance().as(
      LengthUnit.Meter,
      LatLng(_userLat, _userLng),
      _h15,
    );
  }

  // ================= 🎯 CLIQUE NO PINGO =================
  // Ao clicar no Pingo, verifica se o jogador está dentro do raio de 25m.
  // Só então permite a entrada no H15.
  void _clicarPingo() {
    if (_entrandoNoH15) return;

    final distancia = _calcularDistancia();

    if (distancia <= _distanciaMinimaEntrada) {
      _entrandoNoH15 = true;
      Navigator.pushReplacementNamed(context, '/h15');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Você ainda está longe do Pingo. Aproxime-se! '
          'Distância: ${distancia.toStringAsFixed(0)}m',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // ================= 🗺️ ROTA =================
  Future<void> _buscarRota() async {
    final url = 'https://router.project-osrm.org/route/v1/foot/'
        '$_userLng,$_userLat;${_h15.longitude},${_h15.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final coords = data['routes'][0]['geometry']['coordinates'];

        if (!mounted) return;

        setState(() {
          _rota = coords.map<LatLng>((c) {
            return LatLng(c[1], c[0]);
          }).toList();
        });
      }
    } catch (e) {
      print('Erro rota: $e');
    }
  }

  Future<void> salvarProgresso() async {
    final prefs = await SharedPreferences.getInstance();
    final dados = prefs.getString('saves');

    if (dados == null || save == null) return;

    List saves = jsonDecode(dados);

    for (var s in saves) {
      if (s['nome'] == save!['nome']) {
        s['lat'] = _userLat;
        s['lng'] = _userLng;
      }
    }

    await prefs.setString('saves', jsonEncode(saves));
  }

  @override
  void dispose() {
    _geoSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_dadosCarregados) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;

      if (args != null) {
        save = args;

        _personagem = args['personagem'] ?? _personagem;
        _nomeSave = args['nome'] ?? _nomeSave;
        // Usa o nome do personagem no mapa, com fallback para o nome do save.
        _nome = args['nomePersonagem'] ?? args['nome'] ?? _nome;

        PlayerData.atualizar(
          novoNomeSave: _nomeSave,
          novoNomePersonagem: _nome,
          novoPersonagem: _personagem,
        );

        if (args['lat'] != null && args['lng'] != null) {
          _userLat = args['lat'];
          _userLng = args['lng'];
        }
      }

      _dadosCarregados = true;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 🗺️ MAPA
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(_userLat, _userLng),
              initialZoom: 17,
              onPositionChanged: (position, hasGesture) {
                if (!mounted) return;
                setState(() {
                  _zoomAtual = position.zoom ?? _zoomAtual;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),

              // 🧭 ROTA
              if (_rota.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _rota,
                      strokeWidth: 4,
                      color: Colors.blueAccent,
                    ),
                  ],
                ),

              // 📍 MARCADORES
              MarkerLayer(
                markers: [
                  // 👤 JOGADOR
                  Marker(
                    point: LatLng(_userLat, _userLng),
                    width: _calcularTamanho(40),
                    height: _calcularTamanho(40),
                    child: Image.asset(
                      _personagem,
                      width: _calcularTamanho(60),
                      height: _calcularTamanho(60),
                    ),
                  ),

                  // 🐧 DESTINO — clicável dentro do raio de 25m
                  Marker(
                    point: _h15,
                    width: _calcularTamanho(60),
                    height: _calcularTamanho(60),
                    child: GestureDetector(
                      onTap: _clicarPingo,
                      child: Image.asset(
                        'assets/personagens/pingo.png',
                        width: _calcularTamanho(80),
                        height: _calcularTamanho(80),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // 🎮 HUD
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                border: Border.all(color: Colors.cyanAccent),
              ),
              child: Column(
                children: [
                  Text(
                    '👤 Jogador: $_nome',
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    '🐧 Vá até o Pingo e clique nele para iniciar o jogo!',
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                  Text(
                    'Distância: ${_calcularDistancia().toStringAsFixed(0)}m',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // 🚀 BOTÃO ROTA
          Positioned(
            bottom: 40,
            right: 20,
            child: GestureDetector(
              onTap: _buscarRota,
              child: _botaoPixelComIcone('ROTA', Icons.alt_route),
            ),
          ),

          // 🔙 BOTÃO VOLTAR
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () async {
                final sair = await showDialog<bool>(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.cyanAccent, width: 2),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SAIR DO JOGO?',
                            style: TextStyle(
                              fontFamily: 'PixelifySans',
                              color: Colors.cyanAccent,
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context, false),
                                child:
                                    _botaoPixel('CANCELAR', Colors.cyanAccent),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context, true),
                                child: _botaoPixel('SAIR', Colors.redAccent),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                if (sair == true) {
                  await salvarProgresso();
                  Navigator.pop(context);
                }
              },
              child: _botaoPixelComIcone('VOLTAR', Icons.arrow_back),
            ),
          ),
        ],
      ),
    );
  }

  // 🔘 BOTÕES
  Widget _botaoPixel(String texto, Color cor) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: Color(0xFF1a1f3a),
        border: Border.all(color: cor, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontFamily: 'PixelifySans',
          fontSize: 11,
          color: cor,
        ),
      ),
    );
  }

  Widget _botaoPixelComIcone(String texto, IconData icone) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xFF1a1f3a),
        border: Border.all(color: Colors.cyanAccent, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icone, color: Colors.cyanAccent, size: 18),
          SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              fontFamily: 'PixelifySans',
              fontSize: 12,
              color: Colors.cyanAccent,
            ),
          ),
        ],
      ),
    );
  }
}