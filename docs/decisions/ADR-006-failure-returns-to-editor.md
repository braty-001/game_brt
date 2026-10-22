# ADR 006: Falha retorna ao editor

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

## Decisao

Quando o Buneko falhar, o jogo exibe uma mensagem de falha e retorna o jogador ao fluxo de edicao do Buneko e do cerebro.

## Motivo

O resultado da tentativa deve alimentar diretamente o proximo ciclo de diagnostico e ajuste.

## Consequencias

O programa e a montagem atual devem permanecer disponiveis apos a falha. A interface deve destacar o motivo conhecido da falha sem ocultar a area de edicao.
