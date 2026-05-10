// -----------------------------------------------------------------------------
// Arquivo criado/ajustado para padronizar as telas da biblioteca.
// Aqui ficam: áudio contínuo da biblioteca, botão de voltar ao menu, botão de
// silenciar/ativar volume e o componente de marcador clicável usado nas cenas.
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../0-Tela_Inicial/tela_inicial.dart';

class BibliotecaAudioController {
  // Player único/compartilhado para o áudio da biblioteca.
  // Isso impede a música de reiniciar a cada troca de tela.
  // Player único compartilhado por todas as telas da biblioteca.
  static final AudioPlayer _player = AudioPlayer();
  // Evita iniciar a mesma música várias vezes ao trocar de tela.
  static bool _tocando = false;
  // Guarda se o jogador silenciou ou ativou o som.
  static bool mutado = false;

  // Inicia a música em loop somente se ela ainda não estiver tocando.
  // Inicia a música da biblioteca. Se já estiver tocando, não faz nada.
  static Future<void> tocar() async {
    if (_tocando) return;

    // Faz o áudio repetir em loop enquanto o jogador estiver na biblioteca.
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(mutado ? 0.0 : 1.0);
    // Toca o arquivo de áudio cadastrado nos assets do Flutter.
    await _player.play(AssetSource('audio/audio_biblioteca.mp3'));
    _tocando = true;
  }

  // Alterna entre som ligado e som mutado no botão do canto superior.
  static Future<void> alternarSom() async {
    mutado = !mutado;
    await _player.setVolume(mutado ? 0.0 : 1.0);
  }

  // Para o áudio ao sair da biblioteca para o menu ou outro ambiente.
  // Para a música quando o jogador sai da biblioteca e volta ao menu.
  static Future<void> parar() async {
    if (!_tocando) return;
    await _player.stop();
    _tocando = false;
    mutado = false;
  }
}

// Componente base reutilizado nas telas da biblioteca.
// Ele evita repetir o mesmo código de fundo, áudio, botões e caixa de texto.
// Widget base usado por todas as telas de imagem da biblioteca.
class BibliotecaSceneScaffold extends StatefulWidget {
  final String imageAsset;
  final String titulo;
  final String descricao;
  final String dicaRodape;
  final bool mostrarCaixaInformacao;
  final Widget Function(BuildContext context, Size size)? overlayBuilder;

  const BibliotecaSceneScaffold({
    super.key,
    // Caminho da imagem de fundo da tela atual.
    required this.imageAsset,
    required this.titulo,
    required this.descricao,
    required this.dicaRodape,
    this.mostrarCaixaInformacao = true,
    // Função opcional para desenhar itens clicáveis por cima da imagem.
    this.overlayBuilder,
  });

  @override
  State<BibliotecaSceneScaffold> createState() => _BibliotecaSceneScaffoldState();
}

class _BibliotecaSceneScaffoldState extends State<BibliotecaSceneScaffold> {
  bool _mutado = BibliotecaAudioController.mutado;

  @override
  void initState() {
    super.initState();
    // Ao entrar em qualquer tela da biblioteca, garante que o áudio está tocando.
    BibliotecaAudioController.tocar();
  }

  Future<void> _alternarSom() async {
    await BibliotecaAudioController.alternarSom();
    if (!mounted) return;
    setState(() {
      _mutado = BibliotecaAudioController.mutado;
    });
  }

  // Volta para o menu inicial e para a música da biblioteca.
  Future<void> _voltarMenuInicial() async {
    await BibliotecaAudioController.parar();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => TelaInicial()),
      (route) => false,
    );
  }

  Widget _buildBotaoTopo({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 28),
        tooltip: tooltip,
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                // Desenha a imagem de fundo ocupando toda a tela.
                child: Image.asset(
                  widget.imageAsset,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.none,
                  isAntiAlias: false,
                ),
              ),
              // Desenha elementos extras por cima da imagem, como Corujito ou marcadores.
              if (widget.overlayBuilder != null) widget.overlayBuilder!(context, size),
              Positioned(
                top: 40,
                left: 20,
                child: _buildBotaoTopo(
                  icon: Icons.home,
                  tooltip: 'Voltar ao menu inicial',
                  onPressed: _voltarMenuInicial,
                ),
              ),
              Positioned(
                top: 40,
                right: 20,
                child: _buildBotaoTopo(
                  icon: _mutado ? Icons.volume_off : Icons.volume_up,
                  tooltip: _mutado ? 'Ativar volume' : 'Silenciar volume',
                  onPressed: _alternarSom,
                ),
              ),
              if (widget.mostrarCaixaInformacao)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.72),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24, width: 1.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.titulo,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'PixelifySans',
                          fontSize: 20,
                          color: Colors.cyanAccent,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.descricao,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'PixelifySans',
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.dicaRodape,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PixelifySans',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.75),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Marcador clicável usado para indicar onde o jogador deve tocar para avançar
// entre as cenas da biblioteca.
// Marcador clicável usado para indicar onde o jogador deve clicar/entrar.
class BibliotecaIndicadorEntrada extends StatelessWidget {
  final double leftFactor;
  final double topFactor;
  final double sizeFactor;
  final VoidCallback onTap;
  final String label;

  const BibliotecaIndicadorEntrada({
    super.key,
    required this.leftFactor,
    required this.topFactor,
    required this.sizeFactor,
    required this.onTap,
    this.label = 'ENTRAR',
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final largura = constraints.maxWidth;
        final altura = constraints.maxHeight;
        final tamanho = largura * sizeFactor;

        return Stack(
          children: [
            Positioned(
              left: largura * leftFactor,
              top: altura * topFactor,
              child: GestureDetector(
                onTap: onTap,
                child: Column(
                  children: [
                    Container(
                      width: tamanho,
                      height: tamanho,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.cyanAccent, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.35),
                            blurRadius: 14,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Colors.cyanAccent,
                        size: tamanho * 0.55,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontFamily: 'PixelifySans',
                          fontSize: 10,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}