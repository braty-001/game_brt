# ADR 002: Execucao continua do programa

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

## Decisao

Durante uma fase, o programa do Buneko sera avaliado e executado continuamente, em vez de ser uma sequencia executada uma unica vez.

## Motivo

Isso permite comportamento reativo a sensores e abre caminho para missoes mais complexas no futuro.

## Consequencias

O executor precisa limitar instrucoes por atualizacao e disponibilizar pausa, parada, reinicio e diagnostico de programas que nao progridem.
