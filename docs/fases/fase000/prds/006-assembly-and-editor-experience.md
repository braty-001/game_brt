# PRD 006: Experiencia Visual de Montagem e Programacao

## Objetivo

Transformar a montagem e a programacao do Buneko em uma experiencia visual compreensivel, agradavel e diretamente ligada ao personagem. O jogador deve perceber que esta construindo um robo, instalando um cerebro e ensinando esse cerebro a agir, em vez de apenas clicar em botoes de uma ferramenta de debug.

## Problema observado

O prototipo funcional prova os contratos tecnicos, mas ainda nao comunica bem o jogo:

- A bancada apresenta as pecas apenas como botoes de texto e nao mostra o Buneko sendo montado.
- O editor abre como uma grande area cinza vazia, sem foco visual nem exemplo inicial.
- Objetivo, dica, paleta, RAM, validacao, parametros e controles competem pela atencao.
- Os blocos e suas conexoes nao deixam evidente por onde o programa comeca ou como o fluxo avanca.
- O jogador nao ve uma relacao forte entre a cabeca instalada, a memoria disponivel e o programa criado.
- Controles indisponiveis permanecem visiveis em excesso e parecem caminhos bloqueados.

## Experiencia desejada

O jogador entra em uma bancada com o Buneko no centro. Encaixes vazios indicam cabeca, corpo e locomocao, enquanto as pecas disponiveis ficam em uma bandeja lateral. Ao selecionar ou arrastar uma peca compativel, o encaixe reage, a peca aparece no personagem e um resumo mostra o que ela oferece. Quando a cabeca e instalada, a interface comunica que ela contem o cerebro de 5 RAM.

Depois da confirmacao, a camera/interface aproxima a ideia do cerebro e abre o editor. O objetivo permanece visivel em uma faixa compacta. A paleta separa acoes, controle e sensores; o ponto de inicio ja ocupa uma posicao clara; cada bloco tem portas identificaveis e linhas direcionais. O painel de propriedades aparece somente quando existe algo selecionado. Um unico comando principal conduz a tentativa, enquanto pausar, retomar e parar aparecem apenas quando forem relevantes.

O fluxo completo deve ser percebido como:

```text
Montagem  ->  Programacao  ->  Teste da tentativa  ->  Resultado
    ^                ^                    |
    +----------------+---- corrigir ------+
```

## Escopo

### 1. Bancada de montagem visual

- Mostrar uma representacao 2D completa do Buneko no centro da bancada.
- Exibir silhuetas ou encaixes visuais para cabeca, corpo e locomocao.
- Exibir pecas disponiveis em uma bandeja com nome, categoria e beneficio principal.
- Permitir instalar por clique e, quando confortavel no Godot, por arraste para o encaixe.
- Permitir selecionar uma peca instalada para inspecionar ou remover.
- Diferenciar visualmente os estados vazio, compativel, selecionado, instalado e invalido.
- Atualizar a representacao do Buneko imediatamente ao instalar ou remover uma peca.
- Mostrar progresso de montagem, como `2 de 3 pecas instaladas`.
- Explicar na cabeca base: `Cerebro basico - 5 RAM`.
- Manter `Confirmar montagem` como comando principal e habilita-lo apenas quando a montagem for valida.

### 2. Editor de cerebro reorganizado

- Criar uma barra superior compacta com etapa atual, objetivo da missao, RAM e estado do programa.
- Organizar a paleta por categorias: `Acoes`, `Controle` e `Sensores`.
- Usar cor e icone por categoria sem depender apenas da cor para identificacao.
- Manter um no `Inicio` permanente e visualmente distinto no workspace.
- Aplicar fundo de grade discreta e limites visuais para a area util de programacao.
- Representar blocos como nos legiveis, com titulo, parametro atual e portas nomeadas.
- Desenhar conexoes direcionais que partem da porta e chegam na entrada do bloco.
- Destacar uma porta compativel durante a criacao de conexao e explicar recusas no local da acao.
- Destacar o bloco selecionado e, durante a execucao, o bloco ativo.
- Mostrar o inspetor de parametros somente para blocos que possuem configuracao.
- Trocar a coluna de cinco controles sempre visiveis por uma barra contextual de execucao.
- Usar `Executar tentativa` como acao principal enquanto o programa estiver valido.
- Exibir validacao proxima ao problema e manter um resumo curto na barra superior.
- Preservar movimento, remocao, conexoes, parametros, RAM e runtime ja implementados pela PRD 004.

### 3. Orientacao e continuidade do fluxo

- Mostrar um indicador compacto das etapas `Montagem`, `Programacao` e `Teste`.
- Manter o objetivo da missao visivel sem sobrepor a area de trabalho.
- Oferecer uma dica contextual por vez, ligada ao proximo passo possivel.
- No primeiro acesso, indicar visualmente o no `Inicio` e a paleta de blocos.
- Quando um bloco for criado, orientar a conexao sem abrir modal ou interromper a edicao.
- Antes da primeira tentativa, confirmar que o programa valido sera executado pelo Buneko montado.
- Ao falhar, retornar ao editor com grafo e montagem preservados e destacar o ponto util para correcao.
- Permitir retornar a montagem antes da tentativa para revisar as pecas, sem perder o programa.

