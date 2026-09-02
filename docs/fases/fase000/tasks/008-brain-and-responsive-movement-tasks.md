# Tarefas: PRD 008 - Brain e Movimento Responsivo

Status geral: o experimento B foi consolidado como contrato final. `Correr` foi substituido por `Andar` com ritmo `normal` ou `rapido`; a fisica conserva inercia com desaceleracao no chao e momentum no ar. Programas que terminam antes do objetivo encerram a tentativa com feedback. A migracao automatizada esta concluida; falta validar manualmente a sensacao.

## Ordem de implementacao

1. Mapear o comportamento atual de `Andar`, `Pular` e `Virar`. Concluido.
2. Corrigir a acao que reporta sucesso mesmo quando nao alterou o Buneko. Concluido para `Pular`.
3. Prototipar movimento por pulso. Implementado como passo curto com momentum aereo.
4. Prototipar movimento por intencao continua por ciclo. Concluido para comparacao automatizada.
5. Comparar os experimentos na fase tutorial. Concluido pelo usuario.
6. Escolher o contrato final do MVP e atualizar documentacao da linguagem. Escolhido: intencao continua com inercia e ritmo em `Andar`.
7. Adicionar feedback minimo para acao recusada.
8. Adicionar feedback visual de transicao de acao. Movido para a PRD 009.
9. Rodar testes automatizados e validacao manual.

## Plano de entrega

### Marco A: Diagnostico e bug de resposta

- Runtime, dispatcher, motor e fisica ficam auditados.
- `Pular` deixa de reportar sucesso quando o Buneko nao consegue pular.
- Testes cobrem sucesso e falha de acao.

### Marco B: Experimentos de movimento

- Experimento A implementa `Andar` como passo curto.
- Experimento B implementa intencao continua por ciclo.
- Os dois modelos sao testados no tutorial com `IF` e `WHILE`.
- A escolha final e registrada antes de consolidar codigo.

### Marco C: Fechamento do contrato

- Contrato final de `Andar`, `Pular` e `Virar` fica documentado.
- Feedback minimo de acao recusada fica integrado.
- Programas de referencia continuam concluindo a fase.
- Roteiro manual valida sensacao de resposta.

### Marco D: Feedback visual

- A PRD 009 removeu Acompanhar e `NEXT`.
- Pulsos luminosos passaram a indicar mudancas de acao e recusas sem interferir na fisica.

## Modificacoes planejadas

- [x] Diagnosticar a cadeia brain -> runtime -> dispatcher -> Buneko.
  - Arquivos previstos:
    - `braty/src/programming/runtime/program_runtime.gd`
    - `braty/src/buneko/runtime/buneko_action_dispatcher.gd`
    - `braty/src/buneko/physics/buneko_character.gd`
    - `braty/src/buneko/physics/buneko_physics_controller.gd`
    - `braty/src/tutorial/tutorial_mission.gd`
  - Aceite:
    - Documentar onde cada bloco vira comando fisico.
    - Identificar quais comandos sao instantaneos, persistentes ou dependentes do chao.
    - Registrar os pontos que afetam sensacao de resposta.
  - Testes:
    - Nenhum teste novo obrigatorio nesta etapa.
  - Status: concluido durante a implementacao; o brain chama o runtime, o runtime despacha acoes, o dispatcher chama metodos do Buneko e a fisica aplica velocidade/impulso.

- [x] Corrigir retorno de sucesso/falha das acoes fisicas.
  - Arquivos previstos:
    - `braty/src/buneko/runtime/buneko_action_dispatcher.gd`
    - `braty/src/buneko/physics/buneko_character.gd`
    - `braty/src/buneko/physics/buneko_physics_controller.gd`
    - `braty/tests/unit/buneko/runtime/test_buneko_action_dispatcher.gd`
    - `braty/tests/unit/programming/runtime/test_program_runtime.gd`
  - Regras:
    - `Pular` retorna progresso somente quando o pulo foi aplicado.
    - Acoes que nao mudam o estado do Buneko nao devem parecer sucesso silencioso.
    - O runtime deve preservar protecao contra loops sem progresso.
  - Aceite:
    - Pulo no chao produz progresso.
    - Pulo fora do chao nao produz progresso e gera diagnostico possivel.
    - A suite existente continua passando.
  - Status: `BunekoActionDispatcher` agora respeita o retorno de `jump()`; `ProgramRuntime` registra `last_refused_action_block_id` e `last_refused_action_kind`.

