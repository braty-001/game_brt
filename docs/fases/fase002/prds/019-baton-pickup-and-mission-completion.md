# PRD 019: Coleta do bastao e conclusao perceptiveis

Status: implementado e validado automaticamente em 2026-09-16. Em 2026-10-20, o usuario confirmou que ja avaliou o fluxo jogavel e pediu encerramento desta etapa, com criticas encaminhadas a PRD 020. O roteiro detalhado de 019-05 nao foi apresentado item a item nesta conversa.

## Problema e objetivo

A coleta acontece perto do inicio e troca imediatamente para o editor, sem tempo para entender a aquisicao. A vitoria aparece somente na linha de status e nao oferece um encerramento evidente. Tornar os dois marcos reconheciveis e permitir que o jogador escolha quando seguir.

## Coleta do bastao

- Coletar equipa a arma, ativa o checkpoint em memoria e suspende runtime, fisica, inimigos e combate.
- Exibir painel destacado sobre a missao, com mundo visivel ao fundo: `Bastao adquirido!`.
- Explicar que `Atacar`, `inimigo visivel` e `inimigo ao alcance` estao liberados e que derrotas retornam ao checkpoint.
- Manter o painel ate clicar em `Editar cerebro`, sem tempo minimo ou fechamento automatico. O botao abre o editor existente, preservando o programa.
- Controles ao fundo ficam bloqueados. A apresentacao nao se repete ao retomar ou restaurar o checkpoint.
- A pausa didatica inicial continua especifica desta missao. Manter posicao do bastao, geometria e regras de combate nesta entrega.

## Conclusao da missao

- Somente a chegada real a saida (`escaped`) exibe `Missao concluida!` e `Voce escapou do laboratorio.`.
- Encerrar a tentativa, cancelar apresentacoes temporais e suspender simulacao/audio antes de apresentar o resultado.
- Manter o painel ate escolher `Voltar a selecao` ou `Rever cerebro`. Preservar montagem, programa e checkpoint da sessao.
- GameFlow continua responsavel por navegar, recebendo sinais da missao. Cada escolha gera uma unica transicao, mesmo com cliques repetidos.
- Fim prematuro de programa, queda, derrota e programa invalido conservam seus diagnosticos; nunca exibem vitoria.
- O painel nao anuncia dinheiro ou progresso salvo: persistencia e recompensa pertencem a 017.

## Apresentacao e acessibilidade

- Paineis fora do viewport/neblina, com fundo escurecido, titulo destacado, texto curto e botoes com rotulos claros.
- Foco inicial na acao principal, navegacao por teclado entre as acoes disponiveis e controles ao fundo indisponiveis.
- Layout legivel e contido em 960x540, 1440x810 e 1600x900. Sem exigir som para compreender o evento.

## Arquivos e execucao

Cena `braty/scenes/campaign/laboratory_mission.tscn`, script `braty/src/campaign/laboratory/laboratory_mission.gd`, integracao `braty/src/campaign/game_flow.gd` e testes `test_laboratory_combat.gd`, `test_laboratory_mission.gd`, `test_game_flow.gd`.

Ordem: documentacao -> painel/coleta -> conclusao/navegacao -> regressao automatizada -> aceite visual. A missao coordena a apresentacao; nenhuma nova regra pertence ao runtime ou ao editor. Complementa PRDs 015/016/018 e ADRs 010/013. Funcoes e maior liberdade de linguagem ficam em FUT-001.

## Criterios de aceite

- CA-01: coleta real mostra painel persistente e arma/checkpoint/capacidades corretos, sem abrir editor antes da escolha.
- CA-02: leitura nao avanca movimento, vida, inimigos ou programa; controles de pausa/edicao ao fundo e callbacks antigos nao retomam a tentativa.
- CA-03: confirmar coleta abre editor uma vez, preserva grafo e libera combate; reentrada no checkpoint nao repete introducao.
- CA-04: rota real chega a saida e mostra vitoria persistente; demais resultados nao mostram vitoria.
- CA-05: ambas as acoes finais navegam uma vez, preservando grafo/montagem/checkpoint.
- CA-06: regressao de combate/fuga em cinco repeticoes com exatamente 10 RAM, suite completa e carregamento headless aprovados.
- CA-07: usuario reconhece aquisicao e conclusao, le os textos e usa os botoes nas tres resolucoes, com mouse e teclado. Aceite manual nao pode ser inferido dos testes.

## Validacao e riscos

Godot 4.4.1 / GUT 9.4.0. Executar testes focados de campanha e depois a suite completa prescrita em AGENTS.md com dados XDG isolados em `/tmp`, carregamento headless e `git diff --check`. Testes de layout verificam limites e foco, sem estabelecer qualidade visual.

Riscos principais: simulacao ativa atras do painel; temporizador antigo retomando o jogo; navegacao duplicada; perda de grafo; vitoria falsa; controles cortados. Cobrir por comportamento e integrar o fluxo real. GUI requer nova autorizacao antes de abrir/focar/capturar/interagir.

## Fora do escopo

Save, pagamento de recompensa, nova missao, mudanca de fisica/RAM/geometria, novos sons, NPCs programaveis e ampliacao da linguagem.

## Evidencia de implementacao

Godot 4.4.1 / GUT 9.4.0: campanha com 66/66 testes e 1077 assercoes; suite completa com 44 scripts, 272/272 testes e 1962 assercoes, codigo 0. Carregamento headless e verificacao de diff aprovados. Paineis, foco e limites das tres resolucoes verificados automaticamente; nenhuma janela grafica aberta. Resultados detalhados e roteiro manual nas [tarefas 019](../tasks/019-baton-pickup-and-mission-completion-tasks.md).
