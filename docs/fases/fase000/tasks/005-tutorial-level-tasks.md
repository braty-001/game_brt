# Tarefas: PRD 005 - Fase Tutorial

Status geral: implementado para o MVP funcional. Testes automatizados foram preparados para o fluxo principal; verificacao manual de repetibilidade e revisao da experiencia do brain ainda pendentes antes de fechar o tutorial como pronto.

## Ordem de implementacao

1. Modelo de estado da missao, resultado e avaliacao de vitoria/falha.
2. Sensores do nivel tutorial para buraco a frente, objetivo visivel e sinal ouvido.
3. Cena do nivel tutorial com Buneko, plataformas, buraco, area de queda e objetivo.
4. Orquestrador da tentativa: montagem, editor, runtime, Buneko fisico e feedback.
5. Programa de referencia do tutorial e validacao de repetibilidade.
6. Orientacao contextual para apresentar movimento, pulo, sensor visual, `IF` e `WHILE`.
7. Validacao final contra PRD 005 e atualizacao do checklist do MVP.

## Modificacoes planejadas

- [x] Criar modelo de estado da missao e avaliacao independente de fisica.
  - Arquivos previstos:
    - `braty/src/tutorial/mission_state.gd`
    - `braty/src/tutorial/mission_result.gd`
    - `braty/src/tutorial/tutorial_objective_evaluator.gd`
  - Regras:
    - Estados minimos: montagem, edicao, executando, falhou e concluido.
    - Resultado de falha deve distinguir queda, limite de execucao e falha externa generica.
    - Tocar o objetivo conclui a missao.
    - Sair da area jogavel falha a tentativa.
    - Falha preserva montagem e programa para nova tentativa.
  - Aceite:
    - O avaliador retorna conclusao ao receber evento de objetivo.
    - O avaliador retorna falha ao receber queda.
    - Eventos fora de ordem nao corrompem o estado.
  - Testes:
    - `braty/tests/unit/tutorial/test_tutorial_objective_evaluator.gd`
    - Vitoria por objetivo.
    - Falha por queda.
    - Retorno para edicao preservando estado.

- [x] Definir a geometria do nivel, ponto inicial, buraco, area de queda e objetivo final.
  - Arquivos previstos:
    - `braty/scenes/tutorial/tutorial_level.tscn`
    - `braty/src/tutorial/tutorial_level.gd`
  - Geometria inicial:
    - Plataforma de inicio larga o suficiente para o Buneko estabilizar antes do buraco.
    - Um buraco visivel entre duas plataformas.
    - Plataforma final com objetivo claro.
    - Area de queda abaixo do nivel cobrindo o buraco e as bordas.
  - Regras:
    - A fase deve favorecer programacao, nao precisao fisica extrema.
    - A solucao de referencia deve caber em 5 RAM.
    - Ajustes numericos de distancia e velocidade podem mudar durante prototipo, mas ficam concentrados na cena do nivel.
  - Aceite:
    - O caminho suporta uma solucao de no maximo 5 RAM.
    - A margem fisica permite repetir a solucao de referencia sem resultado inconsistente.
  - Verificacao:
    - Teste headless carrega a cena.
    - Teste automatizado valida presenca de ponto inicial, objetivo e area de queda.
    - Verificacao manual posterior: dez execucoes da solucao de referencia.

- [x] Criar sensores do nivel tutorial.
  - Arquivos previstos:
    - `braty/src/tutorial/tutorial_world_sensor.gd`
  - Regras:
    - `has_gap_ahead()` retorna verdadeiro quando o Buneko esta antes do buraco e voltado para ele.
    - `can_see_goal()` retorna verdadeiro quando o objetivo esta a frente em alcance configurado.
    - `heard_signal()` existe para satisfazer o tipo audicao do MVP, mesmo que a fase use apenas uma fonte simples.
    - O sensor usa dados pequenos da cena, nao detalhes do editor.
  - Aceite:
    - `BunekoSensorReader` consegue avaliar as condicoes da PRD 001 usando este sensor.
    - O buraco a frente fica disponivel para `IF` e `WHILE`.
  - Testes:
    - `braty/tests/unit/tutorial/test_tutorial_world_sensor.gd`
    - Buraco detectado antes da borda.
    - Buraco nao detectado depois da borda.
    - Objetivo visivel quando esta a frente.
    - Sinal ouvido retorna o estado configurado.

- [x] Implementar objetivo de missao, condicao de vitoria e condicao de queda.
  - Arquivos previstos:
    - `braty/src/tutorial/tutorial_goal.gd`
    - `braty/src/tutorial/fall_zone.gd`
  - Regras:
    - `TutorialGoal` emite evento ao Buneko entrar na area do objetivo.
    - `FallZone` emite evento ao Buneko sair da area jogavel.
    - O orquestrador converte queda em falha externa do runtime.
  - Aceite:
    - Tocar o objetivo conclui.
    - Entrar na area de queda falha.
    - O feedback mostra `Voce falhou` quando a queda acontece.
  - Testes:
    - Sinais de objetivo e queda podem ser exercitados sem depender de uma simulacao longa.

