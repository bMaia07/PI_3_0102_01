import 'package:flutter/material.dart';
import 'minigame_carrapatos.dart';
import 'minigame_cuidados.dart';
import 'entrada_manacas.dart';

enum Fase { dialogoPre, combateCarrapatos, dialogoPosCombate, cuidados, missaoConcluida }

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
    setState(() => faseAtual = Fase.missaoConcluida);
  }

  void _exibirDerrota(String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text("Derrota!", style: TextStyle(fontFamily: 'PixelifySans')),
        content: Text(msg, style: TextStyle(fontFamily: 'PixelifySans')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                faseAtual = Fase.dialogoPre;
                dialogoPreIndex = 0;
              });
            },
            child: Text("Reiniciar"),
          ),
          TextButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            child: Text("Sair"),
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
          if (faseAtual == Fase.missaoConcluida)
            Center(
              child: Container(
                padding: EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Color.fromRGBO(38, 23, 23, 1),
                  border: Border.all(color: const Color.fromRGBO(65, 26, 26, 1), width: 4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/personagens/manacas/capivara_bem.png', height: 150, errorBuilder: (_, __, ___) => Icon(Icons.pets, size: 100)),
                    SizedBox(height: 20),
                    Text("MISSÃO CONCLUÍDA!", style: TextStyle(fontFamily: 'PixelifySans', fontSize: 24, color: Colors.greenAccent)),
                    Text("Você salvou e cuidou da Capivarilda!", style: TextStyle(fontFamily: 'PixelifySans', color: Colors.white)),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await pararMusicaManacas();
                        if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      child: Text("Voltar ao Menu", style: TextStyle(fontFamily: 'PixelifySans')),
                    ),
                  ],
                ),
              ),
            ),
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
            color: Color.fromRGBO(38, 23, 23, 1).withOpacity(0.95),
            border: Border.all(color: const Color.fromRGBO(65, 26, 26, 1), width: 3),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Text(texto, style: TextStyle(fontFamily: 'PixelifySans', fontSize: 16, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _botaoVoltar() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color.fromRGBO(38, 23, 23, 1),
          border: Border.all(color: const Color.fromRGBO(65, 26, 26, 1), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.arrow_back, color: const Color.fromRGBO(65, 26, 26, 1)),
            SizedBox(width: 6),
            Text("VOLTAR", style: TextStyle(fontFamily: 'PixelifySans', color: const Color.fromARGB(255, 255, 255, 255))),
          ],
        ),
      ),
    );
  }
}