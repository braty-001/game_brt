# Fundacao do Projeto Buneko

## Proposito

Buneko e um jogo 2D de plataforma em que o jogador construi e programa um Buneko para cumprir missoes. O jogador nao controla o personagem durante a fase: ele cria o programa, inicia a execucao e observa o resultado, ajustando a construcao ou a logica quando necessario.

## Loop do jogador

1. Ler o objetivo da missao.
2. Montar ou configurar o Buneko disponivel.
3. Criar o programa no editor de cerebro por blocos.
4. Executar a fase e observar o comportamento.
5. Corrigir o programa ou a configuracao ate concluir o objetivo.

## Escopo atual

O objetivo imediato e um MVP tutorial com um Buneko basico, editor de cerebro, uma fase simples e o conjunto minimo de blocos necessario para concluir a fase. Sistemas de equipamentos, atributos, upgrades, economia e editor de fases pertencem ao futuro, mas a arquitetura deve permitir sua inclusao sem reescrever o nucleo.

## Regras de design ja decididas

- O programa e visual e composto por blocos.
- O cerebro inicia com 5 unidades de RAM.
- Cada bloco colocado consome 1 unidade de RAM. Parametros selecionados dentro de um bloco, como o sentido ou a condicao de um sensor, nao consomem RAM adicional.
- O programa e executado continuamente durante a fase.
- O Buneko percebe o mundo por sensores inspirados nos humanos, como visao e audicao, configurados como condicoes selecionaveis em blocos de controle.
- O jogador podera melhorar o Buneko no futuro, incluindo a capacidade de RAM, velocidade e forca.

## Principios de arquitetura

Aplicar SOLID de forma pratica, sem criar camadas artificiais:

- Cada classe ou script tem uma responsabilidade clara.
- A logica de dominio, como consumo de RAM, validacao e execucao de blocos, deve ser testavel sem depender de cenas ou nos do Godot.
- Interfaces e dependencias devem apontar para comportamentos, nao para implementacoes concretas quando houver variacao real.
- Cenas e nos do Godot tratam apresentacao, entrada, animacao e integracao; nao devem concentrar regras de jogo complexas.
- Sistemas devem se comunicar por contratos pequenos, sinais ou adaptadores definidos, evitando referencias diretas desnecessarias entre cenas.
- Toda extensao futura deve preferir adicionar blocos, sensores ou componentes por contratos existentes em vez de alterar um grande script central.

## PRDs e tarefas

Cada funcionalidade relevante recebe uma PRD em `docs/prds/` e uma lista correspondente em `docs/tasks/`, ambas com o mesmo identificador. Exemplo: `001-brain-editor.md` e `001-brain-editor-tasks.md`.

Uma PRD descreve problema, experiencia do jogador, escopo, regras, criterios de aceite, riscos e limites. A lista de tarefas traduz essa definicao em trabalho executavel, com dependencias, status, criterio de conclusao e testes exigidos. Nenhuma PRD ou lista deve ser criada apenas para preencher estrutura: elas surgem quando o trabalho precisa delas.

## Testes

Todo comportamento deterministico e sem interface deve ter testes automatizados: orcamento de RAM, validacao de programas, estruturas de controle, leituras de sensores, objetivos de missao e regras de progressao quando existirem. Integracoes entre editor, representacao do programa e executor devem ter testes automatizados quando a ferramenta escolhida permitir.

Interacoes visuais, animacao, colisao e usabilidade exigem verificacao manual documentada na tarefa correspondente. Antes da primeira tarefa de codigo, a PRD tecnica deve registrar a ferramenta de testes compativel com a versao de Godot escolhida e como ela sera executada localmente e em CI.

## Execucao segura de programas

Estruturas como `WHILE` podem criar programas que nunca terminam. O executor deve ter um limite de instrucoes por atualizacao, diagnostico compreensivel para o jogador e controles para pausar, parar e reiniciar a execucao. O jogo nao pode congelar por causa de um programa criado pelo jogador.

## Agentes

Os papeis em `.agents/` orientam a execucao e a revisao do trabalho. Eles nao substituem a PRD, a lista de tarefas ou uma decisao registrada: esses documentos sao a fonte de verdade do projeto.
