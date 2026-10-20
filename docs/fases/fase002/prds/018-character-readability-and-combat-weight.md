# PRD 018: Visibilidade do Buneko, peso corporal e clareza do combate

Status: implementacao corrigida e revalidada em 2026-09-16. Em 2026-10-20, o usuario confirmou que ja avaliou a experiencia jogavel, aceitou encerrar esta frente e registrou novas criticas na PRD 020. O roteiro manual detalhado de 018-09 nao foi apresentado nesta conversa e permanece sem evidencia item a item; nao o contabilizar como executado.

Tarefas: [018-character-readability-and-combat-weight-tasks.md](../tasks/018-character-readability-and-combat-weight-tasks.md).

## Problema e evidencia

O jogador programa e observa o Buneko. Se o corpo desaparece, o movimento parece deslizar e nao se distingue um golpe de um acerto, perde-se a ligacao entre programa e resultado.

Retorno do usuario em 2026-09-14: o novo ponto de vista encobre o Buneko, a execucao parece leve e nao foi possivel perceber ataques inimigos.

Auditoria da mesma conversa, em `master`, HEAD `fb02375`, incluindo alteracoes locais ainda sem commit:

- `laboratory_fog.gd` desenha fora do cone sobre o personagem, sem excecao para seu corpo; `laboratory_level.tscn` coloca Fog em `z_index = 100`.
- `buneko_visual.gd` desenha corpo e bastao estaticos com pulsos de acao. `enemy_visual.gd` desenha um arco enquanto o ataque esta ocupado, sem separar suas fases.
- `BunekoCharacter.receive_damage()` altera vida, mas nao publica uma reacao especifica a dano nao letal. A derrota com checkpoint agenda a restauracao imediatamente.
- O controlador aplica imediatamente a velocidade pedida e ja possui desaceleracao. Peso visual e sonoro pode ser trabalhado antes de recalibrar fisica.
- Em uma simulacao frontal controlada, o inimigo emitiu dois golpes e reduziu a vida do Buneko parado de 10 para 6. Nas execucoes observadas dos exemplos curto e combate + fuga, nenhum dos tres inimigos emitiu golpe; Buneko terminou com vida 10 e dois inimigos vivos. A rota completa escapou. Sao observacoes desses cenarios, nao prova de ausencia de ataques em todo programa.
- A suite concluiu com 44 scripts, 247 testes e 1579 assercoes aprovados; carregamento headless e `git diff --check` passaram. Nenhuma janela foi aberta. Esses resultados nao estabelecem aceite visual.

## Objetivo e experiencia esperada

Manter o Buneko identificavel durante toda tentativa, fazer movimento e contato com o solo transmitirem presenca corporal e permitir reconhecer percepcao inimiga, preparacao, golpe, acerto, erro e derrota enquanto o programa executa autonomamente.

Exemplo esperado: um inimigo percebe o Buneko pela frente, muda de postura, ergue o bastao e golpeia. Se acertar, o som, a reacao corporal e a vida confirmam o impacto; se o Buneko saltar para fora do alcance, o golpe atravessa o vazio e termina sem efeito de acerto. O jogador consegue explicar o que aconteceu e revisar o programa.

## Evidencia de implementacao

O visual proprio fica acima de Fog apenas no laboratorio, sem mover sensor, mundo ou inimigos de camada. Ataques publicam inicio e resultado confirmado por lote; animacao e audio distinguem passagem, erro e dano sem aplicar regras de combate. Movimento, salto, pouso, percepcao, dano e derrota possuem estados de apresentacao derivados da simulacao real.

A pausa de impacto usa 0,06 s de relogio monotono e suspende runtime, IA, fisica e ataques sem alterar `Engine.time_scale`. A derrota aguarda mais 0,6 s antes do retorno e respeita pausa manual. O patrulheiro terreo comeca voltado para a esquerda, preservando limites, geometria e atributos.

Em 2026-09-14, 4 scripts focados passaram 50 testes/545 assercoes e a suite completa final passou 44 scripts/261 testes/1657 assercoes. Rota de combate/fuga em 10 RAM, carregamento headless e `git diff --check` passaram. Nenhuma janela foi aberta; CA-01 a CA-06 e CA-08 ainda dependem do aceite perceptivo de 018-09 onde indicado.

Em 2026-09-16, a sincronizacao do bastao e a orientacao visual apos viradas foram corrigidas: suite completa com 44 scripts/266 testes/1788 assercoes aprovados, incluindo cinco repeticoes da rota de 10 RAM. Janela real em 960x540, 1440x810 e 1600x900 confirmou, por roteiro e inspecao de capturas, contato dos dois personagens, visibilidade, esquiva, pausa, derrota/checkpoint e fuga. Audio do jogo foi capturado e medido sem saturacao; nao houve escuta perceptiva pelo agente. Evidencias e limites constam na revalidacao das tarefas 018; isso nao encerra o aceite subjetivo nem substitui as dez tentativas manuais.

