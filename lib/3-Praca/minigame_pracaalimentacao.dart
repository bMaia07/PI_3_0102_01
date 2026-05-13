import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class MinigamePracaAlimentacao extends StatefulWidget {
  const MinigamePracaAlimentacao({super.key});

  @override
  State<MinigamePracaAlimentacao> createState() =>
      _MinigamePracaAlimentacaoState();
}

class _MinigamePracaAlimentacaoState
    extends State<MinigamePracaAlimentacao> {

  final AudioPlayer musicPlayer = AudioPlayer();

  int pedidoAtual = 0;
  int pontos = 0;
  List<String> ingredientesSelecionados = [];

  @override
  void initState() {
    super.initState();
    tocarMusica();
  }

  Future<void> tocarMusica() async {
    await musicPlayer.setVolume(1.0);
    await musicPlayer.setReleaseMode(ReleaseMode.loop);
    await musicPlayer.play(
      AssetSource('audio/somminigamepraca.mp3'),
    );
  }

  @override
  void dispose() {
    musicPlayer.stop();
    musicPlayer.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> pedidos = [
    {
      'nome': 'X-Burguer',
      'ingredientes': [
        'Pão de baixo',
        'Carne',
        'Queijo',
        'Pão de cima',
        'Refrigerante',
      ],
    },
    {
      'nome': 'X-Salada',
      'ingredientes': [
        'Pão de baixo',
        'Carne',
        'Queijo',
        'Alface',
        'Tomate',
        'Pão de cima',
        'Refrigerante',
      ],
    },
    {
      'nome': 'X-Bacon',
      'ingredientes': [
        'Pão de baixo',
        'Carne',
        'Queijo',
        'Bacon',
        'Pão de cima',
        'Refrigerante',
      ],
    },
    {
      'nome': 'X-Tudo',
      'ingredientes': [
        'Pão de baixo',
        'Carne',
        'Queijo',
        'Bacon',
        'Alface',
        'Tomate',
        'Pão de cima',
        'Refrigerante',
      ],
    },
    {
      'nome': 'Combo Ratatoni',
      'ingredientes': [
        'Pão de baixo',
        'Carne',
        'Queijo',
        'Batata',
        'Pão de cima',
        'Refrigerante',
      ],
    },
  ];

  Map<String, dynamic> get pedido => pedidos[pedidoAtual];

  final Map<String, String> imagensIngredientes = {
    'Pão de baixo': 'assets/fundo/Praca/paodebaixoreto.png',
    'Pão de cima':  'assets/fundo/Praca/paodecimareto.png',
    'Carne':        'assets/fundo/Praca/carnereto.png',
    'Queijo':       'assets/fundo/Praca/queijoreto.png',
    'Bacon':        'assets/fundo/Praca/baconreto.png',
    'Alface':       'assets/fundo/Praca/alfacereto.png',
    'Tomate':       'assets/fundo/Praca/tomatereto.png',
    'Batata':       'assets/fundo/Praca/batata.png',
    'Refrigerante': 'assets/fundo/Praca/refri.png',
  };

// Altura VISUAL REAL de cada ingrediente
  final Map<String, double> alturasCamada = {
    'Pão de baixo': 70.0,
    'Pão de cima':  70.0,
    'Carne':        40.0,
    'Queijo':       25.0,
    'Bacon':        28.0,
    'Alface':       28.0,
    'Tomate':       28.0,
  };
  // Largura visual de cada camada
  final Map<String, double> largurasIngrediente = {
    'Pão de baixo': 240.0,
    'Pão de cima':  230.0,
    'Carne':        200.0,
    'Queijo':       180.0,
    'Bacon':        210.0,
    'Alface':       220.0,
    'Tomate':       215.0,
  };

  void selecionarIngrediente(String item) {
    setState(() {
      ingredientesSelecionados.add(item);
    });
  }

  void verificarPedido() {
    final ingredientesCorretos = List<String>.from(pedido['ingredientes']);
    bool lancheCorreto =
        ingredientesCorretos.join(',') == ingredientesSelecionados.join(',');

    if (lancheCorreto) {
      pontos += 50;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 73, 14, 14),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 4),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Pedido correto!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontFamily: 'PixelifySans',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Image.asset(
                    'assets/fundo/Praca/hamburguer.png',
                    height: 220,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '+50 pontos',
                    style: TextStyle(
                      color: Colors.yellow,
                      fontSize: 24,
                      fontFamily: 'PixelifySans',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      if (pontos >= 250) {
                        await musicPlayer.stop();
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (_) {
                            return AlertDialog(
                              backgroundColor:
                                  const Color.fromARGB(255, 73, 14, 14),
                              title: const Text(
                                'Parabéns!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'PixelifySans',
                                ),
                              ),
                              content: const Text(
                                'Você completou todos os pedidos!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'PixelifySans',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    Navigator.pop(context, true);
                                  },
                                  child: const Text(
                                    'Continuar',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        setState(() {
                          if (pedidoAtual < pedidos.length - 1) {
                            pedidoAtual++;
                          }
                          ingredientesSelecionados.clear();
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(fontFamily: 'PixelifySans'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 73, 14, 14),
            title: const Text(
              'Pedido errado!',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'PixelifySans',
              ),
            ),
            content: const Text(
              'Monte novamente para pontuar!',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'PixelifySans',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    ingredientesSelecionados.clear();
                  });
                },
                child: const Text(
                  'Tentar novamente',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Widget ingredienteBotao(String nome, String imagem) {
    bool selecionado = ingredientesSelecionados.contains(nome);

    return GestureDetector(
      onTap: () => selecionarIngrediente(nome),
      child: Container(
        width: 100,
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selecionado
              ? Colors.green
              : const Color.fromARGB(255, 114, 28, 28),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(imagem, height: 52, fit: BoxFit.contain),
            const SizedBox(height: 4),
            Text(
              nome,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontFamily: 'PixelifySans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Monta a visualização do lanche com todos os ingredientes
  /// alinhados na mesma base, com tamanhos proporcionais.
  Widget montarHamburguer() {
    // Separa ingredientes da pilha dos extras (batata e refri)
    List<String> camadas = ingredientesSelecionados.where(
      (item) => item != 'Batata' && item != 'Refrigerante',
    ).toList();

    bool temBatata   = ingredientesSelecionados.contains('Batata');
    bool temRefri    = ingredientesSelecionados.contains('Refrigerante');

    // Calcula a altura total da pilha de ingredientes
    double alturaPilha = camadas.fold(0.0, (soma, item) {
      return soma + (alturasCamada[item] ?? 35.0);
    });

    // Largura e altura disponíveis para a área central do lanche
    const double areaLargura  = 500.0;
    const double areaAltura   = 380.0;
    // Linha de base dos extras (batata/refri) e do lanche
    const double baseY        = areaAltura - 20.0;

    // Tamanho dos extras (batata / refri)
    const double larguraExtra = 110.0;
    const double alturaExtra  = 110.0;

    // Centro horizontal para a pilha do lanche
    const double centroPilha  = areaLargura / 2;

    return SizedBox(
      width: areaLargura,
      height: areaAltura,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ----- Refrigerante (à esquerda do lanche, na mesma base) -----
          if (temRefri)
            Positioned(
              left: centroPilha - 200,
              top: baseY - alturaExtra,
              child: Image.asset(
                imagensIngredientes['Refrigerante']!,
                width: larguraExtra,
                height: alturaExtra,
                fit: BoxFit.contain,
              ),
            ),

          // ----- Batata (à direita do lanche, na mesma base) -----
          if (temBatata)
            Positioned(
              left: centroPilha + 100,
              top: baseY - alturaExtra,
              child: Image.asset(
                imagensIngredientes['Batata']!,
                width: larguraExtra,
                height: alturaExtra,
                fit: BoxFit.contain,
              ),
            ),

          // ----- Pilha de ingredientes do lanche -----
          ...() {
            List<Widget> widgets = [];
            double acumulado = 0.0;
            const double espacamento = 18.0;

            // Percorre de cima para baixo (o último adicionado fica no topo da pilha)
            for (int i = camadas.length - 1; i >= 0; i--) {
              String item    = camadas[i];
              double h       = alturasCamada[item] ?? 35.0;
              double w       = largurasIngrediente[item] ?? 200.0;
              double topPos  = baseY - alturaPilha + acumulado;

              widgets.add(
                Positioned(
                  left: centroPilha - w / 2,
                  top: topPos,
                  child: Image.asset(
                    imagensIngredientes[item]!,
                    width: w,
                    fit: BoxFit.contain,
                  ),
                ),
              );

              acumulado += espacamento;
            }

            return widgets;
          }(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fundo
          Positioned.fill(
            child: Image.asset(
              'assets/fundo/Praca/pracaalimentacao.jpg',
              fit: BoxFit.cover,
            ),
          ),

          // Overlay escuro
          Container(color: Colors.black.withOpacity(0.45)),

          // Personagem Ratatoni
          Positioned(
            right: 20,
            bottom: 20,
            child: Image.asset(
              'assets/fundo/personagens/ratatoni.png',
              height: 240,
            ),
          ),

          // ── Coluna esquerda: caixa de pedido + ingredientes ──
          Positioned(
            top: 40,
            left: 30,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Caixa de pedido / pontos
                Container(
                  width: 360,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 73, 14, 14)
                        .withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido ${pedidoAtual + 1}/5',
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 22,
                          fontFamily: 'PixelifySans',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        pedido['nome'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontFamily: 'PixelifySans',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        (pedido['ingredientes'] as List).join(', '),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontFamily: 'PixelifySans',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Pontos: $pontos / 250',
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontSize: 20,
                          fontFamily: 'PixelifySans',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Painel de ingredientes (abaixo da caixa, lado esquerdo)
                Container(
                  width: 360,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Ingredientes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'PixelifySans',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          ingredienteBotao('Pão de baixo',
                              'assets/fundo/Praca/paodebaixo.png'),
                          ingredienteBotao('Pão de cima',
                              'assets/fundo/Praca/paodecima.png'),
                          ingredienteBotao(
                              'Carne', 'assets/fundo/Praca/carne.png'),
                          ingredienteBotao(
                              'Queijo', 'assets/fundo/Praca/queijo.png'),
                          ingredienteBotao(
                              'Bacon', 'assets/fundo/Praca/bacon.png'),
                          ingredienteBotao(
                              'Alface', 'assets/fundo/Praca/alface.png'),
                          ingredienteBotao(
                              'Tomate', 'assets/fundo/Praca/tomate.png'),
                          ingredienteBotao(
                              'Batata', 'assets/fundo/Praca/batata.png'),
                          ingredienteBotao('Refrigerante',
                              'assets/fundo/Praca/refri.png'),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: verificarPedido,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                        ),
                        child: const Text(
                          'ENTREGAR PEDIDO',
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'PixelifySans',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Área central: visualização do lanche montado
          Positioned.fill(
            child: Align(
              alignment: const Alignment(0.2, 0.0),
              child: montarHamburguer(),
            ),
          ),

          // Botão fechar (X)
          Positioned(
            top: 30,
            right: 20,
            child: GestureDetector(
              onTap: () async {
                await musicPlayer.stop();
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}