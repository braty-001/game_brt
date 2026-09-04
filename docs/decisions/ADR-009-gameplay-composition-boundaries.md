# ADR 009: Fronteiras de composicao do gameplay

## Decisao

O dominio de programacao, o estado do editor, a sessao de tentativa e a apresentacao das cenas devem evoluir como responsabilidades separadas.

- O dominio de programacao nao depende de cenas, do tutorial ou do Buneko concreto.
- O editor altera `EditorGraphState` somente por comandos e publica consultas e sinais pequenos para seus consumidores.
- O editor nao cria adaptadores concretos do Buneko nem conhece exemplos de uma missao especifica.
- A sessao de tentativa coordena runtime, sensores, personagem e encerramento fisico.
- O fluxo da missao controla transicoes e preservacao de montagem e programa sem acessar controles internos das telas.
- Cenas `.tscn` descrevem a hierarquia visual estavel; scripts criam apenas conteudo realmente dinamico e tratam comportamento.

## Motivo

O MVP provou o loop montagem -> programacao -> tentativa, mas `BrainEditor` e `TutorialMission` passaram a concentrar composicao visual, estado, runtime e integracao fisica. Essa concentracao torna novas missoes, sensores e pecas dependentes de alteracoes em scripts centrais.

As fronteiras acima preservam o comportamento atual e permitem crescimento por contratos pequenos, como ja definido em `docs/foundations.md`.

## Consequencias

- Operacoes compostas do editor devem ser atomicas tambem para observadores.
- Resultados de comando devem possuir tipo proprio em vez de chaves de `Dictionary` espalhadas pela UI.
- Exemplos de programa entram no editor por um provedor configuravel.
- `TutorialMission` deixa de controlar diretamente detalhes do runtime e da fisica.
- Testes de integracao podem inspecionar cenas, mas regras devem ser cobertas por APIs publicas dos componentes extraidos.
- A refatoracao nao altera RAM, semantica de blocos, fisica, objetivo, layout aprovado ou escopo de gameplay.
