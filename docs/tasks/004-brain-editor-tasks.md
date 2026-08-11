# Tarefas: PRD 004 - Editor de Cerebro

Status geral: planejado. Depende das PRDs 001 e 002.

- [ ] Definir composicao da interface: paleta, area de trabalho, painel de RAM e controles de execucao.
  - Aceite: o fluxo de montagem do programa cabe em uma tela de referencia e prioriza leitura do grafo.
  - Verificacao manual: legibilidade em resolucoes alvo definidas pelo projeto.
- [ ] Implementar criacao, movimentacao e remocao de blocos usando o modelo da PRD 001.
  - Aceite: alteracoes visuais refletem exatamente o programa de dominio.
  - Testes: sincronizacao da operacao com o modelo onde aplicavel.
- [ ] Implementar pontos e linhas de conexao, incluindo ramos de controle.
  - Aceite: apenas conexoes validas sao persistidas e o usuario recebe retorno ao tentar uma invalida.
  - Verificacao manual: conexoes, remocao de linhas e ramos de `IF` e `WHILE`.
- [ ] Implementar seletores de parametros e indicador de RAM.
  - Aceite: condicoes e direcao podem ser configuradas e o total atualiza sem atraso.
  - Testes: calculo de RAM e configuracao valida ficam cobertos pelo modelo.
- [ ] Integrar validacao e controles com o executor.
  - Aceite: iniciar so e possivel com programa valido; pausa, parada, falha e reinicio exibem o estado correto.
  - Verificacao manual: ciclo completo de editar, executar, falhar e editar novamente.
