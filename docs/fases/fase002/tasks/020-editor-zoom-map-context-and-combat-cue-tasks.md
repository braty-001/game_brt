# Tarefas: PRD 020 - Enquadramento do cerebro, contexto do mapa e sinal de perigo

Status geral: implementacao e testes automatizados concluidos em 2026-10-20; aceite perceptivo manual pendente.

Fonte de verdade: [PRD 020](../prds/020-editor-zoom-map-context-and-combat-cue.md). Complementa PRDs 004, 015, 016 e 018; nao substitui seus aceites manuais pendentes. PRD 017 permanece separada.

## Ordem de execucao

### 020-01 - Fechar criterios e autorizar comportamento

- [x] Definir gatilhos do ajuste automatico e prioridade do zoom/pan manual: abrir/mudar grafo; depois de ajuste manual, apenas botao de enquadrar retoma o automatico.
- [x] Definir elementos do mapa basico: contorno discreto de pisos, paredes e degraus; saida, inimigos e objetos dinamicos apenas quando visiveis.
- [x] Definir gatilho e encerramento do sinal: entrada de inimigo vivo no campo visual do Buneko, inclusive em fuga; terminar ao perder todos de vista; inimigo oculto nao dispara.
- [x] Aprovar margem de 32 px e minimo de 60%, efeito a 40% por 0,5 s com retorno suave/cancelamento e inimigo terreo em x=520.
- [x] Registrar a interacao entre desaceleracao e pausas na ADR 015, preservando a visao da ADR 012.
- [x] Apresentar arquivos afetados, ordem, testes e riscos; obter aprovacao explicita para alterar comportamento e autorizacao grafica nova antes da janela/capturas.

Conclusao: criterios observaveis e escopo aprovados. Dependencia: nenhuma. Risco: implementar gatilho ou informacao visual que o usuario nao escolheu.

Plano tecnico aprovado na 020-01:

| Ordem | Area e arquivos provaveis | Validacao especifica | Risco principal |
| --- | --- | --- | --- |
| 1 | `braty/src/brain_editor/editor_viewport_controller.gd`, `editor_workspace.gd`, `brain_editor.gd`; testes em `braty/tests/unit/brain_editor/` | Enquadramento, limites 60%-160%, grafo pequeno/grande, reabertura e prioridade do zoom manual | Deslocar o foco durante a edicao ou diminuir demais a leitura |
| 2 | `braty/src/campaign/laboratory/laboratory_level.gd`, `laboratory_fog.gd` e, se necessario, `braty/scenes/campaign/laboratory_level.tscn`; testes em `braty/tests/unit/campaign/test_laboratory_vision.gd` | Contorno derivado dos solidos, ocultacao de entidades, oclusao e cone/sensores inalterados | Revelar informacao oculta ou divergir da colisao |
| 3 | Contrato de transicao derivado da visao do Buneko em `braty/src/campaign/laboratory/laboratory_level.gd` e apresentacao coordenada em `laboratory_mission.gd` ou componente pequeno; testes em `braty/tests/unit/campaign/test_laboratory_combat.gd` | Entrada/saida, fuga sem ataque, inimigo oculto, repeticao e cancelamento em transicoes | Conflitar com pausa de impacto ou alterar tempo da simulacao |
| 4 | `braty/scenes/campaign/laboratory_level.tscn` e testes da rota em `braty/tests/unit/campaign/` | Afastar inimigo terreo, preservar encontro frontal, checkpoint e rota em 10 RAM | Deslocamento inviabilizar encontro ou fuga |
| 5 | Documentos desta entrega e, se houver decisao transversal, `docs/decisions/`; suite GUT e carregamento headless | Rota de 10 RAM, `git diff --check` e roteiro visual nas tres resolucoes com autorizacao nova | Confundir regressao automatizada com aceite perceptivo |

O plano foi apresentado com arquivos, ordem, testes e riscos antes da primeira mudanca de comportamento; o usuario aprovou a execucao e a rodada grafica.

