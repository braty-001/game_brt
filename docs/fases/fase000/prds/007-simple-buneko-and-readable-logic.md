# PRD 007: Buneko Simples e Logica Visual Legivel

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../../../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

## Objetivo

Tornar a fantasia central do jogo mais simples de entender e mais coerente visualmente. O Buneko deve parecer um personagem 2D modular, simpatico e facil de reconhecer, enquanto `IF` e `WHILE` devem permitir programas intuitivos baseados no que o personagem percebe a frente.

## Problemas observados

- O Buneko atual possui muitos detalhes metalicos, articulacoes e volume, parecendo mais sofisticado do que o tom inicial do jogo exige.
- A composicao visual das pecas funciona, mas cabeca, corpo e locomocao nao parecem partes de um personagem simples desenhado para leitura rapida.
- A condicao `buraco a frente` funciona para reagir a um perigo, mas nao expressa de forma natural a ideia de continuar andando enquanto o caminho estiver seguro.
- O jogador pode confundir uma nova condicao de sensor com a necessidade de criar um novo tipo de bloco condicional.
- `IF` e `WHILE` possuem semanticas diferentes, mas a interface ainda nao ensina claramente quando usar cada um.
- O programa de exemplo precisa demonstrar uma solucao curta e confiavel em vez de apenas preencher o grafo.

## Modelo mental

Os blocos de controle continuam sendo apenas `IF` e `WHILE`. O que cresce e o catalogo de perguntas que eles podem fazer aos sensores.

- `IF` faz uma pergunta uma vez sempre que a execucao chega ao bloco e escolhe `Sim` ou `Nao`.
- `WHILE` faz a pergunta antes de cada repeticao. Enquanto a resposta for verdadeira, executa `Repetir`; quando ficar falsa, segue por `Depois`.
- A execucao geral continua voltando ao inicio do programa enquanto a tentativa estiver ativa.
- Condicoes sao parametros dos blocos de controle e nao consomem RAM adicional.

## Nova condicao: caminho livre a frente

Adicionar a consulta visual `Caminho livre a frente` ao catalogo de sensores.

Ela retorna verdadeiro quando:

- existe piso seguro na curta distancia de decisao a frente do Buneko; e
- nao existe obstaculo bloqueando o movimento nessa mesma distancia.

Ela retorna falso quando:

- existe um buraco dentro da distancia de decisao; ou
- um obstaculo impede continuar na direcao atual.

`Caminho livre a frente` nao e simplesmente o inverso da visao de longo alcance de `Buraco a frente`. A primeira responde se o proximo trecho imediato e seguro; a segunda pode perceber um buraco mais distante para antecipacao. Distancias numericas ficam configuradas no sensor da fase e devem ser calibradas com a fisica do pulo.

## Comportamento de IF

`IF` avalia a condicao ao entrar no bloco:

```text
INICIO
  |
IF: buraco a frente?
  | Sim -> Pular
  | Nao -> Andar
```

Depois que o ramo termina, o ciclo continuo do programa volta ao inicio. Assim, o Buneko anda enquanto nao ve perigo e tenta pular quando o buraco entra na distancia configurada.

Regras:

- A interface deve apresentar a condicao como pergunta.
- As portas devem continuar sendo internamente `true` e `false`, apresentadas como `Sim` e `Nao`.
- Apenas o ramo escolhido e executado naquela avaliacao.
- Durante a tentativa, o ramo escolhido deve ficar visualmente identificavel quando o editor estiver visivel ou no diagnostico posterior.
- Ramo vazio e permitido pelo dominio atual, mas o editor deve avisar quando isso provavelmente resultar em nenhuma acao.

## Comportamento de WHILE

`WHILE` reavalia a condicao antes de cada passagem pelo corpo:

```text
INICIO
  |
WHILE: caminho livre a frente?
  | Repetir -> Andar
  | Depois  -> Pular
```

Enquanto o caminho estiver seguro, o Buneko anda e a simulacao avanca entre as repeticoes. Quando o sensor indicar que o trecho imediato deixou de ser seguro, o fluxo sai por `Depois` e executa o pulo.

Regras:

- A interface deve apresentar a condicao como frase `Enquanto ...`.
- As portas continuam sendo internamente `body` e `next`, apresentadas como `Repetir` e `Depois`.
- Ao terminar o corpo, o runtime retorna implicitamente ao `WHILE` e reavalia o sensor.
- Toda repeticao que produz uma acao deve ceder tempo para a simulacao fisica.
- Corpo vazio continua protegido pelo limite de execucao e recebe erro compreensivel.
- Se a condicao for falsa e a saida `Depois` estiver vazia, a tentativa pode terminar sem exigir uma conexao artificial. Ao retornar ao editor, o jogo deve explicar que o `WHILE` avaliou falso, seguiu por `Depois` e encontrou a saida vazia.
- Nesse encerramento, o `WHILE` responsavel deve voltar selecionado para que o jogador consiga alterar a condicao ou preencher `Depois` imediatamente.

## Condicoes disponiveis

O catalogo inicial passa a oferecer:

- `Visao: caminho livre a frente`.
- `Visao: buraco a frente`.
- `Visao: objetivo visivel`.
- `Audicao: sinal ouvido`.

Todas as condicoes visuais validas podem ser usadas tanto em `IF` quanto em `WHILE`. A diferenca de comportamento pertence ao bloco de controle, nao ao sensor.

## Programa de referencia

O tutorial deve oferecer dois exemplos carregaveis dentro do limite de 5 RAM:

### Exemplo IF

```text
IF: buraco a frente
  Sim -> Pular
  Nao -> Andar
```