## Escopo e prioridades

1. P0: tornar corpo e arma do jogador visiveis durante a tentativa.
2. P1: separar visualmente fases de ataque, dano, erro e derrota; incluir som e pausa breve de impacto.
3. P1: ajustar orientacao/patrulha para demonstrar ataque inimigo em pelo menos um encontro frontal reproduzivel.
4. P2: adicionar resposta corporal e sonora a movimento, salto e pouso; calibrar a experiencia completa.

Aplica-se inicialmente ao laboratorio. Componentes compartilhados devem preservar o tutorial e suas capacidades. A 018 complementa a visao da 015 e o combate/checkpoint da 016; nao depende de save. Recomenda-se concluir este aceite antes de iniciar a 017, preservando sua numeracao.

## Regras propostas

### 1. Corpo proprio e cone de visao

- Corpo inteiro, arma equipada e reacoes locais do Buneko do jogador permanecem legiveis nas duas direcoes, ao andar, saltar, atacar, pausar e ser derrotado.
- A excecao pertence somente a apresentacao do proprio personagem, conforme [ADR 013](../../../decisions/ADR-013-character-presentation-and-impact-timing.md). Nao abrir um circulo de revelacao do mundo ao redor dele.
- Sensores, inimigos, objetos, plataformas e corpos inimigos continuam sujeitos ao cone frontal de 120 graus, alcance de 240 e oclusao existente. Nao alterar a origem dos sensores para corrigir o desenho.
- Efeitos do Buneko nao recortam a neblina nem revelam alvos ocultos. Nao elevar o nivel inteiro acima de Fog. HUD permanece fora da neblina.
- Preservar enquadramento e escala uniforme atuais; uma nova camera ou zoom automatico nao faz parte desta entrega.

### 2. Ataque observavel

- Buneko e inimigos apresentam preparacao, golpe e recuperacao: bastao recua/ergue, percorre um arco frontal e retorna ao repouso, com participacao visual do corpo.
- Usar o estado real do ataque: preparacao de 0,2 s, impacto unico e ciclo total de 0,8 s em tempo de simulacao. Animacao acompanha esses marcos e nunca aplica dano por conta propria.
- A pose de contato do bastao deve ser alcancada ao completar 0,2 s, tanto no jogador quanto no inimigo. O recuo ocupa os primeiros 0,12 s e o arco frontal termina nos 0,08 s seguintes; a pose de contato permanece ate 0,36 s, incluindo a pausa de impacto, antes da recuperacao ate 0,8 s. Uma derrota simultanea preserva essa pose inicial antes do tombo.
- A orientacao desenhada acompanha a direcao logica mesmo apos viradas repetidas e passos fisicos. O espelhamento pertence ao visual; nao inverter o corpo fisico para virar a apresentacao. Correcao adicional aprovada em 2026-09-16 apos reproducao de arma voltada para tras.
- O fim da preparacao pode emitir um golpe que erre. Efeito de acerto so acontece depois de o resolvedor confirmar dano efetivamente aplicado.
- Um ataque recusado por falta de arma, personagem morto ou ciclo ocupado nao produz uma nova animacao aceita, som de golpe ou impacto falso.
- O inimigo visivel sinaliza a transicao de patrulha para percepcao com uma mudanca breve de postura ou marcador discreto. Esse sinal nao se repete a cada quadro nem concede deteccao extra. Ao perder visao, retorna a patrulha conforme a regra atual.
- Golpe errado conserva movimento do bastao e som de passagem; nao produz flash no alvo, som de pancada nem pausa de impacto.
- A apresentacao do alcance deve permitir associar arma e alvo atingido, evitando que o arco decorativo atual de 38 unidades sugira alcance menor que o contrato de combate.

### 3. Dano, pausa de impacto e derrota

