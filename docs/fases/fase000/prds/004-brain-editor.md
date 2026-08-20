# PRD 004: Editor de Cerebro

## Objetivo

Permitir que o jogador crie e revise visualmente o programa do Buneko por meio de blocos conectados por linhas.

## Experiencia

O jogador arrasta blocos da paleta para uma area de trabalho, configura seus parametros por seletores e liga pontos de fluxo com linhas. Ele ve RAM usada de 5, mensagens de validacao e os controles para iniciar a tentativa. A interface deve tornar visiveis os ramos de `IF` e o corpo e a saida de `WHILE`.

## Funcionalidades do MVP

- Paleta com os blocos definidos pela PRD 001.
- Area de trabalho com ponto de inicio.
- Arrastar, mover, conectar, desconectar e remover blocos.
- Seletores para direcao e condicoes de visao ou audicao.
- Linhas de fluxo entre pontos compativeis.
- Indicador de RAM usada e limite de 5.
- Validacao antes de iniciar, com erros localizados no bloco ou conexao relevante.
- Controles de iniciar, pausar, retomar, parar e reiniciar conforme estado do executor.
- Retorno a edicao apos falha, mantendo programa e montagem.

## Limites

O MVP nao exige salvar programas entre sessoes, copiar e colar blocos, desfazer/refazer, zoom, comentarios ou edicao durante a execucao. O layout do grafo pode permanecer aberto apenas durante a missao atual.

## Criterios de aceite

- O jogador monta por conexoes um programa valido de ate 5 RAM.
- A interface nao permite conexoes incompativeis ou informa claramente por que uma conexao foi recusada.
- Um erro de RAM, inicio ou fluxo aponta para uma correcao compreensivel.
- O jogador consegue perceber o estado de execucao e voltar a editar apos falha.
- O editor usa o modelo da PRD 001, sem guardar uma segunda interpretacao da linguagem.
- A validacao do modelo possui testes automatizados; as interacoes do editor possuem roteiro de verificacao manual.
