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

Cada fase fica em `docs/fases/faseNNN/`, com PRDs em `prds/` e listas correspondentes em `tasks/`. Exemplo: `docs/fases/fase000/prds/004-brain-editor.md` e `docs/fases/fase000/tasks/004-brain-editor-tasks.md`.

Uma PRD descreve problema, experiencia do jogador, escopo, regras, criterios de aceite, riscos e limites. A lista de tarefas traduz essa definicao em trabalho executavel, com dependencias, status, criterio de conclusao e testes exigidos. Nenhuma PRD ou lista deve ser criada apenas para preencher estrutura: elas surgem quando o trabalho precisa delas.

## Testes

Todo comportamento deterministico e sem interface deve ter testes automatizados: orcamento de RAM, validacao de programas, estruturas de controle, leituras de sensores, objetivos de missao e regras de progressao quando existirem. Integracoes entre editor, representacao do programa e executor devem ter testes automatizados quando a ferramenta escolhida permitir.

Interacoes visuais, animacao, colisao e usabilidade exigem verificacao manual documentada na tarefa correspondente. Antes da primeira tarefa de codigo, a PRD tecnica deve registrar a ferramenta de testes compativel com a versao de Godot escolhida e como ela sera executada localmente e em CI.

O mesmo comando da suite completa deve ser executado no CI com Godot 4.4.1. O workflow versionado e a referencia executavel; a ADR da pilha registra versoes e responsabilidades.

Os testes GUT devem ser executados a partir da raiz do repositorio com:

```bash
/home/braty/projetos/godot/godot --headless --path braty -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit -ginclude_subdirs -gexit
```

## Convencoes de workspace e linguagem

- A raiz do repositorio contem documentacao e configuracoes compartilhadas. O projeto Godot fica em `braty/`; seu arquivo de projeto e `braty/project.godot`.
- Cenas, scripts, assets, testes e plugins do Godot devem ficar dentro de `braty/`. Em particular, o GUT deve ficar em `braty/addons/gut` para ser reconhecido pelo editor e pela execucao de testes.
- Comandos do Godot devem apontar explicitamente para `braty/`, por exemplo, `godot --path braty` quando executados a partir da raiz do repositorio.
- Antes de executar comandos dependentes do Godot, confirme a raiz real do projeto e a localizacao de `project.godot`; nao assuma que ela coincide com a raiz do repositorio.
- Nomes de diretorios, arquivos, classes, scripts, cenas, variaveis, funcoes e outros identificadores tecnicos devem ser em ingles.
- Comentarios no codigo devem ser em portugues e explicar somente trechos cuja intencao nao seja evidente pelo proprio codigo.

## Execucao segura de programas

Estruturas como `WHILE` podem criar programas que nunca terminam. O executor deve ter um limite de instrucoes por atualizacao, diagnostico compreensivel para o jogador e controles para pausar, parar e reiniciar a execucao. O jogo nao pode congelar por causa de um programa criado pelo jogador.

## Instrucoes do Codex

`AGENTS.md`, na raiz do repositorio, concentra as regras permanentes para trabalhar no Buneko. Fluxos repetiveis e especializados ficam em `.agents/skills/`; a auditoria de qualidade do projeto e definida pela skill `buneko-godot-audit`.

Essas instrucoes orientam a execucao e a revisao do trabalho, mas nao substituem a PRD, a lista de tarefas ou uma decisao registrada: esses documentos continuam sendo a fonte de verdade do projeto.
