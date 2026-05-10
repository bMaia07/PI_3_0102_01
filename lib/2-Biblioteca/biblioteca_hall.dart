// -----------------------------------------------------------------------------
// Segunda cena da biblioteca. Mostra o hall e encaminha o jogador para a área
// principal por meio de um marcador clicável.
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// ARQUIVO: biblioteca_hall.dart
// OBJETIVO: controlar a segunda tela da biblioteca, com marcador para avançar ao salão principal.
// COMENTÁRIOS DETALHADOS:
// - Usa BibliotecaSceneScaffold para manter fundo, música e botões iguais.
// - Usa BibliotecaIndicadorEntrada para criar o ponto clicável.
// - Ao clicar no marcador, navega para a próxima etapa da biblioteca.
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'biblioteca_principal.dart';
import 'biblioteca_image_screen.dart';

class BibliotecaHallScreen extends StatelessWidget {
  const BibliotecaHallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retorna a tela base da biblioteca com imagem de fundo e elementos sobrepostos.
    return BibliotecaSceneScaffold(
      imageAsset: 'assets/biblioteca/biblioteca_hall.png',
      titulo: 'BIBLIOTECA - HALL',
      descricao:
          'Você está no hall da biblioteca.\nClique no marcador para seguir para a área principal.',
      dicaRodape: '[ CLIQUE NO MARCADOR PARA CONTINUAR ]',
      // Marcador posicionado no hall para levar até a área principal.
      // Cria o marcador clicável por cima da imagem.
      overlayBuilder: (context, size) {
        return BibliotecaIndicadorEntrada(
          leftFactor: 0.69,
          topFactor: 0.47,
          sizeFactor: 0.065,
          onTap: () {
            // Navega para a próxima tela da biblioteca.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BibliotecaPrincipalScreen()),
            );
          },
        );
      },
    );
  }
}