- Dano confirmado produz reacao breve no alvo, realce local e atualizacao perceptivel da vida. Um pequeno recuo apenas do visual pode transmitir impacto; nao deslocar corpo fisico/hitbox nesta etapa.
- Proposta inicial: realce/reacao local por cerca de 0,12 s e pausa de impacto de 0,06 s reais. Parametros ficam centralizados e ajustaveis para aceite, sem virar novas opcoes de produto nesta entrega.
- Aplicar a pausa somente depois de resolver todo o lote de golpes simultaneos. Um lote produz no maximo uma pausa; nunca acumular pausas por atacante nem duplicar dano.
- Durante a pausa, runtime, IA, fisica e ciclos de combate compartilham a mesma suspensao. O relogio que encerra o efeito continua funcionando; a interface responde. A retomada preserva estado e velocidade anteriores.
- Pausa manual tem precedencia: terminar o efeito nao retoma uma tentativa pausada pelo jogador. Interrupcao, editor, checkpoint, derrota, fim e troca de cena cancelam callbacks antigos e restauram qualquer escala temporal temporaria ao valor anterior, sem presumir `1.0`.
- Inimigo derrotado deixa imediatamente de ser alvo/atacante e de bloquear fisicamente; seu visual faz queda/tombo curto, escurece e permanece caido ate reinicio ou fim. O corpo continua sujeito a neblina, sem memoria de exploracao.
- Derrota do Buneko suspende a tentativa e mostra queda/pose final antes da restauracao. Proposta inicial: janela total de 0,6 s reais depois da pausa de impacto, com apresentacao ativa e simulacao suspensa.
- A restauracao continua automatica quando ha checkpoint, uma unica vez, com vida 10, bastao, ultimo programa e tres inimigos vivos. Antes do checkpoint, conservar o fluxo atual de derrota/retorno ao cerebro. Troca de tela cancela a restauracao pendente.

### 4. Peso de movimento, salto e som

- O visual acompanha deslocamento real: oscilacao/inclinacao pequena ao andar, articulacao ou movimento coerente da locomocao existente e acomodacao ao parar. Nao adicionar pernas ou equipamentos novos por conveniencia de animacao.
- Pulo apresenta impulso/extensao visual, pose de voo e compressao breve no pouso. Detectar transicao real de ar para chao; ficar parado, iniciar a cena ou retomar a pausa nao conta como novo pouso.
- Som de deslocamento acompanha movimento efetivo no solo; passagem do bastao, pancada e pouso possuem identidades distintas. Dano e pouso disparam uma vez por evento, sem som de passos no ar ou parado.
- Usar efeitos originais ou de licenca compativel, registrando procedencia quando houver arquivos externos. Sons curtos, volume moderado e limite de sobreposicao; evitar clipagem em impactos simultaneos.
- Os primeiros efeitos desta entrega sao sintetizados localmente pelo jogo e originais do projeto; nao dependem de arquivos ou licencas externas.
- Efeitos visuais inimigos ficam sob a neblina. Nesta entrega, sons de acao inimiga so sao emitidos quando a origem esta visivel para o jogador; um acerto recebido sempre pode produzir som/reacao no proprio Buneko. Audio nao alimenta sensores nem revela posicoes ocultas.
- Movimento e impacto continuam compreensiveis com audio desligado. Evitar flashes de tela inteira e tremor continuo.
- Preservar velocidades, desaceleracao, gravidade, impulso, colisao e trajetorias atuais. Se o aceite ainda apontar flutuacao, registrar uma segunda calibracao de aceleracao/gravidade/recuo fisico com comparacao de percurso e nova revisao de escopo antes de implementar.

### 5. Encontro inimigo demonstravel

- Ajustar primeiro a direcao inicial do patrulheiro terreo para permitir encontro frontal depois do checkpoint. Limites de patrulha podem ser calibrados na cena se necessario; registrar valores finais e motivo.
- Conservar tres inimigos, seus andares, vida, dano, velocidade, alcance e tempos do ataque; preservar geometria de plataformas, escada e saida.
- Deve existir um cenario reproduzivel com o patrulheiro real percebendo, aproximando, iniciando um golpe e causando exatamente 2 de dano a um Buneko exposto. O teste nao pode injetar o pedido de golpe nem chamar `receive_damage()` para provar esse comportamento.
- Um segundo cenario prova golpe iniciado que erra por salto/saida do alcance. Preservar aproximacao pelas costas e perda de visao; nao adicionar visao traseira, memoria ou dano de contato.
- Demonstrar ameaca nao exige que todo programa tome dano: uma boa solucao pode matar antes, esquivar ou fugir. Abates continuam opcionais.
- O exemplo integrado mantem exatamente 10 RAM, ao menos um abate e fuga com vida em cinco repeticoes. Nao enfraquecer suas assercoes nem alterar a geometria para obter aprovacao. Preferir manter o grafo; se ajustes forem necessarios, preservar a semantica dos blocos e documentar o motivo.

## Arquitetura e arquivos previstos

As cenas compoem apresentacao e eventos. Vida, alcance e ciclo continuam deterministas. Usar sinais/contratos pequenos para ataque aceito, resultado de impacto, dano e mudanca de estado; apresentacao consome dados e nao decide dano ou deteccao. Nao criar um controlador que conheca cada bloco ou tipo de inimigo.

