# Tarefas: PRD 006 - Experiencia Visual de Montagem e Programacao

Status geral: implementado para validacao manual. Tema, montagem visual, editor reorganizado e tentativa real estao integrados; falta executar o roteiro manual completo de falha/conclusao e revisar qualitativamente o comportamento do brain editor.

## Ordem de implementacao

1. Registrar a hierarquia visual e criar o tema reutilizavel.
2. Criar a representacao visual montavel do Buneko.
3. Refazer a bancada de montagem com bandeja, encaixes e inspecao.
4. Reorganizar a estrutura do editor de cerebro.
5. Refinar blocos, portas, conexoes e manipulacao do grafo.
6. Integrar orientacao, navegacao entre etapas e tentativa real.
7. Validar responsividade, acessibilidade basica e regressao.

## Plano de entrega e checkpoints

### Marco A: Montagem visual jogavel

Inclui as subfases 6.1, 6.2 e 6.3. Ao final deste marco, o projeto sera aberto para validar a bancada antes de alterar o editor.

- O tema compartilhado e o cabecalho de etapa estao aplicados.
- O Buneko aparece no centro e muda conforme cada peca e instalada ou removida.
- A bandeja, os encaixes, a inspecao, o progresso e a confirmacao funcionam por clique.
- O arraste pode ser incluido depois do clique, mas deve chamar exatamente a mesma regra de montagem.
- Testes de montagem e carregamento de cena passam.
- Checkpoint manual: montar, desmontar e confirmar em 1152x648 e 960x540.

### Marco B: Editor de cerebro compreensivel

Inclui as subfases 6.4 e 6.5. Comeca somente depois da aprovacao visual da bancada para reutilizar o tema e os componentes estabilizados.

- Objetivo, RAM, validacao e etapa ocupam um cabecalho compacto sem sobreposicao.
- Paleta, workspace e inspetor possuem funcoes e regioes visualmente distintas.
- O no `Inicio`, os blocos, as portas e o sentido das conexoes ficam evidentes.
- O jogador cria, move, configura, conecta, desconecta e remove blocos.
- Os controles do runtime aparecem conforme o estado atual.
- Testes existentes do editor continuam passando e novos estados visuais testaveis recebem cobertura.
- Checkpoint manual: construir um fluxo linear, um `IF` e um `WHILE` nos dois tamanhos alvo.

### Marco C: Ciclo jogavel integrado

Inclui as subfases 6.6 e 6.7. Este marco conecta a interface refinada ao comportamento real da missao e encerra a PRD.

- O cabecalho acompanha `Montagem -> Programacao -> Teste -> Resultado`.
- `Executar tentativa` inicia o Buneko dentro da fase, usando sensores e runtime reais.
- Queda, parada e conclusao levam ao estado correto sem perder montagem ou programa.
- A suite GUT completa passa.
- Checkpoint manual: realizar uma falha, corrigir o programa e concluir a missao.
- Checkpoint de usabilidade: uma pessoa sem contexto consegue montar e iniciar uma tentativa sem orientacao verbal.

## Regra de avanço

Cada marco deve terminar com testes automatizados e abertura do projeto para inspecao manual. Problemas que impedem compreender ou operar o fluxo atual sao corrigidos antes do marco seguinte; ajustes puramente esteticos podem ser registrados para o fechamento da subfase 6.7.

## Modificacoes planejadas

- [x] Criar a fundacao visual compartilhada.
  - Arquivos previstos:
    - `braty/themes/buneko_theme.tres`
    - `braty/src/ui/design_tokens.gd`
    - `braty/scenes/ui/mission_step_header.tscn`
    - `braty/src/ui/mission_step_header.gd`
  - Entregas:
    - Paleta equilibrada para fundo, superficies, categorias de bloco, sucesso, alerta e erro.
    - Estilos consistentes de botoes, paineis, labels, foco e selecao.
    - Escala de espacamento e tamanhos minimos para controles.
    - Cabecalho reutilizavel com etapa, objetivo, RAM e estado quando aplicavel.
  - Aceite:
    - Montagem e editor usam o mesmo tema sem estilos locais conflitantes.
    - Estado de foco e selecao e perceptivel sem depender apenas de cor.
    - O cabecalho nao sobrepoe o conteudo em 1152x648 nem 960x540.
  - Testes:
    - Teste headless carrega o tema e a cena do cabecalho.
  - Verificacao manual:
    - Conferir contraste, foco por teclado e legibilidade nos dois tamanhos alvo.