- [x] Prototipar `Andar` como passo curto.
  - Arquivos previstos:
    - `braty/src/buneko/physics/buneko_physics_controller.gd`
    - `braty/src/buneko/physics/buneko_character.gd`
    - testes de fisica afetados
  - Regras:
    - Um `Andar` unico move o Buneko por uma distancia curta e previsivel.
    - Repetir `Andar` por `WHILE` produz caminhada continua.
    - O passo nao depende de precisao de um unico frame.
  - Aceite:
    - O deslocamento de um passo e visivel.
    - O tutorial continua calibravel com `IF` e `WHILE`.
  - Verificacao manual:
    - Executar programa com apenas `Andar`.
    - Executar programa `WHILE caminho livre -> Andar`.
  - Status: experimento historico implementado e rejeitado como contrato final. O runtime nao reinicia a cadeia ao chegar ao fim.

- [x] Prototipar `Andar` como intencao continua por ciclo.
  - Arquivos previstos:
    - `braty/src/programming/runtime/program_runtime.gd`
    - `braty/src/buneko/physics/buneko_physics_controller.gd`
    - `braty/src/tutorial/tutorial_mission.gd`
    - testes de runtime/fisica afetados
  - Regras:
    - Movimento horizontal existe enquanto o brain emite intencao.
    - Ausencia de intencao desacelera o Buneko no chao de forma previsivel.
    - Momentum horizontal continua preservado no ar ate o pouso.
    - Pausa, interrupcao e fim de tentativa limpam a intencao horizontal.
    - `WHILE` continua sendo a forma clara de manter movimento.
    - O modo por pulso e a cena temporaria de comparacao sao removidos apos a escolha.
  - Aceite:
    - Sensacao de plataforma melhora sem esconder a logica do brain.
    - O jogador consegue explicar por que o Buneko parou.
  - Status: consolidado como unico controlador com desaceleracao no chao e momentum aereo.

- [x] Encerrar tentativa cujo programa terminou antes do objetivo.
  - Arquivos previstos:
    - `braty/src/programming/runtime/program_runtime.gd`
    - `braty/src/tutorial/mission_result.gd`
    - `braty/src/tutorial/tutorial_objective_evaluator.gd`
    - `braty/src/tutorial/tutorial_mission.gd`
    - testes de runtime e fluxo tutorial afetados
  - Regras:
    - O runtime deve expor quando uma execucao valida consumiu todo o grafo.
    - A fase deve tratar esse estado como tentativa encerrada antes do objetivo.
    - Movimento horizontal deve parar e o programa deve ser preservado para edicao.
    - O jogador deve receber uma explicacao curta em vez de continuar vendo `Executando`.
  - Aceite:
    - Programa linear terminado nao reinicia e nao deixa a tentativa presa.
    - O editor reaparece com o mesmo programa e feedback sobre o objetivo nao alcancado.
  - Status: implementado; a fase aguarda o movimento produzido pelo ultimo bloco terminar antes de declarar que o objetivo nao foi alcancado.

