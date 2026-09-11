# PRD 016: Combate corpo a corpo e checkpoint didatico

Status: implementacao parcial integrada em 2026-09-11. Regras e fluxos focados passam; rota completa de combate e fuga em 10 RAM e aceite manual permanecem pendentes.

## Estado atual

- Implementados: vida, ciclo do golpe, `Atacar`, consultas de inimigo, requisitos de arma, tres inimigos, oclusao, coleta do bastao, pausa didatica, edicao no checkpoint e restauracao apos derrota.
- Testes focados comprovam dano, alcance, contato inofensivo, simultaneidade, oclusao, capacidades por contexto, pausa e restauracao.
- A rota integrada usa exatamente 10 RAM, derruba inimigo e chega ao andar superior, mas o programa termina antes da area de saida. Em 2026-09-11, a suite encerrou com 238 de 239 testes aprovados e codigo 1 por esse unico teste.
- A cena principal carrega em headless e `git diff --check` passa. A validacao manual de combate, feedback, esquiva e checkpoint ainda nao foi executada.

## Objetivo

Apresentar combate programavel e revisao do codigo durante a fuga, com 10 RAM antes da entrada e adaptacao apos coletar bastao.

## Regras

- Vida Buneko 10; tres inimigos com 2 (1 terreo, 2 superior).
- Bastao de dano 2 para todos, corpo a corpo, sem municao. Um golpe derruba inimigo; apenas golpes causam dano. Contato nao fere; salto permite esquiva.
- Atacar e um golpe frontal: alcance de 48 unidades alem do corpo, altura de 48, preparacao de 0,2 s e ciclo total de 0,8 s. O alvo e escolhido no instante do impacto. Cada execucao aceita do bloco produz no maximo um impacto; dano nao se repete por quadro de contato.
- Golpes preparados no mesmo passo fisico sao resolvidos como simultaneos: ambos podem causar dano mesmo se um dos participantes chegar a zero naquele conjunto de impactos. Depois disso, personagens derrotados nao iniciam nem recebem novos golpes.
- Parede/piso entre atacante e alvo impede deteccao e dano. O golpe usa direcao atual; contato e sobreposicao sem golpe continuam inofensivos.
- IF/WHILE consultam inimigo visivel/ao alcance da arma. Alvo morto deixa de satisfazer condicao. Validar equipamento; sem bloco extra de sensor.
- WHILE com Atacar repete golpes; Depois com Andar retoma caminhada. Nao caminhar automaticamente apos matar.
- Cerebros autorais patrulham trechos curtos, aproximam/atacam ao ver e voltam a patrulha ao perder visao, respeitando paredes/pisos; sem memoria/busca.
- Bastao inicial ativa checkpoint e pausa simulacao para apresentar arma e editar. Avisado no briefing; excecao didatica, nao regra de toda coleta.
- A preparacao anterior a entrada nao mostra `Atacar` nem consultas de combate. A coleta equipa o bastao, marca o checkpoint, interrompe a tentativa e abre o mesmo editor com `Atacar`, `inimigo visivel` e `inimigo ao alcance`. Continuar reinicia o programa confirmado no checkpoint; fisica, AI e golpes nao continuam fora da tentativa.
- Derrota: checkpoint, vida 10, arma e ultimo programa; tres inimigos vivos nas posicoes iniciais. Apresentacao nao repete. Antes da coleta, reinicio da missao.
- Vitoria somente por saida; abates opcionais.

## Contratos de implementacao

- Vida e ciclo de ataque sao regras deterministicas independentes de cena. Personagens publicam pedidos de impacto; o nivel resolve o lote do passo fisico para manter simultaneidade.
- Buneko e inimigos nao colidem fisicamente entre si. Assim, contato nao causa dano nem bloqueia o percurso; plataformas continuam solidas.
- Inimigos possuem visao de 240 unidades usando os mesmos retangulos de oclusao da PRD 015. Patrulham apenas seu piso entre limites definidos na cena. Ao ver Buneko, aproximam se estiver fora do alcance e atacam quando estiver dentro; ao perder visao, voltam imediatamente a patrulhar, sem busca ou memoria.
- Consultas do Buneko ignoram inimigos derrotados. `inimigo ao alcance` exige bastao equipado, alvo vivo, direcao frontal, faixa vertical e linha de visao.
- O limite continua 10 RAM. A campanha oferece exemplos separados de percurso e combate; o jogador pode apagar/recompor codigo entre checkpoint e tentativas. Abater inimigos nao e requisito para a fuga.
- Checkpoint desta PRD vive na sessao em memoria. Fechar/reabrir o jogo e responsabilidade da PRD 017.

## Criterios, testes e riscos

Testar dano exato/uma vez por golpe, alcance, contato inofensivo, alvo morto, intervalo, pausa, reinicio, patrulha/deteccao/perda e preservacao. Provar combate/fuga em 10 RAM com guardas de execucao. Aceite manual para leitura dos golpes, esquiva, vida e pausa.

Riscos: golpes incompreensiveis, dano por paredes, ataque sem arma, AI presa e simulacao rodando no editor. Separar regras de vida/ataque, adaptadores e apresentacao.

## Fora do escopo

Perseguidores, audicao, outras armas, municao, loja e abates obrigatorios. Save do checkpoint em 017.
