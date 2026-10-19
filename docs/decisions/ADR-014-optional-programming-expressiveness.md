# ADR 014: Liberdade de programacao com complexidade opcional

Status: diretriz aprovada pelo usuario em 2026-09-16; capacidades futuras ainda nao implementadas.

## Decisao

A liberdade de programacao e um valor do Buneko. O jogador deve poder escolher composicoes mais elaboradas, mantendo a possibilidade de resolver desafios com programas simples. Recursos avancados devem ser sempre opcionais; sua introducao nao deve tornar obrigatorio o uso de funcoes ou outras estruturas avancadas.

## Consequencias

- Planejar composicao de varios IFs e WHILEs, continuacao comum depois de decisoes e funcoes reutilizaveis no backlog de linguagem.
- Preservar programas simples e sua semantica; nao exigir migracao para recursos avancados para continuar jogando.
- Distinguir repeticao sequencial de monitoramento continuo ou interrupcao. Uma dessas capacidades nao implica a outra.
- Antes da implementacao, definir escopo, apresentacao, RAM, chamadas, guardas de execucao, compatibilidade e testes em PRD e tarefas proprias. Esta diretriz nao altera a regra atual de custo por bloco.
- A expansao fica para trabalho futuro; a melhoria imediata de coleta e conclusao do laboratorio tem prioridade nesta solicitacao.

Referencia: [FUT-001](../backlog.md#fut-001---composicao-livre-e-funcoes-opcionais-no-cerebro). Complementa ADRs 001, 002, 003 e 005.
