# ADR 001: Modelo inicial de RAM

## Decisao

O cerebro do Buneko inicia com 5 unidades de RAM. Cada bloco presente no programa consome 1 unidade de RAM.

## Motivo

O limite cria desde o tutorial uma restricao legivel e estimula programas compactos. Cobrar igualmente por cada bloco deixa a regra simples de entender e permite que estruturas como repeticao economizem espaco quando apropriado.

## Consequencias

O editor deve mostrar o total usado e impedir ou sinalizar programas que excedam o limite. Aumento de RAM sera uma via de progressao futura.
