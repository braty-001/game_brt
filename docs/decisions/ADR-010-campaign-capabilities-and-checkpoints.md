# ADR 010: Campanha, capacidades e checkpoint didatico

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

## Decisao

RAM e contexto do Buneko fornecido pela composicao ao editor e runtime, nao propriedade editavel do programa nem limite global mutavel. Tutorial usa 5; primeira missao fornece 10 antes da entrada. Painel, validacao, pseudocodigo e runtime recebem o mesmo limite. Cada bloco alcancavel custa 1.

Sensores sao capacidades de pecas, nao blocos adicionais. Consultas alimentam IF/WHILE sem reescrever controles. Atacar representa um golpe; WHILE expressa repeticao. Alvo morto deixa de ser valido; equipamento necessario deve ser validado na integracao do combate.

Navegacao pertence a raiz de composicao. Tutorial publica conclusao; editor publica snapshots e pedidos genericos sem importar laboratorio. Sessao preserva montagem/grafo entre telas; persistencia pertence a PRD 017.

Na PRD 015, o contexto tambem fornece as consultas disponiveis ao seletor do editor. `STEP_AHEAD` usa a modalidade VISION existente sem criar bloco nem alterar IF/WHILE; o tutorial mantem suas quatro consultas originais. A campanha nao oferece audicao nesta etapa. `ProgramAttemptSession` reutiliza a execucao fisica; o adaptador tutorial apenas fornece seu sensor. Pausa do laboratorio preserva velocidade e suspende fisica; o tutorial mantem a parada horizontal anterior.

Coleta do bastao e pausa de ensino e checkpoint especificos da missao 1. Retomada executa programa editado desde o inicio; pilha, ponteiro de instrucao e golpes intermediarios nao sao salvos. Derrota/reabertura restauram vida 10 e tres inimigos vivos nas posicoes iniciais, preservando arma/programa. Apresentacao e marcada como vista.

O contexto do editor tambem limita acoes: `Atacar` so aparece depois da coleta. O golpe frontal alcanca 48 unidades alem do corpo, prepara por 0,2 s e completa o ciclo em 0,8 s. O nivel resolve juntos os impactos preparados no mesmo passo fisico, permitindo troca simultanea, e rejeita dano por oclusao. Vida, ciclo do golpe e decisao da IA permanecem testaveis fora da apresentacao.

## Motivo e consequencias

- Orcamento novo nao altera tutorial nem permite ao grafo conceder RAM a si mesmo.
- Visao, nevoa e deteccao compartilham alcance/oclusao. Minimap mostra apenas informacao aproximada.
- Vitoria depende da saida. Recompensa e primeira conclusao sao persistidas juntas, impedindo duplicacao.
- Save usa dados versionados, nunca objetos executaveis, com tratamento de falhas.
- Retomada consistente do checkpoint tem prioridade sobre restaurar cada instante fisico.

Complementa ADRs 001, 003, 006 e 009 para PRDs 014 a 017.

## Apresentacao dos marcos da missao (PRD 019)

Plano aprovado em 2026-09-16: a coleta aguarda confirmacao no painel antes de abrir o editor. A chegada a saida apresenta conclusao com escolhas de selecao ou editor, encaminhadas por sinais para GameFlow. Paineis bloqueiam simulacao e controles ao fundo, preservam a sessao e nao afirmam persistencia ou recompensa. A navegacao por escolha e unica; a introducao nao se repete no checkpoint.
