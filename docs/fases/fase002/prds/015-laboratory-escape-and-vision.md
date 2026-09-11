# PRD 015: Fuga do laboratorio e visao

Status: percurso/visao implementados e validados automaticamente em 2026-09-09. Combate/checkpoint da 016 integrados no checkout em 2026-09-11; rota completa de 10 RAM e aceite manual permanecem pendentes.

## Objetivo e regras

- Missao de dois andares: inicio inferior esquerdo, bastao perto do inicio (016), escadaria de plataformas a direita e saida superior esquerda.
- Subir com Pular, sem teleporte, subida automatica ou controle manual.
- Chegar a saida vence mesmo com inimigos vivos: um no terreo e dois no superior (016).
- Visao padrao da cabeca: raio circular e oclusao por paredes/pisos. Fora da visao atual ha nevoa, inclusive em area ja visitada.
- Sensores e apresentacao da visao compartilham geometria; inimigo oculto nao e detectado. Minimap continua aproximado.
- Preparacao usa 10 RAM. Consulta de degrau somente se demonstrada necessaria pela solucao, com contrato documentado antes do codigo.

## Contrato inicial do percurso

- Mundo de referencia 1440x720; terreo em y=620, piso superior em y=380. Geometria descrita na cena e reutilizada pela visao.
- Tres degraus de 60 unidades no canto direito: x=1000/largura=80, x=1080/largura=80 e x=1160/largura=160. Piso superior termina em x=1000; ultimo salto retorna para ele a esquerda. Percurso verificado em dez tentativas fisicas consecutivas.
- Consulta visual `STEP_AHEAD` (degrau a frente): superficie elevada entre 10 e 90 unidades acima dos pes, no sentido atual, ate 100 unidades a frente, dentro do raio de visao e sem oclusao. Disponivel na preparacao do laboratorio; consultas do tutorial continuam inalteradas.
- `PATH_CLEAR_AHEAD` verifica suporte e obstrucao proximos; `GAP_AHEAD` verifica ausencia de suporte, sem presumir que todo bloqueio e buraco. O raio da visao basica do laboratorio e 240 unidades.
- Referencia inicial: WHILE caminho livre -> Andar; WHILE degrau -> Andar/Pular; Virar; Andar rapido/Pular; WHILE caminho livre -> Andar. Dez blocos, com espera fisica de pouso entre saltos.
- Exemplo de percurso e oferecido pelo provedor da campanha, sem importar o laboratorio no editor. Novas consultas sao configuradas pelo contexto; o tutorial mantem seu catalogo atual.
- A tentativa comeca no inicio do programa confirmado, bloqueia programa invalido/acima de 10 e usa a mesma montagem. Pausa suspende runtime e fisica; voltar permite corrigir o rascunho. Chegada a saida encerra a tentativa.
- Nevoa e consultas usam os mesmos retangulos de oclusao e calculo de visibilidade; nenhuma memoria de areas exploradas. Mundo renderizado em viewport proprio com escala uniforme e controles fora da nevoa.
- Entrada de campanha usa sinal pequeno e estado da sessao. Extrair executor de tentativa reutilizavel do adaptador tutorial preservando seu contrato e testes.

## Limite desta implementacao

Entregar e testar percurso/visao nesta PRD. Bastao coletavel, checkpoint, inimigos ativos, vida/dano e recompensa/save pertencem a 016/017. Briefing diferencia versao de percurso do escopo final. Nao declarar aceite completo de 015 antes da integracao 016 e do teste manual.

## Criterios de validacao

Percurso real, repetivel, sem controle direto; solucao completa em 10 RAM e dez execucoes de subida/virada/chegada. Cobrir borda do raio, oclusao, piso, retorno da nevoa e vitoria sem abates. Integrar checkpoint 016/017. Suite GUT, carregamento e teste manual de fisica, colisao, nevoa e tres resolucoes.

## Arquitetura e riscos

Cena compoe geometria; adaptador consulta mundo; objetivo e testavel. Riscos: degraus inviaveis, visao vazando entre andares e RAM insuficiente. Calibrar distancias/velocidades sem mudar semantica dos blocos por conveniencia.

## Fora do escopo

Audicao, memoria de exploracao, upgrades visuais, outras missoes e arte final.
