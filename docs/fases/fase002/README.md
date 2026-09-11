# Fase 002: Entrada na campanha

Escopo aprovado: selecao e preparacao, laboratorio, combate corpo a corpo e save. PRD 013 permanece concluida; aceite manual ampliado do MVP permanece nas listas anteriores.

## Entregas e ordem

1. [PRD 014](prds/014-campaign-selection-and-preparation.md): selecao e preparacao com 10 RAM. Implementada e testada; selecao/mapa aprovados pelo usuario, aceite manual ampliado pendente.
2. [PRD 015](prds/015-laboratory-escape-and-vision.md): laboratorio de dois andares, percurso de fuga e visao. Percurso implementado e testado; integrado ao combate no checkout, com aceite completo bloqueado pela rota da 016 e pelo roteiro manual.
3. [PRD 016](prds/016-melee-combat-and-checkpoint.md): combate, inimigos e checkpoint didatico. Implementacao parcial integrada; regras e fluxos focados passam, mas a rota completa de combate e fuga em 10 RAM ainda falha.
4. [PRD 017](prds/017-progress-save-and-rewards.md): save persistente e recompensa unica. Planejada.

Cada PRD possui tarefas correspondentes. A entrega atual permite preparar o cerebro, entrar no laboratorio com tres inimigos, coletar o bastao, pausar para adaptar o programa e restaurar o checkpoint apos derrota. A conclusao repetivel da rota integrada ainda depende de finalizar a 016; persistencia e recompensa dependem da 017.

## Decisoes aprovadas

- Tutorial separado; sua conclusao leva a selecao da campanha.
- Selecao mostra planta basica, objetivo, posicoes aproximadas dos inimigos e aviso de pausa na coleta do bastao.
- Tutorial usa 5 RAM; campanha fornece 10 antes de entrar. Cada bloco alcancavel custa 1; parametros/condicoes nao custam extra.
- Missao 1: escapar do laboratorio. Inicio inferior esquerdo, escadaria de plataformas a direita para subir pulando, saida superior esquerda.
- Tres inimigos: um no terreo e dois no superior. Abates opcionais; chegar a saida vence.
- Buneko: vida 10. Inimigos: vida 2. Todos usam bastao de dano 2, corpo a corpo e sem municao. Somente golpe causa dano; contato nao fere e e possivel saltar sobre inimigos.
- Cerebros inimigos definidos pelos autores: patrulha curta, aproxima/ataca ao ver Buneko, volta a patrulha ao perder visao, sem memoria de perseguicao.
- Visao basica da cabeca: circulo centrado no Buneko, limitado por raio e bloqueado por paredes/pisos. Tudo fora da visao atual volta a nevoa. Minimap e inteligencia aproximada, nao rastreamento.
- Bastao no comeco ativa checkpoint e pausa didatica para editar. Excecao de apresentacao desta missao, nao regra automatica de toda coleta.
- Derrota ou reabertura no checkpoint: vida 10, bastao e ultimo programa; tres inimigos vivos nas posicoes iniciais. Apresentacao nao repete. Antes da coleta, reinicio da missao.
- Save preserva dinheiro, montagem/capacidades da cabeca e corpo, programa, fase, checkpoint e primeiras conclusoes. Primeira conclusao paga 10; repeticoes nao pagam.

## Futuro e calibracao

Audicao/`Escutar` (parar para prestar atencao com feedback visual), upgrades de visao, RAM compravel, perseguidores, armas a distancia e missoes 1.2/1.3 ficam para futuras PRDs.

Calibrar raio, alcance/intervalos dos golpes, velocidade/patrulha e degraus. O bloqueio atual e provar a solucao completa de combate e fuga em 10 RAM: o programa de referencia chega ao andar superior, mas termina antes da saida. Novas consultas de navegacao dependem dessa prova; nao adicionar automaticamente blocos como `Bater ate cair` ou `Andar dez passos`.
