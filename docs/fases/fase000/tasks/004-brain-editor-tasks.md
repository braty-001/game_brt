# Tarefas: PRD 004 - Editor de Cerebro

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../../../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

Status geral: concluido para o MVP funcional. Polimento visual e refinamentos de UX podem ser feitos depois sem bloquear a PRD 005.

## Ordem de implementacao

1. Modelo de estado visual do editor e sincronizacao com `ProgramDefinition`.
2. Composicao da cena principal do editor.
3. Paleta e criacao de blocos.
4. Arrastar, mover, remover e selecionar blocos.
5. Portas, linhas e regras de conexao.
6. Seletores de parametros e painel de RAM/validacao.
7. Controles de execucao e integracao com `ProgramRuntime`.
8. Roteiro manual de uso completo.

## Modificacoes planejadas

- [x] Criar o estado visual do editor sem duplicar a linguagem da PRD 001.
  - Arquivos previstos:
    - `braty/src/brain_editor/editor_graph_state.gd`
    - `braty/src/brain_editor/editor_block_state.gd`
    - `braty/src/brain_editor/editor_connection_state.gd`
    - `braty/src/brain_editor/program_graph_builder.gd`
  - Regras:
    - `ProgramDefinition` continua sendo a unica fonte semantica para validacao, RAM e execucao.
    - O estado visual guarda apenas posicao, selecao, portas em edicao e ids dos nos visuais.
    - Toda alteracao visual relevante reconstrui ou atualiza o `ProgramDefinition`.
    - Blocos desconectados podem existir visualmente, mas nao contam RAM ate ficarem alcancaveis a partir do inicio.
  - Aceite:
    - O editor consegue transformar o grafo visual atual em `ProgramDefinition`.
    - O modelo gerado usa `ProgramBlock`, `ProgramConnection` e `ProgramCondition` da PRD 001.
    - Nao ha outra estrutura interpretavel pelo executor.
  - Testes:
    - `braty/tests/unit/brain_editor/test_program_graph_builder.gd`
    - Criacao de programa linear.
    - Bloco desconectado permanece fora do consumo de RAM.
    - Ramos de `IF` e `WHILE` geram portas corretas.

- [x] Definir e implementar a composicao da interface principal.
  - Arquivos previstos:
    - `braty/scenes/brain_editor/brain_editor.tscn`
    - `braty/src/brain_editor/brain_editor.gd`
    - `braty/src/brain_editor/editor_camera_or_workspace.gd`
  - Layout:
    - Paleta lateral com os blocos do MVP.
    - Area de trabalho central com ponto de inicio.
    - Painel compacto de RAM, validacao e estado do executor.
    - Barra de controles para iniciar, pausar, retomar, parar e reiniciar.
  - Regras:
    - A primeira tela deve ser a ferramenta utilizavel, sem pagina introdutoria.
    - O grafo deve priorizar leitura de fluxo e ramos.
    - O MVP nao precisa de zoom, desfazer/refazer, salvar, copiar/colar ou comentarios.
  - Aceite:
    - O fluxo de montagem do programa cabe em uma tela de referencia.
    - O ponto de inicio fica sempre visivel ou facil de localizar.
    - A interface indica claramente quando esta editando, pronta, executando, pausada, falhou ou concluiu.
  - Verificacao manual:
    - Legibilidade em resolucoes alvo definidas pelo projeto.
    - Texto sem sobreposicao em viewport desktop e janela reduzida.
  - Status: `brain_editor.tscn` e `brain_editor.gd` criados; estrutura validada por teste headless de cena.

- [x] Implementar paleta e criacao de blocos.
  - Arquivos previstos:
    - `braty/src/brain_editor/block_palette.gd`
    - `braty/src/brain_editor/block_palette_item.gd`
    - `braty/src/brain_editor/block_factory.gd`
    - `braty/scenes/brain_editor/block_node.tscn`
  - Regras:
    - A paleta oferece `Andar`, `Pular`, `Virar`, `IF` e `WHILE`; o ritmo de `Andar` fica no painel de parametros.
    - Cada item criado recebe id estavel para mapear visual e dominio.
    - Blocos de acao possuem porta de saida `next`.
    - `IF` possui saidas `true` e `false`.
    - `WHILE` possui saidas `body` e `next`.
  - Aceite:
    - O jogador cria blocos por arraste ou clique, conforme o prototipo escolhido.
    - Cada bloco criado aparece no workspace e no modelo visual.
    - A criacao nao excede RAM por si so; apenas o fluxo conectado determina o consumo.
  - Testes:
    - Factory cria cada tipo de bloco com portas esperadas.
    - Ids gerados nao colidem em uma sessao.
  - Verificacao manual:
    - Criar todos os blocos da paleta.
    - Conferir legibilidade dos labels e portas.
  - Status: `block_factory.gd`, paleta visual e `block_node.tscn` criados e testados.