- [x] Criar orquestrador da fase tutorial.
  - Arquivos previstos:
    - `braty/src/tutorial/tutorial_mission.gd`
    - `braty/scenes/tutorial/tutorial_mission.tscn`
  - Composicao:
    - Bancada de montagem da PRD 003.
    - Editor de cerebro da PRD 004.
    - Buneko fisico da PRD 003.
    - Nivel tutorial.
    - Runtime com `BunekoActionDispatcher` e `BunekoSensorReader`.
  - Regras:
    - O jogador passa por montagem antes de editar.
    - A montagem base pode ser instalada automaticamente pelo botao/fluxo do MVP, mas deve continuar visivel.
    - Iniciar execucao usa o programa atual do editor.
    - Falha por queda ou limite de execucao retorna para edicao preservando programa e montagem.
    - Conclusao mostra feedback claro e bloqueia edicao da tentativa concluida.
  - Aceite:
    - Ciclo completo de montar, editar, executar, falhar e editar novamente funciona.
    - Ciclo completo de executar e concluir funciona.
  - Testes:
    - `braty/tests/unit/tutorial/test_tutorial_mission_flow.gd`
    - Montagem completa habilita editor.
    - Inicio invalido fica bloqueado.
    - Falha preserva programa e montagem.
    - Conclusao altera estado para concluido.

- [x] Criar programa de referencia do tutorial.
  - Arquivos previstos:
    - `braty/src/tutorial/tutorial_reference_program.gd`
  - Regras:
    - O programa deve caber em 5 RAM.
    - Deve usar ao menos movimento e pulo.
    - Deve demonstrar uma condicao visual e uma repeticao quando a integracao fisica estiver pronta para isso.
    - O programa de referencia serve para teste e calibracao, nao como solucao unica obrigatoria do jogador.
  - Aceite:
    - O programa e valido pelo `ProgramValidator`.
    - RAM usada e menor ou igual a 5.
    - Acoes esperadas sao emitidas pelo runtime em teste controlado.
  - Testes:
    - `braty/tests/unit/tutorial/test_tutorial_reference_program.gd`
    - Validacao do programa.
    - Consumo de RAM.
    - Sequencia minima de acoes com sensores dublados.

- [x] Adicionar orientacao contextual para movimento, pulo, sensor visual, `IF` e `WHILE`.
  - Arquivos previstos:
    - `braty/src/tutorial/tutorial_hint_presenter.gd`
  - Regras:
    - As mensagens aparecem no momento relevante: montagem, editor vazio, primeiro controle, sensor de buraco, execucao e falha.
    - A orientacao nao deve exigir sintaxe textual.
    - O texto deve ser curto e nao competir com a acao principal.
  - Aceite:
    - A orientacao guia o jogador sem esconder o editor ou o nivel.
    - A fase comunica explicitamente o sensor visual associado ao buraco.
  - Testes:
    - Sequencia de mensagens por estado da missao.
  - Verificacao manual:
    - Jogador novo consegue entender o proximo passo sem explicacao externa.

- [ ] Validar a fase contra todos os criterios da PRD 005.
  - Aceite:
    - Um novo jogador consegue montar o Buneko, criar um programa, iniciar a fase e compreender o objetivo sem controle direto do personagem.
    - Uma solucao valida cabe em 5 RAM e leva o Buneko ao final de forma repetivel.
    - Cair no buraco exibe falha e retorna ao fluxo de edicao com configuracao preservada.
    - A fase comunica o sensor visual do buraco e introduz `IF` e `WHILE`.
    - Condicao de vitoria e transicoes de falha possuem testes automatizados quando independentes de fisica.
  - Testes:
    - Suite GUT completa.
  - Verificacao manual:
    - Abrir `tutorial_mission.tscn`.
    - Executar uma tentativa que falha no buraco.
    - Confirmar retorno para edicao com programa e montagem preservados.
    - Executar a solucao de referencia ate a conclusao.
    - Repetir a solucao de referencia dez vezes sem resultado inconsistente antes de declarar MVP pronto.
    - Revisar se o brain editor comunica claramente como montar, conectar, configurar e executar o programa sem explicacao externa.

## Dependencias e limites

- A PRD 005 usa as cenas e contratos ja criados nas PRDs 003 e 004.
- A fase tutorial nao deve implementar editor de fases, loja, upgrades, inimigos, campanha, pontuacao, estrelas ou persistencia.
- Ajustes finos de arte, animacao e layout podem ser tratados como polimento depois que o ciclo jogavel estiver funcional.
- Se a solucao com `WHILE` e sensor de buraco exigir calibracao fisica alem do escopo imediato, primeiro entregar uma solucao de referencia deterministica com movimento e pulo, depois refinar o desafio guiado.

## Criterio para declarar a PRD 005 concluida

- Todos os testes unitarios novos passam junto com a suite existente.
- A cena `tutorial_mission.tscn` abre e apresenta montagem, editor, nivel e feedback.
- O jogador consegue iniciar uma tentativa sem controle direto do Buneko.
- Queda gera `Voce falhou` e retorna para edicao preservando programa e montagem.
- Objetivo final conclui a missao.
- A solucao de referencia cabe em 5 RAM e e repetivel.
- A experiencia do brain editor parece compreensivel e responsiva para montar a solucao, nao apenas tecnicamente valida.
- O checklist da PRD 000 marca a lista 005 como executada.
