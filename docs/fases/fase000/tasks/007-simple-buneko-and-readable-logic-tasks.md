# Tarefas: PRD 007 - Buneko Simples e Logica Visual Legivel

Status geral: implementado para validacao automatizada. `PATH_CLEAR_AHEAD`, exemplos de `IF`/`WHILE`, seletor do editor e Buneko 2D simples estao integrados; falta validacao manual de layout, leitura do personagem e revisao qualitativa do brain antes de fechar a PRD.

## Ordem de implementacao

1. Estender o contrato de condicoes com `Caminho livre a frente`.
2. Implementar e calibrar a leitura do novo sensor.
3. Validar `IF` e `WHILE` com exemplos de referencia separados.
4. Atualizar editor, mensagens e carregamento de exemplos.
5. Criar e integrar o Buneko 2D simplificado.
6. Executar testes automatizados e validacao manual de repetibilidade.

## Plano de entrega

### Marco A: Logica e sensores

- Catalogo aceita a nova consulta visual.
- Sensor responde com base no proximo trecho seguro.
- Leitor do Buneko traduz a consulta sem conhecer o editor.
- Testes distinguem caminho livre, buraco e obstaculo.

### Marco B: IF e WHILE compreensiveis

- Dois programas de referencia validos ficam dentro do limite de 5 RAM.
- Editor carrega um exemplo de `IF` ou de `WHILE`.
- Blocos mostram pergunta ou frase de repeticao em linguagem natural.
- Feedback identifica condicao ausente e ramo executado.

### Marco C: Buneko simples e validacao

- Novo asset modular substitui o atual na montagem e na fase.
- Silhueta, encaixes e expressao permanecem legiveis.
- Os dois programas concluem a fase repetidamente.
- Suite completa e roteiro manual passam antes de fechar a PRD.

## Modificacoes planejadas

- [x] Adicionar `PATH_CLEAR_AHEAD` ao catalogo de condicoes.
  - Arquivos previstos:
    - `braty/src/programming/domain/condition_catalog.gd`
    - `braty/src/brain_editor/condition_selector.gd`
    - `docs/fases/fase000/prds/001-programming-language.md`
  - Regras:
    - A consulta pertence a modalidade `VISION`.
    - `IF` e `WHILE` aceitam a mesma instancia de `ProgramCondition`.
    - Condicao continua sendo parametro sem custo extra de RAM.
    - Identificadores tecnicos permanecem em ingles e labels visuais em portugues.
  - Aceite:
    - `ConditionCatalog.is_valid_combination(VISION, PATH_CLEAR_AHEAD)` retorna verdadeiro.
    - Combinacao com `HEARING` e recusada.
    - Seletor mostra `Visao: caminho livre a frente`.
  - Testes:
    - Atualizar testes do catalogo, `ProgramCondition` e seletor.
  - Status: implementado e coberto por testes de catalogo, condicao e seletor.

- [x] Implementar a leitura de caminho livre no mundo tutorial.
  - Arquivos previstos:
    - `braty/src/tutorial/tutorial_world_sensor.gd`
    - `braty/src/tutorial/tutorial_level.gd`
    - `braty/src/buneko/runtime/buneko_sensor_reader.gd`
  - Regras:
    - `is_path_clear_ahead()` observa uma distancia curta configuravel.
    - Piso ausente dentro dessa distancia retorna falso.
    - Obstaculo bloqueando a direcao retorna falso.
    - Virar o Buneko inverte corretamente a direcao da consulta.
    - A consulta de buraco de longo alcance continua independente.
  - Aceite:
    - Antes do trecho de decisao, caminho esta livre.
    - Perto da borda, caminho deixa de estar livre.
    - Depois de pousar na plataforma final, caminho volta a estar livre.
    - Obstaculo simulado torna o caminho bloqueado.
  - Testes:
    - Atualizar `test_tutorial_world_sensor.gd`.
    - Atualizar `test_buneko_sensor_reader.gd`.
  - Status: implementado com distancia curta configuravel, obstaculo simulado e direcao invertida.

