# Tarefas: PRD 011 - Linguagem Visual do Cerebro e Pseudocodigo

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../../../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

Status geral: implementacao e validacao automatizada concluidas. Depende apenas do roteiro manual compartilhado com a PRD 010.

A PRD 012 estabiliza as fronteiras internas antes da continuidade do produto, sem alterar a linguagem visual definida aqui.

## Ordem de implementacao

1. Criar viewport navegavel para o workspace.
2. Definir apresentacao extensivel dos blocos.
3. Redesenhar acoes, `IF` e `WHILE`.
4. Criar gaveta lateral e os dois modos de insercao.
5. Gerar pseudocodigo somente leitura.
6. Ajustar responsividade, testes e roteiro manual.

## Modificacoes planejadas

- [x] Reorganizar a superficie de trabalho do cerebro.
  - Arquivos previstos:
    - `braty/src/brain_editor/brain_editor.gd`
    - `braty/src/brain_editor/block_drawer.gd`
    - testes de cena do editor.
  - Regras:
    - A barra inferior mostra somente validacao e execucao.
    - Navegacao, organizacao, gaveta e pseudocodigo usam uma barra horizontal acima do canvas.
    - `Blocos`, `Organizar`, `Codigo`, `Mover` e `Centralizar` possuem rotulos explicitos; `+` significa somente aumentar o zoom.
    - A gaveta mostra os cinco blocos atuais sem rolagem e fecha depois de inserir.
    - A janela padrao usa 1600x900 e continua redimensionavel.
  - Aceite:
    - Cinco blocos continuam legiveis sem a gaveta.
    - A lista de blocos nao ultrapassa a area de trabalho em 960x540.
  - Status: trilho vertical removido; barra horizontal agrupada implementada e janela padrao ampliada para 1600x900.

- [x] Simplificar remocao e reinsercao em saidas vazias.
  - Arquivos previstos:
    - `braty/src/brain_editor/brain_editor.gd`
    - `braty/src/brain_editor/block_drawer.gd`
    - `braty/tests/unit/brain_editor/test_brain_editor_scene.gd`
  - Regras:
    - Remover um bloco nao abre a gaveta, nao preserva conexoes e nao presume substituicao.
    - `IF` e `WHILE` podem ficar parcialmente vazios durante a edicao.
    - Clicar em uma saida vazia abre a gaveta ja apontando para aquela saida.
    - Clicar em uma saida ocupada nao cria uma segunda conexao.
  - Aceite:
    - Remover `Andar` de `WHILE / Repetir` deixa o corpo vazio.
    - Clicar em `Repetir` e escolher outro comando cria a nova conexao.
    - Fechar a gaveta preserva o corpo vazio.
  - Status: implementado e coberto pelo teste de cena no tamanho padrao e em 960x540.

- [x] Criar viewport navegavel do cerebro.
  - Arquivos previstos:
    - `braty/src/brain_editor/editor_viewport_controller.gd`
    - `braty/src/brain_editor/editor_workspace.gd`
    - `braty/src/brain_editor/brain_editor.gd`
    - testes unitarios e de cena novos.
  - Regras:
    - Zoom limitado entre 60% e 160%; botoes `-`, `+`, percentual e `Centralizar`.
    - Pan e zoom alteram somente a visualizacao; `EditorGraphState.position` permanece no espaco do grafo.
    - Arrastar bloco, selecionar portas e desenhar setas usam a mesma conversao de coordenadas.
  - Aceite:
    - Um fluxo conectado continua coerente em 60%, 100% e 160%.
    - Centralizar retorna a origem sem alterar bloco, conexao, RAM ou validacao.

- [x] Consolidar canvas vetorial hibrido e interacao por coordenadas.
  - Arquivos previstos:
    - `braty/src/brain_editor/editor_workspace.gd`
    - `braty/src/brain_editor/block_node.gd`
    - testes de cena do editor.
  - Regras:
    - Grade, setas, blocos, portas, zoom, pan e arraste usam coordenadas do mesmo grafo.
    - Nenhuma tela ou sistema fora de `brain_editor` participa desta mudanca.
  - Aceite:
    - Arrastar em 60%, 100% e 160% atualiza a mesma posicao logica esperada.

- [x] Definir registro de apresentacao de blocos.
  - Arquivos previstos:
    - `braty/src/brain_editor/block_presentation_registry.gd`
    - `braty/src/brain_editor/block_factory.gd`
    - testes unitarios novos.
  - Regras:
    - Separar tipo de bloco, aparencia, portas exibidas e formatacao de pseudocodigo.
    - Nao alterar `ProgramBlockKind`, runtime ou validador por motivos visuais.
  - Aceite:
    - Nova acao futura pode ser apresentada sem duplicar a logica do editor.

- [x] Redesenhar blocos de acao.
  - Arquivos previstos:
    - `braty/src/brain_editor/block_node.gd`
    - `braty/src/ui/design_tokens.gd`
  - Regras:
    - Acoes permanecem cartoes compactos com entrada e saida legiveis.
    - Portas mantem tamanho e posicao estaveis.
  - Verificacao manual:
    - Conferir leitura com cinco blocos no workspace.

- [x] Criar bifurcacao visual para `IF`.
  - Arquivos previstos:
    - `braty/src/brain_editor/block_node.gd`
    - testes de cena do editor.
  - Regras:
    - Usar duas pontas fixas para os ramos.
    - Ramo `true`: verde e `✓`; ramo `false`: coral e `×`.
    - Tooltips explicam os ramos sem exigir rotulos visiveis longos.
  - Aceite:
    - Cor, icone e geometria distinguem os ramos.
    - Portas continuam mapeadas para `true` e `false`.

