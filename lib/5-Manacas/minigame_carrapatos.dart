import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class MinigameCarrapatos extends StatefulWidget {
  final Function(bool success) onGameEnd;
  const MinigameCarrapatos({super.key, required this.onGameEnd});

  @override
  State<MinigameCarrapatos> createState() => _MinigameCarrapatosState();
}

class _MinigameCarrapatosState extends State<MinigameCarrapatos> {
  int vidaJogador = 10;
  int carrapatosRestantes = 10;
  bool faseMestre = false;
  int cliquesNoMestre = 0;
  final int cliquesParaDerrotarMestre = 20;
  List<CarrapatoComum> carrapatosAtivos = [];
  Timer? spawnTimer;
  Timer? ataqueMestreTimer;
  final Random random = Random();

  final double tempoVidaCarrapato = 2.0;
  final double intervaloSpawm = 1.2;
  final double intervaloAtaqueMestre = 2.0;

  @override
  void initState() {
    super.initState();
    iniciarSpawn();
  }

  void iniciarSpawn() {
    spawnTimer = Timer.periodic(Duration(milliseconds: (intervaloSpawm * 1000).round()), (timer) {
      if (faseMestre) return;
      if (carrapatosRestantes <= 0) {
        ativarFaseMestre();
        return;
      }
      if (carrapatosAtivos.length < 5) {
        final novoId = DateTime.now().millisecondsSinceEpoch + random.nextInt(10000);
        final novaPosicao = Offset(
          random.nextDouble() * (MediaQuery.of(context).size.width - 80),
          random.nextDouble() * 300,
        );
        setState(() {
          carrapatosAtivos.add(CarrapatoComum(id: novoId, posicao: novaPosicao));
        });
        Future.delayed(Duration(milliseconds: (tempoVidaCarrapato * 1000).round()), () {
          setState(() {
            if (carrapatosAtivos.any((c) => c.id == novoId)) {
              carrapatosAtivos.removeWhere((c) => c.id == novoId);
              vidaJogador--;
              if (vidaJogador <= 0) {
                spawnTimer?.cancel();
                ataqueMestreTimer?.cancel();
                widget.onGameEnd(false);
              }
            }
          });
        });
      }
    });
  }

  void ativarFaseMestre() {
    spawnTimer?.cancel();
    setState(() {
      faseMestre = true;
      carrapatosAtivos.clear();
    });
    ataqueMestreTimer = Timer.periodic(Duration(seconds: intervaloAtaqueMestre.toInt()), (timer) {
      if (!faseMestre) return;
      setState(() {
        vidaJogador--;
        if (vidaJogador <= 0) {
          timer.cancel();
          widget.onGameEnd(false);
        }
      });
    });
  }

  void clicarMestre() {
    if (!faseMestre) return;
    setState(() => cliquesNoMestre++);
    if (cliquesNoMestre >= cliquesParaDerrotarMestre) {
      ataqueMestreTimer?.cancel();
      widget.onGameEnd(true);
    }
  }

  @override
  void dispose() {
    spawnTimer?.cancel();
    ataqueMestreTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red, size: 28),
                    SizedBox(width: 8),
                    Text("$vidaJogador", style: TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'PixelifySans')),
                  ],
                ),
                if (!faseMestre)
                  Row(
                    children: [
                      Image.asset('assets/personagens/manacas/carrapato_mau.png', width: 30, height: 30),
                      SizedBox(width: 8),
                      Text("$carrapatosRestantes", style: TextStyle(fontSize: 24, color: Colors.white, fontFamily: 'PixelifySans')),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(color: Colors.black),
                ...carrapatosAtivos.map((c) => Positioned(
                  left: c.posicao.dx,
                  top: c.posicao.dy,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (carrapatosAtivos.contains(c)) {
                          carrapatosAtivos.remove(c);
                          carrapatosRestantes--;
                        }
                      });
                    },
                    child: Image.asset('assets/personagens/manacas/carrapato_mau.png', width: 60, height: 60),
                  ),
                )).toList(),
                if (faseMestre)
                  Center(
                    child: GestureDetector(
                      onTap: clicarMestre,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset('assets/personagens/manacas/carrapatao.png', width: 250, height: 250),
                          SizedBox(height: 20),
                          Text(
                            "Cliques: $cliquesNoMestre / $cliquesParaDerrotarMestre",
                            style: TextStyle(fontFamily: 'PixelifySans', color: Colors.white, fontSize: 18),
                          ),
                          SizedBox(height: 10),
                          Container(
                            width: 200,
                            child: LinearProgressIndicator(
                              value: cliquesNoMestre / cliquesParaDerrotarMestre,
                              backgroundColor: Colors.grey,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "⚠️ Ele ataca a cada $intervaloAtaqueMestre segundos!",
                            style: TextStyle(fontFamily: 'PixelifySans', color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CarrapatoComum {
  final int id;
  final Offset posicao;
  CarrapatoComum({required this.id, required this.posicao});
}