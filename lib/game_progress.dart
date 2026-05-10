// -----------------------------------------------------------------------------
// ARQUIVO: game_progress.dart
// OBJETIVO: guardar o progresso global do jogo enquanto o aplicativo está aberto.
// IMPORTANTE: esse controle é simples e fica em memória; se o app for recarregado,
// os valores voltam ao padrão, a menos que outra parte do projeto salve esses dados.
// -----------------------------------------------------------------------------

// Classe com variáveis e métodos estáticos.
// Como tudo é static, qualquer tela consegue acessar o progresso sem criar objeto.
class GameProgress {
  // Indica se o botão/entrada da biblioteca já está liberado no jogo.
  // Começa false porque o jogador primeiro precisa passar pelo H15/Pingo.
  static bool bibliotecaDesbloqueada = false;

  // Indica se o jogador aceitou a missão do Corujito para procurar o livro.
  // Quando true, aparece o marcador PROCURAR na área principal da biblioteca.
  static bool missaoCorujitoAceita = false;

  // Indica se o jogador concluiu o puzzle do acervo e encontrou o livro.
  // Quando true, ao clicar no Corujito começa o diálogo de devolução.
  static bool livroCorujitoEncontrado = false;

  // Indica se o jogador já devolveu o livro para o Corujito.
  // Quando true, a missão da biblioteca fica finalizada.
  static bool livroCorujitoEntregue = false;

  // Libera a biblioteca depois que o jogador passa pela etapa do H15/Pingo.
  static void desbloquearBiblioteca() {
    // Troca a biblioteca para liberada.
    bibliotecaDesbloqueada = true;
  }

  // Marca que o jogador aceitou a proposta do Corujito.
  static void aceitarMissaoCorujito() {
    // A partir daqui o jogador pode procurar o livro no acervo.
    missaoCorujitoAceita = true;
  }

  // Marca que o jogador achou o livro no puzzle do acervo.
  static void marcarLivroCorujitoEncontrado() {
    // Essa variável faz o próximo clique no Corujito abrir o diálogo de devolução.
    livroCorujitoEncontrado = true;
  }

  // Finaliza a missão do livro após a devolução para o Corujito.
  static void entregarLivroCorujito() {
    // Guarda que o livro já foi entregue.
    livroCorujitoEntregue = true;

    // Como o livro já foi entregue, ele não precisa mais ficar como "encontrado".
    livroCorujitoEncontrado = false;
  }

  // Reseta o progresso da biblioteca ao iniciar um novo jogo/save.
  static void resetar() {
    // Bloqueia novamente a biblioteca.
    bibliotecaDesbloqueada = false;

    // Remove a missão aceita do Corujito.
    missaoCorujitoAceita = false;

    // Remove o estado de livro encontrado.
    livroCorujitoEncontrado = false;

    // Remove o estado de livro entregue.
    livroCorujitoEntregue = false;
  }
}