- [x] Criar uma representacao visual composta do Buneko.
  - Arquivos previstos:
    - `braty/scenes/buneko/buneko_assembly_preview.tscn`
    - `braty/src/buneko/assembly/buneko_assembly_preview.gd`
    - `braty/assets/buneko/parts/` para placeholders de cabeca, corpo e locomocao.
  - Regras:
    - A visualizacao recebe uma `BunekoAssembly` e nao altera o dominio diretamente.
    - Cada slot possui estado vazio, compativel, selecionado, instalado e invalido.
    - Instalar ou remover uma peca atualiza apenas a camada visual correspondente.
    - Cabeca, corpo e locomocao continuam sendo entidades separadas para futuras pecas.
  - Aceite:
    - O Buneko incompleto mostra claramente os encaixes restantes.
    - O conjunto completo forma uma silhueta unica e legivel.
    - A visualizacao nao conhece botoes nem o fluxo da missao.
  - Testes:
    - Estado visual reflete montagem vazia, parcial e completa.
    - Peca removida restaura o placeholder correto.
  - Verificacao manual:
    - Conferir alinhamento das tres pecas e resposta visual de selecao/encaixe.

- [x] Refazer a bancada de montagem.
  - Arquivos previstos:
    - `braty/scenes/buneko/assembly_bench.tscn`
    - `braty/src/buneko/assembly/assembly_bench.gd`
    - `braty/scenes/buneko/assembly_part_item.tscn`
    - `braty/src/buneko/assembly/assembly_part_item.gd`
    - `braty/src/buneko/assembly/assembly_slot_view.gd`
  - Layout:
    - Bandeja de pecas a esquerda.
    - Preview montavel no centro.
    - Inspecao da peca a direita.
    - Progresso e confirmacao na regiao inferior.
  - Regras:
    - Clique instala a peca no slot compativel.
    - Arraste e uma segunda forma de executar a mesma acao de dominio.
    - Selecionar peca instalada mostra dados e permite remover.
    - Cabeca base informa `Cerebro basico - 5 RAM`.
    - Confirmacao permanece bloqueada ate tres slots validos.
  - Aceite:
    - O jogador identifica os tres encaixes sem ler uma lista de instrucoes.
    - Progresso muda de 0/3 ate 3/3 conforme a montagem.
    - Confirmar avanca uma unica vez e entrega a montagem valida.
  - Testes:
    - Clique e arraste usam o mesmo metodo de instalacao.
    - Remocao atualiza progresso e bloqueia confirmacao.
    - Confirmacao incompleta continua recusada.
  - Verificacao manual:
    - Montar em ordens diferentes, remover e reinstalar cada peca.
    - Conferir feedback para tentativa de encaixe invalido.

- [x] Reorganizar a cena principal do editor de cerebro.
  - Arquivos previstos:
    - `braty/scenes/brain_editor/brain_editor.tscn`
    - `braty/src/brain_editor/brain_editor.gd`
    - `braty/scenes/brain_editor/block_palette.tscn`
    - `braty/src/brain_editor/block_palette.gd`
    - `braty/scenes/brain_editor/runtime_toolbar.tscn`
    - `braty/src/brain_editor/runtime_toolbar.gd`
  - Layout:
    - Cabecalho de etapa no topo.
    - Paleta categorizada na lateral esquerda.
    - Workspace expansivel no centro.
    - Inspetor contextual recolhivel na lateral direita ou faixa inferior.
    - Barra contextual de execucao junto ao comando principal.
  - Regras:
    - A composicao visual estavel deve ficar na cena, mantendo regras em scripts testaveis.
    - `Executar tentativa` e o comando dominante no estado editavel valido.
    - Pausar, retomar e parar aparecem somente nos estados correspondentes.
    - Reiniciar aparece depois de parada, falha ou conclusao quando fizer sentido.
    - O inspetor nao ocupa espaco quando nenhum bloco configuravel esta selecionado.
  - Aceite:
    - Objetivo, RAM, validacao e proximo comando sao encontrados rapidamente.
    - A area de trabalho recebe a maior parte do espaco disponivel.
    - Nao existe sobreposicao de texto no topo da tela.
  - Testes:
    - Cena carrega e expoe os componentes esperados.
    - Toolbar mostra o conjunto de acoes correto por estado do runtime.
  - Verificacao manual:
    - Redimensionar entre 1152x648 e 960x540 durante edicao e execucao.

