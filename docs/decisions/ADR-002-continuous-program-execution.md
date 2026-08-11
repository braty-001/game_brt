# ADR 002: Execucao continua do programa

## Decisao

Durante uma fase, o programa do Buneko sera avaliado e executado continuamente, em vez de ser uma sequencia executada uma unica vez.

## Motivo

Isso permite comportamento reativo a sensores e abre caminho para missoes mais complexas no futuro.

## Consequencias

O executor precisa limitar instrucoes por atualizacao e disponibilizar pausa, parada, reinicio e diagnostico de programas que nao progridem.