- [x] Formalizar e testar o comportamento de `IF` no tutorial.
  - Arquivos previstos:
    - `braty/src/tutorial/tutorial_reference_program.gd`
    - `braty/tests/unit/tutorial/test_tutorial_reference_program.gd`
  - Programa:
    - Inicio em `IF` com `Visao: buraco a frente`.
    - `Sim` conecta a `Pular`.
    - `Nao` conecta a `Andar`.
  - Aceite:
    - Programa e valido e usa 3/5 RAM.
    - Sensor falso despacha `Andar`.
    - Sensor verdadeiro despacha `Pular`.
    - O ciclo seguinte reavalia o `IF`.
  - Testes:
    - Ambos os ramos em runtime controlado.
    - Transicao de falso para verdadeiro entre atualizacoes.
  - Status: implementado em `TutorialReferenceProgram.build_if_example()` e validado em runtime controlado.

- [x] Formalizar e testar o comportamento de `WHILE` no tutorial.
  - Arquivos previstos:
    - `braty/src/tutorial/tutorial_reference_program.gd`
    - `braty/tests/unit/tutorial/test_tutorial_reference_program.gd`
  - Programa:
    - Inicio em `WHILE` com `Visao: caminho livre a frente`.
    - `Repetir` conecta a `Andar`.
    - `Depois` conecta a um `IF` com `Visao: buraco a frente`.
    - Ramo positivo do `IF` conecta a `Pular`.
  - Aceite:
    - Programa e valido e usa 5/5 RAM.
    - Caminho livre repete `Andar`, cedendo a simulacao entre iteracoes.
    - Caminho bloqueado sai por `Depois` e avalia a alternativa com `IF`.
    - Buraco detectado no `IF` despacha `Pular`.
    - Corpo vazio continua protegido pelo limite de execucao.
  - Testes:
    - Repeticoes com sensor verdadeiro.
    - Transicao de verdadeiro para falso.
    - Saida e reinicio do ciclo continuo.
  - Status: implementado em `TutorialReferenceProgram.build_while_example()` e validado em runtime controlado.

- [x] Atualizar a apresentacao de `IF`, `WHILE` e condicoes.
  - Arquivos previstos:
    - `braty/src/brain_editor/block_node.gd`
    - `braty/src/brain_editor/block_parameter_panel.gd`
    - `braty/src/brain_editor/brain_editor.gd`
    - `braty/src/brain_editor/validation_feedback_mapper.gd`
  - Regras:
    - `IF` resume a selecao como `Se [condicao]`.
    - `WHILE` resume a selecao como `Enquanto [condicao]`.
    - Labels internos continuam mapeados a `true`, `false`, `body` e `next`; `IF` apresenta `true` como ramo positivo e `false` como ramo negativo.
    - Erro de condicao identifica o bloco afetado.
    - Ramo vazio recebe aviso sem mudar a validade definida na PRD 001.
    - Ultimo ramo executado pode ser apresentado apos falha.
  - Aceite:
    - Condicao completa pode ser lida ou consultada por tooltip.
    - Jogador distingue decisao de repeticao sem explicacao verbal.
  - Testes:
    - Resumos por tipo de bloco.
    - Mensagens de condicao ausente e ramo vazio.
  - Status: resumos de bloco, ramos positivo/negativo de `IF` e exemplos foram cobertos por testes; aviso especifico de ramo vazio permanece como polimento futuro sem mudar validade da PRD 001.

- [x] Permitir escolher o programa de exemplo no editor.
  - Arquivos previstos:
    - `braty/src/brain_editor/brain_editor.gd`
    - possivel `braty/src/brain_editor/tutorial_example_loader.gd`
  - Regras:
    - Oferecer `Exemplo com IF` e `Exemplo com WHILE`.
    - Carregar exemplo substitui explicitamente o grafo atual.
    - Zerar cerebro remove blocos e conexoes do grafo atual.
    - Os exemplos sao convertidos para `EditorGraphState` sem duplicar a semantica da linguagem.
    - Posicoes iniciais evitam sobreposicao e deixam os ramos visiveis.
  - Aceite:
    - Exemplo com `IF` cria tres blocos, duas conexoes e mostra `3/5 RAM`.
    - Exemplo com `WHILE` cria cinco blocos, quatro conexoes e mostra `5/5 RAM`.
    - Botao `Zerar cerebro` limpa o grafo e volta para `0/5 RAM`.
    - `Executar tentativa` fica habilitado imediatamente.
  - Testes:
    - Estrutura, condicao, portas, RAM e validade de ambos os exemplos.
  - Status: editor carrega `Exemplo com IF` e `Exemplo com WHILE`; botao `Zerar cerebro` limpa blocos, conexoes e RAM.