| Area | Arquivos existentes a revisar | Mudanca prevista |
|---|---|---|
| Visibilidade | `braty/scenes/buneko/buneko.tscn`, `braty/scenes/campaign/laboratory_level.tscn`, `braty/src/campaign/laboratory/laboratory_fog.gd` | Composicao do visual proprio acima da mascara, restrita ao laboratorio |
| Corpo e arma | `braty/src/buneko/visual/buneko_visual.gd`, `braty/src/buneko/visual/buneko_simple_parts.gd`, `braty/src/campaign/combat/enemy_visual.gd` | Poses, fases do bastao, dano, locomocao e queda |
| Eventos reais | `braty/src/buneko/physics/buneko_character.gd`, `braty/src/campaign/combat/enemy_character.gd`, `braty/src/campaign/combat/melee_attack.gd`, `braty/src/campaign/combat/melee_combat_resolver.gd` | Contratos de apresentacao e resultados aplicados; preservar regras |
| Tempo e transicoes | `braty/src/campaign/laboratory/laboratory_level.gd`, `braty/src/campaign/laboratory/laboratory_mission.gd`, `braty/src/buneko/runtime/program_attempt_session.gd` | Coordenacao de impacto, pausa e derrota sem callbacks residuais |
| Encontros | `braty/scenes/campaign/laboratory_level.tscn`, `braty/src/campaign/combat/enemy_spawn_point.gd`, `braty/src/campaign/laboratory/laboratory_example_provider.gd` | Direcao/patrulha e regressao dos exemplos |
| Audio | Componentes pequenos de apresentacao e recursos sob `braty/` | Sons associados a eventos; localizacao final definida no plano de implementacao |
| Testes | `braty/tests/unit/campaign/`, `braty/tests/unit/buneko/`, `braty/tests/unit/ui/` | Regressao e contratos temporais; aceite visual separado |

Nao exige refatorar cerebros inimigos, criar hierarquia de personagens ou trocar arte final. Se a arquitetura mudar em trabalho separado, integrar pelos contratos publicos e atualizar o plano antes de editar.

## Criterios de aceite

- CA-01: corpo e arma legiveis nos dois sentidos e em todos os estados, sem revelar mundo/inimigos atras ou atraves de piso.
- CA-02: observador distingue preparacao, golpe e recuperacao e identifica acerto versus erro; efeito de acerto coincide com dano real, inclusive em troca simultanea.
- CA-03: dano e derrota tem resposta corporal; inimigo caido permanece visivel enquanto dentro da visao, e Buneko derrotado e reconhecivel antes do checkpoint.
- CA-04: caminhada, salto e pouso transmitem contato com o solo e peso, com e sem audio; sem repeticao espuria de som/efeito.
- CA-05: encontro frontal reproduzivel demonstra golpe autonomo inimigo e dano 2; esquiva e aproximacao pelas costas continuam viaveis.
- CA-06: pausa de impacto termina, respeita pausa manual e nao vaza entre telas; ciclos, simultaneidade, vida e checkpoint permanecem corretos.
- CA-07: rota integrada conclui cinco repeticoes em 10 RAM; percurso, sensores, programas invalidos, controles de fluxo e guardas mantem cobertura verde; tutorial nao ganha capacidades de campanha.
- CA-08: aceite manual registrado em 960x540, 1440x810 e 1600x900, incluindo combate, virada, salto, derrota e retorno; usuario confirma visibilidade e sensacao de peso.

## Validacao e riscos

Godot 4.4.1 e GUT 9.4.0, conforme ADR 007. Executar testes focados por etapa e suite completa ao integrar; comando na lista de tarefas. Dados/logs de validacao devem usar diretorio temporario isolado. Headless comprova contratos e carregamento, nao sensacao.

Riscos principais: excecao de neblina revelar inimigos; animacao sugerir alcance/tempo incorreto; pausa congelar seu proprio relogio ou retomar pausa manual; efeitos atrasados agirem na tentativa seguinte; ajuste do encontro inviabilizar 10 RAM; som repetitivo e efeitos excessivos; compressao visual alterar involuntariamente colisao. Mitigar com composicao restrita, eventos confirmados, testes de transicoes e aceite manual por etapa.

Arquivos, ordem, testes e riscos foram apresentados e aprovados em 2026-09-14, conforme `AGENTS.md`. A implementacao possui validacao automatizada registrada; o aceite perceptivo permanece pendente. Em 2026-09-16 foi aprovada a correcao da sincronizacao do bastao, a reexecucao da suite e a verificacao grafica. Os resultados dessa revalidacao devem ser registrados separadamente das evidencias anteriores.

## Fora do escopo

Save/recompensa (017), novos blocos/sensores, aumento de RAM, dano obrigatorio para vencer, novos inimigos/armas, audicao jogavel, visao traseira, memoria de exploracao, controle direto, nova camera, arte final, menu de efeitos e refatoracao geral de NPCs. Desaceleracao continua ao detectar inimigo e diferente da pausa curta no impacto e nao faz parte desta proposta.