- [x] Criar representacao visual de `WHILE`.
  - Arquivos previstos:
    - `braty/src/brain_editor/block_node.gd`
    - `braty/src/brain_editor/editor_workspace.gd`
    - testes de cena do editor.
  - Regras:
    - Corpo repetido aparece abaixo; saida `Depois` permanece lateral.
    - O retorno do laco e sugestao visual, sem criar conexao de dominio adicional.
  - Aceite:
    - Jogador distingue repeticao de bifurcacao e fluxo linear.

- [x] Criar gaveta lateral recolhivel.
  - Arquivos previstos:
    - `braty/src/brain_editor/block_drawer.gd`
    - `braty/src/brain_editor/brain_editor.gd`
    - testes de cena do editor.
  - Regras:
    - Botao lateral abre e fecha a gaveta.
    - Categorias de acoes e controle continuam claras.
    - Workspace volta a ocupar a largura quando a gaveta fecha.
  - Aceite:
    - Em 960x540, a gaveta nao sobrepoe controles criticos.

- [x] Implementar insercao por clique na saida selecionada.
  - Arquivos previstos:
    - `braty/src/brain_editor/editor_command_controller.gd`
    - `braty/src/brain_editor/block_drawer.gd`
    - testes unitarios e de cena.
  - Regras:
    - Sem saida selecionada, a gaveta explica a proxima acao necessaria.
    - Com saida selecionada, inserir cria bloco, conexao e posicao inicial coerentes.
  - Aceite:
    - Inserir por clique respeita portas compativeis e RAM.

- [x] Consolidar e testar insercao por arraste.
  - Arquivos previstos:
    - `braty/src/brain_editor/block_drawer.gd`
    - `braty/src/brain_editor/editor_workspace.gd`
    - testes de cena do editor.
  - Regras:
    - Destinos compativeis destacam durante o arraste.
    - Soltar em local invalido nao modifica o programa.
    - Resultado no modelo e igual ao da insercao por clique.
    - Falha ao conectar remove atomicamente o bloco criado.
  - Testes:
    - Arrastar item da gaveta para saida vazia cria bloco e conexao.
    - Saida ocupada e dado invalido nao alteram blocos, conexoes ou RAM.
  - Status: caminho da gaveta ate a porta coberto; saida ocupada preserva grafo e estado pendente, e falha de conexao desfaz atomicamente o bloco criado.

- [x] Criar presenter de pseudocodigo.
  - Arquivos previstos:
    - `braty/src/brain_editor/pseudocode_presenter.gd`
    - `braty/src/brain_editor/pseudocode_panel.gd`
    - `braty/src/brain_editor/brain_editor.gd`
    - testes unitarios e de cena.
  - Regras:
    - Botao `Ver pseudocodigo` abre painel somente leitura.
    - Usar indentacao para `SE`, `SENAO` e `ENQUANTO`.
    - Grafo invalido mostra diagnostico curto, nao pseudocodigo inventado.
  - Aceite:
    - Alterar o grafo atualiza o texto ao reabrir o painel.
    - Fechar o painel nao altera selecao, RAM ou conexoes.

- [ ] Validar responsividade e acessibilidade.
  - Arquivos previstos:
    - `braty/src/brain_editor/brain_editor.gd`
    - scripts e cenas visuais afetados.
  - Regras:
    - Portas e icones nao dependem somente de cor.
    - Texto e controles cabem em 960x540, 1440x810 e 1600x900.
  - Verificacao manual:
    - Montar fluxo linear, `IF` e `WHILE` nos tres tamanhos alvo.
  - Resultado parcial em 2026-08-21:
    - Montagem, exemplo `IF + WHILE`, gaveta, pseudocodigo e retorno da tentativa foram inspecionados em 1440x810 e 960x540; os controles permaneceram visiveis nos dois tamanhos.
    - A gaveta sem fechamento, a mensagem antiga ao restaurar o grafo e o baixo contraste do pseudocodigo foram corrigidos; falta reabrir a versao corrigida e concluir criacao por clique, arraste e reorganizacao manual.
    - O trilho vertical ambiguo foi substituido por uma barra horizontal agrupada, o `+` ficou exclusivo para zoom e a janela padrao passou a 1600x900.
    - A largura minima da barra foi verificada automaticamente contra o espaco disponivel em 960x540; falta a aprovacao visual e interativa do usuario.

- [ ] Validar PRD 011.
  - Testes automatizados:
    - [x] Executar suite GUT completa: 35 scripts, 188 testes e 752 assercoes em 2026-09-04.
    - Cobrir registro visual, portas de `IF` e `WHILE`, gaveta, insercao e pseudocodigo.
  - Verificacao manual:
    - Criar programa por clique.
    - Criar programa por arraste.
    - Mover blocos conectados e usar `Organizar`.
    - Conferir pseudocodigo de exemplos validos e de grafo incompleto.

## Criterio para declarar a PRD 011 concluida

- Formas tornam acao, decisao e repeticao distinguiveis.
- Gaveta e workspace tornam a construcao mais confortavel sem remover o arraste.
- Pseudocodigo reflete o mesmo programa visual.
- Extensoes futuras de acao nao exigem outro editor.
- Suite automatizada passa e validacao manual aprova os tres tamanhos alvo.
