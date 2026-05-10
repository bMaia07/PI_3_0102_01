// -----------------------------------------------------------------------------
// COMENTÁRIOS IMPORTANTES DO MAPA:
// - O jogador aparece usando o sprite escolhido na criação do personagem.
// - O Pingo continua no mapa como referência do H15.
// - A Corujita fica na coordenada da biblioteca e é clicável.
// - Se o jogador estiver perto o suficiente, clicar nela abre a biblioteca.
// Tela de geolocalização da biblioteca.
// Depois do H15/Pingo, o jogador vem para este mapa, vê Pingo como referência,
// encontra a Corujita no ponto da biblioteca e só entra na biblioteca ao chegar
// perto o suficiente dela.
// -----------------------------------------------------------------------------
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

import 'player_data.dart';

class TelaMapaBiblioteca extends StatefulWidget {
  const TelaMapaBiblioteca({super.key});

  @override
  State<TelaMapaBiblioteca> createState() => _TelaMapaBibliotecaState();
}

class _TelaMapaBibliotecaState extends State<TelaMapaBiblioteca> {
  // Controlador do mapa usado para centralizar no jogador ou no ponto da biblioteca.
  final MapController _mapController = MapController();

  // Latitude inicial usada antes do navegador retornar a posição real do jogador.
  double _userLat = -22.834084781581872;
  // Longitude inicial usada antes do navegador retornar a posição real do jogador.
  double _userLng = -47.052650679667536;

  // Ponto da Corujita na região da biblioteca.
  // Ajustado para o ponto indicado no mapa.
  // Coordenada exata enviada para posicionar a Corujita no ponto desejado.
  final LatLng _biblioteca = LatLng(-22.834091097460284, -47.051857007284134);

  // Mantém o Pingo aparecendo no mapa como referência do H15.
  // Coordenada do Pingo/H15 para ele continuar aparecendo como referência no mapa.
  final LatLng _pingoH15 = LatLng(-22.834084781581872, -47.052650679667536);

  // Lista de pontos da rota desenhada no mapa quando o jogador clica em ROTA.
  List<LatLng> _rota = [];
  StreamSubscription<html.Geoposition>? _geoSubscription;

  // Controla se é a primeira leitura de GPS, para centralizar o mapa só uma vez.
  bool _primeiraLocalizacao = true;
  bool _entrandoNaBiblioteca = false;
  double _zoomAtual = 17;

  // Raio de liberação: o jogador precisa estar até 35m da Corujita para entrar.
  // Distância máxima em metros para permitir entrar na biblioteca clicando na Corujita.
  static const double _distanciaMinimaEntrada = 35;

  // Ajusta o tamanho dos ícones quando o zoom do mapa muda.
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

  // Usa a geolocalização do navegador para atualizar o jogador em tempo real.
  // Esta implementação é voltada para execução no Chrome/Web.
  void _iniciarLocalizacaoTempoReal() {
    final geo = html.window.navigator.geolocation;
    if (geo == null) return;

    _geoSubscription = geo.watchPosition(enableHighAccuracy: true).listen((event) {
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
          _mapController.move(LatLng(_userLat, _userLng), _mapController.camera.zoom);
          _primeiraLocalizacao = false;
        }
      }
    });
  }

  // Calcula a distância entre a localização atual do jogador e a Corujita.
  double _calcularDistancia() {
    return Distance().as(
      LengthUnit.Meter,
      LatLng(_userLat, _userLng),
      _biblioteca,
    );
  }

  // Busca uma rota a pé usando OSRM, apenas para guiar visualmente até a biblioteca.
  Future<void> _buscarRota() async {
    final url = 'https://router.project-osrm.org/route/v1/foot/'
        '$_userLng,$_userLat;${_biblioteca.longitude},${_biblioteca.latitude}'
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

  // Clicar na Corujita só abre a biblioteca se o jogador estiver dentro do raio.
  void _clicarCorujita() {
    final distancia = _calcularDistancia();

    if (distancia <= _distanciaMinimaEntrada) {
      _entrarBiblioteca();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Você ainda está longe da biblioteca. Aproxime-se da Corujita! Distância: ${distancia.toStringAsFixed(0)}m',
        ),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _entrarBiblioteca() {
    if (_entrandoNaBiblioteca) return;
    _entrandoNaBiblioteca = true;

    // Troca a tela de mapa pela primeira tela da biblioteca.
    Navigator.pushReplacementNamed(context, '/biblioteca');
  }

  @override
  void dispose() {
    _geoSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final distancia = _calcularDistancia();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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
              MarkerLayer(
                markers: [
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
                  Marker(
                    point: _pingoH15,
                    width: _calcularTamanho(46),
                    height: _calcularTamanho(46),
                    child: Image.asset(
                      'assets/personagens/pingo.png',
                      width: _calcularTamanho(64),
                      height: _calcularTamanho(64),
                      filterQuality: FilterQuality.none,
                      isAntiAlias: false,
                    ),
                  ),
                  Marker(
                    point: _biblioteca,
                    width: _calcularTamanho(54),
                    height: _calcularTamanho(54),
                    child: GestureDetector(
                      onTap: _clicarCorujita,
                      child: Image.asset(
                        'assets/personagens/corujito.png',
                        width: _calcularTamanho(70),
                        height: _calcularTamanho(70),
                        filterQuality: FilterQuality.none,
                        isAntiAlias: false,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.72),
                border: Border.all(color: Colors.cyanAccent, width: 2),
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
                  const Text(
                    '🦉 Vá até a biblioteca e clique na Corujita para entrar!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Distância até a biblioteca: ${distancia.toStringAsFixed(0)}m',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 20,
            child: GestureDetector(
              onTap: _buscarRota,
              child: _botaoPixelComIcone('ROTA', Icons.alt_route),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => _mapController.move(_biblioteca, 18),
              child: _botaoPixelComIcone('VER BIBLIOTECA', Icons.location_on),
            ),
          ),
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

  // Botão visual usado nas ações do mapa: voltar, rota e centralizar biblioteca.
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