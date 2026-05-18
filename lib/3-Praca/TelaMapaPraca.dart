// -----------------------------------------------------------------------------
// ARQUIVO: tela_mapa_praca.dart
// OBJETIVO: Tela de geolocalização da Praça de Alimentação.
//
// COMENTÁRIOS IMPORTANTES DO MAPA:
// - O jogador aparece usando o sprite escolhido na criação do personagem.
// - O Rato fica na coordenada da Praça de Alimentação e é clicável.
// - A fase só pode ser acessada após a conclusão da missão da Biblioteca
//   (GameProgress.livroCorujitoEntregue == true).
// - Se o jogador estiver dentro do raio de 25m e clicar no Rato, entra na fase.
// - Se estiver fora do raio, exibe mensagem pedindo para se aproximar.
// - Se a Biblioteca ainda não foi concluída, exibe aviso de bloqueio.
// -----------------------------------------------------------------------------

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import 'package:arquivocapivara_app/player_data.dart';
import 'package:arquivocapivara_app/game_progress.dart';

class TelaMapaPraca extends StatefulWidget {
  const TelaMapaPraca({super.key});

  @override
  State<TelaMapaPraca> createState() => _TelaMapaPracaState();
}

class _TelaMapaPracaState extends State<TelaMapaPraca> {
  // Controlador do mapa usado para centralizar no jogador ou no ponto da Praça.
  final MapController _mapController = MapController();

  // Latitude inicial usada antes do navegador retornar a posição real do jogador.
  double _userLat = -22.833028267502936;
  // Longitude inicial usada antes do navegador retornar a posição real do jogador.
  double _userLng = -47.0520588566346;

  // Ponto central da Praça de Alimentação onde o Rato será posicionado.
  final LatLng _praca =
      LatLng(-22.833028267502936, -47.0520588566346);

  // Lista de pontos da rota desenhada no mapa quando o jogador clica em ROTA.
  List<LatLng> _rota = [];

  StreamSubscription<html.Geoposition>? _geoSubscription;

  // Controla se é a primeira leitura de GPS, para centralizar o mapa só uma vez.
  bool _primeiraLocalizacao = true;

  // Impede navegação dupla caso o GPS dispare dois eventos seguidos dentro do raio.
  bool _entrandoNaFase = false;

  double _zoomAtual = 17;

  // Raio de liberação: o jogador precisa estar até 25m do Rato para entrar.
  static const double _distanciaMinimaEntrada = 25;

  // Ajusta o tamanho dos ícones conforme o zoom do mapa muda.
  double _calcularTamanho(double base) {
    double fator = (20 - _zoomAtual) / 3;
    fator = fator.clamp(0.5, 2.5);
    return base * fator;
  }

  @override
  void initState() {
    super.initState();
    _carregarProgressoEIniciar();
  }

  // Carrega o progresso salvo antes de iniciar a geolocalização,
  // garantindo que GameProgress reflita o estado mais recente do localStorage.
  Future<void> _carregarProgressoEIniciar() async {
    await GameProgress.carregar();
    if (mounted) setState(() {});
    _iniciarLocalizacaoTempoReal();
  }

