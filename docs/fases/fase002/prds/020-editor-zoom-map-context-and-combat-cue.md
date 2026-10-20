# PRD 020: Enquadramento do cerebro, contexto do mapa e sinal de perigo

Status: implementacao e validacao automatizada concluidas em 2026-10-20; calibracao perceptiva e aceite manual CA-06 pendentes. O usuario aprovou os gatilhos do editor, o contorno do mapa, o efeito ao Buneko ver inimigo, o fator/duracao iniciais e o afastamento do primeiro inimigo. Autorizou validacao grafica local desta entrega.

Tarefas: [020-editor-zoom-map-context-and-combat-cue-tasks.md](../tasks/020-editor-zoom-map-context-and-combat-cue-tasks.md).

## Problema e objetivo

Ao adicionar comandos, o grafo do cerebro pode ultrapassar a area visivel e exigir navegacao manual frequente. No laboratorio, a neblina atual esconde tambem a forma fixa do percurso, dificultando a orientacao. Durante uma situacao de combate, inclusive quando a solucao e fugir, o jogador quer perceber que Buneko entrou em perigo antes de depender apenas de um golpe ou dano.

Esta entrega busca tornar o programa e a missao mais legiveis enquanto preserva o desafio de programar, a visao frontal e a possibilidade de escapar sem atacar. Ela complementa as PRDs [004](../../fase000/prds/004-brain-editor.md), [015](015-laboratory-escape-and-vision.md), [016](016-melee-combat-and-checkpoint.md) e [018](018-character-readability-and-combat-weight.md). O save da [PRD 017](017-progress-save-and-rewards.md) continua separado.

## Retorno do usuario

- O editor poderia diminuir o zoom conforme cresce o numero de comandos no cerebro.
- Poderia haver um efeito ao entrar em combate, mesmo que o programa escolha fugir.
- Fora da visao, a neblina poderia mostrar um desenho basico do mapa para dar nocao do percurso, sem mostrar os inimigos.
- O sinal de perigo poderia ser uma breve desaceleracao do tempo, semelhante a um efeito de bullet time, inclusive se o programa fugir sem atacar.
- O sinal deve comecar ao Buneko conseguir ver o inimigo; a deteccao do Buneko por inimigo oculto nao e o gatilho.
- O primeiro inimigo do laboratorio esta perto demais e deve ficar mais distante para melhorar a entrada na missao.

## Experiencia esperada

Ao aumentar o programa, o jogador continua localizando os blocos e lendo as conexoes, sem perder os controles de zoom e navegacao. Ao olhar para o laboratorio, reconhece a estrutura fixa do mapa por um desenho discreto nas areas encobertas; o cone de visao continua indicando o que Buneko percebe agora. Quando uma ameaca relevante aparece, recebe um sinal breve e compreensivel, inclusive se Buneko passar direto ou fugir, sem ser obrigado a atacar.

## Contratos e limites

### Enquadramento do editor

- O ajuste automatico considera o espaco ocupado pelo grafo, nao apenas a contagem de blocos: ramos e blocos distantes podem exigir mais area mesmo com a mesma RAM.
- Preservar zoom e pan manuais, limite de zoom existente, posicoes dos blocos, conexoes e foco no ponto de inicio. O ajuste nao modifica o programa, seu custo de RAM ou a validacao.
- Nao reduzir o grafo ate tornar texto, portas e ligacoes ilegiveis. Quando o limite minimo for insuficiente, o jogador continua podendo navegar manualmente.
- Recalcular ao abrir e ao mudar o grafo. Depois de zoom ou arraste manual, suspender o ajuste automatico ate o jogador usar o botao de enquadrar. Usar margem de 32 px e limite minimo existente de 60%; quando o grafo exceder esse limite, manter navegacao manual e o foco no inicio.

### Mapa sob a neblina

- Mostrar apenas um desenho simplificado da geometria fixa do laboratorio fora do cone: pisos, paredes e degraus. O desenho e contexto espacial, nao visao nem memoria de exploracao.
- Inimigos, seus corpos, bastao, efeitos e demais objetos dinamicos continuam sujeitos a visao e oclusao atuais. O mapa nao indica posicao nem estado de inimigos ocultos.
- Dentro do cone, manter a apresentacao normal. A diferenca entre `estrutura conhecida` e `mundo visivel agora` deve ser perceptivel nas tres resolucoes suportadas.
- Preservar o cone frontal de 120 graus, alcance de 240 unidades, oclusao, sensores e IA das ADRs [012](../../../decisions/ADR-012-directional-vision.md) e [013](../../../decisions/ADR-013-character-presentation-and-impact-timing.md). A geometria fixa deve vir da mesma fonte usada pelo nivel, evitando divergencia entre desenho e colisao.
- Fora do cone, mostrar somente contorno discreto de pisos, paredes e degraus; a saida aparece apenas quando visivel pelo Buneko. Ajustar contraste na verificacao grafica sem revelar objetos.

### Sinal de entrada em perigo

