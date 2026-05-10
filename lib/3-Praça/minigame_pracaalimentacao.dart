import 'package:flutter/material.dart';

class MinigamePracaAlimentacao extends StatefulWidget {
  const MinigamePracaAlimentacao({super.key});

  @override
  State<MinigamePracaAlimentacao> createState() =>
      _MinigamePracaAlimentacaoState();
}

class _MinigamePracaAlimentacaoState
    extends State<MinigamePracaAlimentacao> {

  int pedidoAtual = 0;
  int pedidosConcluidos = 0;

  bool geladeiraAberta = false;

  List<String> ingredientesSelecionados = [];

  final List<Map<String, dynamic>> pedidos = [

    {
      'nome': 'X-Burguer',
      'ingredientes': [
        'Pão de baixo',
        'Pão de cima',
        'Carne',
        'Queijo',
      ],
    },

    {
      'nome': 'X-Salada',
      'ingredientes': [
        'Pão de baixo',
        'Pão de cima',
        'Carne',
        'Queijo',
        'Alface',
        'Tomate',
      ],
    },

    {
      'nome': 'X-Bacon',
      'ingredientes': [
       'Pão de baixo',
        'Pão de cima',
        'Carne',
        'Queijo',
        'Bacon',
      ],
    },

    {
      'nome': 'X-Tudo',
      'ingredientes': [
       'Pão de baixo',
        'Pão de cima',
        'Carne',
        'Queijo',
        'Bacon',
        'Alface',
        'Tomate',
      ],
    },

    {
      'nome': 'Combo Ratatoni',
      'ingredientes': [
       'Pão de baixo',
        'Pão de cima',
        'Carne',
        'Queijo',
        'Batata',
      ],
    },
  ];

  Map<String, dynamic> get pedido =>
      pedidos[pedidoAtual];

  final Map<String, String> imagensIngredientes = {

    'Pão de baixo': 'assets/fundo/Praça/paodebaixo.png',

    'Pão de cima': 'assets/fundo/Praça/paodecima.png',

    'Carne': 'assets/fundo/Praça/carne.png',

    'Queijo': 'assets/fundo/Praça/queijo.png',

    'Bacon': 'assets/fundo/Praça/bacon.png',

    'Alface': 'assets/fundo/Praça/alface.png',

    'Tomate': 'assets/fundo/Praça/tomate.png',

    'Batata': 'assets/fundo/Praça/batata.png',
  };

  void selecionarIngrediente(String item) {

    setState(() {

      if (!ingredientesSelecionados.contains(item)) {
        ingredientesSelecionados.add(item);
      }

    });
  }

  void verificarPedido() {

    final ingredientesCorretos =
    List.from(pedido['ingredientes']);

    ingredientesCorretos.sort();

    final selecionados =
    List.from(ingredientesSelecionados);

    selecionados.sort();

    bool lancheCorreto =
        ingredientesCorretos.join(',') ==
            selecionados.join(',');

    if (lancheCorreto) {

      pedidosConcluidos++;

      showDialog(
        context: context,
        barrierDismissible: false,

        builder: (_) {

          return Dialog(
            backgroundColor: Colors.transparent,

            child: Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    255,
                    73,
                    14,
                    14
                ),

                borderRadius:
                BorderRadius.circular(20),

                border: Border.all(
                  color: Colors.black,
                  width: 4,
                ),
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [

                  const Text(
                    'Pedido Completo!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontFamily: 'PixelifySans',
                    ),
                  ),

                  const SizedBox(height: 20),

                  Image.asset(
                    'assets/fundo/Praça/hamburguer.png',
                    height: 220,
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {

                      Navigator.pop(context);

                      if (pedidosConcluidos >= 5) {

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
                                  14
                              ),

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

                          pedidoAtual++;

                          ingredientesSelecionados.clear();

                          geladeiraAberta = false;

                        });

                      }

                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),

                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontFamily: 'PixelifySans',
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
                14
            ),

            title: const Text(
              'Pedido errado!',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'PixelifySans',
              ),
            ),

            content: const Text(
              'Confira os ingredientes.',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'PixelifySans',
              ),
            ),

            actions: [

              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text(
                  'Ok',
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
    ingredientesSelecionados.contains(nome);

    return GestureDetector(

      onTap: () {
        selecionarIngrediente(nome);
      },

      child: Container(
        width: 120,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(8),

        decoration: BoxDecoration(
          color: selecionado
              ? Colors.green
              : const Color.fromARGB(
              255,
              114,
              28,
              28
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
            ),

            const SizedBox(height: 6),

            Text(
              nome,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'PixelifySans',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget montarHamburguer() {

    List<Widget> camadas = [];

    for (String item in ingredientesSelecionados) {

      if (item == 'Pão') {

        camadas.add(
          Image.asset(
            'assets/fundo/Praça/paodebaixo.png',
            width: 240,
          ),
        );

        camadas.add(
          Image.asset(
            'assets/fundo/Praça/paodecima.png',
            width: 240,
          ),
        );

      } else {

        camadas.add(
          Image.asset(
            imagensIngredientes[item]!,
            width: 220,
          ),
        );
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: camadas,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Stack(
        children: [

          Positioned.fill(
            child: Image.asset(
              'assets/fundo/Praça/pracaalimentacao.jpeg',
              fit: BoxFit.cover,
            ),
          ),

          Container(
            color: Colors.black.withOpacity(0.45),
          ),

          Positioned(
            right: 20,
            bottom: 20,

            child: Image.asset(
              'assets/personagens/ratatoni.png',
              height: 240,
            ),
          ),

          Positioned(
            top: 40,
            left: 30,

            child: Container(
              width: 320,
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    255,
                    73,
                    14,
                    14
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
                    pedido['ingredientes'].join(', '),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontFamily: 'PixelifySans',
                    ),
                  ),
                ],
              ),
            ),
          ),

          // HAMBÚRGUER SENDO MONTADO
          Center(
            child: SizedBox(
              width: 300,
              height: 450,
              child: montarHamburguer(),
            ),
          ),

          // BANCADA
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,

            child: Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.82),

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
                      fontFamily: 'PixelifySans',
                    ),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [

                      ingredienteBotao(
                        'Pão de baixo',
                        'assets/fundo/Praça/paodebaixo.png',
                      ),

                      ingredienteBotao(
                          'Pão de cima',
                          'assets/fundo/Praça/paodecima.png',
                        ),

                      ingredienteBotao(
                        'Carne',
                        'assets/fundo/Praça/carne.png',
                      ),

                      ingredienteBotao(
                        'Queijo',
                        'assets/fundo/Praça/queijo.png',
                      ),

                      ingredienteBotao(
                        'Bacon',
                        'assets/fundo/Praça/bacon.png',
                      ),

                      ingredienteBotao(
                        'Alface',
                        'assets/fundo/Praça/alface.png',
                      ),

                      ingredienteBotao(
                        'Tomate',
                        'assets/fundo/Praça/tomate.png',
                      ),

                      ingredienteBotao(
                        'Batata',
                        'assets/fundo/Praça/batata.png',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: verificarPedido,

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
                        fontFamily: 'PixelifySans',
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
              onTap: () {
                Navigator.pop(context);
              },

              child: Container(
                padding: const EdgeInsets.all(10),

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