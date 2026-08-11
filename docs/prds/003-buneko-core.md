# PRD 003: Buneko Basico, Montagem e Fisica

## Objetivo

Criar um unico Buneko montavel que responda ao programa em um mundo de plataforma 2D com fisica livre.

## Montagem do MVP

Antes de programar, o jogador ve uma bancada com encaixes para cabeca, corpo e locomocao. O MVP oferece apenas um conjunto compativel de pecas basicas; o jogador monta um unico Buneko, sem escolhas de estatistica ou equipamentos alternativos. A cabeca hospeda o cerebro de 5 RAM.

Os encaixes sao parte do MVP porque estabelecem a linguagem visual e tecnica para futuras pecas. Neste momento, montar as pecas basicas nao altera atributos.

## Movimento e fisica

O Buneko opera em uma plataforma lateral 2D com gravidade, colisao e impacto. Ele possui direcao atual, estado de apoio e velocidades de andar e correr. O executor solicita intencoes, e o controlador fisico decide o resultado permitido pelo ambiente.

- Andar produz movimento na direcao atual.
- Correr produz movimento mais rapido na direcao atual.
- Virar altera a direcao atual sem deslocar o Buneko.
- Pular funciona apenas enquanto apoiado no chao.
- Cair para fora da area jogavel causa falha de missao.

Valores de velocidade, altura de pulo, gravidade e tolerancias serao ajustados por prototipo; eles nao fazem parte desta PRD como numeros fixos.

## Extensibilidade

O nucleo deve expor capacidades de movimento e atributos de forma que futuras pecas possam modificarlos. O executor nao pode conhecer tipos concretos de peca, e pecas nao podem alterar diretamente a interface do editor de cerebro.

## Criterios de aceite

- O jogador monta o conjunto basico nos encaixes corretos antes da fase.
- O Buneko responde a andar, correr, virar e pular de acordo com a fisica.
- Pulo no ar nao produz novo impulso.
- Colisoes e queda para fora do nivel geram resultados consistentes.
- As regras de montagem e restricoes de movimento possuem testes automatizados; o comportamento fisico possui verificacao manual.
