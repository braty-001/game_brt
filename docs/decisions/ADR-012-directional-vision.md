# ADR 012: Visao frontal direcional compartilhada

## Decisao

A visao de Bunekos usa um cone frontal de 120 graus, com alcance de 240 unidades e meio angulo de 60 graus em torno da direcao atual do observador.

- Alvos exatamente nas duas bordas angulares pertencem ao cone; alvos logo fora ou atras nao pertencem.
- Virar o observador atualiza imediatamente sensores e apresentacao.
- Paredes e pisos continuam ocluindo a visao.
- Sensores e neblina consomem a mesma geometria e nao guardam memoria de exploracao.
- Cada NPC avalia visao com sua propria posicao e direcao.
- A linha de oclusao usada na resolucao de golpes permanece independente do cone. Alcance, altura e direcao frontal do golpe continuam definidos pelo contrato de combate.

## Motivo

O alcance circular permitia perceber alvos atras do personagem e comunicava pouco a importancia de orientacao, patrulha e aproximacao. Uma unica geometria direcional para consulta e neblina mantem o comportamento programavel observavel e evita divergencia entre aquilo que o jogador ve e aquilo que os sensores respondem.

Separar visao de oclusao de golpes evita que uma mudanca de apresentacao ou percepcao altere implicitamente combate ja aprovado.

## Consequencias

- `OccludedVision` passa a conhecer direcao frontal e meio angulo, alem de alcance e oclusores.
- A fronteira aberta do cone precisa ser desenhada sem frestas na neblina e redesenhada ao mover ou virar.
- Consultas de caminho, degrau, objetivo e inimigo continuam usando a visao da PRD 015.
- Deteccao inimiga depende da orientacao atual, permitindo aproximacao pelas costas enquanto o alvo permanecer fora do cone.
- Testes cobrem ambas as direcoes, bordas inclusivas, pontos logo fora, costas, oclusao e igualdade entre sensor e neblina.

Complementa ADRs 010 e 011 e se aplica as PRDs 015 e 016.
