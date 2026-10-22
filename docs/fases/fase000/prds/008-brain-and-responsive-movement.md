# PRD 008: Brain e Movimento Responsivo

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../../../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

## Objetivo

Ajustar a relacao entre o brain programado pelo jogador e o movimento fisico do Buneko para que cada bloco produza uma resposta corporal clara, previsivel e gostosa de observar. O jogador deve sentir que o Buneko esta obedecendo ao programa em tempo real, nao que a fase esta executando uma simulacao opaca.

## Problema

O MVP ja possui editor, runtime, sensores e fisica integrados, mas a experiencia ainda pode parecer frouxa quando o jogador tenta fazer o Buneko andar, pular ou repetir acoes. Para este jogo, resposta ruim e mais grave do que arte simples: se o jogador nao entende por que o Buneko se moveu, parou ou falhou, ele perde confianca no brain.

## Modelo mental desejado

O brain e o controle autonomo do Buneko. Cada bloco de acao deve emitir uma intencao fisica compreensivel:

- `Andar` faz o Buneko dar um passo curto quando executado uma vez.
- `WHILE` com `Andar` ensina que repetir a intencao produz movimento continuo.
- `Andar [rapido]` solicita velocidade maior sem criar uma segunda acao.
- `Pular` aplica uma forca de pulo quando o Buneko pode pular.
- Se uma acao nao puder acontecer, o jogo deve comunicar a falha de forma perceptivel.

### Ritmo e inercia

`Andar` aceita os ritmos discretos `normal` e `rapido`. O parametro representa a intencao do brain, enquanto a peca de locomocao determina a capacidade fisica. Quando o brain deixa de emitir movimento, o Buneko conserva inercia e desacelera no chao. No ar, o momentum horizontal e preservado ate o pouso.

Quando a cadeia chega ao fim, o brain nao reinicia automaticamente. Para sustentar velocidade, o programa precisa repetir `Andar` explicitamente, como em `WHILE -> Andar`. Um bloco isolado produz movimento seguido de desaceleracao.

A linguagem deve continuar simples. Parametros podem existir, mas devem ensinar o comportamento, nao virar ajuste fino obrigatorio.

## Direcao de design

### Andar como passo

`Andar` deve ser tratado como uma acao curta e observavel. Sem repeticao, o Buneko deve avancar apenas um pouco. Isso transforma a diferenca entre acao unica e repeticao em aprendizado natural:

```text
Andar
```

resultado esperado: um passo curto.

```text
WHILE: caminho livre a frente
  Repetir -> Andar
```

resultado esperado: caminhar continuamente enquanto o sensor permitir.

### Parametro de movimento

`Andar` recebe um parametro simples de ritmo com opcoes discretas:

- `normal`;
- `rapido`.

O parametro nao consome RAM. No futuro, atributos e upgrades do Buneko podem limitar ou ampliar essas opcoes sem mudar a estrutura da linguagem.

### Pulo com forca

`Pular` pode receber um parametro simples de forca no futuro:

- `baixo`;
- `normal`;
- `forte`, se necessario para desafios futuros.

Para o MVP, o valor padrao deve bastar para concluir o tutorial. Forca de pulo nao deve transformar a fase inicial em puzzle de precisao numerica.

Quando `Pular` possui uma proxima acao, o runtime da fase espera o Buneko pousar antes de liberar esse proximo bloco. Assim, `Pular -> Andar [rapido]` inicia o movimento no outro lado do vao. Repeticoes de `WHILE -> Andar` nao recebem essa espera.

### Falha visivel de acao

Se `Pular` for executado enquanto o Buneko nao esta no chao, a acao nao deve ser tratada como sucesso silencioso. O jogador deve receber feedback minimo, por exemplo:

- bloco piscando em estado de acao recusada;
- texto curto de diagnostico;
- efeito visual ou sonoro simples no Buneko;
- registro do ultimo bloco que tentou agir e falhou.

O mesmo principio vale para futuras acoes que possam falhar.

### Feedback de acao

A PRD 009 substitui o modo Acompanhar por um sinal luminoso temporario na cabeca do Buneko. Ele aparece em mudancas de acao e recusas, sem pausar a fisica ou acrescentar texto durante a tentativa.

### Peso e impacto

O Buneko deve sentir que possui corpo:

- aceleracao e desaceleracao devem ser previsiveis;
- o pulo deve ter impulso claro;
- aterrissagem deve ser perceptivel;
- comandos repetidos nao devem gerar derrapagem ou velocidade inesperada.

