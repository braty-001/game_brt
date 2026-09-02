# PRD 011: Linguagem Visual do Cerebro e Pseudocodigo

## Objetivo

Transformar o cerebro em uma linguagem visual mais legivel e expressiva, preservando a liberdade de arrastar blocos e introduzindo um canvas navegavel, insercao por gaveta lateral, formas distintas de controle e uma visualizacao opcional de pseudocodigo.

## Problema

Cartoes retangulares iguais tornam `IF`, `WHILE` e acoes parecidos demais. A paleta fixa reduz a area de trabalho, e o jogador nao possui uma segunda leitura simples do programa que acabou de montar. A linguagem precisa ganhar identidade sem criar uma segunda interpretacao do programa.

## Experiencia desejada

O workspace ocupa a maior parte da tela. Uma barra horizontal compacta acima do canvas separa criacao (`Blocos`, `Organizar`, `Codigo`) de navegacao (`Mover`, zoom e `Centralizar`) com rotulos explicitos. `Blocos` abre uma gaveta por categoria; o jogador pode clicar para inserir na saida selecionada ou arrastar um item para um encaixe visivel. Ele ainda pode mover os blocos livremente depois.

`IF` aparece como uma bifurcacao com duas pontas: a positiva usa verde e icone `✓`; a alternativa usa coral e icone `×`. Os ramos mantem sempre a mesma posicao relativa. `WHILE` comunica repeticao por um contorno ou retorno integrado, com corpo abaixo e saida `Depois` lateral. Acoes continuam simples e sequenciais.

Um botao `Ver pseudocodigo` abre uma visualizacao somente leitura do programa atual em portugues. Fechar o painel retorna imediatamente ao workspace, sem alterar o grafo.

## Regras de comportamento

- A gaveta lateral fica fechada por padrao, mostra todos os blocos atuais sem rolagem e nao reduz permanentemente o workspace.
- A barra do canvas usa nomes explicitos para acoes; o simbolo `+` fica reservado ao aumento de zoom.
- O canvas possui pan e zoom limitado entre 60% e 160%, com botoes `-`, `+`, percentual e `Centralizar`.
- A janela padrao usa 1600x900, permanece redimensionavel e preserva o layout funcional nos alvos menores.
- Posicoes dos blocos continuam no espaco do grafo; zoom e pan sao transformacoes visuais e nunca alteram conexoes, RAM ou semantica.
- O cerebro usa um canvas vetorial hibrido: grade e conexoes sao desenhadas por primitivas do canvas; blocos e portas sao views que obedecem ao mesmo sistema de coordenadas do grafo.
- Inserir por clique exige uma saida selecionada; inserir por arraste destaca somente encaixes compativeis.
- Clicar em uma saida vazia abre a gaveta diretamente no contexto daquela saida.
- Remover um bloco apenas remove o bloco e suas conexoes; o editor nao presume substituicao nem reconecta o fluxo automaticamente.
- Ramos e corpos podem permanecer vazios durante a edicao, ainda que o programa incompleto nao possa ser executado.
- O jogador pode continuar arrastando blocos existentes para organizar sua leitura.
- Cor nunca e a unica indicacao de ramo: `✓` e `×`, posicao fixa e tooltip explicam a bifurcacao.
- `IF` continua usando portas logicas `true` e `false`; a nova forma nao muda runtime, validador ou serializacao.
- `WHILE` continua usando `body` e `next`; a representacao do retorno e visual, nao uma conexao arbitraria nova.
- O pseudocodigo e derivado exclusivamente de `EditorGraphState` e nao e editavel.
- O pseudocodigo usa termos em portugues: `SE`, `SENAO`, `ENQUANTO`, acoes e condicoes localizadas.

## Direcao de extensibilidade

O dominio da linguagem nao deve depender do formato visual atual. Cada tipo de bloco recebe uma definicao de apresentacao com categoria, formato, icones, portas exibidas e formatacao de pseudocodigo. Futuras pecas e missoes podem liberar acoes como `Atirar`, `Bomba` ou `Soco` pela paleta, sem criar um editor separado para combate ou plataforma.

## Limite desta refatoracao

Esta PRD altera somente o cerebro: o estado visual do grafo, seu canvas, suas interacoes e seus paineis locais. Nao altera montagem, personagem, fase, RAM, runtime, persistencia ou tema global do jogo.

## Criterios de aceite

- O jogador reconhece acao, decisao e repeticao sem ler texto tecnico longo.
- `IF` apresenta ramos positivo e alternativo com cor, icone e posicao consistentes.
- `WHILE` deixa claro corpo repetido e saida posterior.
- Gaveta lateral permite inserir todos os blocos atuais por clique ou arraste.
- `Ver pseudocodigo` reproduz exatamente o grafo atual e nao permite edicao.
- Mover blocos depois da insercao preserva conexoes e leitura visual.
- Os exemplos do tutorial permanecem validos e compreensiveis em 960x540, 1440x810 e 1600x900.
- Zoom e pan preservam o arraste, as portas e as setas no ponto visual correspondente.

## Fora do escopo

- Tela inicial, selecao de modo, campanha ou laboratorio.
- Novas acoes de combate, pecas de combate ou novas fisicas.
- Edicao de pseudocodigo, conversao de texto para blocos ou comentarios no codigo.
- Persistencia, desfazer/refazer, copiar e colar, zoom infinito ou minimapa.

## Dependencias e riscos

- Depende da PRD 010 para que layout e renderizacao nao quebrem a semantica.
- Formas muito decorativas podem esconder portas; cada formato precisa manter pontos de entrada e saida grandes e previsiveis.
- Insercao por clique e arraste precisa ter o mesmo resultado no modelo.
- Pseudocodigo de fluxo incompleto deve comunicar validacao em vez de inventar estrutura inexistente.

## Resultado esperado

O cerebro parece uma ferramenta criativa de programacao: gostoso de arrastar, claro de ler, consistente de executar e preparado para ganhar novas acoes sem perder sua linguagem visual.