  // Usa a geolocalização do navegador para atualizar o jogador em tempo real.
  // Implementação voltada para execução no Chrome/Web.
  void _iniciarLocalizacaoTempoReal() {
    final geo = html.window.navigator.geolocation;
    if (geo == null) return;

    _geoSubscription =
        geo.watchPosition(enableHighAccuracy: true).listen((event) {
      if (!mounted) return;

      final pos = event as html.Geoposition;
      final lat = pos.coords?.latitude?.toDouble();
      final lng = pos.coords?.longitude?.toDouble();

      if (lat != null && lng != null) {
        setState(() {
          _userLat = lat;
          _userLng = lng;
        });

        // Centraliza o mapa apenas na primeira leitura real de GPS.
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

  // Calcula a distância em metros entre o jogador e a Praça de Alimentação.
  double _calcularDistancia() {
    return Distance().as(
      LengthUnit.Meter,
      LatLng(_userLat, _userLng),
      _praca,
    );
  }

  // Busca uma rota a pé via OSRM para guiar o jogador até a Praça de Alimentação.
  Future<void> _buscarRota() async {
    final url = 'https://router.project-osrm.org/route/v1/foot/'
        '$_userLng,$_userLat;${_praca.longitude},${_praca.latitude}'
        '?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'];

        if (!mounted) return;

        setState(() {
          _rota = coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível calcular a rota agora.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // Ao clicar no Rato:
  // 1. Verifica se a missão da Biblioteca foi concluída (pré-requisito).
  // 2. Verifica se o jogador está dentro do raio de 25m.
  // 3. Só então permite a entrada na fase da Praça de Alimentação.
  void _clicarRato() {
    // Pré-requisito: o livro do Corujito precisa ter sido entregue na Biblioteca.
    if (!GameProgress.livroCorujitoEntregue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '📚 Você precisa concluir a missão da Biblioteca antes de acessar a Praça de Alimentação!',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final distancia = _calcularDistancia();

    if (distancia <= _distanciaMinimaEntrada) {
      _entrarNaFase();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Você ainda está longe da Praça de Alimentação. Aproxime-se do Rato! '
          'Distância: ${distancia.toStringAsFixed(0)}m',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Navega para a primeira tela da fase da Praça de Alimentação.
  // Usa _entrandoNaFase para evitar navegação duplicada.
  void _entrarNaFase() {
    if (_entrandoNaFase) return;
    _entrandoNaFase = true;

    Navigator.pushReplacementNamed(context, '/pracaalimentacao');
  }

  @override
  void dispose() {
    _geoSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final distancia = _calcularDistancia();
    final bool faseBloqueada = !GameProgress.livroCorujitoEntregue;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ===================== MAPA =====================
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
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),

              // ===================== ROTA =====================
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

              // ===================== MARCADORES =====================
              MarkerLayer(
                markers: [
                  // Sprite do jogador na posição atual.
                  Marker(
                    point: LatLng(_userLat, _userLng),
                    width: _calcularTamanho(44),
                    height: _calcularTamanho(44),
                    child: Image.asset(
                      PlayerData.personagem,
                      width: _calcularTamanho(64),
                      height: _calcularTamanho(64),
                      filterQuality: FilterQuality.none,
                      isAntiAlias: false,
                    ),
                  ),

                  // Rato: ponto de referência da Praça de Alimentação.
                  // Fica esmaecido se a fase ainda estiver bloqueada,
                  // para indicar visualmente que não pode ser acessada ainda.
                  Marker(
                    point: _praca,
                    width: _calcularTamanho(54),
                    height: _calcularTamanho(54),
                    child: GestureDetector(
                      onTap: _clicarRato,
                      child: Opacity(
                        opacity: faseBloqueada ? 0.45 : 1.0,
                        child: Image.asset(
                          'assets/personagens/ratatoni.png',
                          width: _calcularTamanho(70),
                          height: _calcularTamanho(70),
                          filterQuality: FilterQuality.none,
                          isAntiAlias: false,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ===================== HUD SUPERIOR =====================
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.72),
                border: Border.all(
                  color: faseBloqueada ? Colors.redAccent : Colors.cyanAccent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '👤 Jogador: ${PlayerData.nomePersonagem}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 4),

                  // Mensagem muda conforme a fase está bloqueada ou não.
                  if (faseBloqueada)
                    const Text(
                      '🔒 Conclua a missão da Biblioteca antes de acessar a Praça de Alimentação!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.redAccent),
                    )
                  else
                    const Text(
                      '🐀 Vá até a Praça de Alimentação e clique no Rato para entrar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.cyanAccent),
                    ),

                  const SizedBox(height: 4),
                  Text(
                    'Distância até a Praça: ${distancia.toStringAsFixed(0)}m',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // ===================== BOTÃO: ROTA =====================
          Positioned(
            bottom: 40,
            right: 20,
            child: GestureDetector(
              onTap: _buscarRota,
              child: _botaoPixelComIcone('ROTA', Icons.alt_route),
            ),
          ),

          // ===================== BOTÃO: VER PRAÇA =====================
          Positioned(
            bottom: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => _mapController.move(_praca, 18),
              child: _botaoPixelComIcone('VER PRAÇA', Icons.location_on),
            ),
          ),

          // ===================== BOTÃO: VOLTAR =====================
          Positioned(
            top: 50,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: _botaoPixelComIcone('VOLTAR', Icons.arrow_back),
            ),
          ),
        ],
      ),
    );
  }

  // Botão visual padrão do projeto: fundo escuro com borda cyanAccent.
  Widget _botaoPixelComIcone(String texto, IconData icone) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1a1f3a),
        border: Border.all(color: Colors.cyanAccent, width: 2),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(3, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, color: Colors.cyanAccent, size: 18),
          const SizedBox(width: 6),
          Text(
            texto,
            style: const TextStyle(
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