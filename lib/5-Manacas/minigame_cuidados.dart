import 'package:flutter/material.dart';
import 'dart:math';

class MinigameCuidados extends StatefulWidget {
  final Function() onComplete;
  const MinigameCuidados({super.key, required this.onComplete});

  @override
  State<MinigameCuidados> createState() => _MinigameCuidadosState();
}

class _MinigameCuidadosState extends State<MinigameCuidados> {
  // Ações concluídas
  bool banhoFeito = false;
  bool folhasFeito = false;
  bool galhosFeito = false;
  bool pomadaFeito = false;
  bool penteFeito = false;
  bool lacinhoFeito = false;

  bool allDone = false;

  final Random random = Random();

  // Elementos interativos sobre a capivara
  List<Offset> sujeiras = [];
  List<Offset> folhas = [];
  List<Offset> galhos = [];
  List<Offset> machucados = [];

  @override
  void initState() {
    super.initState();
    _gerarPosicoes();
  }

  void _gerarPosicoes() {
    sujeiras = List.generate(3, (_) => Offset(
      100 + random.nextDouble() * 200,
      160 + random.nextDouble() * 200,
    ));
    folhas = List.generate(3, (_) => Offset(
      80 + random.nextDouble() * 240,
      150 + random.nextDouble() * 200,
    ));
    galhos = List.generate(2, (_) => Offset(
      90 + random.nextDouble() * 100,
      300 + random.nextDouble() * 80,
    ));
    machucados = List.generate(2, (_) => Offset(
      140 + random.nextDouble() * 180,
      180 + random.nextDouble() * 150,
    ));
  }

  void _verificarConclusao() {
    if (banhoFeito && folhasFeito && galhosFeito && pomadaFeito && penteFeito && lacinhoFeito) {
      setState(() {
        allDone = true;
      });
    }
  }

  void _aplicarBanho() {
    if (!banhoFeito) {
      setState(() {
        sujeiras.clear();
        banhoFeito = true;
      });
      _verificarConclusao();
    }
  }

  void _aplicarFolha() {
    if (!folhasFeito) {
      setState(() {
        folhas.clear();
        folhasFeito = true;
      });
      _verificarConclusao();
    }
  }

  void _aplicarGalho() {
    if (!galhosFeito) {
      setState(() {
        galhos.clear();
        galhosFeito = true;
      });
      _verificarConclusao();
    }
  }

  void _aplicarPomada() {
    if (!pomadaFeito) {
      setState(() {
        machucados.clear();
        pomadaFeito = true;
      });
      _verificarConclusao();
    }
  }

  void _aplicarPente() {
    if (!penteFeito) {
      setState(() {
        penteFeito = true;
      });
      _verificarConclusao();
    }
  }

  void _aplicarLacinho() {
    if (!lacinhoFeito) {
      setState(() {
        lacinhoFeito = true;
      });
      _verificarConclusao();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tela final após todos os cuidados
    if (allDone) {
      return Container(
        color: Colors.brown.shade900,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/fundo/Manacas/sala_principal_cap.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(color: Colors.black.withOpacity(0.5)),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/personagens/manacas/capivara_bem.png',
                    height: 300,
                    errorBuilder: (_, __, ___) => Icon(Icons.pets, size: 150),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      widget.onComplete();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(38, 23, 23, 1),
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Voltar à sala principal", style: TextStyle(fontFamily: 'PixelifySans', fontSize: 18)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Tela principal do minigame com drag & drop
    return Container(
      color: Colors.brown.shade900,
      child: Stack(
        children: [
          // Fundo
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fundo/Manacas/sala_principal_cap.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.5)),

          // DragTarget (a capivara) - recebe os itens arrastados
          Center(
            child: DragTarget<String>(
              onAccept: (data) {
                if (data == "sabao") _aplicarBanho();
                if (data == "folha") _aplicarFolha();
                if (data == "galho") _aplicarGalho();
                if (data == "pomada") _aplicarPomada();
                if (data == "pente") _aplicarPente();
                if (data == "laco") _aplicarLacinho();
              },
              builder: (context, candidateData, rejectedData) {
                return Stack(
                  children: [
                    Image.asset(
                      'assets/personagens/manacas/capivara_machucada.png',
                      height: 400,
                      errorBuilder: (_, __, ___) => Container(height: 400, color: Colors.brown),
                    ),
                    // Sujeiras
                    ...sujeiras.map((pos) => Positioned(
                      left: pos.dx,
                      top: pos.dy,
                      child: Image.asset('assets/personagens/manacas/sujeira.png', width: 35, height: 35),
                    )),
                    // Folhas
                    ...folhas.map((pos) => Positioned(
                      left: pos.dx,
                      top: pos.dy,
                      child: Image.asset('assets/personagens/manacas/folha.png', width: 35, height: 35),
                    )),
                    // Galhos
                    ...galhos.map((pos) => Positioned(
                      left: pos.dx,
                      top: pos.dy,
                      child: Image.asset('assets/personagens/manacas/galho.png', width: 35, height: 35),
                    )),
                    // Machucados
                    ...machucados.map((pos) => Positioned(
                      left: pos.dx,
                      top: pos.dy,
                      child: Image.asset('assets/personagens/manacas/machucado.png', width: 35, height: 35),
                    )),
                  ],
                );
              },
            ),
          ),

          // Barra inferior com itens arrastáveis
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDraggableItem('assets/personagens/manacas/sabao.png', 'sabao', banhoFeito, "Limpar sujeira"),
                  _buildDraggableItem('assets/personagens/manacas/folha.png', 'folha', folhasFeito, "Tirar folhas"),
                  _buildDraggableItem('assets/personagens/manacas/galho.png', 'galho', galhosFeito, "Remover galhos"),
                  _buildDraggableItem('assets/personagens/manacas/pomada.png', 'pomada', pomadaFeito, "Aplicar pomada"),
                  _buildDraggableItem('assets/personagens/manacas/pente.png', 'pente', penteFeito, "Pentear"),
                  _buildDraggableItem('assets/personagens/manacas/laco.png', 'laco', lacinhoFeito, "Colocar laço"),
                ],
              ),
            ),
          ),

          // Indicador de progresso
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
              child: Text(
                "Progresso: ${[banhoFeito, folhasFeito, galhosFeito, pomadaFeito, penteFeito, lacinhoFeito].where((e) => e).length}/6",
                style: TextStyle(fontFamily: 'PixelifySans', color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableItem(String asset, String tag, bool alreadyDone, String hint) {
    if (alreadyDone) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(asset, fit: BoxFit.cover),
              ),
            ),
            Text(hint, style: TextStyle(fontFamily: 'PixelifySans', color: Colors.white70, fontSize: 10)),
            Icon(Icons.check, color: Colors.white, size: 16),
          ],
        ),
      );
    }

    return Draggable<String>(
      data: tag,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.cyanAccent, width: 2),
          ),
          child: Image.asset(asset, fit: BoxFit.cover),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.cyanAccent, width: 2),
          ),
          child: Image.asset(asset, fit: BoxFit.cover),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent, width: 2),
              ),
              child: Image.asset(asset, fit: BoxFit.cover),
            ),
            Text(hint, style: TextStyle(fontFamily: 'PixelifySans', color: Colors.white, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}