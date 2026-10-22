# ADR 003: Papel do jogador durante a fase

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

## Decisao

O jogador nao controla diretamente o Buneko durante a execucao da missao. Ele programa, inicia e observa a execucao, podendo interromper e ajustar o programa.

## Motivo

O desafio central e criar a logica autonoma do Buneko, nao demonstrar habilidade de plataforma por controle manual.

## Consequencias

A interface deve priorizar observacao, clareza do estado do programa, feedback de sensores e um ciclo rapido de editar e tentar novamente.
