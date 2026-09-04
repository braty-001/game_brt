# Tarefas: PRD 012 - Estabilizacao da Arquitetura do MVP

Status geral: concluido em 2026-09-04; validacao automatizada e smoke test visual aprovados.

## Ordem de implementacao

1. Registrar as fronteiras arquiteturais.
2. Tornar comandos e eventos do grafo atomicos e tipados.
3. Desacoplar o editor do tutorial e do Buneko concreto.
4. Extrair fluxo e sessao de tentativa da missao.
5. Reduzir composicao procedural das cenas estaveis.
6. Migrar testes para contratos publicos onde pratico.
7. Adicionar CI, normalizar UIDs e validar o projeto.

## Modificacoes planejadas

- [x] Registrar ADR 009 e PRD 012.
  - A arquitetura alvo e as regras de preservacao estao documentadas antes do codigo.

- [x] Fortalecer comandos e eventos do grafo.
  - Criar resultado de comando tipado.
  - Publicar uma unica mudanca para insercao conectada.
  - Remover mutacao legada pelo seletor de condicao.
  - Cobrir sucesso, recusa e rollback sem estado intermediario.
  - Resultado: `BrainEditorCommandResult` substitui dicionarios, `EditorGraphState` oferece lote atomico e a insercao conectada publica um unico evento somente quando confirmada.

- [x] Desacoplar `BrainEditor`.
  - Remover imports de `tutorial` e `buneko/runtime`.
  - Receber exemplos por provedor configuravel.
  - Expor snapshot e sinais em vez de controles internos para a missao.
  - Resultado: exemplos entram por `BrainEditorExampleProvider`, runtime isolado usa contratos genericos e `TutorialMission` consome `BrainEditorSnapshot` e sinais publicos.

- [x] Extrair fluxo e sessao da tentativa.
  - Encapsular transicoes de missao.
  - Encapsular runtime, sensores, pausa, parada e espera de pouso.
  - Preservar mensagens especificas, incluindo `WHILE` falso com `Depois` vazio.
  - Resultado: `TutorialMissionFlow` protege transicoes e `TutorialAttemptSession` concentra adaptadores, tick, controles, pulsos e diagnostico de encerramento.

- [x] Reduzir composicao procedural.
  - Colocar hierarquias estaveis de missao, editor e bancada em cenas quando a migracao puder preservar nomes e sinais.
  - Manter blocos, conexoes e conteudo de runtime dinamicos.
  - Resultado: `brain_editor.tscn`, `assembly_bench.tscn`, `tutorial_mission.tscn` e `tutorial_attempt_hud.tscn` descrevem a composicao estavel; scripts apenas vinculam, estilizam e criam conteudo variavel.

- [x] Fortalecer testes e automacao.
  - Manter testes de RAM, controle, sensores, execucao e fisica.
  - Preferir APIs publicas para novos testes de fluxo.
  - Adicionar workflow de CI com Godot 4.4.1 e GUT vendorizado.
  - Versionar `.gd.uid` ausentes.
  - Resultado: novos testes cobrem atomicidade, fluxo e sessao; testes de cena usam contagens, selecao e snapshots publicos quando aplicavel; o workflow executa suite e cena principal.

- [x] Validar automaticamente a PRD 012.
  - Executar testes focados apos cada extracao.
  - Executar suite GUT completa.
  - Executar carregamento headless da cena principal.
  - Executar `git diff --check`.
  - Resultado em 2026-09-04: 35 scripts, 188 testes e 752 assercoes passaram; a cena principal carregou em modo headless e `git diff --check` nao encontrou erros.

- [x] Validar visualmente a PRD 012.
  - Resultado em 2026-09-04: o usuario abriu o jogo, executou um teste manual do fluxo atual e informou que nao percebeu problemas.
  - Este resultado aprova o smoke test da refatoracao. Os roteiros ampliados de resolucao, interacao e usabilidade das PRDs 006 a 011 continuam registrados nas tarefas correspondentes.

## Criterio para declarar a PRD 012 concluida

- Criterios da PRD 012 atendidos sem mudanca intencional de gameplay.
- Suite completa e carregamento headless passam.
- Pendencias manuais ficam registradas e nao sao confundidas com aceite automatizado.
