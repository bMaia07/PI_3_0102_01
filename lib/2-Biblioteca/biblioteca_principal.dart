// -----------------------------------------------------------------------------
// Área principal da biblioteca. Contém o Corujito, controla o diálogo dele,
// libera a busca nas prateleiras após aceitar a missão e mostra as opções finais
// depois que o livro é devolvido.
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// ARQUIVO: biblioteca_principal.dart
// OBJETIVO: controlar a área principal da biblioteca, onde fica o Corujito.
// COMENTÁRIOS DETALHADOS DA ÁREA PRINCIPAL:
// - O Corujito abre diálogos diferentes dependendo do progresso do jogador.
// - Depois de aceitar a missão, aparece o marcador para procurar o livro.
// - Depois de achar o livro no acervo, o diálogo muda para devolução.
// - Ao terminar, aparecem opções para ir à Praça de Alimentação ou voltar ao menu.
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'biblioteca_acervo.dart';
import 'biblioteca_image_screen.dart';
import '../game_progress.dart';
import '../0-Tela_Inicial/tela_inicial.dart';
import '../player_data.dart';

class BibliotecaPrincipalScreen extends StatefulWidget {
  const BibliotecaPrincipalScreen({super.key});

  @override
  State<BibliotecaPrincipalScreen> createState() => _BibliotecaPrincipalScreenState();
}

class _BibliotecaPrincipalScreenState extends State<BibliotecaPrincipalScreen> {
  // Mostra o botão "PROCURAR" somente depois que a missão do Corujito for aceita
  // e antes do livro ser encontrado/entregue.
  // Controla se o botão PROCURAR aparece entre as prateleiras.
  bool _mostrarMarcadorPrateleiras = GameProgress.missaoCorujitoAceita &&
      !GameProgress.livroCorujitoEncontrado &&
      !GameProgress.livroCorujitoEntregue;