- [x] Implementar movimentacao, selecao e remocao de blocos.
  - Arquivos previstos:
    - `braty/src/brain_editor/block_node.gd`
    - `braty/src/brain_editor/workspace_input_controller.gd`
  - Regras:
    - Arrastar altera apenas a posicao visual.
    - Remover um bloco remove tambem conexoes ligadas a ele.
    - Remover o bloco inicial ou desconectar o inicio torna o programa invalido com erro claro.
    - Edicao fica bloqueada enquanto o runtime estiver executando ou pausado.
  - Aceite:
    - Alteracoes visuais refletem exatamente o programa de dominio quando aplicavel.
    - O jogador consegue limpar e reconstruir o grafo sem estado residual.
  - Testes:
    - Remocao de bloco remove conexoes relacionadas.
    - Movimentacao nao altera `ProgramDefinition`.
  - Verificacao manual:
    - Mover blocos sem quebrar linhas.
    - Remover bloco intermediario e observar erro/conexoes atualizadas.
  - Status: selecao, movimentacao programatica e remocao criadas e testadas; drag-and-drop por mouse fica para refinamento visual.

- [x] Implementar portas, linhas e validacao de conexoes.
  - Arquivos previstos:
    - `braty/src/brain_editor/connection_port.gd`
    - `braty/src/brain_editor/connection_line.gd`
    - `braty/src/brain_editor/connection_controller.gd`
  - Regras:
    - Conexoes partem de uma porta de saida valida para uma entrada de bloco.
    - Portas incompativeis sao recusadas antes de persistir a conexao.
    - Cada porta de saida aceita no maximo uma conexao ativa no MVP.
    - Ciclos arbitrarios continuam proibidos; repeticao deve usar `WHILE`.
    - O retorno implicito do corpo de `WHILE` nao vira linha visual criada pelo jogador.
  - Aceite:
    - Apenas conexoes validas sao persistidas.
    - Tentativa invalida mostra feedback local e compreensivel.
    - Ramos de `IF` e `WHILE` ficam visualmente distinguiveis.
  - Testes:
    - Controller recusa porta inexistente.
    - Controller substitui ou rejeita segunda conexao na mesma saida, conforme decisao do prototipo.
    - Builder gera conexoes compativeis com `ProgramValidator`.
  - Verificacao manual:
    - Conectar e desconectar fluxo linear.
    - Conectar `IF` nos ramos verdadeiro e falso.
    - Conectar `WHILE` no corpo e na saida.
    - Tentar conexao invalida e observar retorno.
  - Status: `connection_controller.gd` criado e testado; portas clicaveis e linhas visuais simples integradas ao editor. Refinamento de UX dos ramos fica para polimento da PRD 004.

- [x] Implementar seletores de parametros e condicoes.
  - Arquivos previstos:
    - `braty/src/brain_editor/block_parameter_panel.gd`
    - `braty/src/brain_editor/condition_selector.gd`
  - Regras:
    - `IF` e `WHILE` exibem seletor de condicao.
    - Condicoes usam `ConditionCatalog` e `ProgramCondition`.
    - O MVP deve mostrar opcoes de visao e audicao previstas na PRD 001.
    - Blocos de acao do MVP nao precisam de parametros adicionais.
  - Aceite:
    - Condicoes de visao e audicao podem ser selecionadas nos blocos de controle.
    - Parametro invalido torna o programa invalido e aponta o bloco afetado.
  - Testes:
    - Seletor cria `ProgramCondition` valida para cada opcao disponivel.
    - Alterar condicao atualiza o bloco correspondente no modelo.
  - Verificacao manual:
    - Configurar condicao de buraco a frente.
    - Configurar condicao de audicao disponivel.
    - Ver erro ao deixar bloco de controle sem condicao.
  - Status: `condition_selector.gd` e `block_parameter_panel.gd` criados, integrados ao editor e testados.

