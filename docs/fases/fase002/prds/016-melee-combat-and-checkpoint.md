# PRD 016: Combate corpo a corpo e checkpoint didatico

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../../../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

Status: comportamento automatizado, composicao reutilizavel de inimigos e deteccao frontal integrados ate 2026-09-14; aceite manual permanece pendente.

A [PRD 018](018-character-readability-and-combat-weight.md) implementa animacoes, som, pausa de impacto, derrota legivel e encontros que demonstram ataque inimigo, com tarefas proprias. Numeros de combate e rota de 10 RAM permanecem preservados; aceite manual continua pendente.

## Estado atual

- Implementados: vida, ciclo do golpe, `Atacar`, consultas de inimigo, requisitos de arma, tres inimigos, oclusao, coleta do bastao, pausa didatica, edicao no checkpoint e restauracao apos derrota.
- Testes focados comprovam dano, alcance, contato inofensivo, simultaneidade, oclusao, capacidades por contexto, pausa e restauracao.
- A rota integrada usa exatamente 10 RAM, derruba ao menos um inimigo, conclui a travessia com pouso e alcanca a saida em cinco repeticoes consecutivas.
- O arquetipo patrulheiro, seu visual, os pontos de surgimento e o resolvedor de golpes foram separados do laboratorio e cobertos por contrato.
- A cena principal carrega em headless e `git diff --check` passa. A validacao manual de combate, feedback, esquiva e checkpoint ainda nao foi executada.

## Correcao de fechamento automatizado

- O exemplo `Combate + fuga / 10 RAM` foi estabilizado sem alterar a semantica global do runtime nem elevar o limite de RAM.
- O grafo preserva os comportamentos observaveis de aproximar, atacar, subir, virar e caminhar ate a saida.
- A cobertura integrada comprova que o salto de travessia e aceito, sai do chao e pousa antes da continuidade do laco final de fuga.
- A PRD so muda para concluida depois que a rota repetir com sucesso, a suite GUT completa ficar verde e o aceite manual for registrado.

## Objetivo

Apresentar combate programavel e revisao do codigo durante a fuga, com 10 RAM antes da entrada e adaptacao apos coletar bastao.

## Regras

- Vida Buneko 10; tres inimigos com 2 (1 terreo, 2 superior).
- Bastao de dano 2 para todos, corpo a corpo, sem municao. Um golpe derruba inimigo; apenas golpes causam dano. Contato nao fere; salto permite esquiva.
- Atacar e um golpe frontal: alcance de 48 unidades alem do corpo, altura de 48, preparacao de 0,2 s e ciclo total de 0,8 s. O alvo e escolhido no instante do impacto. Cada execucao aceita do bloco produz no maximo um impacto; dano nao se repete por quadro de contato.
- Golpes preparados no mesmo passo fisico sao resolvidos como simultaneos: ambos podem causar dano mesmo se um dos participantes chegar a zero naquele conjunto de impactos. Depois disso, personagens derrotados nao iniciam nem recebem novos golpes.
- Parede/piso entre atacante e alvo impede deteccao e dano. Deteccao usa o cone frontal do observador; o golpe usa alcance e direcao frontal proprios, independentes do cone visual. Contato e sobreposicao sem golpe continuam inofensivos.
- IF/WHILE consultam inimigo visivel/ao alcance da arma. Alvo morto deixa de satisfazer condicao. Validar equipamento; sem bloco extra de sensor.
- WHILE com Atacar repete golpes; Depois com Andar retoma caminhada. Nao caminhar automaticamente apos matar.
- Cerebros autorais patrulham trechos curtos, aproximam/atacam ao ver e voltam a patrulha ao perder visao, respeitando paredes/pisos; sem memoria/busca.
- Bastao inicial ativa checkpoint e pausa simulacao para apresentar arma e editar. Avisado no briefing; excecao didatica, nao regra de toda coleta.
- A preparacao anterior a entrada nao mostra `Atacar` nem consultas de combate. A coleta equipa o bastao, marca o checkpoint, interrompe a tentativa e apresenta o painel da PRD 019; somente ao confirmar `Editar cerebro` abre o mesmo editor com `Atacar`, `inimigo visivel` e `inimigo ao alcance`. Continuar reinicia o programa confirmado no checkpoint; fisica, AI e golpes nao continuam fora da tentativa.
- Derrota: checkpoint, vida 10, arma e ultimo programa; tres inimigos vivos nas posicoes iniciais. Apresentacao nao repete. Antes da coleta, reinicio da missao.
- Vitoria somente por saida; abates opcionais.

