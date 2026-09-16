# Tarefas: PRD 018 - Visibilidade do Buneko, peso corporal e clareza do combate

Status geral: implementacao corrigida e revalidada em 2026-09-16, com verificacao grafica por roteiro nas tres resolucoes; aceite perceptivo do usuario e roteiro manual ampliado pendentes em 018-09.

Fonte de verdade: [PRD 018](../prds/018-character-readability-and-combat-weight.md). Contratos transversais implementados: [ADR 013](../../../decisions/ADR-013-character-presentation-and-impact-timing.md).

## Ordem e dependencias

018-01 -> 018-02 -> 018-03 -> 018-04 -> 018-05 -> 018-06 -> 018-07 -> 018-08 -> 018-09. Trabalhar com um agente; nenhuma delegacao faz parte deste plano. A 017 permanece separada, com aceite desta experiencia recomendado antes de iniciar save.

## 018-01 - Confirmar plano e baseline

- [x] Conferir HEAD, branch, diff e arquivos novos; preservar alteracoes locais de 015/016 e composicao inimiga.
- [x] Ler foundations, PRDs/listas 015, 016 e 018 e ADRs 003, 008, 009, 010, 011, 012 e 013.
- [x] Apresentar arquivos finais, ordem, testes e riscos; obter aprovacao explicita antes de mudar comportamento.
- [x] Registrar baseline dos exemplos, vida, golpes inimigos e rota de 10 RAM. Em 2026-09-14, no `master`/`fb02375` com alteracoes locais preservadas: 44 scripts, 247 testes e 1579 assercoes aprovados; carregamento headless e `git diff --check` com codigo 0. Os cenarios automatizados preservam dano inimigo 2 e rota repetida em exatamente 10 RAM; aparencia continua sem aceite.

Conclusao: plano aprovado e snapshot verificavel em 2026-09-14. Dependencia: nenhuma. Nao marcar aceite visual por testes automatizados.

## 018-02 - Manter corpo e arma visiveis

- [x] Apresentar somente o no `Visual` do Buneko acima de Fog durante o spawn do laboratorio; a cena compartilhada conserva sua camada padrao nos demais contextos.
- [x] Preservar geometria/origem do sensor e mascaramento de mundo, inimigos, corpos inimigos e efeitos externos; nao criar halo que revele o entorno.
- [x] Cobrir ordenacao/restricao da camada e regressao de cone, costas, bordas, virada e oclusao.
- [x] Preparar verificacao visual de corpo/arma em repouso, salto e duas direcoes.

Conclusao: contrato CA-01 atendido automaticamente onde verificavel, com aparencia pendente ate 018-09. Dependencia: 018-01. Risco: elevar acidentalmente objetos ocultos junto do jogador.

## 018-03 - Expor eventos e resultados de combate

- [x] Definir contratos pequenos para ataque aceito, fases, dano efetivamente aplicado e derrota, aproveitando sinais/estado existentes.
- [x] Publicar resultado de impacto somente apos resolver o lote completo; preservar dano exato, uma emissao por golpe, alvo vivo, alcance, oclusao e simultaneidade.
- [x] Permitir que apresentacao diferencie ataque recusado, golpe errado e golpe com dano, sem decidir combate.
- [x] Cobrir contratos por comportamento: evento confirmado, ausencia de efeito em erro/recusa, troca simultanea e nenhuma nova acao apos morte.

Arquivos: personagens, `melee_attack.gd`, `melee_combat_resolver.gd` e integracao no nivel. Conclusao: CA-02/06 possuem dados reais para apresentacao. Dependencia: 018-02. Risco: fazer visual aplicar dano ou depender de campos internos.

## 018-04 - Animar percepcao, golpe e dano

- [x] Animar preparacao de 0,2 s, passagem do bastao e recuperacao ate 0,8 s nos visuais do Buneko e inimigos, seguindo o ciclo real.
- [x] Sinalizar transicao de deteccao do inimigo visivel sem repeticao por quadro e sem ampliar visao.
- [x] Implementar reacao/realce local de dano e atualizacao perceptivel de vida; proposta inicial de 0,12 s, sem recuo fisico.
- [x] Distinguir golpe errado e acerto, incluindo alcance visual coerente e efeitos sujeitos a neblina.
- [x] Cobrir correspondencia entre eventos/estados e reset de apresentacao em reinicio; preparar casos manuais de troca simultanea e esquiva.

Arquivos: `buneko_visual.gd`, `buneko_simple_parts.gd`, `enemy_visual.gd` e adaptadores dos personagens. Conclusao: CA-02/03 sem depender de som. Dependencia: 018-03. Risco: animacao antecipar ou atrasar artificialmente dano.

## 018-05 - Pausa breve de impacto e derrota legivel