- [x] Implementar painel de RAM, validacao e mensagens localizadas.
  - Arquivos previstos:
    - `braty/src/brain_editor/ram_panel.gd`
    - `braty/src/brain_editor/validation_panel.gd`
    - `braty/src/brain_editor/validation_feedback_mapper.gd`
  - Regras:
    - RAM usada vem de `ProgramRamCalculator`.
    - Validacao vem de `ProgramValidator`.
    - Erros devem apontar bloco, conexao ou regra global quando possivel.
    - Programa acima de 5 RAM bloqueia inicio.
  - Aceite:
    - Indicador mostra RAM usada de 5 sem atraso perceptivel.
    - Erro de RAM, inicio, fluxo ou condicao aponta para correcao compreensivel.
    - O estado valido/pronto fica evidente antes de executar.
  - Testes:
    - Feedback mapper traduz codigos de erro conhecidos.
    - Atualizacao de RAM acompanha conexoes alcancaveis.
  - Verificacao manual:
    - Criar programa com 5 RAM.
    - Exceder 5 RAM conectada.
    - Criar programa sem inicio ou com conexao incompleta.
  - Status: `ram_panel.gd`, `validation_panel.gd` e `validation_feedback_mapper.gd` criados, integrados ao editor e testados.

- [x] Integrar controles do editor com `ProgramRuntime`.
  - Arquivos previstos:
    - `braty/src/brain_editor/runtime_controls.gd`
    - `braty/src/brain_editor/runtime_state_presenter.gd`
  - Regras:
    - Iniciar chama `prepare(program)` e depois `start()` somente se a validacao passar.
    - Pausar, retomar, parar e reiniciar seguem as transicoes do runtime.
    - Durante execucao, o editor mostra o bloco ou ramo atual quando possivel.
    - Ao falhar, o jogador volta a editar preservando programa e montagem.
    - Ao parar, o jogador volta a editar com o grafo atual preservado.
  - Aceite:
    - Iniciar so e possivel com programa valido.
    - Pausa, parada, falha e reinicio exibem o estado correto.
    - O editor nao altera programa enquanto a tentativa esta em execucao.
  - Testes:
    - Presenter mapeia estados do runtime para controles habilitados/desabilitados.
    - Inicio invalido preserva edicao e exibe erros.
    - Falha externa retorna ao estado editavel sem descartar grafo.
  - Verificacao manual:
    - Ciclo completo de editar, executar, pausar, retomar e parar.
    - Ciclo completo de executar, falhar e editar novamente.
    - Reiniciar tentativa sem perder programa.
  - Status: `runtime_controls.gd` e `runtime_state_presenter.gd` criados, botoes visuais integrados ao runtime e testados.

- [x] Revisar a PRD 001 apos o prototipo do editor estabilizar a representacao visual.
  - Arquivos afetados:
    - `docs/fases/fase000/tasks/001-programming-language-tasks.md`
    - opcionalmente `docs/fases/fase000/prds/001-programming-language.md`, se houver ajuste real de contrato.
  - Regras:
    - Atualizar somente divergencias reais encontradas na integracao.
    - Nao mudar a semantica da linguagem para acomodar detalhe visual sem necessidade.
  - Aceite:
    - A tarefa pendente da PRD 001 sobre representacao final do grafo pode ser concluida ou recebe pendencia explicita.
  - Status: revisao concluida; o editor manteve a semantica definida pela PRD 001.

## Dependencias e limites

- Esta PRD usa diretamente `ProgramDefinition`, `ProgramBlock`, `ProgramConnection`, `ProgramCondition`, `ProgramValidator`, `ProgramRamCalculator` e `ProgramRuntime`.
- O editor nao deve conhecer tipos concretos de peca da PRD 003; recebe apenas montagem/atributos ja preparados pelo fluxo anterior.
- A integracao fisica completa depende do `BunekoActionDispatcher` da PRD 003.
- A fase tutorial, geometria do nivel e orientacao contextual final pertencem a PRD 005.
- Nao implementar persistencia entre sessoes, undo/redo, zoom, comentarios, copiar/colar, editor de fases ou edicao durante execucao nesta PRD.

## Criterio para declarar a PRD 004 concluida

- [x] Todos os testes unitarios novos passam junto com a suite existente.
- [x] O jogador consegue montar visualmente um programa valido de ate 5 RAM.
- [x] A UI impede ou explica conexoes incompativeis.
- [x] RAM, validacao e estado do runtime ficam visiveis e atualizados.
- [x] O editor usa o modelo da PRD 001 como fonte unica para validacao e execucao.
- [x] O roteiro de criar, conectar, validar, executar, pausar, falhar e voltar a editar esta coberto pela implementacao funcional; ajustes visuais ficam como polimento futuro.