### 020-02 - Enquadrar grafos maiores no editor

- [x] Medir a area ocupada pelos blocos, incluindo ramos e blocos afastados; manter a regra independente de RAM e sem alterar o grafo.
- [x] Integrar o calculo ao `editor_viewport_controller.gd`, `editor_workspace.gd` e ao fluxo de atualizacao do editor conforme os gatilhos aprovados.
- [x] Preservar zoom/pan manual e localizar o inicio; tratar grafos que excedem o zoom minimo sem esconder controles.
- [x] Testar grafo pequeno/grande, remocao, limite minimo e ajuste manual; reabertura e posicoes salvas cobertas pela suite existente.

Conclusao: CA-01/02 automatizados onde verificaveis. Dependencia: 020-01. Risco: reajuste inesperado durante a edicao.

### 020-03 - Desenhar estrutura fixa fora da visao

- [x] Reutilizar a geometria fixa de `laboratory_level.tscn`/`laboratory_level.gd` como fonte do contorno, sem copiar coordenadas em uma segunda planta divergente.
- [x] Integrar o desenho discreto em `laboratory_fog.gd`, respeitando o cone atual.
- [x] Garantir que inimigos, corpos, bastao, efeitos e outros objetos dinamicos permaneçam ocultos quando fora da visao.
- [x] Verificar frente/costas, virada, oclusao e sensores pela suite de visao existente; inspecionar as capturas nas tres resolucoes.

Conclusao: CA-03/04 automatizados onde verificaveis. Dependencia: 020-01. Risco: vazamento visual ou diferenca entre contorno e colisao.

### 020-04 - Sinalizar a entrada em perigo

- [x] Consumir a transicao da visao atual do Buneko, sem criar regra de combate no visual nem alterar a IA.
- [x] Mostrar o sinal apenas quando um inimigo vivo estiver visivel; fuga sem ataque, perda e nova deteccao seguem a mesma regra.
- [x] Impedir repeticao por quadro e cancelar o efeito em pausa, edicao, derrota, checkpoint, conclusao e troca de cena.
- [x] Testar visivel/oculto, nova entrada, cancelamento e restauracao da escala; regressao da fuga sem abate e checkpoint na suite existente.
- [x] Afastar o primeiro inimigo no terreo para x=520, preservando patrulha e a rota de 10 RAM.

Conclusao: CA-05 automatizado onde verificavel. Dependencia: 020-01. Risco: revelar ameaca oculta ou conflitar com feedback da PRD 018.

### 020-05 - Integrar e validar

- [x] Rodar testes focados, suite GUT completa e carregamento headless com dados temporarios isolados: 46 scripts, 292 testes, 2116 assercoes, codigo 0 em 2026-10-20.
- [x] Repetir a rota integrada de combate/fuga em exatamente 10 RAM e verificar tutorial, sensores, RAM, programas invalidos e guardas de execucao pela suite completa.
- [x] Executar `git diff --check` e atualizar estado/evidencias da PRD e desta lista sem chamar teste automatizado de aceite visual.
- [x] Com autorizacao grafica nova, inspecionar capturas em 960x540, 1440x810 e 1600x900: editor pequeno/grande, mapa dentro/fora do cone e inimigo oculto/visivel. O fator/duracao do sinal foram verificados por testes; a sensacao durante luta e fuga permanece no aceite manual.
- [ ] Registrar percepcao do usuario, ajustes necessarios e aceite manual de CA-06; manter pendencias das PRDs 015/018/019 separadas quando seus roteiros completos nao forem executados.

Conclusao: CA-01 a CA-05 e CA-07 cobertos por testes e inspecao grafica dirigida onde aplicavel; CA-06 depende da avaliacao jogavel do usuario. Dependencias: 020-02 a 020-04. Risco: confundir carregamento headless ou capturas estaticas com aceite perceptivo.