### 4. Fundacao visual reutilizavel

- Criar um tema Godot para cores, tipografia, espacamentos, botoes, paineis e estados de foco.
- Definir tokens visuais para fundo, superficie, texto, destaque, sucesso, alerta e erro.
- Usar componentes reutilizaveis para cabecalho de etapa, botao principal, paineis e feedback.
- Reservar espaco para arte final sem acoplar regras de dominio aos assets temporarios.
- Usar formas simples e assets placeholder consistentes para o Buneko e suas pecas.
- Adicionar transicoes curtas de instalacao, selecao e troca de etapa, sem atrasar comandos.
- Preparar sinais para efeitos sonoros de encaixe, conexao, erro e confirmacao; audio final nao e obrigatorio nesta PRD.

## Layout de referencia

### Montagem

```text
+ Etapa 1/3: Montagem ---------------- Objetivo resumido --------+
| Pecas disponiveis |          Buneko          | Peca selecionada |
| [Cabeca base]     |        [ CABECA ]        | Cabeca base      |
| [Corpo base]      |        [ CORPO  ]        | Cerebro: 5 RAM   |
| [Locomocao base]  |        [ PERNAS ]        | [Remover]        |
|                   |                          |                  |
| 2/3 instaladas    |             [Confirmar montagem]           |
+---------------------------------------------------------------+
```

### Programacao

```text
+ Etapa 2/3: Programacao --- 0/5 RAM --- Programa incompleto ----+
| Acoes/Controle |                                               |
| [Andar]        | [Inicio] -> [Enquanto: buraco a frente]       |
| [Pular]        |                  | corpo -> [Pular]            |
| [IF] [WHILE]   |                  + depois -> [Andar]           |
|----------------|                                               |
| Dica atual     |                                               |
+----------------+-------------------------------+---------------+
| Propriedades do bloco selecionado              | [Executar]    |
+---------------------------------------------------------------+
```

O layout e uma referencia de hierarquia, nao uma exigencia de medidas fixas.

## Regras de interacao

- Toda acao principal deve ter apenas um proximo passo visualmente dominante.
- Botoes desabilitados devem ser usados somente quando a indisponibilidade ensina uma regra; controles de estados futuros devem ficar ocultos.
- Clique continua sendo uma alternativa completa ao arraste para montagem e criacao de blocos.
- A interface nao pode depender de hover para comunicar informacao essencial.
- Textos devem caber em 1152x648 e em uma janela reduzida de referencia de 960x540.
- Foco por teclado, contraste e estado selecionado devem permanecer perceptiveis.
- A interface nao deve cobrir blocos, portas ou conexoes com mensagens persistentes.

## Criterios de aceite

- Um jogador novo identifica visualmente onde cabeca, corpo e locomocao serao instalados.
- Instalar ou remover uma peca altera imediatamente a representacao do Buneko.
- O jogador entende que a cabeca fornece o cerebro e o limite de 5 RAM.
- O jogador distingue objetivo, paleta, workspace, propriedades e comando principal sem sobreposicao.
- O no `Inicio`, a direcao das conexoes e as saidas de `IF` e `WHILE` sao compreensiveis sem explicacao externa.
- Criar, mover, conectar, configurar e remover blocos continua funcional.
- O comando de executar a tentativa fica evidente quando o programa e valido.
- Falha retorna ao editor preservando montagem e programa.
- O layout funciona em 1152x648 e 960x540 sem texto ou controles sobrepostos.
- A suite automatizada existente continua passando e os novos estados deterministicos possuem testes.
- Um roteiro manual com uma pessoa que nao participou da implementacao consegue completar montagem e iniciar uma tentativa sem orientacao verbal.

## Fora do escopo

- Arte final, animacao complexa do personagem, narrativa, loja, economia e upgrades compraveis.
- Novas pecas com efeitos de gameplay; a interface fica pronta para recebe-las, mas usa apenas as pecas base.
- Persistencia entre sessoes, desfazer/refazer, zoom, copiar/colar e editor de fases.
- Redesenho da linguagem, do calculo de RAM ou da semantica do runtime.
- Suporte completo a controle ou telas sensiveis ao toque nesta etapa.

## Dependencias e riscos

- A PRD depende das regras de montagem da PRD 003, do grafo da PRD 004 e do fluxo da PRD 005.
- A interface atual e criada majoritariamente por script; o refinamento deve mover composicao visual estavel para cenas sem duplicar regras.
- Assets placeholder podem limitar a avaliacao estetica, por isso a verificacao deve priorizar hierarquia, compreensao e resposta da interface.
- Arraste e conexoes precisam ser verificados manualmente em diferentes tamanhos de janela.
- O fluxo real de `Executar tentativa` deve usar o orquestrador da missao, e nao apenas o runtime isolado do editor.

## Resultado esperado

Ao concluir esta PRD, o prototipo continua sendo um MVP, mas ja apresenta a fantasia central do jogo: montar um Buneko visivel, instalar seu cerebro, programar seu comportamento e observar a tentativa. A interface deixa de parecer uma tela tecnica temporaria e passa a sustentar testes reais de compreensao e diversao.