- [x] Implementar pausa de 0,06 s reais apos lote com dano, uma por lote, sem acumulo; usar relogio monotono que continue com simulacao suspensa.
- [x] Suspender juntos runtime, IA, fisica e golpes; preservar velocidades e relogios de simulacao.
- [x] Preservar pausa manual e cancelar efeitos ao parar, editar, atingir checkpoint, terminar ou sair da cena; nao modificar `Engine.time_scale`.
- [x] Animar queda/escurecimento inimigo e manter corpo ate reinicio/fim, sujeito a neblina e sem participacao em combate/colisao.
- [x] Apresentar derrota do Buneko por 0,6 s reais depois do impacto, com simulacao suspensa e restauracao unica posterior; conservar fluxo sem checkpoint.
- [x] Cobrir impacto durante pausa, retomada, editor, derrota simultanea, troca de cena, valor temporal anterior diferente de 1 e cancelamento de callbacks da tentativa antiga.
- [x] Provar que checkpoint conserva arma/grafo, restaura vida/inimigos e nao repete introducao; nenhum ataque ocorre durante a apresentacao de derrota.

Arquivos: nivel, missao, sessao de tentativa e componente temporal pequeno se necessario. Conclusao: CA-03/06, sem congelamento ou retomada indevida. Dependencia: 018-04. Risco: timer bloqueado pela propria pausa e restauracao duplicada.

## 018-06 - Peso corporal e efeitos sonoros

- [x] Implementar oscilacao/inclinacao de movimento, acomodacao de parada, pose de salto/voo e compressao no pouso apenas no visual.
- [x] Derivar movimento/pouso da fisica real; impedir eventos espurios no spawn, parado e ao retomar pausa.
- [x] Sintetizar sons originais de movimento no solo, passagem do bastao, pancada e pouso em `combat_audio_presenter.gd`, sem recursos ou licencas externas.
- [x] Ligar sons aos eventos confirmados, limitar sobreposicao e impedir repeticao por quadro, passos no ar e audio residual entre telas.
- [x] Restringir audio de acao inimiga a origem visivel; manter feedback local do Buneko ao receber dano; nao adicionar capacidade de audicao.
- [x] Cobrir disparo unico de pouso/impacto, ausencia de passos parado/no ar e descarte de eventos pendentes; preparar comparacao manual com som ligado/desligado.

Conclusao: CA-04, sem alterar fisica. Dependencia: 018-05. Risco: efeitos repetitivos, clipagem ou vazamento de posicao inimiga pelo som.

## 018-07 - Demonstrar ataques inimigos nos encontros

- [x] Ajustar a orientacao inicial do patrulheiro terreo para a esquerda; conservar limites finais de 250 a 720 e todos os demais atributos.
- [x] Criar regressao integrada com IA/fisica/ataque reais: deteccao frontal -> aproximacao -> preparacao -> golpe -> vida reduzida exatamente em 2. Nao injetar golpe/dano.
- [x] Cobrir golpe iniciado que erra por salto/saida de alcance, aproximacao pelas costas, perda de visao e bloqueio por paredes/pisos.
- [x] Verificar que coleta/checkpoint continuam utilizaveis, que nao ha dano inevitavel ao retomar e que fugir sem matar permanece possivel.
- [x] Executar exemplo curto e rota integrada; preservar exatamente 10 RAM, ao menos um abate e fuga com vida nas cinco repeticoes. Nao exigir dano recebido de uma solucao eficiente.
- [x] Preservar o grafo, as geometrias, vida, dano e velocidades; somente a direcao inicial do patrulheiro terreo mudou.

Arquivos: cena do nivel, spawn points, exemplos e `test_laboratory_combat.gd`. Conclusao: CA-05/07. Dependencia: 018-06. Risco: transformar a demonstracao em dificuldade obrigatoria ou quebrar o percurso.

## 018-08 - Regressao completa e coerencia documental

- [x] Rodar testes focados por etapa e concluir suite GUT completa apos integracao, confirmando resumo e codigo de saida.
- [x] Confirmar cobertura de 5/10 RAM, programa invalido, IF/WHILE, sensores, guardas, movimento/salto, pausa e tutorial sem capacidades extras.
- [x] Carregar cena principal em headless e executar `git diff --check`.
- [x] Atualizar o texto de fuga em `laboratory_mission.gd` para refletir combate ativo.
- [x] Atualizar referencias/estados de 015, 016, 018, foundations, indice e ADR 013 conforme o que foi efetivamente implementado, mantendo aceite manual separado.

Conclusao: CA-07 e evidencias reproduziveis. Dependencia: 018-07. Risco: declarar experiencia aceita por suite verde.

Evidencias automatizadas de 2026-09-14: 4 scripts focados, 50 testes e 545 assercoes; suite completa final com 44 scripts, 261 testes e 1657 assercoes, todos aprovados com codigo 0. A rota de combate/fuga concluiu cinco repeticoes em exatamente 10 RAM. A cena principal carregou em headless e `git diff --check` passou. Nenhuma janela grafica foi aberta.

