// -----------------------------------------------------------------------------
// ARQUIVO: game_progress.dart
// OBJETIVO: guardar o progresso global do jogo.
// Usa shared_preferences para persistir entre sessões (Flutter Web = localStorage).
// -----------------------------------------------------------------------------

import 'package:shared_preferences/shared_preferences.dart';

class GameProgress {
  // ======================== H15 ========================

  // Indica se o jogador concluiu a fase H15 (desbloqueia a Biblioteca).
  static bool h15Concluida = false;

  // ======================== BIBLIOTECA ========================

  static bool bibliotecaDesbloqueada = false;
  static bool missaoCorujitoAceita = false;
  static bool livroCorujitoEncontrado = false;
  static bool livroCorujitoEntregue = false;

  // ======================== PRAÇA DE ALIMENTAÇÃO ========================

  // Desbloqueada quando a missão da biblioteca é concluída (livroCorujitoEntregue).
  // Getter de conveniência — não precisa de campo separado.
  static bool get pracaDesbloqueada => livroCorujitoEntregue;

  // ======================== ARQUITETURA ========================

  // Indica se o jogador já acessou o prédio de arquitetura (passou pelo OUT).
  static bool arquiteturaDesbloqueada = false;

  // Indica se o jogador concluiu toda a fase (puzzle + diálogo pós).
  static bool arquiteturaConcluida = false;

  // ======================== MANACÁS ========================

  // Desbloqueado quando a arquitetura é concluída.
  // Getter de conveniência.
  static bool get manacasDesbloqueada => arquiteturaConcluida;

  // ======================== SALVAR ========================

  /// Salva todo o progresso atual no localStorage (shared_preferences).
  static Future<void> salvar() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('h15Concluida', h15Concluida);
    await prefs.setBool('bibliotecaDesbloqueada', bibliotecaDesbloqueada);
    await prefs.setBool('missaoCorujitoAceita', missaoCorujitoAceita);
    await prefs.setBool('livroCorujitoEncontrado', livroCorujitoEncontrado);
    await prefs.setBool('livroCorujitoEntregue', livroCorujitoEntregue);
    await prefs.setBool('arquiteturaDesbloqueada', arquiteturaDesbloqueada);
    await prefs.setBool('arquiteturaConcluida', arquiteturaConcluida);
  }

  // ======================== CARREGAR ========================

  /// Carrega o progresso salvo do localStorage para as variáveis em memória.
  /// Chamar isso no initState da tela inicial ou do mapa de exploração.
  static Future<void> carregar() async {
    final prefs = await SharedPreferences.getInstance();

    h15Concluida =
        prefs.getBool('h15Concluida') ?? false;
    bibliotecaDesbloqueada =
        prefs.getBool('bibliotecaDesbloqueada') ?? false;
    missaoCorujitoAceita =
        prefs.getBool('missaoCorujitoAceita') ?? false;
    livroCorujitoEncontrado =
        prefs.getBool('livroCorujitoEncontrado') ?? false;
    livroCorujitoEntregue =
        prefs.getBool('livroCorujitoEntregue') ?? false;
    arquiteturaDesbloqueada =
        prefs.getBool('arquiteturaDesbloqueada') ?? false;
    arquiteturaConcluida =
        prefs.getBool('arquiteturaConcluida') ?? false;
  }

  // ======================== H15 — MÉTODOS ========================

  /// Chamar ao final da fase H15 para desbloquear a Biblioteca.
  static Future<void> concluirH15() async {
    h15Concluida = true;
    await salvar();
  }

  // ======================== BIBLIOTECA — MÉTODOS ========================

  static Future<void> desbloquearBiblioteca() async {
    bibliotecaDesbloqueada = true;
    await salvar();
  }

  static Future<void> aceitarMissaoCorujito() async {
    missaoCorujitoAceita = true;
    await salvar();
  }

  static Future<void> marcarLivroCorujitoEncontrado() async {
    livroCorujitoEncontrado = true;
    await salvar();
  }

  static Future<void> entregarLivroCorujito() async {
    livroCorujitoEntregue = true;
    livroCorujitoEncontrado = false;
    await salvar();
  }

  // ======================== ARQUITETURA — MÉTODOS ========================

  static Future<void> desbloquearArquitetura() async {
    arquiteturaDesbloqueada = true;
    await salvar();
  }

  /// Chamado ao final de arquiteturaPOS, quando o jogador clica "VOLTAR AO MAPA".
  static Future<void> concluirArquitetura() async {
    arquiteturaConcluida = true;
    await salvar();
  }

  // ======================== RESET ========================

  static Future<void> resetar() async {
    h15Concluida = false;
    bibliotecaDesbloqueada = false;
    missaoCorujitoAceita = false;
    livroCorujitoEncontrado = false;
    livroCorujitoEntregue = false;
    arquiteturaDesbloqueada = false;
    arquiteturaConcluida = false;
    await salvar();
  }
}