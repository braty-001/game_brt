# Tarefas: PRD 010 - Fundacao Reativa do Editor de Cerebro

Status geral: implementacao e validacao automatizada concluidas. A fundacao reativa e a view dedicada estao integradas; falta concluir o roteiro manual.

A PRD 012 complementa esta fundacao ao tornar operacoes compostas atomicas e restringir as mutacoes ao controlador de comandos.

## Ordem de implementacao

1. Mapear mutacoes e consumidores atuais do grafo.
2. Definir eventos e comandos do editor.
3. Migrar RAM, validacao e workspace para a atualizacao centralizada.
4. Preservar arraste e separar layout de semantica.
5. Adicionar organizacao automatica.
6. Extrair a construcao da view sem alterar o contrato do editor.
7. Cobrir regressao e validar manualmente o fluxo completo.

## Modificacoes planejadas

- [x] Auditar os caminhos atuais de mutacao do editor.
  - Arquivos previstos:
    - `braty/src/brain_editor/brain_editor.gd`
    - `braty/src/brain_editor/editor_graph_state.gd`
    - `braty/src/brain_editor/workspace_input_controller.gd`
    - `braty/src/brain_editor/editor_workspace.gd`
  - Aceite:
    - Listar cada ponto que hoje cria, conecta, move, remove ou redefine o grafo.
    - Identificar qualquer cache visual ou calculo duplicado.
  - Resultado:
    - `BrainEditor` concentrava insercao, conexao, movimento, remocao e atualizacao visual.
    - `workspace_input_controller.gd` duplicava movimento e remocao, sem participar mais do fluxo; sua inicializacao foi removida.
    - `EditorWorkspace` permanece somente como renderer das conexoes calculadas a partir de `EditorGraphState`.

- [x] Definir eventos de `EditorGraphState`.
  - Arquivos previstos:
    - `braty/src/brain_editor/editor_graph_state.gd`
    - testes de estado do grafo.
  - Regras:
    - Cada mutacao valida emite uma notificacao com tipo e ids afetados.
    - Mutacoes recusadas nao emitem mudanca.
  - Testes:
    - Inserir, conectar, desconectar, mover, remover e resetar possuem cobertura.

- [x] Criar controlador de comandos do editor.
  - Arquivos previstos:
    - `braty/src/brain_editor/editor_command_controller.gd`
    - `braty/src/brain_editor/connection_controller.gd`
    - testes unitarios novos.
  - Regras:
    - A interface pede comandos; somente o controlador altera o estado.
    - Erros retornam resultado estruturado para o presenter.
  - Aceite:
    - O controlador funciona sem cena Godot.
    - Conectar e remover preservam as regras atuais de portas.

- [x] Centralizar atualizacao de paineis e renderizacao.
  - Arquivos previstos:
    - `braty/src/brain_editor/brain_editor.gd`
    - `braty/src/brain_editor/editor_workspace.gd`
    - `braty/src/brain_editor/ram_panel.gd`
    - `braty/src/brain_editor/validation_panel.gd`
  - Regras:
    - Uma mudanca confirmada atualiza RAM, validacao, selecao e conexoes pelo mesmo fluxo.
    - O workspace desenha apenas o estado atual.
  - Testes:
    - Remover pelo botao `x` atualiza painel interno e cabecalho no mesmo ciclo.

- [x] Preservar arraste como layout visual.
  - Arquivos previstos:
    - `braty/src/brain_editor/block_node.gd`
    - `braty/src/brain_editor/editor_workspace.gd`
    - testes de cena do editor.
  - Regras:
    - Arrastar altera apenas `position` do bloco.
    - Conexoes e RAM nao mudam durante arraste.
  - Aceite:
    - Uma seta acompanha o bloco movido e nao desaparece.

- [x] Adicionar comando `Organizar`.
  - Arquivos previstos:
    - `braty/src/brain_editor/editor_layout_controller.gd`
    - `braty/src/brain_editor/brain_editor.gd`
    - testes unitarios e de cena.
  - Regras:
    - Posicionar inicio, fluxo linear, ramos de `IF` e corpo de `WHILE` de forma deterministica.
    - Nao alterar blocos, conexoes, RAM ou validacao.
  - Verificacao manual:
    - Organizar exemplos de `IF` e `WHILE` apos reposicionar blocos livremente.

- [x] Migrar exemplos e fluxo tutorial.
  - Arquivos previstos:
    - `braty/src/tutorial/tutorial_reference_program.gd`
    - `braty/src/tutorial/tutorial_mission.gd`
    - `braty/src/brain_editor/program_graph_importer.gd`
    - testes de editor e tutorial afetados.
  - Aceite:
    - Exemplos continuam validos, dentro de 5 RAM e executaveis.
  - Resultado:
    - O programa de referencia passou a ser a unica fonte dos exemplos; o importador converte dominio para `EditorGraphState` sem remontar blocos e conexoes em `BrainEditor`.
    - O exemplo `IF + WHILE` usa 5 RAM e o exemplo `WHILE` usa 4 RAM, com estruturas realmente diferentes e execucao preservada na missao.

- [x] Extrair a composicao visual de `BrainEditor`.
  - Arquivos previstos:
    - `braty/src/brain_editor/brain_editor.gd`
    - `braty/src/brain_editor/brain_editor_view.gd`
    - `braty/tests/unit/brain_editor/test_brain_editor_scene.gd`
  - Regras:
    - `BrainEditor` continua responsavel por coordenar estado, comandos, runtime e integracao com a missao.
    - O novo componente cria e expoe a hierarquia visual, sem mutar `EditorGraphState`.
    - Nomes de nos, sinais e referencias publicas usadas pelos testes e pela missao permanecem compativeis.
  - Testes:
    - A cena continua expondo todas as regioes e controles esperados.
    - Criacao, conexao, remocao, organizacao, zoom e pseudocodigo continuam passando.
  - Resultado:
    - `BrainEditorView` passou a construir e expor a hierarquia visual; `BrainEditor` preserva sua API publica e conecta a view ao estado, aos comandos e ao runtime.
    - `BrainEditor` deixou de construir diretamente toolbar, workspace, paineis e inspetor.

- [ ] Validar PRD 010.
  - Testes automatizados:
    - [x] Executar suite GUT completa: 35 scripts, 188 testes e 752 assercoes em 2026-09-04.
    - Cobrir comandos, eventos, RAM, conexoes, arraste e organizacao.
  - Verificacao manual:
    - Criar cinco blocos, conectar, mover todos e executar.
    - Apagar comando e laco por `x` e conferir RAM, linhas e validacao.
    - Reorganizar um fluxo com `IF` e `WHILE` e confirmar que o resultado nao mudou.

## Criterio para declarar a PRD 010 concluida

- O estado e a unica fonte de verdade do editor.
- Arrastar preserva a experiencia visual sem afetar a semantica.
- Inserir, conectar, remover e organizar mantem RAM, validacao e setas coerentes.
- Suite automatizada passa e roteiro manual aprova o fluxo.
