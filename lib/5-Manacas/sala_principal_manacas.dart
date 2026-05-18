import 'package:flutter/material.dart';
import 'minigame_carrapatos.dart';
import 'minigame_cuidados.dart';
import 'entrada_manacas.dart';

enum Fase { dialogoPre, combateCarrapatos, dialogoPosCombate, cuidados }

class SalaPrincipalManacasScreen extends StatefulWidget {
  const SalaPrincipalManacasScreen({super.key});
  @override
  State<SalaPrincipalManacasScreen> createState() => _SalaPrincipalManacasScreenState();
}

class _SalaPrincipalManacasScreenState extends State<SalaPrincipalManacasScreen> {
  Fase faseAtual = Fase.dialogoPre;
  int dialogoPreIndex = 0;
  final List<String> dialogosPre = [
    "Carrapato do Mal: Veja só... mais um que caiu no nosso ninho!",
    "Carrapato do Mal: Vamos acabar com você!",
    "Capivarilda: Cuidado! Eles são traiçoeiros!",
  ];

  bool isMuted = false;

  void toggleMute() {
    setState(() => isMuted = !isMuted);
    if (isMuted) {
      pausarMusicaManacas();
    } else {
      retomarMusicaManacas();
    }
  }

  void avancarDialogoPre() {
    if (dialogoPreIndex < dialogosPre.length - 1) {
      setState(() => dialogoPreIndex++);
    } else {
      setState(() => faseAtual = Fase.combateCarrapatos);
    }
  }

  void fimCombateCarrapatos(bool venceu) {
    if (venceu) {
      setState(() => faseAtual = Fase.dialogoPosCombate);
    } else {
      _exibirDerrota("Você foi derrotado pelos carrapatos...");
    }
  }

  void avancarDialogoPos() {
    setState(() => faseAtual = Fase.cuidados);
  }

  void concluirCuidados() {
    pararMusicaManacas();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _exibirDerrota(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Derrota!", style: TextStyle(fontFamily: 'PixelifySans', color: Color.fromRGBO(65, 26, 26, 1))),
        content: Text(msg, style: TextStyle(fontFamily: 'PixelifySans', color: Colors.white)),
        backgroundColor: Color.fromRGBO(38, 23, 23, 1),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color.fromRGBO(65, 26, 26, 1), width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                faseAtual = Fase.dialogoPre;
                dialogoPreIndex = 0;
              });
            },
            child: Text("Reiniciar", style: TextStyle(color: Color.fromRGBO(65, 26, 26, 1))),
          ),
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: Text("Sair", style: TextStyle(color: Color.fromRGBO(65, 26, 26, 1))),
          ),
        ],
      ),
    );
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
                image: AssetImage('assets/fundo/Manacas/sala_principal_cap.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),

          // Botão MUTE (cores originais)
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: toggleMute,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(38, 23, 23, 1),
                  border: Border.all(color: Color.fromRGBO(65, 26, 26, 1), width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),

          // Imagem da Capivarilda atacada
          if (faseAtual == Fase.dialogoPre)
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/personagens/manacas/Capivarilda_atacada.png',
                  height: 250,
                  errorBuilder: (_, __, ___) => Container(height: 250, color: Colors.transparent),
                ),
              ),
            ),

          // Carrapato morto
          if (faseAtual == Fase.dialogoPosCombate)
            Positioned(
              top: 120,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/personagens/manacas/carrapato_morto.png',
                  height: 200,
                  errorBuilder: (_, __, ___) => Container(),
                ),
              ),
            ),

          if (faseAtual == Fase.dialogoPre)
            _buildDialogoPixel(dialogosPre[dialogoPreIndex], avancarDialogoPre),

          if (faseAtual == Fase.combateCarrapatos)
            MinigameCarrapatos(onGameEnd: fimCombateCarrapatos),

          if (faseAtual == Fase.dialogoPosCombate)
            _buildDialogoPixel(
              "🐗 Carrapato Mestre: Que... impossível!\n\n🐾 Capivarilda: Você conseguiu! Agora preciso de seus cuidados...",
              avancarDialogoPos,
            ),

          if (faseAtual == Fase.cuidados)
            MinigameCuidados(onComplete: concluirCuidados),

          if (faseAtual == Fase.dialogoPre || faseAtual == Fase.dialogoPosCombate)
            Positioned(
              top: 20,
              left: 20,
              child: _botaoVoltar(),
            ),
        ],
      ),
    );
  }

  Widget _buildDialogoPixel(String texto, VoidCallback onTap) {
    return Positioned(
      bottom: 80,
      left: 20,
      right: 20,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color.fromRGBO(38, 23, 23, 0.95),
            border: Border.all(color: Color.fromRGBO(65, 26, 26, 1), width: 3),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(8),
            ),
            boxShadow: [BoxShadow(color: Colors.black87, blurRadius: 15, offset: Offset(6, 6))],
          ),
          child: Text(
            texto,
            style: TextStyle(fontFamily: 'PixelifySans', fontSize: 16, color: Colors.white, height: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _botaoVoltar() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Color.fromRGBO(38, 23, 23, 1),
          border: Border.all(color: Color.fromRGBO(65, 26, 26, 1), width: 2),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black87, blurRadius: 10, offset: Offset(4, 4))],
        ),
        child: Row(
          children: [
            Icon(Icons.arrow_back, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text("VOLTAR", style: TextStyle(fontFamily: 'PixelifySans', fontSize: 12, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}