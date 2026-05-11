import 'package:flutter/material.dart';
import 'combate_ritmico_sem_esquadro.dart';
import 'combate_mestre_angular.dart';
import 'entrada_manacas.dart';

enum FaseBatalha { dialogoPre, combateComum, combateMestre, dialogoPos, dialogoFinal, missaoConcluida }

class SalaPrincipalManacasScreen extends StatefulWidget {
  const SalaPrincipalManacasScreen({super.key});
  @override
  State<SalaPrincipalManacasScreen> createState() => _SalaPrincipalManacasScreenState();
}

class _SalaPrincipalManacasScreenState extends State<SalaPrincipalManacasScreen> {
  FaseBatalha faseAtual = FaseBatalha.dialogoPre;

  // Diálogo pré-batalha (carrapatos comuns)
  int dialogoPreIndex = 0;
  final List<String> dialogosPre = [
    "🐛 Carrapato do Mal: Veja só... mais um que caiu na nossa teia!",
    "🐛 Carrapato do Mal: Seus amiguinhos vão te derrotar primeiro!",
    "🐾 Capivarilda: Cuidado! Eles são rápidos...",
  ];

  // Diálogo entre as duas fases (aparecimento do mestre)
  int dialogoPosIndex = 0;
  final List<String> dialogosPos = [
    "🐗 CARRAPATO MESTRE: IDIOTA! Achou que venceria tão fácil?",
    "🐗 CARRAPATO MESTRE: Agora vou acabar com você pessoalmente!",
    "🐾 Capivarilda: Use o ESQUADRO MÁGICO! É a única chance!",
  ];

  // Diálogo após vencer o mestre
  int dialogoFinalIndex = 0;
  final List<String> dialogoFinal = [
    "🐗 Mestre: ISSO É IMPOSSÍVEL!!! (foge)",
    "🐾 Capivarilda: Você conseguiu! Obrigado, herói!",
    "🐾 Capivarilda: Tome o Amuleto da Amizade. Nunca esquecerei isso!",
    "🎉 MISSÃO CONCLUÍDA! 🎉",
  ];

  void avancarDialogoPre() {
    if (dialogoPreIndex < dialogosPre.length - 1) {
      setState(() => dialogoPreIndex++);
    } else {
      setState(() => faseAtual = FaseBatalha.combateComum);
    }
  }

  void fimCombateComum(bool vitoria) {
    if (vitoria) {
      setState(() {
        faseAtual = FaseBatalha.dialogoPos;
        dialogoPosIndex = 0;
      });
    } else {
      _exibirDerrota("Os carrapatos venceram... Tente novamente.");
    }
  }

  void avancarDialogoPos() {
    if (dialogoPosIndex < dialogosPos.length - 1) {
      setState(() => dialogoPosIndex++);
    } else {
      setState(() => faseAtual = FaseBatalha.combateMestre);
    }
  }

  void fimCombateMestre(bool vitoria) {
    if (vitoria) {
      setState(() {
        faseAtual = FaseBatalha.dialogoFinal;
        dialogoFinalIndex = 0;
      });
    } else {
      _exibirDerrota("O Carrapato Mestre foi mais forte...");
    }
  }

  void avancarDialogoFinal() {
    if (dialogoFinalIndex < dialogoFinal.length - 1) {
      setState(() => dialogoFinalIndex++);
    } else {
      setState(() => faseAtual = FaseBatalha.missaoConcluida);
    }
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
                faseAtual = FaseBatalha.dialogoPre;
                dialogoPreIndex = 0;
              });
            },
            child: Text("Reiniciar Batalha"),
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
          // Fundo
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/fundo/Manacas/sala_principal_cap.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),

          // Capivarilda (só aparece fora do combate)
          if (faseAtual != FaseBatalha.combateComum && faseAtual != FaseBatalha.combateMestre)
            Positioned(
              bottom: 50,
              right: 50,
              child: Image.asset(
                'assets/personagens/capivarilda_atacada.png',
                width: 300,
                height: 300,
                errorBuilder: (_, __, ___) => const SizedBox(),
              ),
            ),

          // Diálogos e combates conforme a fase
          if (faseAtual == FaseBatalha.dialogoPre)
            _buildDialogoPixel(dialogosPre[dialogoPreIndex], avancarDialogoPre),
          if (faseAtual == FaseBatalha.combateComum)
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: CombateRitmicoSemEsquadro(onBattleEnd: fimCombateComum),
              ),
            ),
          if (faseAtual == FaseBatalha.dialogoPos)
            _buildDialogoPixel(dialogosPos[dialogoPosIndex], avancarDialogoPos),
          if (faseAtual == FaseBatalha.combateMestre)
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: CombateMestreAngular(onBattleEnd: fimCombateMestre),
              ),
            ),
          if (faseAtual == FaseBatalha.dialogoFinal)
            _buildDialogoPixel(dialogoFinal[dialogoFinalIndex], avancarDialogoFinal),
          if (faseAtual == FaseBatalha.missaoConcluida)
            _buildTelaConclusao(),

          // Botão voltar
          if (faseAtual != FaseBatalha.combateComum && faseAtual != FaseBatalha.combateMestre)
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
            color: Color(0xFF0a0e27).withOpacity(0.95),
            border: Border.all(color: Colors.cyanAccent, width: 3),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(8),
            ),
          ),
          child: Text(
            texto,
            style: TextStyle(fontFamily: 'PixelifySans', fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildTelaConclusao() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Color(0xFF0a0e27),
          border: Border.all(color: Colors.greenAccent, width: 4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, color: Colors.yellow, size: 80),
            SizedBox(height: 20),
            Text(
              "MISSÃO CONCLUÍDA!",
              style: TextStyle(fontFamily: 'PixelifySans', fontSize: 28, color: Colors.greenAccent),
            ),
            SizedBox(height: 20),
            Text(
              "Você derrotou o Carrapato Mestre e resgatou Capivarilda!",
              style: TextStyle(fontFamily: 'PixelifySans', fontSize: 16, color: Colors.white),
            ),
            SizedBox(height: 30),
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
    );
  }

  Widget _botaoVoltar() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Color(0xFF1a1f3a),
          border: Border.all(color: Colors.cyanAccent, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.arrow_back, color: Colors.cyanAccent),
            SizedBox(width: 6),
            Text("VOLTAR", style: TextStyle(fontFamily: 'PixelifySans', color: Colors.cyanAccent)),
          ],
        ),
      ),
    );
  }
}