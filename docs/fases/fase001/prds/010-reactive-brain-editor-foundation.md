# PRD 010: Fundacao Reativa do Editor de Cerebro

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../../../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

## Objetivo

Reestruturar o editor de cerebro para que o programa seja a unica fonte de verdade e toda a interface reaja de forma consistente a insercao, conexao, movimento e remocao de blocos.

## Problema

O editor atual concentra mutacao do grafo, atualizacao de RAM, validacao, posicionamento e redesenho em pontos diferentes. Isso permitiu que uma acao visual, como apagar um bloco ou move-lo, deixasse RAM ou conexoes fora de sincronia. O jogador deve poder organizar o cerebro livremente sem duvidar se o programa real mudou.

## Experiencia desejada

O jogador arrasta blocos pelo workspace por prazer e para organizar visualmente seu programa. Ao criar, conectar, mover ou remover um bloco, as linhas, o RAM, a validacao e o pseudocodigo futuro passam a refletir o mesmo grafo imediatamente. Mover um bloco nunca cria, remove ou altera uma conexao logica.

## Regras de arquitetura

- `EditorGraphState` e a fonte unica de verdade para blocos, portas, conexoes e inicio.
- O estado emite uma notificacao de mudanca com o tipo de alteracao e os ids afetados.
- Acoes da interface viram comandos pequenos de editor: inserir, conectar, desconectar, mover, remover, redefinir e carregar exemplo.
- Um controlador aplica comandos ao estado; componentes visuais nao mutam o modelo diretamente.
- `BrainEditor` coordena o fluxo e a integracao; a construcao da arvore visual pertence a um componente de view dedicado.
- RAM, validacao, pseudocodigo e workspace observam a mesma mudanca de estado.
- A posicao de um bloco pertence ao layout visual, mas conexoes pertencem ao grafo. O layout nao pode ser usado para inferir fluxo.
- O workspace desenha conexoes somente a partir do estado atual e das posicoes atuais dos blocos.
- A remocao pelo botao do bloco deve atualizar o modelo e os paineis no mesmo ciclo; a liberacao do no Godot pode ser adiada para o proximo frame.

## Funcionalidades

- Sinais ou evento equivalente de mudanca em `EditorGraphState`.
- Controlador de comandos do editor, testavel sem a cena.
- Atualizacao centralizada de RAM, validacao, estado de execucao e desenho do workspace.
- Arraste preservado como organizacao visual.
- Botao `Organizar` que aplica um layout automatico deterministico, sem mudar o programa.
- Cobertura automatizada para os fluxos de insercao, conexao, arraste, remocao e reorganizacao.
- Composicao visual extraida do orquestrador sem alterar nomes de nos, sinais ou o contrato publico usado pela missao.

## Criterios de aceite

- Remover um comando ou laco devolve RAM imediatamente e elimina todas as conexoes relacionadas.
- Mover um bloco conectado preserva exatamente as mesmas conexoes e redesenha suas setas na nova posicao.
- RAM, validacao, contador de conexoes e pseudocodigo derivam do mesmo estado apos qualquer comando.
- `Organizar` altera somente posicoes; programa, RAM e resultado da validacao permanecem iguais.
- Nenhum componente visual mantem uma lista propria de conexoes logicas.
- O orquestrador nao constroi diretamente toda a hierarquia de controles do editor.
- Testes de dominio nao dependem de cenas Godot; testes de cena cobrem os sinais dos botoes e o arraste real.

## Fora do escopo

- Novos formatos visuais de `IF` e `WHILE`.
- Gaveta lateral de insercao.
- Pseudocodigo visivel ao jogador.
- Tela inicial, novos modos, combate, tiro, bombas ou golpes.
- Salvar programas entre sessoes, desfazer/refazer, copiar e colar.

## Dependencias e riscos

- Depende do modelo da linguagem e do validador da fase `000`.
- A migracao deve preservar os programas de exemplo e o contrato do runtime.
- Sinais excessivos ou atualizacoes recursivas podem produzir redraws duplicados; o controlador precisa consolidar uma atualizacao por comando.
- O layout automatico deve manter os ramos legiveis sem decidir o significado das conexoes.

## Resultado esperado

O cerebro continua agradavel de manipular, mas deixa de ser um conjunto de objetos que precisam ser sincronizados manualmente. O jogador move blocos por escolha visual e confia que o programa, as linhas, o RAM e a validacao permanecem coerentes.