- Sinalizar a transicao de nenhum inimigo visivel para ao menos um inimigo vivo visivel pelo Buneko, inclusive quando o programa nao usa `Atacar`. A direcao proposta pelo usuario e uma breve desaceleracao do tempo, percebida como bullet time. O sinal e de apresentacao: nao inicia combate, nao altera o programa, nao causa dano e nao muda a IA.
- Ser breve, legivel com o som desligado e nao repetir a cada quadro. Encerrar ou limpar o sinal ao terminar a tentativa, editar, restaurar checkpoint ou trocar de cena.
- Nao revelar posicao, identidade ou quantidade de inimigos fora da visao permitida. Preservar a regra de que o jogador pode fugir sem abates.
- A PRD 018 ja apresenta a transicao de percepcao no inimigo visivel. Esta entrega deve distinguir o novo sinal de perigo desse marcador e dos efeitos de golpe, acerto e dano.
- A situacao visivel termina quando Buneko perde de vista todos os inimigos vivos; uma nova entrada pode sinalizar outra vez. Inimigo oculto, ainda que detecte Buneko, nao dispara o efeito. Tempo de simulacao a 40% durante 0,5 s reais, uma vez por entrada, com retorno suave nos ultimos 0,15 s; pausa manual e apresentacoes de impacto/derrota prevalecem e cancelam o efeito. Restauracao, edicao e troca de cena tambem o cancelam. O coordenador da tentativa controla a escala e restaura o valor anterior, conforme [ADR 015](../../../decisions/ADR-015-visible-danger-time-cue.md).

### Distancia do primeiro encontro

- Inimigo do terreo movido de x=300 para x=520; checkpoint em x=180 e limite esquerdo de patrulha em x=470, deixando pelo menos 290 unidades horizontais entre checkpoint e patrulha normal. Os demais inimigos, andares, geometria, vida, dano, IA e possibilidade de fugir permanecem. O exemplo curto de combate foi ajustado para aproximar e atacar no novo encontro; a rota integrada em 10 RAM continuou aprovada.

## Criterios de aceite

- CA-01: programas pequenos permanecem legiveis; um grafo maior pode ser enquadrado sem perder blocos, ramos, linhas ou controles; zoom/pan manuais continuam utilizaveis.
- CA-02: criar, mover, remover e reabrir grafos nao altera semantica, RAM ou posicoes salvas por causa do enquadramento.
- CA-03: fora da visao, o jogador identifica pisos, paredes e degraus pelo desenho basico; inimigos e objetos dinamicos ocultos nao aparecem nem deixam pistas de posicao.
- CA-04: sensor, cone, oclusao, deteccao inimiga, ataques, checkpoint e rota de fuga continuam com as regras atuais.
- CA-05: uma entrada real na situacao de perigo produz um sinal unico e compreensivel mesmo quando Buneko foge; casos fora da regra aprovada nao produzem sinal. Reinicio e transicoes nao deixam efeito residual.
- CA-06: verificacao manual em 960x540, 1440x810 e 1600x900 confirma legibilidade do editor, distincao entre mapa conhecido e visao atual e percepcao do sinal de perigo. O usuario avalia se o ritmo e a intensidade ajudam a leitura.
- CA-07: a nova posicao do primeiro inimigo permite observar a entrada no laboratorio e alcancar o checkpoint sem encontro imediato; a rota em 10 RAM e o combate/fuga continuam possiveis.

## Validacao e riscos

Cobrir por testes o calculo de enquadramento, seus limites e o respeito ao controle manual; a fonte geometrica do mapa e a ausencia de vazamento de entidades; as transicoes do sinal e seu cancelamento. Reexecutar a suite GUT, carregamento headless e a rota integrada de combate/fuga em 10 RAM. A aparencia, a usabilidade e o impacto perceptivo exigem verificacao manual; testes headless nao encerram CA-06.

Riscos: zoom automatico tirar o foco enquanto o jogador edita; reduzir tanto que portas e textos deixam de ser uteis; contorno da neblina revelar objetos ou sugerir que Buneko os enxerga; sinal global denunciar inimigo oculto; desaceleracao alterar o ritmo real do combate, competir com a pausa de impacto, deixar relogios inconsistentes ou sobreviver ao checkpoint. O controle manual do enquadramento, a derivacao dos solidos, o gatilho pela visao do Buneko e a restauracao da escala mitigam esses riscos; a percepcao do usuario ainda precisa ser avaliada.

## Evidencia de implementacao de 2026-10-20

- `editor_viewport_controller.gd` calcula escala/pan pelo limite real do grafo; `editor_workspace.gd` enquadra ao abrir e mudar e suspende o automatico apos zoom/pan manual. O botao `Centralizar` retoma o enquadramento. O grafo e as regras de RAM permanecem inalterados.
- `laboratory_fog.gd` desenha apenas as bordas da geometria fixa recebida de `laboratory_level.gd` e so onde o sensor nao enxerga. Saida, inimigos e objetos dinamicos nao entram no contorno; cone e consultas continuam na mesma geometria.
- `danger_time_cue.gd` calcula a transicao e a duracao em tempo real. `laboratory_mission.gd` consome a visao atual do Buneko, aplica e restaura `Engine.time_scale`, cancelando o efeito nas pausas e transicoes. A cena deslocou o inimigo terreo para x=520.
- Inspecao grafica autorizada por capturas reais em subviewports de 960x540, 1440x810 e 1600x900: editor pequeno/grande, mapa com inimigo oculto e encontro visivel. Capturas em `/tmp/buneko-prd020-*.png`, com dados de usuario isolados. Em 960x540, um grafo espalhado alem do limite de 60% exige arraste manual; o inicio permanece visivel. Capturas estaticas nao permitem julgar o ritmo da desaceleracao.
- Suite GUT completa apos o ultimo ajuste: **46 scripts, 292 testes e 2116 assercoes**, todos aprovados, codigo 0. Carregamento headless da cena principal e `git diff --check` aprovados. A rota integrada de combate/fuga em 10 RAM foi repetida em cinco execucoes aprovadas. O usuario ainda precisa avaliar jogando se contraste, legibilidade e meio segundo de desaceleracao produzem a sensacao desejada; CA-06 permanece aberto.

## Fora do escopo

Nova camera da fase, memoria de areas exploradas, minimapa tatico com inimigos, aumento de alcance visual, novo sensor/bloco, mudanca de RAM, alteracao de IA, ataque obrigatorio, dano por proximidade, save/recompensa e novas missoes.
