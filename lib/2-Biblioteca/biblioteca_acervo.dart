// -----------------------------------------------------------------------------
// Cena do acervo da biblioteca. Aqui acontece o mini game do livro perdido:
// o jogador investiga 4 corredores, coleta 4 partes da capa e monta o puzzle
// do livro "O Segredo dos Animais".
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// ARQUIVO: biblioteca_acervo.dart
// OBJETIVO: controlar o mini game do acervo da biblioteca.
// O jogador investiga 4 corredores, coleta 4 pedaços da capa e depois monta
// o puzzle do livro "O Segredo dos Animais".
// COMENTÁRIOS DETALHADOS DO ACERVO:
// - _pedacosColetados guarda quais partes já foram encontradas.
// - _investigarCorredor abre o popup de coleta de cada pedaço.
// - _PuzzleLivroDialog é a janela onde o jogador arrasta as peças.
// - Quando a capa é montada corretamente, o jogo marca o livro como encontrado.
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'biblioteca_image_screen.dart';
import '../game_progress.dart';

class BibliotecaAcervoScreen extends StatefulWidget {
  const BibliotecaAcervoScreen({super.key});

  @override
  State<BibliotecaAcervoScreen> createState() => _BibliotecaAcervoScreenState();
}

class _BibliotecaAcervoScreenState extends State<BibliotecaAcervoScreen> {
  // Guarda quais corredores já foram investigados e quais partes da capa já foram coletadas.
  // Guarda os números dos pedaços já encontrados nos corredores.
  final Set<int> _pedacosColetados = <int>{};
  // Impede abrir o puzzle duas vezes ao mesmo tempo.
  bool _puzzleAberto = false;

  // Ao clicar em um corredor, entrega uma parte da capa correspondente.
  // Se o corredor já foi usado, apenas informa que ele já foi investigado.
  // Método chamado quando o jogador clica em um corredor.
  void _investigarCorredor(int numero) {
    // Se o pedaço desse corredor já foi pego, mostra aviso em vez de coletar de novo.
    if (_pedacosColetados.contains(numero)) {
      _mostrarAviso(
        titulo: 'CORREDOR JÁ INVESTIGADO',
        mensagem: 'Você já encontrou a parte da capa que estava escondida nesse corredor.',
      );
      return;
    }

    setState(() {
      // Adiciona o pedaço encontrado no conjunto de coletados.
      _pedacosColetados.add(numero);
    });

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E27).withOpacity(0.97),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.cyanAccent, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.55),
                  blurRadius: 20,
                  offset: const Offset(6, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PARTE DA CAPA ENCONTRADA!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 18,
                    color: Colors.cyanAccent,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 14),
                Image.asset(
                  'assets/fundo/Biblioteca/livro_segredo_animais_pedaco_$numero.png',
                  width: 130,
                  filterQuality: FilterQuality.none,
                  isAntiAlias: false,
                ),
                const SizedBox(height: 14),
                Text(
                  'Você encontrou a parte $numero da capa do livro.\nPartes coletadas: ${_pedacosColetados.length}/4',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _BotaoAcervo(
                  texto: _pedacosColetados.length == 4 ? 'MONTAR CAPA' : 'CONTINUAR PROCURANDO',
                  onTap: () {
                    Navigator.pop(context);
                    if (_pedacosColetados.length == 4) {
                      Future.delayed(const Duration(milliseconds: 200), _abrirPuzzle);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _mostrarAviso({required String titulo, required String mensagem}) {
    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 420,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E27).withOpacity(0.97),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.cyanAccent, width: 2.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 16,
                    color: Colors.cyanAccent,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  mensagem,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _BotaoAcervo(
                  texto: 'OK',
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Abre o puzzle depois que as 4 partes da capa foram coletadas.
  // Abre a janela do quebra-cabeça quando os 4 pedaços foram coletados.
  Future<void> _abrirPuzzle() async {
    if (_puzzleAberto) return;
    _puzzleAberto = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PuzzleLivroDialog(
        onConcluido: () {
          // Marca globalmente que o livro foi encontrado, para liberar o diálogo de devolução.
          GameProgress.marcarLivroCorujitoEncontrado();
          Navigator.pop(context); // fecha o puzzle
          Navigator.pop(context); // volta para o Corujito
        },
      ),
    );

    _puzzleAberto = false;
  }

  @override
  Widget build(BuildContext context) {
    return BibliotecaSceneScaffold(
      imageAsset: 'assets/fundo/Biblioteca/biblioteca_acervo.png',
      titulo: '',
      descricao: '',
      dicaRodape: '',
      mostrarCaixaInformacao: false,
      // overlayBuilder desenha os elementos clicáveis por cima da imagem do acervo.
      overlayBuilder: (context, size) {
        return Stack(
          children: [
            Positioned(
              top: 106,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF11151F).withOpacity(0.86),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.75), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(4, 4),
                      ),
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.10),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_stories_rounded, color: Colors.cyanAccent, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        'Investigue os 4 corredores e colete as partes da capa. ${_pedacosColetados.length}/4',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'PixelifySans',
                          fontSize: 12,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _CorredorBiblioteca(
              numero: 1,
              left: size.width * 0.045,
              top: size.height * 0.40,
              width: size.width * 0.13,
              height: size.height * 0.37,
              coletado: _pedacosColetados.contains(1),
              onTap: () => _investigarCorredor(1),
            ),
            _CorredorBiblioteca(
              numero: 2,
              left: size.width * 0.255,
              top: size.height * 0.35,
              width: size.width * 0.16,
              height: size.height * 0.42,
              coletado: _pedacosColetados.contains(2),
              onTap: () => _investigarCorredor(2),
            ),
            _CorredorBiblioteca(
              numero: 3,
              left: size.width * 0.555,
              top: size.height * 0.35,
              width: size.width * 0.16,
              height: size.height * 0.42,
              coletado: _pedacosColetados.contains(3),
              onTap: () => _investigarCorredor(3),
            ),
            _CorredorBiblioteca(
              numero: 4,
              left: size.width * 0.82,
              top: size.height * 0.37,
              width: size.width * 0.14,
              height: size.height * 0.40,
              coletado: _pedacosColetados.contains(4),
              onTap: () => _investigarCorredor(4),
            ),
          ],
        );
      },
    );
  }
}

