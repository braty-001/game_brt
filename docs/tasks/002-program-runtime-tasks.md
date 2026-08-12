# Tarefas: PRD 002 - Executor Continuo do Programa

Status geral: concluido. A integracao com a fisica foi entregue pela PRD 003.

- [x] Definir contratos de leitura de sensores, despacho de acoes e estado do programa.
  - Aceite: o executor pode ser exercitado sem cenas do Godot.
  - Testes: dublas de mundo e de acoes para cada contrato.
- [x] Implementar interpretacao de fluxo para acoes, `IF` e `WHILE`.
  - Aceite: o executor segue o grafo valido e preserva estado entre intervalos de simulacao.
  - Testes: fluxo linear, ambos os ramos de `IF` e repeticao de `WHILE`.
- [x] Implementar estados de iniciar, pausar, retomar, parar, reiniciar, falhar e concluir.
  - Aceite: transicoes invalidas sao rejeitadas e transicoes validas preservam o programa.
  - Testes: maquina de estados e eventos de falha/conclusao.
- [x] Implementar limite de instrucoes e diagnostico de falta de progresso.
  - Aceite: programas problematicos param com erro e sem travar a aplicacao.
  - Testes: `WHILE` infinito, ciclo sem acao e programa valido longo.
- [x] Integrar o executor ao adaptador de fisica do Buneko apos a PRD 003.
  - Aceite: acoes viram intencoes observaveis no personagem.
  - Testes: `BunekoActionDispatcher` traduz blocos de acao para intencoes do motor.
  - Verificacao manual: pausa e reinicio durante uma fase completa ficam para a PRD 004/005.
