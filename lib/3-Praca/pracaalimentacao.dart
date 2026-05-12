import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'minigame_pracaalimentacao.dart';

class Telapracaalimentacao extends StatefulWidget {
  const Telapracaalimentacao({super.key});

  @override
  State<Telapracaalimentacao> createState() =>
      _TelapracaalimentacaoState();
}

class _TelapracaalimentacaoState
    extends State<Telapracaalimentacao> {

  int etapa = 0;

  final AudioPlayer _player = AudioPlayer();

  bool mutado = false;

  @override
  void initState() {
    super.initState();
    tocarAudio();
  }

  Future<void> tocarAudio() async {

    await _player.setVolume(1.0);

    await _player.setReleaseMode(
      ReleaseMode.loop,
    );

    await _player.play(
      AssetSource(
        'audios/sompraca.mp3',
      ),
    );
  }

  void alternarMute() async {

    setState(() {
      mutado = !mutado;
    });

    if (mutado) {

      await _player.setVolume(0.0);

    } else {

      await _player.setVolume(1.0);
    }
  }

  @override
  void dispose() {

    _player.dispose();

    super.dispose();
  }

  String get textoAtual {

    switch (etapa) {

      case 0:
        return '\nOlá criatura feia, em que posso te ajudar?';

      case 1:
        return 'Você:';

      case 2:
        return '\nAh sim, tenho uma informação útil... mas só direi se completar um desafio!';

      case 3:
        return 'Você:';

      case 4:
        return '\nVocê terá que fazer três hambúrgueres corretamente seguindo os pedidos!';

      case 5:
        return 'Você:';

      case 6:
        return '\nMuito bem! O animal desaparecido foi visto com um hambúrguer, ele pediu um para ele e outro para seu amigo coala...';

      case 7:
        return 'Você:';

      case 8:
        return '\nEle é muito bom em desenhos e prédios, acho que ele quer ser arquiteto.';

      case 9:
        return 'Você:';

      case 10:
        return '\nBoa sorte!';

      default:
        return '';
    }
  }

  void avancar() {

    setState(() {

      if (
      etapa == 1 ||
          etapa == 3 ||
          etapa == 5 ||
          etapa == 7 ||
          etapa == 9 ||
          etapa == 10
      ) {
        return;
      }

      etapa++;
    });
  }

  Widget buildOpcoes() {

    // PRIMEIRA ESCOLHA
    if (etapa == 1) {

      return Column(
        children: [

          _botaoPixel(
            'Estou a procura de um animal desaparecido no Campus, ele está com você?',
                () {

              setState(() {
                etapa = 2;
              });

            },
          ),
        ],
      );
    }

    // SEGUNDA ESCOLHA
    if (etapa == 3) {

      return Column(
        children: [

          _botaoPixel(
            'Vamos nessa!',
                () async {

              await _player.stop();

              final venceu = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const MinigamePracaAlimentacao(),
                ),
              );

              await tocarAudio();

              if (venceu == true) {

                setState(() {
                  etapa = 6;
                });
              }
            },
          ),

          SizedBox(height: 10),

          _botaoPixel(
            'Como é este desafio?',
                () {

              setState(() {
                etapa = 4;
              });

            },
          ),
        ],
      );
    }

    // TERCEIRA ESCOLHA
    if (etapa == 5) {

      return _botaoPixel(
        'Vamos nessa',
            () async {

          await _player.stop();

          final venceu = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const MinigamePracaAlimentacao(),
            ),
          );

          await tocarAudio();

          if (venceu == true) {

            setState(() {
              etapa = 6;
            });
          }
        },
      );
    }

    // QUARTA ESCOLHA
    if (etapa == 7) {

      return Column(
        children: [

          _botaoPixel(
            'Onde encontro o Coala?',
                () {

              setState(() {
                etapa = 8;
              });

            },
          ),

          SizedBox(height: 10),

          _botaoPixel(
            'Vou em busca do coala!',
                () {

              setState(() {
                etapa = 10;
              });

            },
          ),
        ],
      );
    }

    // QUINTA ESCOLHA
    if (etapa == 9) {

      return Column(
        children: [

          _botaoPixel(
            'Obrigada pela ajuda!',
                () {

              setState(() {
                etapa = 10;
              });

            },
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Widget _botaoPixel(
      String texto,
      VoidCallback onTap,
      ) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: double.infinity,

        padding: EdgeInsets.symmetric(
          vertical: 12,
        ),

        decoration: BoxDecoration(
          color: Color(0xFF1a1f3a),

          border: Border.all(
            color: const Color.fromARGB(
              255,
              73,
              14,
              14,
            ),
            width: 2,
          ),

          borderRadius:
          BorderRadius.circular(8),
        ),

        child: Text(
          texto,
          textAlign: TextAlign.center,

          style: TextStyle(
            fontFamily: 'PixelifySans',
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildBotaoContinuar() {

    if (etapa == 10) {

      return Align(
        alignment: Alignment.bottomRight,

        child: ElevatedButton(
          onPressed: () {

            print("Voltar ao mapa");

          },

          style: ElevatedButton.styleFrom(
            backgroundColor:
            Color.fromARGB(
              255,
              114,
              28,
              28,
            ),

            side: BorderSide(
              color: const Color.fromARGB(
                255,
                73,
                14,
                14,
              ),
              width: 2,
            ),

            padding: EdgeInsets.symmetric(
              horizontal: 22,
              vertical: 12,
            ),
          ),

          child: Text(
            'Voltar ao mapa',

            style: TextStyle(
              color: Colors.white,
              fontFamily: 'PixelifySans',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (
    etapa == 1 ||
        etapa == 3 ||
        etapa == 5 ||
        etapa == 7 ||
        etapa == 9
    ) {
      return const SizedBox();
    }

    return Align(
      alignment: Alignment.bottomRight,

      child: ElevatedButton(
        onPressed: avancar,

        style: ElevatedButton.styleFrom(
          backgroundColor:
          Color.fromARGB(
            255,
            114,
            28,
            28,
          ),

          side: BorderSide(
            color: const Color.fromARGB(
              255,
              73,
              14,
              14,
            ),
            width: 2,
          ),

          padding: EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 12,
          ),
        ),

        child: Text(
          'Continuar',

          style: TextStyle(
            color: Colors.white,
            fontFamily: 'PixelifySans',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildDialogo() {

    return Container(
      padding: EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: Color.fromARGB(
          255,
          85,
          20,
          20,
        ).withOpacity(0.95),

        border: Border.all(
          color: const Color.fromARGB(
            255,
            73,
            14,
            14,
          ),
          width: 3,
        ),

        borderRadius:
        BorderRadius.circular(16),

        boxShadow: [

          BoxShadow(
            color: const Color.fromARGB(
              221,
              0,
              0,
              0,
            ),

            blurRadius: 15,

            offset: Offset(6, 6),
          ),

        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),

            decoration: BoxDecoration(
              color: Color.fromARGB(
                255,
                114,
                28,
                28,
              ),

              borderRadius:
              BorderRadius.circular(6),
            ),

            child: Text(
              etapa == 1 ||
                  etapa == 3 ||
                  etapa == 5 ||
                  etapa == 7 ||
                  etapa == 9
                  ? 'VOCÊ:'
                  : 'DON RATATONI:',

              style: TextStyle(
                fontFamily: 'PixelifySans',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(height: 12),

          Text(
            textoAtual,

            style: TextStyle(
              fontFamily: 'PixelifySans',
              color: Colors.white,
              fontSize: 15,
              height: 1.5,
            ),
          ),

          SizedBox(height: 12),

          buildOpcoes(),

          buildBotaoContinuar(),
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
            color: Colors.black.withOpacity(0.4),
          ),

          Positioned(
            left: 0,
            bottom: 90,

            child: Image.asset(
              'assets/personagens/ratatoni.png',
              height: 400,
            ),
          ),

          Positioned(
            right: 20,
            left: 300,
            bottom: 80,

            child: buildDialogo(),
          ),

          Positioned(
            top: 40,
            left: 20,

            child: GestureDetector(
              onTap: () {

                Navigator.pop(context);

              },

              child: Container(
                padding: EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: Color.fromARGB(
                    255,
                    95,
                    31,
                    31,
                  ).withOpacity(0.8),

                  border: Border.all(
                    color: const Color.fromARGB(
                      255,
                      73,
                      14,
                      14,
                    ),
                    width: 2,
                  ),

                  borderRadius:
                  BorderRadius.circular(8),
                ),

                child: Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          Positioned(
            top: 40,
            right: 20,

            child: GestureDetector(
              onTap: alternarMute,

              child: Container(
                padding: EdgeInsets.all(10),

                decoration: BoxDecoration(
                  color: Color.fromARGB(
                    255,
                    95,
                    31,
                    31,
                  ).withOpacity(0.8),

                  border: Border.all(
                    color: const Color.fromARGB(
                      255,
                      73,
                      14,
                      14,
                    ),
                    width: 2,
                  ),

                  borderRadius:
                  BorderRadius.circular(8),
                ),

                child: Icon(
                  mutado
                      ? Icons.volume_off
                      : Icons.volume_up,

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