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

  await musicPlayer.setReleaseMode(
    ReleaseMode.loop,
  );

  await musicPlayer.play(
    AssetSource(
      'audio/somminigamepraca.mp3',
    ),
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

  Map<String, dynamic> get pedido =>
      pedidos[pedidoAtual];

  final Map<String, String> imagensIngredientes = {

    'Pão de baixo':
    'assets/fundo/Praca/paodebaixo.png',

    'Pão de cima':
    'assets/fundo/Praca/paodecima.png',

    'Carne':
    'assets/fundo/Praca/carne.png',

    'Queijo':
    'assets/fundo/Praca/queijo.png',

    'Bacon':
    'assets/fundo/Praca/bacon.png',

    'Alface':
    'assets/fundo/Praca/alface.png',

    'Tomate':
    'assets/fundo/Praca/tomate.png',

    'Batata':
    'assets/fundo/Praca/batata.png',

    'Refrigerante':
    'assets/fundo/Praca/refri.png',
  };

  void selecionarIngrediente(
      String item,
      ) {

    setState(() {

      ingredientesSelecionados.add(item);

    });
  }

  void verificarPedido() {

    final ingredientesCorretos =
    List<String>.from(
      pedido['ingredientes'],
    );

    bool lancheCorreto =

        ingredientesCorretos.join(',') ==

            ingredientesSelecionados.join(',');

    if (lancheCorreto) {

      pontos += 50;

      showDialog(
        context: context,
        barrierDismissible: false,

        builder: (_) {

          return Dialog(

            backgroundColor: Colors.transparent,

            child: Container(

              padding:
              const EdgeInsets.all(20),

              decoration: BoxDecoration(

                color:
                const Color.fromARGB(
                  255,
                  73,
                  14,
                  14,
                ),

                borderRadius:
                BorderRadius.circular(20),

                border: Border.all(
                  color: Colors.black,
                  width: 4,
                ),
              ),

              child: Column(

                mainAxisSize:
                MainAxisSize.min,

                children: [

                  const Text(
                    'Pedido correto!',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontFamily:
                      'PixelifySans',
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Image.asset(
                    'assets/fundo/Praca/hamburguer.png',

                    height: 220,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    '+50 pontos',

                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 24,
                      fontFamily:
                      'PixelifySans',
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

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
                              const Color.fromARGB(
                                255,
                                73,
                                14,
                                14,
                              ),

                              title: const Text(
                                'Parabéns!',

                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                  'PixelifySans',
                                ),
                              ),

                              content: const Text(
                                'Você completou todos os pedidos!',

                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily:
                                  'PixelifySans',
                                ),
                              ),

                              actions: [

                                TextButton(

                                  onPressed: () {

                                    Navigator.pop(
                                      context,
                                    );

                                    Navigator.pop(
                                      context,
                                      true,
                                    );
                                  },

                                  child: const Text(
                                    'Continuar',

                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                      } else {

                        setState(() {

                          if (pedidoAtual <
                              pedidos.length - 1) {

                            pedidoAtual++;
                          }

                          ingredientesSelecionados
                              .clear();
                        });
                      }
                    },

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      Colors.green,
                    ),

                    child: const Text(
                      'OK',

                      style: TextStyle(
                        fontFamily:
                        'PixelifySans',
                      ),
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

            backgroundColor:
            const Color.fromARGB(
              255,
              73,
              14,
              14,
            ),

            title: const Text(
              'Pedido errado!',

              style: TextStyle(
                color: Colors.white,
                fontFamily:
                'PixelifySans',
              ),
            ),

            content: const Text(
              'Monte novamente para pontuar!',

              style: TextStyle(
                color: Colors.white,
                fontFamily:
                'PixelifySans',
              ),
            ),

            actions: [

              TextButton(

                onPressed: () {

                  Navigator.pop(context);

                  setState(() {

                    ingredientesSelecionados
                        .clear();
                  });
                },

                child: const Text(
                  'Tentar novamente',

                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Widget ingredienteBotao(
      String nome,
      String imagem,
      ) {

    bool selecionado =
    ingredientesSelecionados
        .contains(nome);

    return GestureDetector(

      onTap: () {

        selecionarIngrediente(nome);

      },

      child: Container(

        width: 120,

        margin:
        const EdgeInsets.all(8),

        padding:
        const EdgeInsets.all(8),

        decoration: BoxDecoration(

          color: selecionado
              ? Colors.green
              : const Color.fromARGB(
            255,
            114,
            28,
            28,
          ),

          borderRadius:
          BorderRadius.circular(12),

          border: Border.all(
            color: Colors.black,
            width: 3,
          ),
        ),

        child: Column(
          children: [

            Image.asset(
              imagem,
              height: 60,
              fit: BoxFit.contain,
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              nome,

              textAlign: TextAlign.center,

              style: const TextStyle(
                color: Colors.white,
                fontFamily:
                'PixelifySans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget montarHamburguer() {

    List<String> ingredientesHamburguer =

    ingredientesSelecionados.where(

          (item) =>

      item != 'Batata' &&
          item != 'Refrigerante',

    ).toList();

    bool temBatata =
    ingredientesSelecionados
        .contains('Batata');

    bool temRefri =
    ingredientesSelecionados
        .contains('Refrigerante');

    return SizedBox(

      width: 900,
      height: 550,

      child: Stack(

        children: [

          if (temRefri)

            Positioned(
              left: 20,
              bottom: 30,

              child: Image.asset(
                imagensIngredientes[
                'Refrigerante'
                ]!,

                width: 130,
                height: 130,

                fit: BoxFit.contain,
              ),
            ),

          if (temBatata)

            Positioned(
              right: 60,
              bottom: 30,

              child: Image.asset(
                imagensIngredientes['Batata']!,

                width: 130,
                height: 130,

                fit: BoxFit.contain,
              ),
            ),

          ...List.generate(

            ingredientesHamburguer.length,

                (index) {

              String item =
              ingredientesHamburguer[index];

              bool ehPao =

                  item == 'Pão de baixo' ||
                      item == 'Pão de cima';

              return Positioned(

                left: ehPao ? 200 : 250,

                bottom: index * 35,

                child: Image.asset(

                  imagensIngredientes[item]!,

                  width: ehPao ? 320 : 220,
                  height: ehPao ? 190 : 120,

                  fit: BoxFit.contain,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              'assets/fundo/Praca/pracaalimentacao.jpg',
              fit: BoxFit.cover,
            ),
          ),

          Container(
            color: Colors.black
                .withOpacity(0.45),
          ),

          Positioned(
            right: 20,
            bottom: 20,

            child: Image.asset(
              'assets/fundo/personagens/ratatoni.png',
              height: 240,
            ),
          ),

          Positioned(
            top: 40,
            left: 30,

            child: Container(

              width: 360,

              padding:
              const EdgeInsets.all(18),

              decoration: BoxDecoration(

                color:
                const Color.fromARGB(
                  255,
                  73,
                  14,
                  14,
                ).withOpacity(0.95),

                borderRadius:
                BorderRadius.circular(16),

                border: Border.all(
                  color: Colors.black,
                  width: 3,
                ),
              ),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Text(
                    'Pedido ${pedidoAtual + 1}/5',

                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 22,
                      fontFamily:
                      'PixelifySans',
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    pedido['nome'],

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontFamily:
                      'PixelifySans',
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    pedido['ingredientes']
                        .join(', '),

                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontFamily:
                      'PixelifySans',
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    'Pontos: $pontos / 250',

                    style: const TextStyle(
                      color: Colors.yellow,
                      fontSize: 20,
                      fontFamily:
                      'PixelifySans',
                    ),
                  ),
                ],
              ),
            ),
          ),

          Center(
            child: SizedBox(
              width: 900,
              height: 550,

              child: montarHamburguer(),
            ),
          ),

          Positioned(
            left: 20,
            right: 20,
            bottom: 20,

            child: Container(

              padding:
              const EdgeInsets.all(16),

              decoration: BoxDecoration(

                color: Colors.black
                    .withOpacity(0.82),

                borderRadius:
                BorderRadius.circular(18),
              ),

              child: Column(
                children: [

                  const Text(
                    'Ingredientes',

                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily:
                      'PixelifySans',
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Wrap(

                    alignment:
                    WrapAlignment.center,

                    children: [

                      ingredienteBotao(
                        'Pão de baixo',
                        'assets/fundo/Praca/paodebaixo.png',
                      ),

                      ingredienteBotao(
                        'Pão de cima',
                        'assets/fundo/Praca/paodecima.png',
                      ),

                      ingredienteBotao(
                        'Carne',
                        'assets/fundo/Praca/carne.png',
                      ),

                      ingredienteBotao(
                        'Queijo',
                        'assets/fundo/Praca/queijo.png',
                      ),

                      ingredienteBotao(
                        'Bacon',
                        'assets/fundo/Praca/bacon.png',
                      ),

                      ingredienteBotao(
                        'Alface',
                        'assets/fundo/Praca/alface.png',
                      ),

                      ingredienteBotao(
                        'Tomate',
                        'assets/fundo/Praca/tomate.png',
                      ),

                      ingredienteBotao(
                        'Batata',
                        'assets/fundo/Praca/batata.png',
                      ),

                      ingredienteBotao(
                        'Refrigerante',
                        'assets/fundo/Praca/refri.png',
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  ElevatedButton(

                    onPressed:
                    verificarPedido,

                    style:
                    ElevatedButton.styleFrom(

                      backgroundColor:
                      Colors.green,

                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 16,
                      ),
                    ),

                    child: const Text(
                      'ENTREGAR PEDIDO',

                      style: TextStyle(
                        fontSize: 18,
                        fontFamily:
                        'PixelifySans',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            top: 30,
            right: 20,

            child: GestureDetector(

              onTap: () async {

                await musicPlayer.stop();

                Navigator.pop(context);
              },

              child: Container(

                padding:
                const EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: Colors.black54,

                  borderRadius:
                  BorderRadius.circular(10),
                ),

                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}