# PRD 001: Linguagem de Programacao por Blocos

## Objetivo

Definir a linguagem visual minima que permite ao jogador descrever o comportamento autonomo do Buneko dentro de 5 RAM.

## Modelo mental

O jogador conecta blocos para formar um fluxo. Ao iniciar a missao, o executor percorre esse fluxo continuamente. Os blocos de controle escolhem ou repetem caminhos; os blocos de acao fazem o Buneko agir no mundo fisico.

## Blocos do MVP

- `Andar`: movimenta o Buneko na direcao para a qual ele esta voltado.
- `Correr`: movimenta o Buneko na direcao atual com maior velocidade.
- `Pular`: aplica um pulo quando o Buneko esta apoiado no chao.
- `Virar`: inverte a direcao atual do Buneko.
- `IF`: avalia uma condicao e direciona o fluxo para o ramo verdadeiro ou falso.
- `WHILE`: continua executando seu ramo enquanto a condicao for verdadeira.

Cada bloco colocado consome 1 RAM. O ponto inicial, as conexoes e os parametros de um bloco nao consomem RAM. O programa nao pode ultrapassar 5 RAM.

## Sensores e condicoes

`IF` e `WHILE` possuem uma condicao selecionavel. A condicao combina modalidade e consulta, permitindo uma interface generica como `visao: ha buraco a frente?` ou `audicao: ouviu sinal?`.

O MVP deve suportar pelo menos condicoes visuais necessarias para o tutorial, incluindo caminho livre a frente, percepcao do buraco a frente e percepcao do objetivo. Audicao deve existir como tipo de condicao selecionavel, mesmo que a primeira fase use apenas uma fonte simples de som ou apenas demonstre sua indisponibilidade de forma clara. Consultas e alvos futuros devem poder ser adicionados sem modificar os blocos de controle.

## Regras de fluxo

- Um programa possui exatamente um ponto de inicio.
- A execucao segue conexoes de fluxo validas.
- `IF` tem saidas verdadeira e falsa; ambas podem ficar vazias.
- `WHILE` possui uma saida de corpo e uma saida para continuar apos a repeticao.
- Ao terminar o fluxo conectado ao corpo de `WHILE`, a execucao retorna implicitamente para reavaliar a condicao. Essa volta nao usa uma conexao visual nem permite ciclo arbitrario.
- Ciclos arbitrarios por conexao nao sao permitidos no MVP; repeticao deve usar `WHILE`.
- Um bloco desconectado nao faz parte do programa executavel e nao consome RAM ate ser conectado ao fluxo de inicio.
- Parametros invalidos e conexoes incompletas tornam o programa invalido e impedem sua execucao.

## Fora do escopo

- Variaveis, funcoes criadas pelo jogador, numeros, operadores logicos compostos e blocos personalizados.
- Sensores de tato, cheiro e memoria persistente.
- Custos de RAM diferentes por tipo de bloco.

## Criterios de aceite

- Um programa conectado calcula corretamente o consumo de RAM e bloqueia execucao acima de 5.
- O jogador pode expressar comportamento de movimento, pulo, troca de direcao, condicao e repeticao.
- Condicoes de visao e audicao sao representadas por seletores, sem criar um bloco de sensor separado.
- Programas sem inicio, com conexoes invalidas ou com ciclos arbitrarios recebem erro claro.
- As regras de validacao e RAM possuem testes automatizados.