  // Decide qual diálogo abrir com base no progresso atual:
  // início, lembrete, devolução do livro ou diálogo finalizado.
  // Abre o diálogo correto do Corujito conforme o estado da missão.
  Future<void> _abrirDialogoCorujito(BuildContext context) async {
    final String tipoDialogo;

    if (GameProgress.livroCorujitoEntregue) {
      // Se a missão já terminou, mostra só fala final/recado.
      tipoDialogo = 'finalizado';
    } else if (GameProgress.livroCorujitoEncontrado) {
      // Se o livro foi encontrado, abre diálogo para devolver o livro.
      tipoDialogo = 'devolucao';
    } else if (GameProgress.missaoCorujitoAceita) {
      // Se a missão foi aceita, mas o livro ainda não foi encontrado, mostra lembrete.
      tipoDialogo = 'lembrete';
    } else {
      // Primeira conversa com o Corujito.
      tipoDialogo = 'inicio';
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DialogoCorujito(tipoDialogo: tipoDialogo),
    );

    if (!mounted) return;

    setState(() {
      _mostrarMarcadorPrateleiras = GameProgress.missaoCorujitoAceita &&
          !GameProgress.livroCorujitoEncontrado &&
          !GameProgress.livroCorujitoEntregue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BibliotecaSceneScaffold(
      imageAsset: 'assets/biblioteca/biblioteca_principal.png',
      titulo: '',
      descricao: '',
      dicaRodape: '',
      mostrarCaixaInformacao: false,
      overlayBuilder: (context, size) {
        final corujitoWidth = size.width * 0.115;

        return Stack(
          children: [
            if (_mostrarMarcadorPrateleiras)
              BibliotecaIndicadorEntrada(
                leftFactor: 0.31,
                topFactor: 0.34,
                sizeFactor: 0.055,
                label: 'PROCURAR',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BibliotecaAcervoScreen()),
                  ).then((_) {
                    if (!mounted) return;
                    setState(() {
                      _mostrarMarcadorPrateleiras = GameProgress.missaoCorujitoAceita &&
                          !GameProgress.livroCorujitoEncontrado &&
                          !GameProgress.livroCorujitoEntregue;
                    });
                  });
                },
              ),
            Positioned(
              left: size.width * 0.41,
              top: size.height * 0.53,
              child: GestureDetector(
                onTap: () => _abrirDialogoCorujito(context),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/personagens/corujito.png',
                      width: corujitoWidth,
                      filterQuality: FilterQuality.none,
                      isAntiAlias: false,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Text(
                        'CORUJITO',
                        style: TextStyle(
                          fontFamily: 'PixelifySans',
                          fontSize: 10,
                          color: Colors.white,
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

// Estrutura simples para representar cada fala do diálogo.
// personagem = quem fala; texto = conteúdo exibido na caixa.
// Modelo simples para representar uma fala dentro do diálogo.
class _FalaDialogo {
  // Nome de quem está falando: JOGADOR ou CORUJITO.
  final String personagem;
  // Texto exibido na caixa de diálogo.
  final String texto;

  const _FalaDialogo({
    required this.personagem,
    required this.texto,
  });
}

// Modal de diálogo do Corujito.
// Controla avanço de falas, escolhas do jogador e opções finais.
// Modal/dialog responsável por exibir as falas e opções do Corujito.
class _DialogoCorujito extends StatefulWidget {
  final String tipoDialogo;

  const _DialogoCorujito({
    required this.tipoDialogo,
  });

  @override
  State<_DialogoCorujito> createState() => _DialogoCorujitoState();
}

class _DialogoCorujitoState extends State<_DialogoCorujito> {
  // Usa o nome digitado na criação do personagem.
  String get nomeJogador => PlayerData.nomePersonagem;

  // Lista de falas que serão exibidas neste diálogo específico.
  late List<_FalaDialogo> _falas;
  // Índice da fala atual dentro da lista _falas.
  int _indiceFala = 0;
  // Mostra as opções aceitar/recusar a proposta do Corujito.
  bool _mostrarOpcoes = false;
  // Mostra as opções finais: Praça de Alimentação ou Menu Principal.
  bool _mostrarOpcoesFinais = false;
  bool _fecharAoFinal = false;
  bool _marcarLivroEntregueAoFinal = false;

  @override
  void initState() {
    super.initState();
    _configurarDialogoInicial();
  }

  // Monta a lista de falas correta para o momento atual da missão.
  // Escolhe qual conjunto de falas será usado ao abrir o diálogo.
  void _configurarDialogoInicial() {
    switch (widget.tipoDialogo) {
      case 'devolucao':
        _falas = _falasDevolucaoLivro();
        _marcarLivroEntregueAoFinal = true;
        break;
      case 'lembrete':
        _falas = const [
          _FalaDialogo(
            personagem: 'CORUJITO',
            texto:
                'Você voltou! Ainda preciso do meu livro perdido. Ele é um livro com várias páginas, muito grosso, e sua cor azul é azul escuro. Pelo que eu me lembre a última vez que eu estive com ele eu estava passando perto das prateleiras ali atrás, acredito que ele esteja nessa região.',
          ),
          _FalaDialogo(
            personagem: 'JOGADOR',
            texto: 'Pode deixar, Corujito. Vou continuar procurando!',
          ),
        ];
        _fecharAoFinal = true;
        break;
      case 'finalizado':
        _falas = const [
          _FalaDialogo(
            personagem: 'CORUJITO',
            texto: 'Não há de que! É um prazer ajudá-lo. Boa sorte nessa missão! Até mais!',
          ),
        ];
        _fecharAoFinal = true;
        break;
      default:
        _falas = _falasInicio();
        _mostrarOpcoes = false;
        break;
    }
  }

  // Falas da primeira conversa com o Corujito.
  List<_FalaDialogo> _falasInicio() {
    return [
      _FalaDialogo(
        personagem: 'JOGADOR',
        texto: 'Oi Sr. Coruja! Finalmente te encontrei! Porque você está triste? Oque aconteceu?',
      ),
      _FalaDialogo(
        personagem: 'CORUJITO',
        texto:
            'Olá… Quem é você? Obrigado pela preocupação, mas está tudo bem, é que eu perdi meu livro preferido e não estou conseguindo encontrá-lo, não sei mais o que fazer.',
      ),
      _FalaDialogo(
        personagem: 'JOGADOR',
        texto:
            'Meu nome é $nomeJogador, e o seu? Eu vim te procurar pois preciso da sua ajuda! Fui enviado para procurar e salvar a Capivarilda, o Pingo me contou que ela está perdida e não vê ela a um longo tempo. Então eu decidi ajudá-lo a encontrá-la. Ele me disse que você pode me ajudar!',
      ),
      _FalaDialogo(
        personagem: 'CORUJITO',
        texto:
            'Pode me chamar de Corujito! Que bacana que você está disposto a ajudar! Ela sumiu faz um tempo já, mas eu acho que posso te ajudar nessa missão. Que tal você achar meu livro e como recompensa eu te passo uma informação! O que você acha??',
      ),
    ];
  }

  // Falas exibidas depois que o jogador aceita procurar o livro.
  List<_FalaDialogo> _falasAceitouMissao() {
    return const [
      _FalaDialogo(
        personagem: 'CORUJITO',
        texto:
            'Ufa! Que bom que você topou! Agora vamos lá, o meu livro perdido é o “Segredo dos Animais”, ele é um livro com várias páginas, muito grosso, e sua cor azul é azul escuro. Pelo que eu me lembre a última vez que eu estive com ele eu estava passando perto das prateleiras ali atrás, acredito que ele esteja nessa região. Se você achar pode trazer para mim, que logo em seguida eu te ajudo!',
      ),
      _FalaDialogo(
        personagem: 'JOGADOR',
        texto: 'Combinado! Vou procurar, já volto!',
      ),
    ];
  }

  // Falas exibidas quando o jogador volta com o livro encontrado.
  List<_FalaDialogo> _falasDevolucaoLivro() {
    return const [
      _FalaDialogo(
        personagem: 'JOGADOR',
        texto: 'Encontrei! Aqui está seu livro Corujito.',
      ),
      _FalaDialogo(
        personagem: 'CORUJITO',
        texto: 'Nossa! Que bom que você achou! Achei que nunca mais ia ver ele novamente, muito obrigado mesmo!',
      ),
      _FalaDialogo(
        personagem: 'CORUJITO',
        texto:
            'Agora conforme nosso combinado, vou te passar algumas informações. A última vez que eu vi a Capivarilda eu estava com ela no refeitório, porém voltei mais cedo para a biblioteca e ela ficou por lá. Procure pelo Don Ratatoni, o rato, ele sempre está na Praça de Alimentação e sabe de tudo que acontece por lá!',
      ),
      _FalaDialogo(
        personagem: 'JOGADOR',
        texto: 'Não precisa agradecer, foi apenas um favor!',
      ),
      _FalaDialogo(
        personagem: 'JOGADOR',
        texto:
            'Hum… entendi. Vou ir para a Praça de Alimentação para conversar com o Don Ratatoni. Muito obrigado pela informação, me ajudou muito!',
      ),
      _FalaDialogo(
        personagem: 'JOGADOR',
        texto:
            'Bom Corujito, vou indo nessa, não tenho tempo a perder! E novamente, muito obrigado por toda ajuda, espero te reencontrar em breve! Até a próxima!',
      ),
      _FalaDialogo(
        personagem: 'CORUJITO',
        texto: 'Não há de que! É um prazer ajudá-lo. Boa sorte nessa missão! Até mais!',
      ),
    ];
  }

  // Avança as falas e, no fim, abre opções ou fecha o diálogo conforme o estado.
  // Avança para a próxima fala ou mostra opções quando chega ao fim.
  void _proximaFala() {
    if (_mostrarOpcoes || _mostrarOpcoesFinais) return;

    if (_indiceFala < _falas.length - 1) {
      setState(() {
        _indiceFala++;
      });
      return;
    }

    if (widget.tipoDialogo == 'inicio' && !GameProgress.missaoCorujitoAceita) {
      setState(() {
        _mostrarOpcoes = true;
      });
      return;
    }

    if (_marcarLivroEntregueAoFinal) {
      GameProgress.entregarLivroCorujito();
      setState(() {
        _mostrarOpcoesFinais = true;
        _marcarLivroEntregueAoFinal = false;
      });
      return;
    }

    if (_fecharAoFinal) {
      Navigator.pop(context);
    }
  }

  // Quando o jogador aceita, libera o marcador para procurar o livro no acervo.
  // Jogador aceita a missão do Corujito.
  void _aceitarProposta() {
    GameProgress.aceitarMissaoCorujito();

    setState(() {
      _falas = _falasAceitouMissao();
      _indiceFala = 0;
      _mostrarOpcoes = false;
      _fecharAoFinal = true;
    });
  }

  // Jogador recusa a missão; o diálogo fecha.
  void _recusarProposta() {
    Navigator.pop(context);
  }

  // Opção final: para a música da biblioteca e segue para o próximo ambiente.
  // Para o áudio da biblioteca e navega para a Praça de Alimentação.
  Future<void> _irParaPracaAlimentacao() async {
    await BibliotecaAudioController.parar();
    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pushNamed(context, '/refeitorio');
  }

  // Para o áudio da biblioteca e volta para o menu principal.
  Future<void> _voltarMenuPrincipal() async {
    await BibliotecaAudioController.parar();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => TelaInicial()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pega a fala atual que deve aparecer na tela.
    final falaAtual = _falas[_indiceFala];
    // Define se deve mostrar o retrato do Corujito ou o ícone do jogador.
    final bool falandoCorujito = falaAtual.personagem == 'CORUJITO';
    final String nomeExibido = falandoCorujito ? 'CORUJITO' : PlayerData.nomePersonagem.toUpperCase();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 760,
          maxHeight: 560,
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0E27).withOpacity(0.97),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.cyanAccent, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.50),
                blurRadius: 20,
                offset: const Offset(6, 6),
              ),
              BoxShadow(
                color: Colors.cyanAccent.withOpacity(0.13),
                blurRadius: 22,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (falandoCorujito)
                    Image.asset(
                      'assets/personagens/corujito.png',
                      width: 78,
                      height: 78,
                      filterQuality: FilterQuality.none,
                      isAntiAlias: false,
                    )
                  else
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.blue[900],
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: falandoCorujito
                            ? Colors.cyanAccent.withOpacity(0.16)
                            : Colors.blueAccent.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: falandoCorujito ? Colors.cyanAccent : Colors.blueAccent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        nomeExibido,
                        style: TextStyle(
                          fontFamily: 'PixelifySans',
                          fontSize: 16,
                          color: falandoCorujito ? Colors.cyanAccent : Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      falaAtual.texto,
                      style: const TextStyle(
                        fontFamily: 'PixelifySans',
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.55,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_mostrarOpcoes)
                Column(
                  children: [
                    _BotaoDialogoCorujito(
                      texto: 'Por mim pode ser!',
                      onTap: _aceitarProposta,
                    ),
                    const SizedBox(height: 10),
                    _BotaoDialogoCorujito(
                      texto: 'Não estou interessado nessa proposta.',
                      onTap: _recusarProposta,
                      corBorda: Colors.redAccent,
                      corTexto: Colors.redAccent,
                    ),
                  ],
                )
              else if (_mostrarOpcoesFinais)
                Column(
                  children: [
                    _BotaoDialogoCorujito(
                      texto: 'IR PARA A PRAÇA DE ALIMENTAÇÃO',
                      onTap: _irParaPracaAlimentacao,
                    ),
                    const SizedBox(height: 10),
                    _BotaoDialogoCorujito(
                      texto: 'VOLTAR PARA O MENU PRINCIPAL',
                      onTap: _voltarMenuPrincipal,
                      corBorda: Colors.white70,
                      corTexto: Colors.white,
                    ),
                  ],
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!_fecharAoFinal || _indiceFala < _falas.length - 1)
                      Text(
                        '[ TOQUE PARA CONTINUAR ]',
                        style: TextStyle(
                          fontFamily: 'PixelifySans',
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.55),
                          letterSpacing: 1.5,
                        ),
                      ),
                    const SizedBox(width: 12),
                    _BotaoDialogoCorujito(
                      texto: _indiceFala == _falas.length - 1 && _fecharAoFinal
                          ? 'FECHAR'
                          : 'CONTINUAR',
                      onTap: _proximaFala,
                      larguraFixa: false,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Botão reutilizado nas escolhas e ações do diálogo do Corujito.
class _BotaoDialogoCorujito extends StatelessWidget {
  // Texto exibido na caixa de diálogo.
  final String texto;
  final VoidCallback onTap;
  final Color corBorda;
  final Color corTexto;
  final bool larguraFixa;

  const _BotaoDialogoCorujito({
    required this.texto,
    required this.onTap,
    this.corBorda = Colors.cyanAccent,
    this.corTexto = Colors.cyanAccent,
    this.larguraFixa = true,
  });

  @override
  Widget build(BuildContext context) {
    final botao = GestureDetector(
      onTap: onTap,
      child: Container(
        width: larguraFixa ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F3A),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: corBorda, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 8,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'PixelifySans',
            fontSize: 12,
            color: corTexto,
            letterSpacing: 1,
          ),
        ),
      ),
    );

    if (larguraFixa) return botao;
    return IntrinsicWidth(child: botao);
  }
}