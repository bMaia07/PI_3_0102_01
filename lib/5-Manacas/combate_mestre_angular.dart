import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class CombateMestreAngular extends StatefulWidget {
  final Function(bool victory) onBattleEnd;

  const CombateMestreAngular({super.key, required this.onBattleEnd});

  @override
  State<CombateMestreAngular> createState() => _CombateMestreAngularState();
}

class _CombateMestreAngularState extends State<CombateMestreAngular> {
  int mestreHealth = 5;
  int playerHealth = 10;
  bool batalhaAtiva = true;
  bool aguardandoAtaque = true;
  String feedback = "";
  double anguloAtual = 0.0;
  double anguloAlvo = 0.0;
  Timer? timerBarreira;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _proximoAnguloAlvo();
  }

  void _proximoAnguloAlvo() {
    anguloAlvo = _random.nextInt(181).toDouble(); // 0 a 180
    setState(() {
      feedback = "Gire o Esquadro até o ângulo $anguloAlvo° e ATIRE!";
    });
    // Começa a barreira giratória (simula defesa do mestre)
    _iniciarBarreira();
  }

  void _iniciarBarreira() {
    timerBarreira?.cancel();
    timerBarreira = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!batalhaAtiva) {
        timer.cancel();
        return;
      }
      setState(() {
        anguloAtual = (anguloAtual + 3) % 180;
      });
    });
  }

  void _atacar() {
    if (!batalhaAtiva || !aguardandoAtaque) return;
    double diff = (anguloAlvo - anguloAtual).abs();
    bool acertoCritico = diff <= 5;
    bool acertoNormal = diff <= 15;
    if (acertoCritico) {
      mestreHealth -= 2;
      feedback = "⚡ ACERTO CRÍTICO! Causou 2 de dano!";
    } else if (acertoNormal) {
      mestreHealth -= 1;
      feedback = "✓ Acerto! Causou 1 de dano.";
    } else {
      playerHealth -= 2;
      feedback = "❌ Errou o ângulo! Levou 2 de dano.";
    }
    setState(() {});
    if (mestreHealth <= 0) {
      batalhaAtiva = false;
      timerBarreira?.cancel();
      widget.onBattleEnd(true);
    } else if (playerHealth <= 0) {
      batalhaAtiva = false;
      timerBarreira?.cancel();
      widget.onBattleEnd(false);
    } else {
      _proximoAnguloAlvo();
    }
  }

  void _ajustarAngulo(double delta) {
    if (!batalhaAtiva) return;
    setState(() {
      anguloAtual = (anguloAtual + delta).clamp(0.0, 180.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF0a0e27).withOpacity(0.95),
        border: Border.all(color: Colors.deepPurple, width: 4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("🐗 CARRAPATO MESTRE", style: TextStyle(fontFamily: 'PixelifySans', fontSize: 20, color: Colors.deepPurpleAccent)),
          SizedBox(height: 10),
          LinearProgressIndicator(value: mestreHealth / 5, color: Colors.red, backgroundColor: Colors.grey),
          SizedBox(height: 10),
          _buildVidaPlayer(),
          Divider(color: Colors.deepPurple),
          Text("🎯 Ângulo alvo: ${anguloAlvo.toStringAsFixed(0)}°", style: TextStyle(fontFamily: 'PixelifySans', fontSize: 20, color: Colors.yellowAccent)),
          SizedBox(height: 20),
          _mostrarEsquadro(),
          SizedBox(height: 20),
          Text("Esquadro aponta: ${anguloAtual.toStringAsFixed(0)}°", style: TextStyle(fontFamily: 'PixelifySans', color: Colors.white)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _botaoAngular("-10", () => _ajustarAngulo(-10)),
              _botaoAngular("-1", () => _ajustarAngulo(-1)),
              _botaoAngular("+1", () => _ajustarAngulo(1)),
              _botaoAngular("+10", () => _ajustarAngulo(10)),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: batalhaAtiva ? _atacar : null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white, padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12)),
            child: Text("⚔️ ATIRAR COM ESQUADRO ⚔️", style: TextStyle(fontFamily: 'PixelifySans', fontSize: 16)),
          ),
          Text(feedback, style: TextStyle(fontFamily: 'PixelifySans', color: Colors.cyanAccent)),
        ],
      ),
    );
  }

  Widget _mostrarEsquadro() {
    return Container(
      width: 200,
      height: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.deepPurple, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CustomPaint(
        painter: EsquadroPainter(anguloAtual),
        size: Size(200, 100),
      ),
    );
  }

  Widget _buildVidaPlayer() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(Icons.favorite, color: Colors.red),
    Text(" $playerHealth / 10", style: TextStyle(fontFamily: 'PixelifySans', color: Colors.white)),
  ]);

  Widget _botaoAngular(String texto, VoidCallback onTap) => Padding(
        padding: EdgeInsets.all(6),
        child: ElevatedButton(
          onPressed: batalhaAtiva ? onTap : null,
          child: Text(texto, style: TextStyle(fontSize: 18)),
        ),
      );
}

class EsquadroPainter extends CustomPainter {
  final double angle;
  EsquadroPainter(this.angle);
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    final Paint paintArc = Paint()..color = Colors.deepPurple..strokeWidth = 2..style = PaintingStyle.stroke;
    final Paint paintPointer = Paint()..color = Colors.yellow..strokeWidth = 3;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), pi, pi, false, paintArc);
    double rad = (angle - 90) * pi / 180;
    Offset pointerEnd = center + Offset(radius * 0.9 * cos(rad), radius * 0.9 * sin(rad));
    canvas.drawLine(center, pointerEnd, paintPointer);
    // desenha marcações a cada 30 graus
    for (int ang = 0; ang <= 180; ang += 30) {
      double r = (ang - 90) * pi / 180;
      Offset start = center + Offset(radius * 0.7 * cos(r), radius * 0.7 * sin(r));
      Offset end = center + Offset(radius * 0.9 * cos(r), radius * 0.9 * sin(r));
      canvas.drawLine(start, end, paintArc);
    }
  }
  @override
  bool shouldRepaint(covariant EsquadroPainter oldDelegate) => oldDelegate.angle != angle;
}