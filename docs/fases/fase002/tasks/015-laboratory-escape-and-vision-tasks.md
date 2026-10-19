# Tarefas: PRD 015 - Laboratorio e visao

Status geral: percurso, cone frontal, combate/checkpoint e rota completa de 10 RAM validados automaticamente ate 2026-09-14. Aceite manual permanece pendente.

A correcao de visibilidade do corpo/arma sob a neblina foi implementada nas [tarefas 018](018-character-readability-and-combat-weight-tasks.md), sem mudar os sensores desta PRD. O roteiro manual abaixo permanece aberto.

Ordem: contrato de sensor/geometria; visao testavel e cena; sessao de tentativa reutilizavel; integracao preparacao/tentativa/retorno; testes reais de fisica e suite completa. Arquivos novos em src/campaign/laboratory e scenes/campaign; alteracoes em catalogo/seletor de condicoes, adaptador de sensores, provedor de exemplos e navegacao da campanha.

Riscos principais: salto insuficiente para retornar ao piso superior, perda de movimento na pausa, visao atravessando piso e exposicao da nova consulta no tutorial.

- [x] Definir geometria, raio e percurso de referencia em 10 RAM.
- [x] Criar dois andares, degraus, inicio/saida e objetivo por chegada.
- [x] Implementar adaptador de sensores, visao, oclusao e nevoa.
- [x] Substituir o alcance circular por cone frontal de 120 graus compartilhado entre sensores e nevoa, com virada imediata e bordas inclusivas.
- [x] Cobrir frente, costas, bordas angulares, duas direcoes, oclusao e redesenho da nevoa.
- [x] Ligar preparacao 014 a tentativa real preservando montagem/programa.
- [x] Cobrir raio, paredes/pisos, chegada sem exigir abates e repetibilidade do percurso. Validacao com inimigos ativos depende de 016.
- [x] Integrar checkpoint/inimigos 016 ao percurso e validar a rota integrada de 10 RAM.
- [x] Rodar suite GUT e carregamento headless.
- [ ] Aceite manual: dez execucoes, saltos, virada, fuga e visibilidade nos tres tamanhos.

Retorno do usuario em 2026-09-09: laboratorio considerado visualmente aprovado e liberado para os proximos passos. Como o tamanho usado e as dez repeticoes manuais nao foram registrados, o aceite ampliado nos tres tamanhos continua pendente.

## Evidencias de 2026-09-09

- Suite completa Godot 4.4.1 / GUT 9.4.0: 42 scripts, 223 testes, 1549 assercoes, todos aprovados; codigo de saida 0. Tutorial e controles antigos permanecem cobertos.
- Percurso de exemplo com exatamente 10 RAM: dez execucoes reais de CharacterBody2D, com subida a direita, virada e chegada superior esquerda. Relogio do teste acelerado mantendo delta fisico 1/60; sem teleporte ou simulador de movimento alternativo.
- Pausa em salto preserva posicao, velocidade e instrucao; retomada alcanca a saida.
- Entrada invalida/acima de RAM bloqueada antes do spawn; termino prematuro/limite de execucao mantem retorno ao cerebro disponivel.
- Ida/volta por sinais preserva montagem, grafo, posicoes e parametros. Exemplo de laboratorio fornecido por adaptador, consultas por contexto; tutorial permanece em 5 RAM e com catalogo anterior.
- Visao original: limite circular, oclusao por parede/piso nos dois sentidos, consultas de suporte/degrau/buraco, objetivo oculto e ausencia de memoria. Foi substituida pela evidencia direcional abaixo.
- Viewport proprio e escala uniforme; controles cabem em 960x540, 1440x810 e 1600x900 em verificacao automatizada. Headless nao comprova aparencia, legibilidade nem sensacao de jogo.
- `git diff --check` sem erros. Nenhuma janela grafica aberta.

## Evidencias de 2026-09-14

- Cone frontal com alcance de 240 unidades: frente, costas, bordas inclusivas de mais ou menos 60 graus, pontos logo fora, duas direcoes e oclusao passaram em 8 testes focados com 318 assercoes.
- A neblina usa a mesma fronteira ocluida do sensor e acompanha mudancas de posicao e direcao sem memoria de exploracao.
- `STEP_AHEAD` consulta a face frontal visivel do degrau, preservando a rota fisica sem ampliar o cone nem alterar a geometria do nivel.
- Suite de campanha: 6 scripts, 44 testes e 752 assercoes; suite completa: 44 scripts, 247 testes e 1579 assercoes, todas aprovadas com codigo 0.
- A rota de combate e fuga continuou concluindo cinco repeticoes com exatamente 10 RAM.
- Cena principal `res://scenes/campaign/game_flow.tscn` carregada em headless e `git diff --check` aprovado.
- Nenhuma janela grafica foi aberta; forma, legibilidade, frestas e sensacao da virada continuam no aceite manual.

## Melhoria de conclusao aprovada em 2026-09-16

Execucao e aceite centralizados nas [tarefas 019](019-baton-pickup-and-mission-completion-tasks.md). Implementada e validada automaticamente em 2026-09-16; aceite manual pendente. Evidencias historicas desta lista permanecem preservadas.

## Como testar o percurso existente

1. Executar `braty/project.godot` com F5; concluir o tutorial para abrir a campanha.
2. Preparar cerebro e carregar o exemplo **Percurso do laboratorio**. Conferir 10/10 RAM e a condicao **Visao: degrau a frente** no WHILE da escada.
3. Confirmar o cerebro e clicar **Entrar no laboratorio**.
4. Observar inicio inferior esquerdo, degraus a direita, salto de retorno e saida superior esquerda. Conferir cone frontal, mudanca imediata ao virar, oclusao entre andares e nevoa cobrindo novamente o que ficou para tras.
5. Pausar no meio de um salto, continuar e voltar ao cerebro; conferir que o programa foi preservado. Coletar o bastao, adaptar o programa no checkpoint e confirmar a retomada com arma preservada.
6. Repetir nos tres tamanhos suportados, incluindo combate, derrota e restauracao do checkpoint. Save entre processos e recompensa ainda nao estao ativos.
