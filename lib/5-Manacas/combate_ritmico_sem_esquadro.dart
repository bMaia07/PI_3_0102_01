import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class CombateRitmicoSemEsquadro extends StatefulWidget {
  final Function(bool victory) onBattleEnd;

  const CombateRitmicoSemEsquadro({
    super.key,
    required this.onBattleEnd,
  });

  @override
  State<CombateRitmicoSemEsquadro> createState() => _CombateRitmicoSemEsquadroState();
}

class _CombateRitmicoSemEsquadroState extends State<CombateRitmicoSemEsquadro> {
  int playerHealth = 10;
  List<int> enemyHealth = [3, 3, 3];
  int currentEnemy = 0;
  bool batalhaAtiva = true;
  bool aguardandoInput = false;
  String feedback = "";
  List<String> sequencia = [];
  List<String> inputUsuario = [];
  final List<String> direcoesValidas = ["↑", "↓", "←", "→"];
  Timer? timerDesafio;
  int tempoRestante = 4; // ⏱️ tempo maior (4 segundos)
  bool tempoAcabou = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    gerarNovaSequencia();
  }

  void gerarNovaSequencia() {
    sequencia.clear();
    inputUsuario.clear();
    for (int i = 0; i < 3; i++) {
      sequencia.add(direcoesValidas[_random.nextInt(direcoesValidas.length)]);
    }
    _reiniciarTimer();
    setState(() {
      aguardandoInput = true;
      tempoAcabou = false;
      feedback = "Repita a sequência!";
    });
  }

  void _reiniciarTimer() {
    timerDesafio?.cancel();
    tempoRestante = 4;
    timerDesafio = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted || !aguardandoInput) return;
      if (tempoRestante <= 1) {
        timer.cancel();
        tempoAcabou = true;
        aguardandoInput = false;
        _falhouSequencia();
      } else {
        setState(() => tempoRestante--);
      }
    });
  }

  void _falhouSequencia() {
    setState(() {
      playerHealth -= 2;
      feedback = "❌ Errou ou tempo esgotado! Perdeu 2 de vida.";
      aguardandoInput = false;
    });
    _verificarFimBatalha();
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && batalhaAtiva) gerarNovaSequencia();
    });
  }

  void _verificarFimBatalha() {
    if (playerHealth <= 0) {
      batalhaAtiva = false;
      widget.onBattleEnd(false);
      return;
    }
    if (enemyHealth[currentEnemy] <= 0) {
      if (currentEnemy + 1 < enemyHealth.length) {
        setState(() {
          currentEnemy++;
          feedback = "⚔️ Avançou para o próximo Carrapato!";
        });
        gerarNovaSequencia();
      } else {
        batalhaAtiva = false;
        widget.onBattleEnd(true); // ✅ VENCEU OS 3 CARRAPATOS
        return;
      }
    }
  }

  void _adicionarInput(String dir) {
    if (!batalhaAtiva || !aguardandoInput || tempoAcabou) return;
    setState(() => inputUsuario.add(dir));
    int idx = inputUsuario.length - 1;
    if (inputUsuario[idx] != sequencia[idx]) {
      _falhouSequencia();
      return;
    }
    if (inputUsuario.length == sequencia.length) {
      timerDesafio?.cancel();
      setState(() {
        enemyHealth[currentEnemy]--;
        feedback = "🔥 Acertou a sequência! Causou 1 de dano.";
        aguardandoInput = false;
      });
      _verificarFimBatalha();
      if (batalhaAtiva && mounted) gerarNovaSequencia();
    } else {
      _reiniciarTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF0a0e27).withOpacity(0.95),
        border: Border.all(color: Colors.cyanAccent, width: 3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildVidaPlayer(),
              Text("FASE 1", style: TextStyle(color: Colors.cyanAccent, fontFamily: 'PixelifySans')),
            ],
          ),
          SizedBox(height: 10),
          _buildBarrasInimigos(),
          Divider(color: Colors.cyanAccent),
          Text("🐛 Carrapato ${currentEnemy + 1} | Sequência: 3 direções",
              style: TextStyle(fontFamily: 'PixelifySans', color: Colors.cyanAccent)),
          SizedBox(height: 20),
          Wrap(
            spacing: 12,
            alignment: WrapAlignment.center,
            children: sequencia.asMap().entries.map((entry) {
              int idx = entry.key;
              String dir = entry.value;
              Color cor = inputUsuario.length > idx ? Colors.greenAccent : Colors.white70;
              return Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFF1a1f3a),
                  border: Border.all(color: inputUsuario.length > idx ? Colors.greenAccent : Colors.cyanAccent, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(dir, style: TextStyle(fontSize: 28, color: cor))),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [_botaoDirecao("↑", () => _adicionarInput("↑"))]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _botaoDirecao("←", () => _adicionarInput("←")),
                SizedBox(width: 20),
                _botaoDirecao("↓", () => _adicionarInput("↓")),
                SizedBox(width: 20),
                _botaoDirecao("→", () => _adicionarInput("→")),
              ]),
            ],
          ),
          if (aguardandoInput) Text("⏱️ $tempoRestante s", style: TextStyle(color: Colors.white)),
          Text(feedback, style: TextStyle(fontFamily: 'PixelifySans', color: Colors.cyanAccent)),
        ],
      ),
    );
  }

  Widget _buildVidaPlayer() => Column(children: [
        Text("Vida", style: TextStyle(fontFamily: 'PixelifySans', color: Colors.white70)),
        Row(children: [
          Icon(Icons.favorite, color: Colors.red, size: 16),
          Text("$playerHealth / 10", style: TextStyle(color: Colors.white)),
        ]),
      ]);

  Widget _buildBarrasInimigos() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(enemyHealth.length, (i) => Column(children: [
          Text("Carrapato ${i+1}", style: TextStyle(fontFamily: 'PixelifySans', color: Colors.cyanAccent)),
          Row(children: List.generate(3, (j) => Icon(j < enemyHealth[i] ? Icons.bug_report : Icons.bug_report_outlined, color: Colors.red))),
        ])),
      );

  Widget _botaoDirecao(String texto, VoidCallback onTap) => Padding(
        padding: EdgeInsets.all(8),
        child: ElevatedButton(
          onPressed: aguardandoInput && batalhaAtiva && !tempoAcabou ? onTap : null,
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1a1f3a), foregroundColor: Colors.cyanAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15)),
          child: Text(texto, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ),
      );
}