Comando de referencia, a partir da raiz do repositorio, usando diretorio temporario isolado para dados/logs:

```bash
audit_data_dir=$(mktemp -d /tmp/buneko-prd018-XXXXXX)
XDG_DATA_HOME="$audit_data_dir" /home/braty/projetos/godot/godot --headless --path braty -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit -ginclude_subdirs -gexit
XDG_DATA_HOME="$audit_data_dir" /home/braty/projetos/godot/godot --headless --path braty --quit-after 10
git diff --check
```

## 018-09 - Aceite manual e calibracao final

Revalidacao autorizada em 2026-09-16:

- [x] Apresentar arquivos, ordem, testes e riscos da correcao; obter aprovacao para implementar e abrir/focar/capturar/interagir com o jogo.
- [x] Sincronizar os dois visuais com contato em 0,2 s; preservar continuidade, pausa de impacto e pose inicial de troca letal simultanea.
- [x] Cobrir pose antes/no/depois do dano e pausa; reexecutar suite completa e rota de 10 RAM.
- [x] Corrigir orientacao visual apos fisica/viradas nos dois personagens, conforme ampliacao aprovada em 2026-09-16; cobrir direcao renderizada e repetir regressao e capturas.
- [x] Registrar verificacao grafica de visibilidade, peso, sons, esquiva, pausa e derrota/checkpoint; separar evidencia observada e aceite do usuario.

- [x] Anunciar e obter autorizacao nova antes de abrir/focar janela, capturar imagem ou interagir com GUI. Autorizacoes recebidas para as rodadas de 2026-09-16.
- [ ] Verificar em 960x540, 1440x810 e 1600x900: corpo/arma, virada, neblina, salto, pouso e HUD.
- [ ] Observar encontro frontal, golpe acertado, golpe errado/esquiva, troca simultanea, aproximacao pelas costas, derrota inimiga e fuga sem abates.
- [ ] Verificar pausa/retomada durante impacto e derrota; editor/checkpoint/saida nao deixam tempo, sons ou callbacks residuais.
- [ ] Executar dez tentativas manuais de percurso/combate, registrando distribuicao entre resolucoes, sucessos/falhas e configuracao. Registrar explicitamente se tambem satisfaz o roteiro ampliado da 015.
- [ ] Comparar som ligado/desligado e confirmar com o usuario se distingue golpe/acerto/erro e sente peso; ajustar apenas parametros visuais/sonoros e duracao proposta dos efeitos dentro do contrato.
- [ ] Se ainda houver flutuacao, registrar proposta posterior de aceleracao, gravidade ou recuo fisico com impactos em percurso/10 RAM; nao implementar essa segunda calibracao implicitamente.
- [ ] Registrar data, resolucao, cenarios, parametros finais, defeitos restantes e aceite do usuario. Concluir somente quando CA-01 a CA-08 estiverem atendidos.

Criterio de conclusao ainda pendente: experiencia aceita pelo usuario, com evidencias manuais. Dependencia: 018-08. Risco: encobrir um problema de fisica com efeitos ou encerrar sem validar percepcao real.

## Revalidacao de 2026-09-16

Snapshot: `master`, HEAD `fb02375`, worktree com alteracoes locais anteriores preservadas; nenhuma publicacao. A curva compartilhada em `melee_attack_pose.gd` chega ao contato em 0,2 s e conserva a pose ate 0,36 s. Os visuais guardam a pose ao receber dano letal antes do reset do ataque inimigo.

Suite GUT completa: 44 scripts, 264 testes e 1738 assercoes aprovados, codigo 0, incluindo cinco repeticoes de combate/fuga com exatamente 10 RAM. Carregamento headless e `git diff --check` passaram. A primeira execucao teve tres falhas de espera da pausa; os testes passaram a aguardar o estado com limite monotono de 500 ms, compativel com o relogio da implementacao, em vez de assumir que um `SceneTreeTimer` de 80 ms sempre implica o termino do efeito. A duracao de producao continua 60 ms.

Inspecao grafica inicial: Godot 4.4.1, Forward+/Vulkan, GTX 1650, velocidade normal, janela real em 960x540, 1440x810 e 1600x900. Um roteiro temporario instancia a missao real, prepara encontros controlados e aciona os sinais dos botoes de pausa; a rota completa executa o runtime normal. As capturas foram inspecionadas pelo agente. Isso e verificacao grafica assistida por roteiro, nao dez tentativas manuais nem aceite subjetivo do usuario.

