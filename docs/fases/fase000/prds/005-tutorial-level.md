# PRD 005: Fase Tutorial

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../../../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

## Objetivo

Ensinar o ciclo basico de montagem, programacao, observacao, falha e correcao em uma missao curta de plataforma.

## Sequencia

1. O jogador monta as pecas basicas do unico Buneko disponivel.
2. A missao apresenta o objetivo de atravessar o trecho e alcancar o final.
3. O jogador abre o editor de cerebro com 5 RAM e os blocos iniciais disponiveis.
4. O Buneko executa o programa em uma plataforma com um buraco.
5. Se cair, uma mensagem explica a falha e o jogador retorna a montagem e edicao preservando seu trabalho.
6. Ao chegar ao objetivo, a missao apresenta conclusao clara.

## Design do desafio

A fase deve tornar o buraco visualmente identificavel e expor a condicao visual correspondente no editor. O desafio deve caber no limite de 5 RAM e permitir uma solucao que use ao menos movimento e pulo. Durante o tutorial, o jogador tambem deve ser apresentado a uma condicao e a uma repeticao de forma guiada, sem exigir que memorize sintaxe textual.

O nivel deve ter margem fisica suficiente para que um programa correto seja confiavel. A falha deve ser atribuivel ao programa ou a decisao do jogador, e nao a comportamento imprevisivel da fisica.

## Feedback

- Antes da execucao: objetivo, RAM disponivel e sensores relevantes.
- Durante a execucao: estado do Buneko, movimento observavel e indicacao de que o programa esta ativo.
- Na falha: mensagem `Voce falhou` acompanhada do motivo, como queda no buraco ou limite de execucao.
- Na conclusao: confirmacao de que o objetivo foi atingido.

## Fora do escopo

- Narrativa extensa, avaliacao por estrelas, pontuacao, coleta de itens e multiplas solucoes obrigatorias.
- Editor de fases, inimigos, combate, loja e upgrades.

## Criterios de aceite

- Um novo jogador consegue montar o Buneko, criar um programa, iniciar a fase e compreender o objetivo sem controle direto do personagem.
- Uma solucao valida cabe em 5 RAM e leva o Buneko ao final de forma repetivel.
- Cair no buraco exibe a falha e retorna ao fluxo de edicao com a configuracao preservada.
- A fase comunica o sensor visual associado ao buraco e introduz `IF` e `WHILE` por orientacao contextual.
- A condicao de vitoria e as transicoes de falha possuem testes automatizados quando independentes de fisica; o tutorial completo possui verificacao manual.
