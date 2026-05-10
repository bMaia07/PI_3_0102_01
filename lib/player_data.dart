// -----------------------------------------------------------------------------
// ARQUIVO: player_data.dart
// OBJETIVO: guardar dados globais do jogador atual.
// Esses dados são usados em várias telas, por exemplo no mapa e nos diálogos.
// -----------------------------------------------------------------------------

// Classe estática para facilitar o acesso ao nome e personagem em qualquer tela.
class PlayerData {
  // Nome do save; usado para identificar o jogo salvo.
  static String nomeSave = 'Save';

  // Nome do personagem; usado nas falas do jogador nos diálogos.
  static String nomePersonagem = 'Jogador';

  // Caminho do sprite/imagem do personagem escolhido.
  // Esse caminho é usado para desenhar o jogador no mapa.
  static String personagem = 'assets/personagens/player-masc1.png';

  // Atualiza um ou mais dados do jogador.
  // Os parâmetros são opcionais para permitir atualizar só o que mudou.
  static void atualizar({
    // Novo nome do save, se o usuário informou um.
    String? novoNomeSave,

    // Novo nome do personagem, se o usuário informou um.
    String? novoNomePersonagem,

    // Novo caminho do sprite escolhido.
    String? novoPersonagem,
  }) {
    // Só troca o nome do save se ele não for nulo e não estiver vazio.
    if (novoNomeSave != null && novoNomeSave.trim().isNotEmpty) {
      // trim() remove espaços extras no começo e no fim.
      nomeSave = novoNomeSave.trim();
    }

    // Só troca o nome do personagem se ele não for nulo e não estiver vazio.
    if (novoNomePersonagem != null && novoNomePersonagem.trim().isNotEmpty) {
      // Esse nome depois aparece nos diálogos como fala do jogador.
      nomePersonagem = novoNomePersonagem.trim();
    }

    // Só troca o sprite se o caminho vier preenchido.
    if (novoPersonagem != null && novoPersonagem.trim().isNotEmpty) {
      // Caminho da imagem escolhida para o personagem no mapa.
      personagem = novoPersonagem.trim();
    }
  }

  // Carrega dados de um save salvo anteriormente.
  // Aceita Map porque os saves normalmente vêm de JSON/localStorage.
  static void carregarDeSave(Map save) {
    // Reaproveita o método atualizar para evitar repetir validações.
    atualizar(
      // Lê o campo "nome" como nome do save.
      novoNomeSave: save['nome']?.toString(),

      // Lê "nomePersonagem" se existir; se for save antigo, usa o nome do save.
      novoNomePersonagem: save['nomePersonagem']?.toString() ?? save['nome']?.toString(),

      // Lê o caminho do personagem salvo.
      novoPersonagem: save['personagem']?.toString(),
    );
  }
}