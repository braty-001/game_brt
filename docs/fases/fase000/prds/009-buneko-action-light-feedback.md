# PRD 009: Sinal Luminoso de Acao do Buneko

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../../../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

## Objetivo

Substituir o modo `Acompanhar` por um feedback visual imediato e nao intrusivo no Buneko. Durante uma tentativa normal, o jogador deve perceber quando o brain muda o comportamento do personagem sem pausar a fisica, ler mensagens de depuracao ou clicar em `NEXT`.

## Problema

O modo `Acompanhar` criou uma segunda forma de executar o programa. Isso torna o fluxo menos confiavel e pode alterar a leitura de inercia entre movimento e pulo. Ao mesmo tempo, a execucao normal precisa deixar claro que o Buneko esta obedecendo a uma decisao do brain, especialmente quando muda de comportamento.

## Experiencia desejada

O jogador monta o programa e usa somente `Executar tentativa`. O Buneko se move normalmente e sua cabeca emite um pulso curto de luz quando uma nova acao efetiva comeca:

- `Andar`, em qualquer ritmo: luz turquesa discreta.
- `Pular`: luz azul-clara curta.
- `Virar`: luz violeta curta.
- Acao recusada: luz vermelha curta.

O pulso e um acento visual, nao um texto flutuante nem uma interface adicional. A barra inferior continua reservada para estado geral da tentativa, falha e objetivo concluido.

## Regras de comportamento

- O modo `Acompanhar`, seu botao e o `NEXT` sao removidos do editor, da fase e do runtime de missao.
- A tentativa sempre usa o fluxo normal de `Executar tentativa`.
- A luz e disparada somente quando a ultima acao efetiva muda de tipo.
- Repeticoes consecutivas da mesma acao, como `WHILE -> Andar`, nao repetem o pulso a cada iteracao.
- Uma acao recusada dispara o pulso vermelho mesmo que seja do mesmo tipo da acao anterior.
- O sinal nao pode modificar velocidade, impulso, inercia, ordem do programa ou resultado do runtime.
- O efeito deve desaparecer sozinho em pouco tempo e nao permanecer visivel entre tentativas.

## Direcao visual

O Buneko atual possui cabeca simples desenhada em `BunekoVisual`. A luz deve ficar concentrada nela, com um halo curto ou uma mudanca temporaria de cor no contorno/olhos. Preferir desenho procedimental e cores ja presentes no tema; nao adicionar sprites, texto ou efeitos de tela.

## Criterios de aceite

- `Executar tentativa` funciona sem dependencias de Acompanhar ou `NEXT`.
- `WHILE -> Andar` produz caminhada continua sem flicker de luz a cada passo.
- A transicao de `Andar` para `Pular` e visualmente perceptivel e preserva a inercia normal.
- `Pular -> Andar [rapido]` continua obedecendo a fisica normal.
- Pulo recusado recebe sinal vermelho perceptivel.
- O Buneko volta ao visual neutro apos o pulso e ao iniciar nova tentativa.
- Testes de runtime, fluxo tutorial e visual do Buneko continuam passando.

## Fora do escopo

- Texto flutuante de nome da acao.
- Linha do tempo, miniatura do brain ou destaque de bloco durante a fase.
- Sons, particulas, shakes de camera ou animacoes complexas.
- Novas acoes, sensores ou parametros alem do ritmo de `Andar` definido pela PRD 008.

## Dependencias e riscos

- Depende de `ProgramRuntime` expor a ultima acao executada ou recusada e de `TutorialMission` observar a mudanca sem atrasar a fisica.
- O pulso precisa ser breve; se for intenso ou frequente, pode competir com a leitura do buraco e do objetivo.
- A remocao do Acompanhar deve limpar sinais, botoes e testes associados para nao deixar fluxo morto.

## Resultado esperado

O jogador enxerga o Buneko reagir ao brain pelo proprio corpo: caminhada repetida segue limpa, mudancas como pulo ganham uma piscada de luz na cabeca, e erros ficam visiveis sem interromper a tentativa.
