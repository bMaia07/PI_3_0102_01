// -----------------------------------------------------------------------------
// Primeira cena da biblioteca. O jogador vê a fachada e só avança ao clicar
// no marcador posicionado na rampa/entrada.
// -----------------------------------------------------------------------------
// -----------------------------------------------------------------------------
// ARQUIVO: biblioteca_fachada.dart
// OBJETIVO: controlar a primeira tela da biblioteca, com marcador na rampa.
// COMENTÁRIOS DETALHADOS:
// - Usa BibliotecaSceneScaffold para manter fundo, música e botões iguais.
// - Usa BibliotecaIndicadorEntrada para criar o ponto clicável.
// - Ao clicar no marcador, navega para a próxima etapa da biblioteca.
// -----------------------------------------------------------------------------
import 'package:flutter/material.dart';
import 'biblioteca_hall.dart';
import 'biblioteca_image_screen.dart';

class BibliotecaFachadaScreen extends StatelessWidget {
  const BibliotecaFachadaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retorna a tela base da biblioteca com imagem de fundo e elementos sobrepostos.
    return BibliotecaSceneScaffold(
      imageAsset: 'assets/fundo/Biblioteca/biblioteca_fachada.png',
      titulo: 'BIBLIOTECA - FACHADA',
      descricao:
          'Você chegou à entrada da biblioteca.\nClique no marcador da rampa para entrar no prédio.',
      dicaRodape: '[ CLIQUE NO MARCADOR PARA ENTRAR ]',
      // Marcador posicionado na rampa/entrada da fachada.
      // Cria o marcador clicável por cima da imagem.
      overlayBuilder: (context, size) {
        return BibliotecaIndicadorEntrada(
          leftFactor: 0.60,
          topFactor: 0.46,
          sizeFactor: 0.07,
          onTap: () {
            // Navega para a próxima tela da biblioteca.
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BibliotecaHallScreen()),
            );
          },
        );
      },
    );
  }
}