A primeira entrega pode usar ajustes simples de duracao de passo, aceleracao, atrito e feedback visual. Nao e necessario implementar fisica complexa.

## Resultado dos experimentos

Foram comparados dois modelos:

### Experimento A: acao por pulso

Cada bloco `Andar` aplica um passo curto com duracao ou distancia controlada. O programa precisa repetir `Andar` para manter movimento.

Perguntas:

- O jogador entende melhor a diferenca entre `Andar` e `WHILE -> Andar`?
- O Buneko parece responsivo ou robotico demais?
- O tutorial continua repetivel sem depender de timing preciso?

### Experimento B: intencao continua por ciclo

Enquanto o runtime passa por `Andar`, o Buneko recebe intencao de movimento naquele ciclo fisico. Quando o brain deixa de mandar movimento, o Buneko desacelera ou para.

O experimento B foi escolhido como base do contrato final. O teste manual mostrou que uma intencao limitada a um unico frame era curta demais; por isso o modelo final combina intencao por ciclo com inercia e desaceleracao calibradas. No modo final:

- `Andar` renova a velocidade desejada conforme o ritmo somente no ciclo em que e executado;
- repeticoes explicitas, como `WHILE -> Andar`, renovam essa intencao em cada ciclo;
- na ausencia de uma nova intencao, o Buneko desacelera de modo deterministico no chao;
- o impulso horizontal continua preservado no ar ate o pouso;
- pausar, interromper ou encerrar uma tentativa limpa a intencao horizontal.

Conclusao:

- `Correr` e removido por duplicar a mesma intencao de `Andar`.
- Ritmos permanecem discretos e nao consomem RAM.
- Velocidade e desaceleracao podem ser alteradas por futuras pecas de locomocao.
- A validacao manual final ainda deve confirmar a calibracao da inercia.

## Criterios de aceite

- `Andar` executado uma vez produz deslocamento curto, visivel e previsivel.
- `WHILE` repetindo `Andar` produz movimento continuo compreensivel.
- `Pular` respeita se o Buneko pode pular e nao reporta sucesso quando nada aconteceu.
- Falhas de acao possuem feedback util para o jogador.
- O tutorial pode ser concluido de forma repetivel com os programas de referencia.
- Um jogador consegue explicar, apos observar a fase, por que um `Andar` unico nao atravessa o buraco sozinho.
- Movimento nao depende de precisao de um unico frame.
- A mudanca nao quebra RAM, validacao, sensores ou montagem.
- Se o programa chegar ao fim antes do objetivo, a tentativa termina com feedback util em vez de permanecer indefinidamente como `Executando`.

## Fora do escopo

- Miniatura persistente do brain na tela de fase.
- Linha do tempo detalhada de execucao.
- Novos sensores compostos, operadores logicos ou blocos alem de `IF` e `WHILE`.
- Upgrades reais de pecas, atributos desbloqueaveis ou progressao.
- Animacoes finais, efeitos sonoros finais ou polimento audiovisual completo.

## Guardado para versao futura

Uma miniatura do brain durante a fase pode mostrar o que esta acontecendo na cabeca do Buneko:

- bloco ativo;
- ramo escolhido de `IF`;
- entrada e saida de `WHILE`;
- resultado do sensor como verdadeiro ou falso;
- acao recusada, como pulo sem chao.

Essa ideia deve ser preservada como aprimoramento de feedback, mas nao deve bloquear a correcao do movimento base.

## Dependencias e riscos

- A PRD depende do runtime da PRD 002, do Buneko fisico da PRD 003, do editor da PRD 004, da fase tutorial da PRD 005 e das melhorias visuais das PRDs 006 e 007.
- Ajustar movimento pode exigir atualizar testes de runtime, dispatcher, motor, fisica e fluxo tutorial.
- Se o passo for curto demais, o jogo pode parecer travado; se for longo demais, o jogador perde controle mental sobre a repeticao.
- Parametros demais podem fazer o MVP parecer ferramenta de ajuste numerico em vez de jogo de programacao.
- Feedback de falha precisa ajudar sem poluir a tela.
- O sinal luminoso nao pode alterar a ordem do programa nem bloquear sequencias legitimas como `Pular -> Andar [rapido]`.

## Resultado esperado

O jogador coloca blocos, executa a tentativa e reconhece uma relacao direta entre programa e corpo: um `Andar` inicia movimento no ritmo escolhido, repeticao sustenta a caminhada, a ausencia de comando produz desaceleracao, `Pular` so funciona quando existe apoio, e erros de resposta ficam legiveis o bastante para corrigir o brain.
