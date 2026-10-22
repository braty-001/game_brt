# ADR 001: Modelo inicial de RAM

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

## Decisao

O cerebro do Buneko inicia com 5 unidades de RAM. Cada bloco presente no programa consome 1 unidade de RAM.

## Motivo

O limite cria desde o tutorial uma restricao legivel e estimula programas compactos. Cobrar igualmente por cada bloco deixa a regra simples de entender e permite que estruturas como repeticao economizem espaco quando apropriado.

## Consequencias

O editor deve mostrar o total usado e impedir ou sinalizar programas que excedam o limite. Aumento de RAM sera uma via de progressao futura.

Complemento da Fase 002: ADR 010 mantem 5 no tutorial e fornece 10 antes da primeira missao. Limite e contexto explicito do Buneko; custo e alcance dos blocos seguem PRD 001.
