# Trabalho futuro

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

Itens solicitados sem compromisso de data. Uma entrada neste backlog nao indica implementacao nem substitui a PRD e sua lista de tarefas.

## FUT-001 - Composicao livre e funcoes opcionais no cerebro

Status: solicitado pelo usuario em 2026-09-16; planejamento detalhado futuro, sem data ou fase de entrega definida. Diretriz: [ADR 014](decisions/ADR-014-optional-programming-expressiveness.md).

Necessidade: escolher montar um WHILE principal com varias decisoes em sequencia e outros WHILEs internos, sem ser obrigado a usar essa complexidade nos programas simples. Incluir funcoes reutilizaveis entre as possibilidades a planejar.

- [ ] Planejar sequencias dentro de IF/WHILE, aninhamento e continuacao comum apos os ramos de um IF.
- [ ] Planejar criacao e chamada de funcoes reutilizaveis, com representacao clara no editor.
- [ ] Explicar quando cada condicao e reavaliada; avaliar separadamente eventual necessidade de monitoramento continuo/interrupcao.
- [ ] Definir RAM, limites de chamadas/recursao, guardas, validacao, pseudocodigo, serializacao e compatibilidade antes de implementar.
- [ ] Garantir que os recursos avancados sejam opcionais e que programas simples continuem utilizaveis sem exigir funcoes.
- [ ] Criar PRD e tarefas de implementacao quando esta frente for priorizada, com exemplos escolhidos pelo usuario e aceite manual de composicao.

Prioridade atual: primeiro melhorar a apresentacao da coleta do bastao e da conclusao do laboratorio. Este item nao amplia agora o runtime, o editor nem o limite de 10 RAM.