- [x] Refinar paleta, blocos e propriedades.
  - Arquivos previstos:
    - `braty/scenes/brain_editor/block_node.tscn`
    - `braty/src/brain_editor/block_node.gd`
    - `braty/src/brain_editor/block_palette_item.gd`
    - `braty/src/brain_editor/block_parameter_panel.gd`
  - Regras:
    - Paleta separa `Acoes`, `Controle` e `Sensores`.
    - Bloco mostra titulo, icone/categoria e parametro resumido.
    - `IF` nomeia saidas `Sim` e `Nao`; `WHILE` nomeia `Repetir` e `Depois`.
    - Selecao, arraste, foco e execucao possuem estados distintos.
    - Remocao pode ser acionada por botao contextual e teclado.
  - Aceite:
    - O jogador reconhece as categorias sem memorizar os nomes tecnicos.
    - Parametro atual pode ser lido no proprio bloco.
    - Texto e portas nao alteram inesperadamente o tamanho do bloco.
  - Testes:
    - Labels e portas continuam mapeados aos tipos da PRD 001.
    - Alterar parametro atualiza o resumo visual e o modelo.
  - Verificacao manual:
    - Criar e manipular todos os tipos de bloco do MVP.

- [x] Refinar conexoes e feedback do workspace.
  - Arquivos previstos:
    - `braty/src/brain_editor/connection_port.gd`
    - `braty/src/brain_editor/connection_line.gd`
    - `braty/src/brain_editor/connection_controller.gd`
    - `braty/src/brain_editor/editor_workspace.gd`
  - Regras:
    - Linhas partem de posicoes reais das portas e terminam na entrada do destino.
    - Conexoes exibem direcao e evitam atravessar texto quando o layout permitir.
    - Durante a conexao, destinos compativeis ficam destacados.
    - Recusa informa o motivo perto do cursor/porta e nao apenas no painel lateral.
    - O no `Inicio` e permanente e sua saida segue as mesmas regras visuais.
    - Fundo de grade ajuda posicionamento sem competir com os blocos.
  - Aceite:
    - O jogador completa uma conexao sem precisar selecionar o bloco inteiro como destino ambiguo.
    - Mover blocos atualiza linhas continuamente.
    - Ramos de controle sao visualmente distinguiveis.
  - Testes:
    - Regras atuais de conexao continuam passando.
    - Posicoes das linhas sao recalculadas apos movimento e redimensionamento.
  - Verificacao manual:
    - Montar fluxo linear, `IF` e `WHILE`; mover os blocos e desconectar cada ramo.
  - Ajuste posterior: o proprio workspace desenha conexoes a partir do grafo atual, no mesmo ciclo de desenho da grade; mover ou remover blocos atualiza as setas sem estado visual separado.
  - Ajuste posterior: a exclusao pelo botao `x` agenda a destruicao visual para depois do sinal do botao; o grafo e o RAM atualizam imediatamente.
  - Ajuste posterior: a criacao pela paleta reutiliza a proxima posicao disponivel conforme a quantidade atual de blocos; criar e apagar nao desloca os novos blocos indefinidamente.

- [x] Integrar as etapas da missao e a execucao real.
  - Arquivos previstos:
    - `braty/scenes/tutorial/tutorial_mission.tscn`
    - `braty/src/tutorial/tutorial_mission.gd`
    - `braty/src/tutorial/tutorial_hint_presenter.gd`
  - Regras:
    - Cabecalho indica `Montagem`, `Programacao` ou `Teste` conforme estado da missao.
    - O comando principal do editor chama `TutorialMission.start_attempt()` quando usado dentro da missao.
    - A tentativa conecta runtime, sensores, dispatcher, Buneko, objetivo e zona de queda reais.
    - O jogador pode voltar a montagem antes da tentativa sem perder o grafo.
    - Falha retorna a programacao preservando montagem e grafo.
    - Uma dica curta acompanha apenas o proximo passo relevante.
  - Aceite:
    - Nao existe um botao de execucao que rode apenas um runtime isolado sem mostrar a fase.
    - A transicao de programacao para teste apresenta o Buneko executando o programa.
    - Queda, parada e objetivo final retornam ao estado visual correto.
  - Testes:
    - Fluxo montagem -> programacao -> teste.
    - Retorno programacao -> montagem -> programacao preserva estado.
    - Falha preserva montagem e grafo.
    - Objetivo conclui e atualiza cabecalho/toolbar.
  - Verificacao manual:
    - Executar uma tentativa invalida, uma queda e uma conclusao.

