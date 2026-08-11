# Tarefas: PRD 005 - Fase Tutorial

Status geral: planejado. Depende das PRDs 001 a 004.

- [ ] Definir a geometria do nivel, ponto inicial, buraco, area de queda e objetivo final.
  - Aceite: o caminho suporta uma solucao de no maximo 5 RAM e tem margem fisica definida por prototipo.
  - Verificacao manual: dez execucoes da solucao de referencia sem resultado inconsistente.
- [ ] Criar objetivo de missao, condicao de vitoria e condicao de queda.
  - Aceite: tocar o objetivo conclui; sair da area jogavel falha.
  - Testes: avaliacao de vitoria e falha fora da fisica.
- [ ] Implementar a sequencia de montagem, edicao, execucao e retorno apos falha.
  - Aceite: falha preserva programa e montagem e oferece nova tentativa clara.
  - Verificacao manual: ciclo completo de uma falha e uma conclusao.
- [ ] Adicionar orientacao contextual para movimento, pulo, sensor visual, `IF` e `WHILE`.
  - Aceite: a orientacao aparece no momento relevante sem exigir texto de sintaxe.
  - Verificacao manual: jogador novo consegue concluir com o roteiro definido.
- [ ] Validar a fase contra todos os criterios da PRD 005.
  - Aceite: criterios documentados como aprovados ou com pendencia conhecida antes de declarar o MVP pronto.
