# ADR 015: Sinal temporal de perigo visivel

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

Status: implementada na PRD 020 em 2026-10-20; calibracao perceptiva pelo usuario pendente.

## Decisao

- A entrada de um inimigo vivo no campo visual atual do Buneko dispara uma desaceleracao breve, mesmo se o programa optar por fugir. A deteccao por inimigo oculto nao dispara o sinal.
- A transicao de nenhum inimigo visivel para ao menos um visivel dispara uma vez. O sinal pode ocorrer novamente depois que todos saem da visao e um inimigo volta a aparecer.
- O coordenador da tentativa aplica `Engine.time_scale` a 40% do valor anterior por 350 ms reais e retorna suavemente ao valor anterior nos 150 ms seguintes. O relogio de duracao e monotono e independente da escala de simulacao.
- Pausa manual, impacto, derrota, coleta do bastao, edicao, conclusao, restauracao e troca de cena cancelam o sinal e restauram a escala anterior. Nenhum inimigo, sensor ou efeito individual altera o tempo global.
- O sinal nao altera visao, sensores, IA, dano, alcance, programa ou RAM. A geometria e a oclusao continuam regidas pela ADR 012; a pausa curta de impacto da ADR 013 continua prevalecendo.

## Motivo e consequencias

O usuario quer perceber o perigo ao ver um inimigo, inclusive numa rota de fuga, sem receber informacao sobre ameacas escondidas. A escala aplicada globalmente exige restauracao em todas as saidas da tentativa e testes contra callbacks atrasados. O efeito e uma calibracao inicial; o aceite de ritmo e intensidade depende de observacao jogavel.
