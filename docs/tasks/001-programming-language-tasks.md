# Tarefas: PRD 001 - Linguagem de Programacao por Blocos

Status geral: concluido. A revisao de integracao com o prototipo do editor foi concluida na PRD 004 sem alterar a semantica da linguagem.

- [x] Definir o modelo independente do Godot para programa, bloco, conexao, parametro e condicao.
  - Aceite: permite representar todos os blocos da PRD 001 sem detalhes de interface.
  - Testes: criacao e serializacao do modelo, se persistencia for introduzida.
- [x] Implementar o catalogo inicial de blocos e parametros de direcao e condicao.
  - Aceite: `Andar`, `Correr`, `Pular`, `Virar`, `IF` e `WHILE` podem ser instanciados e configurados.
  - Testes: catalogo e valores validos de parametros.
- [x] Implementar validacao de inicio, conexoes, ramos e ciclos permitidos.
  - Aceite: programas invalidos retornam erros especificos e nao podem executar.
  - Testes: um caso valido e casos para cada regra invalida.
- [x] Implementar calculo de RAM do fluxo conectado.
  - Aceite: cada bloco conectado custa 1 e parametros nao alteram o custo.
  - Testes: limite de 5, excedente e blocos desconectados.
- [x] Revisar a PRD e atualizar esta lista quando a representacao final do grafo for decidida pelo prototipo do editor.
  - Dependencia: PRD 004.
  - Status: o editor visual usa `ProgramDefinition`, `ProgramBlock`, `ProgramConnection` e `ProgramCondition` como fonte unica; nao houve mudanca necessaria na PRD 001.
