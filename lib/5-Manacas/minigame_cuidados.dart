import 'dart:math';
import 'package:flutter/material.dart';

class MinigameCuidados extends StatefulWidget {
  final Function() onComplete;
  const MinigameCuidados({super.key, required this.onComplete});

  @override
  State<MinigameCuidados> createState() => _MinigameCuidadosState();
}

class _MinigameCuidadosState extends State<MinigameCuidados> {
  // Ações concluídas
  bool banhoFeito = false;     // sujeira
  bool folhasFeito = false;    // folhas
  bool galhosFeito = false;    // galhos/espinhos
  bool pomadaFeito = false;    // machucados
  bool penteFeito = false;
  bool lacinhoFeito = false;

  // Listas de elementos interativos
  List<Offset> folhas = [];
  List<Offset> sujeiras = [];
  List<Offset> galhos = [];
  List<Offset> machucados = [];

  bool penteAplicado = false;
  bool lacinhoAplicado = false;

  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _gerarPosicoes();
  }

  void _gerarPosicoes() {
    // 3 folhas
    folhas = List.generate(3, (_) => Offset(
      80 + random.nextDouble() * 240,
      150 + random.nextDouble() * 220,
    ));
    // 3 manchas de sujeira
    sujeiras = List.generate(3, (_) => Offset(
      100 + random.nextDouble() * 220,
      160 + random.nextDouble() * 200,
    ));
    // 2 galhos/espinhos
    galhos = List.generate(2, (_) => Offset(
      90 + random.nextDouble() * 100,
      300 + random.nextDouble() * 80,
    ));
    // 2 machucados (feridas)
    machucados = List.generate(2, (_) => Offset(
      140 + random.nextDouble() * 180,
      180 + random.nextDouble() * 150,
    ));
  }

  void _verificarConclusao() {
    if (banhoFeito && folhasFeito && galhosFeito && pomadaFeito && penteFeito && lacinhoFeito) {
      widget.onComplete();
    }
  }

  void _removerFolha(Offset pos) {
    setState(() {
      folhas.remove(pos);
      if (folhas.isEmpty) folhasFeito = true;
    });
    _verificarConclusao();
  }

  void _removerSujeira(Offset pos) {
    setState(() {
      sujeiras.remove(pos);
      if (sujeiras.isEmpty) banhoFeito = true;
    });
    _verificarConclusao();
  }

  void _removerGalho(Offset pos) {
    setState(() {
      galhos.remove(pos);
      if (galhos.isEmpty) galhosFeito = true;
    });
    _verificarConclusao();
  }

  void _removerMachucado(Offset pos) {
    setState(() {
      machucados.remove(pos);
      if (machucados.isEmpty) pomadaFeito = true;
    });
    _verificarConclusao();
  }

  void _aplicarPente() {
    if (!penteFeito) {
      setState(() {
        penteFeito = true;
        penteAplicado = true;
      });
      _verificarConclusao();
    }
  }

  void _aplicarLacinho() {
    if (!lacinhoFeito) {
      setState(() {
        lacinhoFeito = true;
        lacinhoAplicado = true;
      });
      _verificarConclusao();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.brown.shade900,
      child: Stack(
        children: [
          // Fundo da caverna
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fundo/Manacas/sala_principal_cap.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.5)),

          // Capivara (centralizada)
          Center(
            child: Stack(
              children: [
                Image.asset(
                  'assets/personagens/manacas/capivara_machucada.png',
                  height: 400,
                  errorBuilder: (_, __, ___) => Container(height: 400, color: Colors.brown),
                ),
                // Sujeiras (manchas)
                ...sujeiras.map((pos) => Positioned(
                  left: pos.dx,
                  top: pos.dy,
                  child: GestureDetector(
                    onTap: () => _removerSujeira(pos),
                    child: Image.asset(
                      'assets/personagens/manacas/sujeira.png',
                      width: 35,
                      height: 35,
                    ),
                  ),
                )),
                // Folhas
                ...folhas.map((pos) => Positioned(
                  left: pos.dx,
                  top: pos.dy,
                  child: GestureDetector(
                    onTap: () => _removerFolha(pos),
                    child: Image.asset(
                      'assets/personagens/manacas/folha.png',
                      width: 35,
                      height: 35,
                    ),
                  ),
                )),
                // Galhos/espinhos
                ...galhos.map((pos) => Positioned(
                  left: pos.dx,
                  top: pos.dy,
                  child: GestureDetector(
                    onTap: () => _removerGalho(pos),
                    child: Image.asset(
                      'assets/personagens/manacas/galho.png',
                      width: 35,
                      height: 35,
                    ),
                  ),
                )),
                // Machucados (feridas)
                ...machucados.map((pos) => Positioned(
                  left: pos.dx,
                  top: pos.dy,
                  child: GestureDetector(
                    onTap: () => _removerMachucado(pos),
                    child: Image.asset(
                      'assets/personagens/manacas/machucado.png',
                      width: 35,
                      height: 35,
                    ),
                  ),
                )),
                // Pente aplicado
                if (penteAplicado)
                  Positioned(
                    left: 180,
                    top: 200,
                    child: Image.asset('assets/personagens/manacas/pente.png', width: 40, height: 40),
                  ),
                // Lacinho aplicado
                if (lacinhoAplicado)
                  Positioned(
                    left: 210,
                    top: 120,
                    child: Image.asset('assets/personagens/manacas/laco.png', width: 35, height: 35),
                  ),
              ],
            ),
          ),

          // Botões das ações (barra rolável inferior)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _botaoAcao(
                    icone: 'assets/personagens/manacas/sabao.png',
                    texto: "Limpar sujeira",
                    concluido: banhoFeito,
                    onTap: () {
                      if (!banhoFeito && sujeiras.isEmpty) {
                        setState(() { banhoFeito = true; });
                        _verificarConclusao();
                      } else if (!banhoFeito) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Clique nas manchas de sujeira!"), duration: Duration(seconds: 1)),
                        );
                      }
                    },
                  ),
                  _botaoAcao(
                    icone: 'assets/personagens/manacas/folha.png',
                    texto: "Tirar folhas",
                    concluido: folhasFeito,
                    onTap: () {
                      if (!folhasFeito && folhas.isEmpty) {
                        setState(() { folhasFeito = true; });
                        _verificarConclusao();
                      } else if (!folhasFeito) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Clique nas folhas!"), duration: Duration(seconds: 1)),
                        );
                      }
                    },
                  ),
                  _botaoAcao(
                    icone: 'assets/personagens/manacas/galho.png',
                    texto: "Remover galhos",
                    concluido: galhosFeito,
                    onTap: () {
                      if (!galhosFeito && galhos.isEmpty) {
                        setState(() { galhosFeito = true; });
                        _verificarConclusao();
                      } else if (!galhosFeito) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Clique nos galhos/espinhos!"), duration: Duration(seconds: 1)),
                        );
                      }
                    },
                  ),
                  _botaoAcao(
                    icone: 'assets/personagens/manacas/pomada.png',
                    texto: "Aplicar pomada",
                    concluido: pomadaFeito,
                    onTap: () {
                      if (!pomadaFeito && machucados.isEmpty) {
                        setState(() { pomadaFeito = true; });
                        _verificarConclusao();
                      } else if (!pomadaFeito) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Clique nas feridas (machucados)!"), duration: Duration(seconds: 1)),
                        );
                      }
                    },
                  ),
                  _botaoAcao(
                    icone: 'assets/personagens/manacas/pente.png',
                    texto: "Pentear",
                    concluido: penteFeito,
                    onTap: _aplicarPente,
                  ),
                  _botaoAcao(
                    icone: 'assets/personagens/manacas/laco.png',
                    texto: "Colocar laço",
                    concluido: lacinhoFeito,
                    onTap: _aplicarLacinho,
                  ),
                ],
              ),
            ),
          ),

          // Indicador de progresso (agora /6)
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

  Widget _botaoAcao({required String icone, required String texto, required bool concluido, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: GestureDetector(
        onTap: concluido ? null : onTap,
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: concluido ? Colors.green : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(icone, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported)),
              ),
            ),
            SizedBox(height: 5),
            Text(texto, style: TextStyle(fontFamily: 'PixelifySans', color: Colors.white, fontSize: 11)),
            if (concluido) Icon(Icons.check_circle, color: Colors.green, size: 18),
          ],
        ),
      ),
    );
  }
}