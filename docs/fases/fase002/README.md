# Fase 002: Entrada na campanha

Escopo aprovado: selecao e preparacao, laboratorio, combate corpo a corpo e save. PRD 013 permanece concluida; aceite manual ampliado do MVP permanece nas listas anteriores.

## Entregas e ordem

1. [PRD 014](prds/014-campaign-selection-and-preparation.md): selecao e preparacao com 10 RAM. Implementada e testada; selecao/mapa aprovados pelo usuario, aceite manual ampliado pendente.
2. [PRD 015](prds/015-laboratory-escape-and-vision.md): laboratorio de dois andares, percurso de fuga e visao. Percurso implementado, integrado ao combate e validado automaticamente; roteiro manual pendente.
3. [PRD 016](prds/016-melee-combat-and-checkpoint.md): combate, inimigos e checkpoint didatico. Implementacao automatizada integrada, incluindo rota repetivel de combate e fuga em exatamente 10 RAM; aceite manual pendente.
4. [PRD 017](prds/017-progress-save-and-rewards.md): save persistente e recompensa unica. Planejada.
5. [PRD 018](prds/018-character-readability-and-combat-weight.md): visibilidade do Buneko, peso corporal, feedback de combate e encontros demonstraveis. Implementacao automatizada concluida; [tarefas](tasks/018-character-readability-and-combat-weight-tasks.md) de aceite manual pendentes.

Ordem recomendada apos o retorno de 2026-09-14: aceitar manualmente a experiencia da 018 antes de iniciar a 017. A numeracao existente permanece preservada. A [ADR 013](../../decisions/ADR-013-character-presentation-and-impact-timing.md) registra os contratos implementados de apresentacao/tempo que complementam 015 e 016.

Cada PRD possui tarefas correspondentes. A entrega atual permite preparar o cerebro, entrar no laboratorio com tres inimigos, coletar o bastao, pausar para adaptar o programa, restaurar o checkpoint apos derrota e concluir repetidamente a rota integrada. Persistencia e recompensa dependem da 017.

## Decisoes aprovadas

- Tutorial separado; sua conclusao leva a selecao da campanha.
- Selecao mostra planta basica, objetivo, posicoes aproximadas dos inimigos e aviso de pausa na coleta do bastao.
- Tutorial usa 5 RAM; campanha fornece 10 antes de entrar. Cada bloco alcancavel custa 1; parametros/condicoes nao custam extra.
- Missao 1: escapar do laboratorio. Inicio inferior esquerdo, escadaria de plataformas a direita para subir pulando, saida superior esquerda.
- Tres inimigos: um no terreo e dois no superior. Abates opcionais; chegar a saida vence.
- Buneko: vida 10. Inimigos: vida 2. Todos usam bastao de dano 2, corpo a corpo e sem municao. Somente golpe causa dano; contato nao fere e e possivel saltar sobre inimigos.
- Cerebros inimigos definidos pelos autores: patrulha curta, aproxima/ataca ao ver Buneko, volta a patrulha ao perder visao, sem memoria de perseguicao.
- Visao basica da cabeca: cone frontal de 120 graus, alcance de 240 unidades e bloqueio por paredes/pisos. Virar muda imediatamente sensores e nevoa; tudo fora da visao atual volta a ficar encoberto. Minimap e inteligencia aproximada, nao rastreamento.
- Bastao no comeco ativa checkpoint e pausa didatica para editar. Excecao de apresentacao desta missao, nao regra automatica de toda coleta.
- Derrota ou reabertura no checkpoint: vida 10, bastao e ultimo programa; tres inimigos vivos nas posicoes iniciais. Apresentacao nao repete. Antes da coleta, reinicio da missao.
- Save preserva dinheiro, montagem/capacidades da cabeca e corpo, programa, fase, checkpoint e primeiras conclusoes. Primeira conclusao paga 10; repeticoes nao pagam.

## Futuro e calibracao

Audicao/`Escutar` (parar para prestar atencao com feedback visual), upgrades de visao, RAM compravel, perseguidores, armas a distancia e missoes 1.2/1.3 ficam para futuras PRDs.

A rota integrada de combate e fuga em 10 RAM ja foi comprovada automaticamente; o fechamento visual permanece pendente. O retorno de 2026-09-14 originou a PRD 018 para visibilidade, peso e clareza dos ataques. Sua primeira etapa preserva fisica, alcance/tempos de combate e geometria; calibra apresentacao e orientacao/patrulha com regressao da rota. Novas consultas de navegacao precisam de necessidade demonstrada; nao adicionar automaticamente blocos como `Bater ate cair` ou `Andar dez passos`.
