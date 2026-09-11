# PRD 002: Executor Continuo do Programa

## Objetivo

Executar com seguranca o programa visual do Buneko em uma fase de fisica livre, convertendo blocos em acoes e reavaliando a logica continuamente.

## Comportamento

O ciclo principal do executor e implicito e nao consome RAM. Ele comeca no ponto inicial do programa e volta a avaliacao continuamente enquanto a missao estiver ativa. Acoes de movimento devem ser aplicadas por intervalos de simulacao, permitindo que `WHILE` mantenha uma acao ativa por repeticao e que sensores sejam reavaliados conforme o mundo muda.

`Andar` usa a direcao atual do Buneko e encaminha seu ritmo configurado para o adaptador fisico. `Virar` troca essa direcao. `Pular` so produz efeito quando a fisica informar que o Buneko pode saltar. O dispatcher recebe o bloco de acao completo para preservar parametros sem acoplar o executor a detalhes da cena.

## Estados

- Editando: programa pode ser alterado e validado.
- Pronto: programa valido, aguardando inicio.
- Executando: programa e fisica estao ativos; a interface mostra o bloco ou ramo atual quando possivel.
- Pausado: a simulacao e o executor ficam suspensos e podem ser retomados, interrompidos ou reiniciados.
- Parado: a tentativa foi interrompida pelo jogador e retorna a edicao.
- Falhou: o jogo exibe a mensagem de falha e retorna a edicao preservando programa e montagem.
- Concluido: o objetivo foi alcancado e o resultado e exibido.

## Seguranca

O executor deve limitar instrucoes consecutivas sem progresso de simulacao. Ao atingir o limite, a tentativa e interrompida com diagnostico de execucao excessiva, sem congelar o jogo. Um `WHILE` deve ceder a simulacao entre iteracoes que produzem acao; condicoes que nao produzem progresso tambem estao sujeitas ao limite.

## Integracoes

O executor recebe uma abstracao de estado do mundo para ler sensores e uma abstracao de acoes para comandar o Buneko. Ele nao deve depender diretamente de cenas, controles visuais ou detalhes do nivel.

A PRD 014 acrescenta capacidade de RAM explicita ao runtime, mantendo 5 como padrao. A composicao fornece a mesma capacidade ao editor e ao executor (ADR 010).

## Criterios de aceite

- Um programa valido inicia, pausa, retoma, para e reinicia sem perder integridade.
- Acoes respeitam direcao atual, estado de apoio e simulacao fisica.
- `IF` escolhe o ramo correto e `WHILE` repete enquanto sua condicao for verdadeira.
- O jogo permanece responsivo diante de repeticao infinita ou fluxo sem progresso.
- Falha retorna ao editor com uma mensagem e preserva a configuracao atual.
- A interpretacao deterministica possui testes automatizados, incluindo protecao contra execucao excessiva.
