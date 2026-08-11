# Tarefas: PRD 001 - Linguagem de Programacao por Blocos

Status geral: planejado. Depende da escolha da versao do Godot e da ferramenta de testes.

- [ ] Definir o modelo independente do Godot para programa, bloco, conexao, parametro e condicao.
  - Aceite: permite representar todos os blocos da PRD 001 sem detalhes de interface.
  - Testes: criacao e serializacao do modelo, se persistencia for introduzida.
- [ ] Implementar o catalogo inicial de blocos e parametros de direcao e condicao.
  - Aceite: `Andar`, `Correr`, `Pular`, `Virar`, `IF` e `WHILE` podem ser instanciados e configurados.
  - Testes: catalogo e valores validos de parametros.
- [ ] Implementar validacao de inicio, conexoes, ramos e ciclos permitidos.
  - Aceite: programas invalidos retornam erros especificos e nao podem executar.
  - Testes: um caso valido e casos para cada regra invalida.
- [ ] Implementar calculo de RAM do fluxo conectado.
  - Aceite: cada bloco conectado custa 1 e parametros nao alteram o custo.
  - Testes: limite de 5, excedente e blocos desconectados.
- [ ] Revisar a PRD e atualizar esta lista quando a representacao final do grafo for decidida pelo prototipo do editor.