- [x] Criar o novo Buneko 2D simplificado.
  - Arquivos previstos:
    - `braty/src/buneko/visual/buneko_simple_parts.gd`
  - Direcao:
    - Robo-gato frontal, formas geometricas, contorno consistente e leitura em tamanho pequeno.
    - Cabeca, corpo e locomocao separados e alinhados verticalmente.
    - Ate quatro cores dominantes e sombra plana discreta.
    - Sem metal realista, parafusos ornamentais ou excesso de articulacoes.
    - Fundo removivel ou transparencia validada antes da integracao.
  - Aceite:
    - Cada peca funciona isoladamente e o conjunto forma uma silhueta coerente.
    - Expressao permanece legivel na fase.
  - Verificacao manual:
    - Aprovar primeiro uma composicao completa antes de substituir o asset atual.
    - Qualquer geracao, abertura de janela ou captura de tela deve respeitar a autorizacao de interacao com o desktop.
  - Status: implementado como desenho vetorial simples compartilhado; aprovacao visual manual ainda pendente.

- [x] Integrar o Buneko simples na montagem e na fase.
  - Arquivos previstos:
    - `braty/src/buneko/assembly/buneko_assembly_preview.gd`
    - `braty/src/buneko/visual/buneko_visual.gd`
    - cenas Buneko afetadas, se necessario.
  - Regras:
    - Montagem e fase usam o mesmo conjunto visual.
    - Regioes das pecas e pontos de encaixe ficam definidos em um unico lugar quando pratico.
    - Colisao, escala fisica e regras de montagem nao mudam por causa do asset.
    - Espelhamento horizontal altera somente o personagem.
  - Aceite:
    - Preview vazio, parcial e completo continua funcional.
    - Buneko da fase corresponde ao personagem confirmado na bancada.
  - Testes:
    - Cenas carregam e partes esperadas existem.
    - Regras de montagem e fisica continuam passando.
  - Status: `BunekoAssemblyPreview` e `BunekoVisual` usam o mesmo helper visual; colisao e fisica nao foram alteradas.

- [x] Calibrar os dois exemplos na fase tutorial.
  - Arquivos previstos:
    - `braty/src/tutorial/tutorial_world_sensor.gd`
    - `braty/scenes/tutorial/tutorial_level.tscn`
    - ajustes de atributos somente se justificados por repetibilidade.
  - Regras:
    - Preferir ajustar distancia de decisao do sensor antes de alterar a linguagem.
    - Fisica nao pode depender de precisao de um unico quadro.
    - `IF` e `WHILE` devem produzir resultados equivalentes no desafio inicial.
  - Aceite:
    - Cada exemplo conclui dez tentativas consecutivas.
    - Falha ocorre por programa alterado, nao por variacao fisica inesperada.
  - Verificacao manual:
    - Dez execucoes com `IF`.
    - Dez execucoes com `WHILE`.
  - Status: validado automaticamente por teste de fluxo com dez tentativas consecutivas para cada exemplo; verificacao manual visual ainda fica no item final da PRD.

- [ ] Validar a PRD 007 e atualizar o MVP.
  - Testes automatizados:
    - Executar toda a suite GUT.
    - Cobrir catalogo, sensor, leitor, runtime, exemplos e cenas alteradas.
  - Verificacao manual:
    - Montar o Buneko simples.
    - Carregar, compreender e executar cada exemplo.
    - Montar manualmente uma solucao com `IF` e uma com `WHILE`, sem depender dos exemplos carregaveis.
    - Confirmar leitura do personagem na montagem e na fase.
    - Confirmar que textos, blocos e conexoes nao se sobrepoem em 1440x810 e 960x540.
    - Confirmar que a diferenca entre `Se [condicao]` e `Enquanto [condicao]` fica clara durante edicao e tentativa.
  - Documentacao:
    - Atualizar PRD 001 com a condicao final.
    - Atualizar tarefas 005, 006 e checklist 000 conforme resultados reais.
    - Registrar achados da revisao do brain como ajustes de comportamento ou polimento pendente.

## Criterio para declarar a PRD 007 concluida

- [x] `PATH_CLEAR_AHEAD` existe e possui testes.
- [x] `IF` e `WHILE` apresentam semantica clara no editor.
- [x] Exemplos separados de `IF` e `WHILE` sao validos e ficam dentro de 5 RAM.
- [x] Ambos concluem a fase dez vezes consecutivas.
- [x] Buneko simples substitui o asset atual na montagem e na fase.
- [x] Suite GUT completa passa.
- [ ] Verificacao manual de layout e fluxo foi executada.
