# ADR 005: Editor de cerebro conectado por linhas

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

## Decisao

O jogador monta o programa arrastando blocos para uma area de trabalho e conectando seus pontos de fluxo por linhas.

## Motivo

O formato torna visiveis a ordem e os desvios da logica, e pode crescer para programas mais ricos sem abandonar o modelo mental inicial.

## Consequencias

O editor precisa validar conexoes, inicio do programa, ramificacao e ciclos. A representacao interna do programa nao deve depender da interface visual.