- [ ] Fazer validacao visual e de usabilidade da PRD 006.
  - Aceite:
    - Todas as funcionalidades das PRDs 003, 004 e 005 continuam acessiveis.
    - Um jogador novo monta o Buneko e inicia uma tentativa sem instrucao verbal.
    - Nenhum texto, botao, bloco ou painel se sobrepoe nos tamanhos alvo.
    - Estados de foco, selecao, compatibilidade, erro e execucao sao distinguiveis.
  - Testes automatizados:
    - [x] Executar toda a suite GUT: 35 scripts, 188 testes e 752 assercoes em 2026-09-04.
    - [x] Adicionar testes de carregamento das cenas alteradas.
    - [x] Adicionar testes para estados deterministicos de toolbar, preview e progresso.
  - Verificacao manual:
    - Capturar montagem vazia, parcial e completa em 1152x648 e 960x540.
    - Capturar editor vazio, programa valido, conexao em andamento e execucao.
    - Completar o tutorial uma vez sem atalhos de teste.
    - Pedir a uma pessoa sem contexto que monte e inicie uma tentativa; registrar pontos de hesitacao.

- [ ] Revisar comportamento e sensacao de uso do brain editor.
  - Motivacao:
    - A implementacao atual cobre contratos tecnicos, mas ainda precisa ser julgada pela sensacao de criar, entender e executar um programa.
    - A revisao deve responder se o brain esta divertido, claro e previsivel, nao apenas se passa nos testes.
  - Pontos de revisao:
    - Criacao de blocos pela paleta.
    - Selecao e configuracao de condicoes.
    - Conexao de saidas e entradas, incluindo `Inicio`, `IF` e `WHILE`.
    - Feedback para conexao recusada, condicao ausente, programa invalido e RAM.
    - Diferenca entre carregar exemplo, zerar cerebro, editar manualmente e executar tentativa real.
    - Clareza visual do bloco ativo durante execucao e do ultimo ramo executado em falhas.
  - Aceite:
    - Um jogador consegue construir um fluxo linear sem hesitar sobre onde clicar.
    - Um jogador entende que `IF` decide entre `Sim`/`Nao` e `WHILE` repete por `Repetir`/`Depois`.
    - O editor mostra o problema atual perto da acao que causou o problema, quando possivel.
    - O comando `Executar tentativa` parece conectado ao Buneko no mundo, nao a uma simulacao separada invisivel.
  - Testes:
    - Atualizar ou adicionar testes somente apos decidir ajustes concretos de comportamento.
  - Verificacao manual:
    - Montar manualmente um programa `IF` sem usar exemplo.
    - Montar manualmente um programa `WHILE` sem usar exemplo.
    - Forcar pelo menos tres erros comuns e avaliar se a mensagem ajuda a corrigir.

## Dependencias e limites

- Reutilizar `BunekoAssembly`, `ProgramDefinition`, `EditorGraphState`, `ProgramRuntime` e o avaliador da missao existentes.
- Nao alterar as regras da linguagem, RAM ou fisica para resolver problemas puramente visuais.
- Nao adicionar pecas alternativas com atributos reais nesta fase.
- Assets placeholder devem ser substituiveis sem alterar scripts de dominio.
- Se arraste e clique divergirem, o clique e o caminho obrigatorio e o arraste deve ser corrigido antes de ser mantido.

## Criterio para declarar a PRD 006 concluida

- [x] A bancada mostra o Buneko sendo montado em cabeca, corpo e locomocao.
- [x] A cabeca comunica visualmente o cerebro e as 5 unidades de RAM.
- [x] O editor possui hierarquia clara, paleta categorizada e workspace legivel.
- [x] Portas e conexoes comunicam inicio, direcao e ramos.
- [x] O comando principal inicia a tentativa real da missao.
- [x] Montagem e programa sao preservados nos retornos previstos.
- [x] Layout aprovado em 1152x648 e 960x540.
- [x] Suite GUT completa passa.
- [ ] Roteiro manual de montagem, programacao, falha e conclusao foi executado.
- [ ] Revisao qualitativa do brain editor foi executada e seus ajustes necessarios foram registrados ou implementados.
