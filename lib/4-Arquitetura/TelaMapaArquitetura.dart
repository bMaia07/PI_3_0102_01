// -----------------------------------------------------------------------------
// ARQUIVO: tela_mapa_arquitetura.dart
// OBJETIVO: Tela de geolocalização do prédio de Arquitetura.
//
// COMENTÁRIOS IMPORTANTES DO MAPA:
// - O jogador aparece usando o sprite escolhido na criação do personagem.
// - O Coala fica na coordenada do prédio de Arquitetura e é clicável.
// - A fase só pode ser acessada após a conclusão da Praça de Alimentação
//   (GameProgress.pracaDesbloqueada == true).
// - Se o jogador estiver dentro do raio de 25m e clicar no Coala, entra na fase.
// - Se estiver fora do raio, exibe mensagem pedindo para se aproximar.
// - Se a Praça de Alimentação ainda não foi concluída, exibe aviso de bloqueio.
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

class TelaMapaArquitetura extends StatefulWidget {
  const TelaMapaArquitetura({super.key});

  @override
  State<TelaMapaArquitetura> createState() => _TelaMapaArquiteturaState();
}

class _TelaMapaArquiteturaState extends State<TelaMapaArquitetura> {
  // Controlador do mapa usado para centralizar no jogador ou no ponto da Arquitetura.
  final MapController _mapController = MapController();

  // Latitude inicial usada antes do navegador retornar a posição real do jogador.
  double _userLat = -22.83194737673203;
  // Longitude inicial usada antes do navegador retornar a posição real do jogador.
  double _userLng = -47.052204537602655;

  // Ponto central do prédio de Arquitetura onde o Coala será posicionado.
  final LatLng _arquitetura =
      LatLng(-22.83194737673203, -47.052204537602655);

  // Lista de pontos da rota desenhada no mapa quando o jogador clica em ROTA.
  List<LatLng> _rota = [];

  StreamSubscription<html.Geoposition>? _geoSubscription;

  // Controla se é a primeira leitura de GPS, para centralizar o mapa só uma vez.
  bool _primeiraLocalizacao = true;

  // Impede navegação dupla caso o GPS dispare dois eventos seguidos dentro do raio.
  bool _entrandoNaFase = false;

  double _zoomAtual = 17;

  // Raio de liberação: o jogador precisa estar até 25m do Coala para entrar.
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

  // Calcula a distância em metros entre o jogador e o prédio de Arquitetura.
  double _calcularDistancia() {
    return Distance().as(
      LengthUnit.Meter,
      LatLng(_userLat, _userLng),
      _arquitetura,
    );
  }

  // Busca uma rota a pé via OSRM para guiar o jogador até o prédio de Arquitetura.
  Future<void> _buscarRota() async {
    final url = 'https://router.project-osrm.org/route/v1/foot/'
        '$_userLng,$_userLat;${_arquitetura.longitude},${_arquitetura.latitude}'
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

  // Ao clicar no Coala:
  // 1. Verifica se a Praça de Alimentação foi concluída (pré-requisito).
  // 2. Verifica se o jogador está dentro do raio de 25m.
  // 3. Só então permite a entrada na fase de Arquitetura.
  void _clicarCoala() {
    // Pré-requisito: a fase da Praça de Alimentação precisa estar concluída.
    if (!GameProgress.pracaDesbloqueada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '🍽️ Você precisa concluir a Praça de Alimentação antes de acessar o prédio de Arquitetura!',
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
          'Você ainda está longe do prédio de Arquitetura. Aproxime-se do Coala! '
          'Distância: ${distancia.toStringAsFixed(0)}m',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // Navega para a primeira tela da fase de Arquitetura.
  // Usa _entrandoNaFase para evitar navegação duplicada.
  void _entrarNaFase() {
    if (_entrandoNaFase) return;
    _entrandoNaFase = true;

    // Marca a arquitetura como desbloqueada no progresso global.
    GameProgress.desbloquearArquitetura().then((_) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/arquiteturaOUT');
    });
  }

  @override
  void dispose() {
    _geoSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final distancia = _calcularDistancia();
    final bool faseBloqueada = !GameProgress.pracaDesbloqueada;

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

                  // Coala: ponto de referência do prédio de Arquitetura.
                  // Fica esmaecido se a fase ainda estiver bloqueada,
                  // para indicar visualmente que não pode ser acessada ainda.
                  Marker(
                    point: _arquitetura,
                    width: _calcularTamanho(54),
                    height: _calcularTamanho(54),
                    child: GestureDetector(
                      onTap: _clicarCoala,
                      child: Opacity(
                        opacity: faseBloqueada ? 0.45 : 1.0,
                        child: Image.asset(
                          'assets/personagens/coala.png',
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
                      '🔒 Conclua a Praça de Alimentação para desbloquear o prédio de Arquitetura!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.redAccent),
                    )
                  else
                    const Text(
                      '🐨 Vá até o prédio de Arquitetura e clique no Coala para entrar!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.cyanAccent),
                    ),

                  const SizedBox(height: 4),
                  Text(
                    'Distância até a Arquitetura: ${distancia.toStringAsFixed(0)}m',
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

          // ===================== BOTÃO: VER ARQUITETURA =====================
          Positioned(
            bottom: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => _mapController.move(_arquitetura, 18),
              child:
                  _botaoPixelComIcone('VER ARQUITETURA', Icons.location_on),
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