### Exemplo WHILE

```text
WHILE: caminho livre a frente
  Repetir -> Andar
  Depois  -> IF: buraco a frente
    Sim -> Pular
    Nao -> sem acao por enquanto
```

Os dois devem concluir a fase tutorial de forma repetivel. O jogador pode carregar um exemplo, observar as conexoes, mover os blocos e modificar a condicao. O exemplo nao deve ser apresentado como unica solucao possivel.

## Direcao visual temporaria do Buneko

Durante a validacao do MVP, o Buneko usa um placeholder deliberadamente neutro para que leitura, movimento e montagem sejam avaliados sem a influencia de um design de personagem prematuro:

- Cabeca, corpo e locomocao aparecem como tres caixas alinhadas.
- Tons neutros, preenchimento plano e contorno consistente substituem cores e detalhes de personalidade.
- O placeholder nao possui olhos, orelhas, rosto, simbolos, articulacoes ou ornamentos.
- Uma marca lateral minima na cabeca comunica somente a direcao na fase.
- O pulso luminoso de acao permanece por ser feedback funcional do programa.
- Pontos de encaixe entre cabeca, corpo e locomocao continuam claros na montagem.

Esse placeholder nao define a direcao de arte final nem precisa parecer um robo-gato. Uma futura decisao visual pode substitui-lo sem alterar montagem, colisao, atributos, runtime ou sensores.

O mesmo conjunto visual deve alimentar a bancada e o personagem da fase para que o jogador reconheca imediatamente o Buneko que montou.

## Estados visuais necessarios

- Encaixe vazio: silhueta simples com nome da parte.
- Peca disponivel: miniatura limpa sem fundo.
- Peca instalada: parte colorida compondo o personagem.
- Peca selecionada: contorno de destaque sem aumentar o tamanho do personagem.
- Movimento: inclinacao ou deslocamento minimo que preserve leitura.
- Pulo: pose simples distinguivel da caminhada.
- Direcao: o personagem deve espelhar horizontalmente sem inverter textos ou elementos de interface.

## Orientacao no editor

- O resumo do bloco deve mostrar a condicao completa sem corte quando houver espaco.
- `IF` deve mostrar `Se [condicao]` e portas `Sim` e `Nao`.
- `WHILE` deve mostrar `Enquanto [condicao]` e portas `Repetir` e `Depois`.
- Bloco sem condicao deve ser destacado e informar exatamente o que falta.
- A area de exemplos deve permitir escolher `Exemplo com IF` ou `Exemplo com WHILE`.
- A RAM do exemplo deve atualizar imediatamente: `3/5 RAM` no exemplo com `IF` e `5/5 RAM` no exemplo com `WHILE` mais decisao de saida.
- O editor deve permitir zerar o cerebro atual, removendo blocos e conexoes.
- O bloco e o ramo executados mais recentemente devem ficar disponiveis para feedback de falha.

## Criterios de aceite

- `Caminho livre a frente` aparece no seletor e e valido para `IF` e `WHILE`.
- O sensor distingue trecho imediato seguro, buraco proximo e obstaculo a frente.
- `IF` escolhe corretamente entre pular e andar conforme o sensor de buraco.
- `WHILE` repete andar enquanto o caminho esta livre e sai para um `IF` que escolhe uma alternativa, como pular quando ha buraco.
- Um `WHILE` inicialmente falso com `Depois` vazio retorna ao editor com diagnostico especifico e deixa o bloco responsavel selecionado.
- Os exemplos de `IF` e `WHILE` ficam dentro do limite de 5 RAM e sao validos pelo mesmo `ProgramValidator` do jogo.
- Os dois exemplos concluem a fase tutorial de forma repetivel apos calibracao fisica.
- O editor comunica pergunta, repeticao, saida e erro de condicao sem exigir explicacao externa.
- O placeholder do Buneko usa tres caixas separaveis, continua legivel na bancada e na fase e nao antecipa a arte final.
- Trocar os assets nao altera regras de montagem, atributos, runtime ou sensores.
- Testes automatizados cobrem catalogo, leitor de sensor, semantica do runtime, exemplos e carregamento das cenas.

## Fora do escopo

- Adicionar novos blocos de controle alem de `IF` e `WHILE`.
- Operadores `AND`, `OR`, `NOT`, comparacoes numericas ou condicoes compostas.
- Pecas alternativas, atributos diferentes, loja, upgrades ou personalizacao de cor.
- Arte final, animacao quadro a quadro complexa ou efeitos visuais elaborados.
- Alterar o limite de 5 RAM ou o custo dos blocos.

## Dependencias e riscos

- A PRD depende do catalogo e runtime das PRDs 001 e 002, do Buneko da PRD 003, do editor da PRD 004 e da fase das PRDs 005 e 006.
- A distancia de decisao de `Caminho livre` deve ser calibrada junto com velocidade e alcance de pulo; um sensor correto com numeros ruins pode produzir falhas aparentemente aleatorias.
- A velocidade horizontal atual pode permanecer ativa durante o pulo. Os testes precisam confirmar que isso e intencional e repetivel.
- Simplificar o asset nao deve reduzir a clareza dos tres encaixes nem quebrar a colisao fisica existente.
- Os exemplos devem usar contratos publicos da linguagem e nao atalhos exclusivos do tutorial.

## Resultado esperado

O jogador reconhece um Buneko simples e carismatico, entende a diferenca entre decidir com `IF` e repetir com `WHILE`, e consegue montar uma solucao curta lendo frases naturais sobre o mundo percebido pelo personagem.
