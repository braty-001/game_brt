# PRD 015: Fuga do laboratorio e visao

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../../../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

Status: percurso e cone frontal compartilhado por sensores/nevoa implementados e validados automaticamente em 2026-09-14; aceite manual permanece pendente.

A [PRD 018](018-character-readability-and-combat-weight.md) mantem corpo/arma do jogador acima da neblina somente na apresentacao propria. A excecao foi implementada conforme ADR 013; cone, sensores e oclusao do mundo permanecem iguais. Aceite visual permanece pendente.

## Objetivo e regras

- Missao de dois andares: inicio inferior esquerdo, bastao perto do inicio (016), escadaria de plataformas a direita e saida superior esquerda.
- Subir com Pular, sem teleporte, subida automatica ou controle manual.
- Chegar a saida vence mesmo com inimigos vivos: um no terreo e dois no superior (016).
- Visao padrao da cabeca: cone frontal de 120 graus, alcance de 240 unidades e oclusao por paredes/pisos. Fora da visao atual ha nevoa, inclusive em area ja visitada.
- Sensores e apresentacao da visao compartilham geometria; inimigo oculto nao e detectado. Minimap continua aproximado.
- O cone acompanha imediatamente a direcao atual do observador. Alvos exatamente nas bordas de 60 graus acima ou abaixo da frente sao visiveis; alvos atras ou logo fora dessas bordas nao sao detectados.
- Preparacao usa 10 RAM. Consulta de degrau somente se demonstrada necessaria pela solucao, com contrato documentado antes do codigo.

## Contrato inicial do percurso

- Mundo de referencia 1440x720; terreo em y=620, piso superior em y=380. Geometria descrita na cena e reutilizada pela visao.
- Tres degraus de 60 unidades no canto direito: x=1000/largura=80, x=1080/largura=80 e x=1160/largura=160. Piso superior termina em x=1000; ultimo salto retorna para ele a esquerda. Percurso verificado em dez tentativas fisicas consecutivas.
- Consulta visual `STEP_AHEAD` (degrau a frente): obstaculo com superficie elevada entre 10 e 90 unidades acima dos pes, no sentido atual, ate 100 unidades a frente e com a face frontal dentro do cone sem oclusao. Disponivel na preparacao do laboratorio; consultas do tutorial continuam inalteradas.
- `PATH_CLEAR_AHEAD` verifica suporte e obstrucao proximos; `GAP_AHEAD` verifica ausencia de suporte, sem presumir que todo bloqueio e buraco. O alcance da visao basica do laboratorio e 240 unidades.
- Referencia inicial: WHILE caminho livre -> Andar; WHILE degrau -> Andar/Pular; Virar; Andar rapido/Pular; WHILE caminho livre -> Andar. Dez blocos, com espera fisica de pouso entre saltos.
- Exemplo de percurso e oferecido pelo provedor da campanha, sem importar o laboratorio no editor. Novas consultas sao configuradas pelo contexto; o tutorial mantem seu catalogo atual.
- A tentativa comeca no inicio do programa confirmado, bloqueia programa invalido/acima de 10 e usa a mesma montagem. Pausa suspende runtime e fisica; voltar permite corrigir o rascunho. Chegada a saida encerra a tentativa.
- Nevoa e consultas usam o mesmo cone frontal, os mesmos retangulos de oclusao e o mesmo calculo de visibilidade; nenhuma memoria de areas exploradas. Mundo renderizado em viewport proprio com escala uniforme e controles fora da nevoa.
- Entrada de campanha usa sinal pequeno e estado da sessao. Extrair executor de tentativa reutilizavel do adaptador tutorial preservando seu contrato e testes.

## Limite desta implementacao

Entregar e testar percurso/visao nesta PRD. Bastao coletavel, checkpoint, inimigos ativos, vida/dano e recompensa/save pertencem a 016/017. Briefing diferencia versao de percurso do escopo final. Nao declarar aceite completo de 015 antes da integracao 016 e do teste manual.

## Criterios de validacao

Percurso real, repetivel, sem controle direto; solucao completa em 10 RAM e dez execucoes de subida/virada/chegada. Cobrir alcance, frente, costas, bordas exatas de mais ou menos 60 graus, virada, oclusao, piso, retorno da nevoa e vitoria sem abates. Integrar checkpoint 016/017. Suite GUT, carregamento e teste manual de fisica, colisao, nevoa e tres resolucoes.

## Arquitetura e riscos

Cena compoe geometria; adaptador consulta mundo; objetivo e testavel. Riscos: degraus inviaveis, visao vazando entre andares, frestas no desenho da nevoa, imprecisao nas bordas angulares e RAM insuficiente. Calibrar distancias/velocidades sem mudar semantica dos blocos por conveniencia.

## Melhoria de conclusao aprovada em 2026-09-16

Contrato e implementacao concentrados na [PRD 019](019-baton-pickup-and-mission-completion.md), com [tarefas proprias](../tasks/019-baton-pickup-and-mission-completion-tasks.md). Implementada e validada automaticamente em 2026-09-16; aceite manual pendente nas tarefas 019.

## Fora do escopo

Audicao, memoria de exploracao, upgrades visuais, outras missoes e arte final.