// Botão visual de cada corredor do acervo.
// O design mostra se o corredor ainda precisa ser investigado ou se já foi coletado.
// Widget visual de cada corredor clicável do acervo.
class _CorredorBiblioteca extends StatelessWidget {
  final int numero;
  final double left;
  final double top;
  final double width;
  final double height;
  // Indica se o jogador já pegou a peça deste corredor.
  final bool coletado;
  // Função executada quando o jogador clica no corredor.
  final VoidCallback onTap;

  const _CorredorBiblioteca({
    required this.numero,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.coletado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Verde quando já foi coletado; ciano quando ainda precisa investigar.
    final Color destaque = coletado ? Colors.greenAccent : Colors.cyanAccent;

    return Positioned(
      left: left,
      top: top,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: width,
            height: height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Center(
                  child: Container(
                    width: width * 0.52,
                    height: height * 0.86,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: coletado
                            ? [
                                Colors.greenAccent.withOpacity(0.14),
                                Colors.greenAccent.withOpacity(0.03),
                              ]
                            : [
                                Colors.cyanAccent.withOpacity(0.14),
                                Colors.cyanAccent.withOpacity(0.03),
                              ],
                      ),
                      border: Border.all(
                        color: destaque.withOpacity(0.20),
                        width: 1.2,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF0C1120).withOpacity(0.92),
                          border: Border.all(color: destaque, width: 2.2),
                          boxShadow: [
                            BoxShadow(
                              color: destaque.withOpacity(0.18),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.30),
                              blurRadius: 8,
                              offset: const Offset(3, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          coletado ? Icons.check_rounded : Icons.search_rounded,
                          color: destaque,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C1120).withOpacity(0.90),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: destaque.withOpacity(0.85), width: 1.8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.28),
                              blurRadius: 8,
                              offset: const Offset(3, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'CORREDOR $numero',
                              style: TextStyle(
                                fontFamily: 'PixelifySans',
                                fontSize: 10,
                                color: destaque,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              coletado ? 'COLETADO' : 'INVESTIGAR',
                              style: TextStyle(
                                fontFamily: 'PixelifySans',
                                fontSize: 9,
                                color: Colors.white.withOpacity(0.90),
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Icon(
                      Icons.keyboard_double_arrow_down_rounded,
                      color: destaque.withOpacity(0.90),
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Janela do mini game de montar a capa do livro.
// Janela/modal do puzzle onde o jogador monta a capa do livro.
class _PuzzleLivroDialog extends StatefulWidget {
  final VoidCallback onConcluido;

  const _PuzzleLivroDialog({required this.onConcluido});

  @override
  State<_PuzzleLivroDialog> createState() => _PuzzleLivroDialogState();
}

class _PuzzleLivroDialogState extends State<_PuzzleLivroDialog> {
  // Peças começam embaralhadas para o jogador precisar reorganizar.
  final List<int> _pecasDisponiveis = <int>[3, 1, 4, 2];
  // Slots do tabuleiro; null significa que aquele espaço ainda está vazio.
  final List<int?> _slots = <int?>[null, null, null, null];

  String _assetPeca(int numero) => 'assets/fundo/Biblioteca/livro_segredo_animais_pedaco_$numero.png';

  // A ordem correta é: 1, 2, 3, 4.
  // Quando todos os slots batem com essa ordem, o livro é considerado encontrado.
  // Verifica se as peças estão na ordem correta: 1, 2, 3, 4.
  bool get _montadoCorretamente {
    for (int i = 0; i < 4; i++) {
      if (_slots[i] != i + 1) return false;
    }
    return true;
  }

  // Coloca uma peça no slot. Se já existia peça ali, ela volta para o banco.
  // Coloca uma peça arrastada no slot escolhido.
  void _colocarPeca(int indiceSlot, int numeroPeca) {
    setState(() {
      final pecaAntiga = _slots[indiceSlot];
      if (pecaAntiga != null && !_pecasDisponiveis.contains(pecaAntiga)) {
        _pecasDisponiveis.add(pecaAntiga);
      }
      _slots[indiceSlot] = numeroPeca;
      _pecasDisponiveis.remove(numeroPeca);
    });
  }

  // Remove uma peça do tabuleiro e devolve para o banco de peças.
  void _removerPeca(int indiceSlot) {
    setState(() {
      final peca = _slots[indiceSlot];
      if (peca != null && !_pecasDisponiveis.contains(peca)) {
        _pecasDisponiveis.add(peca);
      }
      _slots[indiceSlot] = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 680),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0E27).withOpacity(0.98),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.cyanAccent, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 22,
                offset: const Offset(6, 6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'MONTE A CAPA DO LIVRO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 20,
                    color: Colors.cyanAccent,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Arraste cada parte para o lugar correto e forme o livro "O Segredo dos Animais".',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'PixelifySans',
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 18,
                  runSpacing: 18,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _buildTabuleiro(),
                    _buildBancoDePecas(),
                  ],
                ),
                const SizedBox(height: 16),
                if (_montadoCorretamente)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.greenAccent, width: 2),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'CAPA MONTADA!\nVocê encontrou o livro perdido do Corujito.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'PixelifySans',
                            fontSize: 13,
                            color: Colors.greenAccent,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _BotaoAcervo(
                          texto: 'VOLTAR AO CORUJITO',
                          onTap: widget.onConcluido,
                        ),
                      ],
                    ),
                  )
                else if (!_slots.contains(null))
                  const Text(
                    'A capa ainda não está correta. Toque em uma peça posicionada para removê-la e tente de novo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PixelifySans',
                      fontSize: 11,
                      color: Colors.orangeAccent,
                      height: 1.4,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Monta o quadro 2x2 onde a capa deve ser reconstruída.
  Widget _buildTabuleiro() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Row(children: [_buildSlot(0), _buildSlot(1)]),
          Row(children: [_buildSlot(2), _buildSlot(3)]),
        ],
      ),
    );
  }

  // Cria cada espaço que aceita uma peça arrastada.
  Widget _buildSlot(int indice) {
    final peca = _slots[indice];
    return DragTarget<int>(
      onWillAccept: (_) => true,
      onAccept: (data) => _colocarPeca(indice, data),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: 130,
          height: 170,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(candidateData.isNotEmpty ? 0.16 : 0.07),
            border: Border.all(
              color: candidateData.isNotEmpty ? Colors.cyanAccent : Colors.white30,
              width: 2,
            ),
          ),
          child: peca == null
              ? Center(
                  child: Text(
                    'PARTE ${indice + 1}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PixelifySans',
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.55),
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () => _removerPeca(indice),
                  child: Image.asset(
                    _assetPeca(peca),
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.none,
                    isAntiAlias: false,
                  ),
                ),
        );
      },
    );
  }

  // Mostra as peças disponíveis para arrastar.
  Widget _buildBancoDePecas() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'PEÇAS ENCONTRADAS',
            style: TextStyle(
              fontFamily: 'PixelifySans',
              fontSize: 12,
              color: Colors.cyanAccent,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _pecasDisponiveis.map((numero) {
              return Draggable<int>(
                data: numero,
                feedback: Material(
                  color: Colors.transparent,
                  child: Image.asset(
                    _assetPeca(numero),
                    width: 95,
                    filterQuality: FilterQuality.none,
                    isAntiAlias: false,
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.25,
                  child: _buildMiniPeca(numero),
                ),
                child: _buildMiniPeca(numero),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Text(
            _pecasDisponiveis.isEmpty
                ? 'Toque em uma peça posicionada para remover.'
                : 'Arraste as peças para os espaços da capa.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'PixelifySans',
              fontSize: 10,
              color: Colors.white.withOpacity(0.62),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPeca(int numero) {
    return Container(
      width: 95,
      height: 125,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.cyanAccent.withOpacity(0.7), width: 2),
        color: Colors.black.withOpacity(0.35),
      ),
      child: Image.asset(
        _assetPeca(numero),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.none,
        isAntiAlias: false,
      ),
    );
  }
}

class _BotaoAcervo extends StatelessWidget {
  final String texto;
  // Função executada quando o jogador clica no corredor.
  final VoidCallback onTap;

  const _BotaoAcervo({
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.cyanAccent, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.30),
              blurRadius: 8,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'PixelifySans',
            fontSize: 12,
            color: Colors.cyanAccent,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}