- [x] Consolidar `Andar` com ritmos discretos e capacidades de locomocao.
  - Arquivos previstos:
    - `braty/src/programming/domain/program_block.gd`
    - `braty/src/brain_editor/block_parameter_panel.gd`
    - `braty/src/brain_editor/block_node.gd`
    - `docs/fases/fase000/prds/001-programming-language.md`
  - Regras:
    - Parametros nao consomem RAM.
    - Preferir opcoes discretas a slider livre.
    - `Andar` recebe `normal` ou `rapido`.
    - `Correr` deixa de existir como bloco separado.
    - Velocidade e desaceleracao podem ser modificadas por futuras pernas.
    - `Pular` permanece com forca padrao no MVP.
  - Aceite:
    - O parametro padrao conclui o tutorial.
    - O jogador nao precisa ajustar numero fino para passar da primeira fase.
  - Status: decisao registrada na ADR 008 e implementada no dominio, editor, runtime, fisica e tutorial.

- [ ] Adicionar feedback minimo para acao recusada.
  - Arquivos previstos:
    - `braty/src/programming/runtime/program_runtime.gd`
    - `braty/src/brain_editor/block_node.gd`
    - `braty/src/tutorial/tutorial_mission.gd`
    - possivel presenter dedicado para diagnostico de execucao
  - Regras:
    - Acao recusada deve indicar bloco e motivo quando possivel.
    - Feedback nao deve competir com objetivo, HUD ou movimento.
    - A primeira versao pode usar texto curto e estado visual simples.
  - Aceite:
    - Pulo sem chao fica compreensivel.
    - O jogador sabe qual bloco tentou agir.
  - Status: parcialmente implementado no runtime e overlay textual da tentativa; ainda falta validar se o feedback e suficiente para jogador.

- [x] Substituir Acompanhar por feedback visual de transicao.
  - Status: implementado pela PRD 009; o editor e a fase usam apenas tentativa normal, e a cabeca do Buneko recebe pulsos luminosos por mudanca de acao ou recusa.

- [ ] Registrar melhoria futura de miniatura do brain na fase.
  - Arquivos previstos:
    - `docs/fases/fase000/tasks/008-brain-and-responsive-movement-tasks.md`
    - possivel PRD futura quando virar escopo ativo
  - Direcao:
    - Mostrar bloco ativo, ramo escolhido, resultado de sensor e acao recusada.
    - Nao bloquear o ajuste de resposta basica do Buneko.
  - Status:
    - Guardado para versao futura, fora do MVP imediato desta PRD.

- [ ] Validar PRD 008.
  - Testes automatizados:
    - Executar suite GUT completa.
    - Cobrir dispatcher, runtime, fisica e fluxo tutorial afetados.
  - Verificacao manual:
    - Programa com apenas `Andar`.
    - Programa com `WHILE caminho livre -> Andar`.
    - Programa com `IF buraco -> Pular / senao Andar`.
    - Pulo propositalmente executado sem chao.
    - Executar `WHILE caminho livre -> Andar` e confirmar que a caminhada segue continua sem flicker repetido.
    - Executar `WHILE -> Andar -> Pular -> Andar [rapido]` e confirmar inercia e retomada apos o pouso.
    - Dez execucoes do programa escolhido para referencia.
  - Documentacao:
    - Atualizar PRD 001 com contrato final de movimento.
    - Atualizar tarefas 005, 006, 007 e checklist 000 conforme o resultado real.
  - Pendencia identificada:
    - A referencia deve usar `Andar [rapido]` e repeticao explicita depois do pouso para concluir dentro de 5 RAM, sem depender de deslizamento excessivo.
  - Validacao automatizada mais recente:
    - 34 scripts, 175 testes e 659 asserts passaram em 2026-08-21.
    - O contrato final, os ritmos, a inercia, o encerramento antecipado e o programa de referencia possuem cobertura automatizada.
    - A sensacao da desaceleracao e a usabilidade visual continuam reservadas ao teste manual do usuario.

## Criterio para declarar a PRD 008 concluida

- O contrato final de movimento foi escolhido apos experimento.
- `Andar` unico, `WHILE -> Andar` e `Pular` possuem comportamento compreensivel.
- Acoes fisicas nao reportam sucesso quando nada aconteceu.
- Existe feedback minimo para acao recusada.
- Suite automatizada passa.
- Validacao manual confirma que o Buneko responde de forma previsivel e agradavel.