- Corpo/arma permanecem visiveis nas duas direcoes, no salto e na derrota; HUD legivel nas tres resolucoes.
- Nas tres resolucoes, golpe do jogador derrubou o inimigo; esquiva por salto preservou vida 10, sem pausa de impacto ou som de pancada; rota completa escapou com vida 10, dois inimigos vivos e 10 RAM.
- Em 960x540 e 1440x810, inimigo autonomo causou cinco golpes de dano 2; pausa durante derrota impediu retorno automatico e continuar restaurou uma vez vida 10, arma e tres inimigos. Em 1600x900 o roteiro atingiu seu limite de espera sem derrota: resultado inconclusivo, requer repeticao.
- Gravacao do mix do proprio jogo: stereo, 44100 Hz, 49,923 s, pico absoluto 0,1074 da escala digital e zero amostras saturadas. Os eventos distinguiram passagem/acerto/esquiva; passos e pousos apareceram na rota. Nao houve escuta perceptiva pelo agente; timbre, volume percebido e sensacao de peso precisam de confirmacao do usuario.
- Defeito observado: depois de virar e executar fisica, a transformacao pode desenhar o bastao para o lado oposto da direcao logica. Reproduzido nos dois personagens em headless com passos fisicos: direcao `1` e base X `(-1, 0)`. A correcao temporal local esta validada, mas esse defeito impede aceitar a orientacao visual do golpe. Ampliacao do plano apresentada ao usuario para aprovacao.

Artefatos locais desta rodada: `/tmp/buneko-sync-20260916/` (`gut-final.log`, `focused-final.log`, `load.log`, `visual.gd`, `visual.log`, `visual-results.json`, `visual-audio.wav` e capturas por resolucao). Resultados adicionais devem ser registrados abaixo; nao substituir a evidencia desta rodada por aceite retroativo.

### Resultado final apos corrigir a orientacao

Ampliacao aprovada pelo usuario: espelhamento aplicado somente a `Visual` em Buneko/inimigo, conforme ADR 013. Regressao cobre viradas repetidas intercaladas com movimento fisico, direcao desenhada e transformacao da colisao preservada.

- Suite completa final: 44 scripts, **266 testes, 1788 assercoes**, todos aprovados, codigo 0; cinco repeticoes da rota integrada de 10 RAM. Log: `/tmp/buneko-sync-20260916/gut-orientation.log`.
- Carregamento headless final e `git diff --check` aprovados. Nenhuma regra numerica de combate, RAM ou movimento foi alterada.
- Segunda rodada grafica: 12 cenarios, quatro por resolucao (golpe do jogador/pausa, inimigo autonomo/derrota/checkpoint, esquiva e rota completa). Cliques sinteticos foram entregues ao viewport nos botoes reais, com pausa e retomada observadas. Janela encerrada ao terminar.
- Nas tres resolucoes, a arma aponta para a frente no contato; corpo/arma ficam visiveis ao virar e saltar, reacao e tombo aparecem, e os corpos inimigos permanecem sob a neblina. Em 960x540 os personagens ficam pequenos, mas o contato e a mudanca de pose sao distinguiveis nas capturas; nao houve ajuste de camera ou escala.
- Golpe do jogador: inimigo com vida 0, jogador com vida 10, angulo local de contato 0,28 rad, direcao logica e visual coerentes. Pausa conserva a pose.
- Inimigo autonomo: primeiro acerto reduz vida de 10 para 8; cinco acertos levam a derrota. Pausa segura a restauracao em zero; continuar restaura uma vez vida 10, bastao e tres inimigos. **Confirmado tambem em 1600x900** nesta repeticao; o limite de espera anterior nao se repetiu.
- Esquiva: salto aceito, vida 10, sem pausa de impacto; um som de passagem e nenhum de pancada. Rota: `escaped`, vida 10, dois inimigos vivos e 10 RAM nas tres resolucoes.
- Audio final capturado do proprio jogo: 46,266 s, stereo/44100 Hz, pico 0,1074 e zero amostras saturadas. Cada cenario de acerto do jogador gerou uma passagem e uma pancada; o cenario de derrota gerou cinco de cada; cada rota gerou dez passos e cinco pousos. Verificacao tecnica de eventos/mix, sem afirmar escuta ou aprovacao de timbre.
- Peso: preparacao, extensao do golpe, reacao, pose de salto e queda foram inspecionadas nas capturas. A sensacao em movimento, comparacao perceptiva com audio ligado/desligado e aceite do usuario continuam abertos, assim como o roteiro manual ampliado de 018-09.

Artefatos finais: `/tmp/buneko-sync-20260916/final/` (`visual-results.json`, `visual-audio.wav` e 45 capturas). Roteiro executado em `/tmp/buneko-sync-20260916/visual.gd`, log em `visual.log`; versoes iniciais preservadas como `visual-initial.gd`/`visual-initial.log`. A verificacao grafica assistida nao foi contabilizada como dez tentativas manuais.