## Contratos de implementacao

- Vida e ciclo de ataque sao regras deterministicas independentes de cena. Personagens publicam pedidos de impacto; o nivel resolve o lote do passo fisico para manter simultaneidade.
- Buneko e inimigos nao colidem fisicamente entre si. Assim, contato nao causa dano nem bloqueia o percurso; plataformas continuam solidas.
- Inimigos possuem cone frontal de 120 graus e alcance de 240 unidades usando os mesmos retangulos de oclusao da PRD 015. A deteccao acompanha a direcao de cada inimigo; aproximar pelas costas nao ativa perseguicao ate que ele vire ou volte a enxergar. Patrulham apenas seu piso entre limites definidos na cena. Ao ver Buneko, aproximam se estiver fora do alcance e atacam quando estiver dentro; ao perder visao, voltam imediatamente a patrulhar, sem busca ou memoria.
- Consultas do Buneko ignoram inimigos derrotados. `inimigo ao alcance` exige bastao equipado, alvo vivo, direcao frontal, faixa vertical e linha de visao.
- O limite continua 10 RAM. A campanha oferece exemplos separados de percurso e combate; o jogador pode apagar/recompor codigo entre checkpoint e tentativas. Abater inimigos nao e requisito para a fuga.
- Checkpoint desta PRD vive na sessao em memoria. Fechar/reabrir o jogo e responsabilidade da PRD 017.

### Composicao reutilizavel de inimigos

- O arquetipo patrulheiro nao depende do laboratorio: atributos de vida, velocidade, gravidade e alcance visual sao configuracao da cena.
- Cerebro deterministico, personagem fisico, visual e ponto de surgimento possuem responsabilidades separadas, conforme ADR 011.
- A cena do nivel declara posicao, limites de patrulha, direcao inicial e arquetipo. O script do nivel apenas instancia e conecta contratos.
- Sensores e resolucao de golpes consultam metodos publicos comuns a Buneko e inimigos; campos internos de vida, ataque e locomocao nao fazem parte do contrato.
- A refatoracao nao muda numeros, IA, colisoes, checkpoint, disponibilidade de blocos nem a solucao de 10 RAM.

## Criterios, testes e riscos

Testar dano exato/uma vez por golpe, alcance, contato inofensivo, alvo morto, intervalo, pausa, reinicio, patrulha/deteccao frontal/perda e preservacao. Provar que aproximacao pelas costas nao detecta, sem alterar a oclusao propria do golpe. Provar combate/fuga em 10 RAM com guardas de execucao. Aceite manual para leitura dos golpes, esquiva, vida e pausa.

Riscos: golpes incompreensiveis, dano por paredes, ataque sem arma, AI presa e simulacao rodando no editor. Separar regras de vida/ataque, adaptadores e apresentacao.

## Melhoria de coleta aprovada em 2026-09-16

Contrato e implementacao concentrados na [PRD 019](019-baton-pickup-and-mission-completion.md), com [tarefas proprias](../tasks/019-baton-pickup-and-mission-completion-tasks.md). Implementada e validada automaticamente em 2026-09-16; aceite manual pendente nas tarefas 019.

## Fora do escopo

Perseguidores, audicao, outras armas, municao, loja e abates obrigatorios. Save do checkpoint em 017.
