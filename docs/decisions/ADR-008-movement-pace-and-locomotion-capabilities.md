# ADR 008: Ritmo de movimento e capacidades de locomocao

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

## Decisao

O brain oferece um unico bloco `Andar` com os ritmos discretos `normal` e `rapido`. O ritmo e um parametro do bloco, nao consome RAM e representa a intencao do programa. A peca de locomocao define a capacidade fisica usada para atender essa intencao, como velocidade e desaceleracao.

O bloco separado `Correr` deixa de fazer parte da linguagem. Seu antigo identificador numerico permanece reservado para que dados antigos nao sejam interpretados como outra acao.

Quando o brain deixa de emitir movimento, o Buneko conserva inercia e desacelera no chao. No ar, o momentum horizontal e preservado ate o pouso. Pausa, interrupcao e falha continuam limpando o movimento imediatamente.

`Pular` permanece com forca padrao no MVP. Pecas podem modificar o impulso fisico, mas ritmos de pulo configuraveis so entram quando uma fase demonstrar essa necessidade.

## Motivo

`Andar` e `Correr` expressavam a mesma intencao com velocidades diferentes, ocupavam espaco visual separado e aumentavam a linguagem sem criar uma decisao nova. Um parametro discreto torna o brain mais compacto, preserva a regra de 5 RAM e separa corretamente o pedido do programa da capacidade do corpo montado.

A inercia torna a resposta corporal mais natural sem esconder a logica: repeticoes por `WHILE` sustentam a velocidade, enquanto a ausencia de nova intencao permite que o corpo perca movimento de forma observavel.

## Consequencias

- Editor, pseudocodigo, importacao e runtime devem preservar parametros de acao.
- O dispatcher recebe o bloco executado, incluindo seus parametros.
- A paleta deixa de oferecer `Correr`.
- Programas de referencia usam `Andar [rapido]` quando precisam de maior velocidade.
- Velocidade e desaceleracao ficam centralizadas nos atributos do Buneko e podem receber modificadores de pecas futuras.
- A calibracao final da inercia depende de teste manual de sensacao e repetibilidade.
