# ADR 004: Fisica livre de plataforma

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

## Decisao

O MVP sera uma plataforma 2D com movimento continuo, gravidade, colisao e impacto, e nao uma grade de posicoes discretas.

## Motivo

A fisica livre sustenta melhor a fantasia de construir um robo e cria espaco para atributos futuros, como velocidade, forca e equipamentos.

## Consequencias

As acoes do programa precisam produzir intencoes de movimento compativeis com a fisica. A fase tutorial deve ser desenhada com tolerancia suficiente para que seu desafio seja programacao, nao precisao manual impossivel.
