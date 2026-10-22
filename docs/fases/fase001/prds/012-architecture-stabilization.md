# PRD 012: Estabilizacao da Arquitetura do MVP

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../../../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

Status: concluida em 2026-09-04; validacao automatizada e smoke test visual aprovados.

## Problema

O loop completo do MVP esta funcional, mas os coordenadores de editor e tutorial acumulam responsabilidades e dependencias concretas. O comportamento esta coberto por testes, porem a estrutura atual aumenta o risco de regressao ao adicionar novas missoes, sensores, pecas ou apresentacoes.

## Objetivo

Preservar exatamente a experiencia atual enquanto o projeto passa a ter fronteiras explicitas entre estado do editor, comandos, apresentacao, fluxo de missao e sessao de tentativa.

## Escopo

- Tornar operacoes compostas do editor atomicas para estado e observadores.
- Substituir resultados de comando baseados em `Dictionary` por um contrato tipado.
- Impedir caminhos de mutacao do grafo fora do controlador de comandos.
- Remover dependencias do editor em adaptadores concretos do Buneko e em conteudo do tutorial.
- Extrair fluxo de missao e sessao de tentativa de `TutorialMission`.
- Mover hierarquias visuais estaveis para cenas quando isso reduzir construcao procedural e acoplamento.
- Criar CI para a suite GUT e normalizar metadados `.gd.uid`.
- Corrigir divergencias documentais encontradas na auditoria.

## Regras de preservacao

- O jogador continua seguindo montagem -> programacao -> tentativa -> resultado.
- Montagem e programa permanecem preservados ao voltar para editar.
- RAM continua limitada a 5 e cada bloco alcancavel continua custando 1 RAM.
- `IF`, `WHILE`, sensores, movimento, salto e feedback luminoso mantem a semantica atual.
- O runtime continua protegido contra execucao sem progresso.
- Nenhum sprite final e integrado nesta PRD.

## Criterios de aceite

- `BrainEditor` nao importa scripts de `tutorial` nem adaptadores concretos de `buneko/runtime`.
- Consumidores da missao nao leem labels, botoes ou colecoes internas do editor para obter seu estado.
- Insercao conectada com falha nao publica um bloco intermediario aos observadores.
- Toda alteracao do grafo usada pela aplicacao passa pelo controlador de comandos.
- Transicoes de missao passam por uma API de fluxo em vez de escrever o estado do avaliador diretamente.
- A sessao de tentativa concentra preparacao, tick, pausa, retomada, parada e espera de pouso.
- A suite automatizada completa passa e o projeto inicia em modo headless.
- Um smoke test manual confirma que o fluxo continua operavel depois da refatoracao. Os roteiros ampliados de usabilidade das PRDs 006 a 011 permanecem registrados nas tarefas correspondentes e nao sao considerados executados por este aceite.

## Fora do escopo

- Novas missoes, blocos, sensores, pecas ou progressao.
- Alteracao de fisica, dificuldade ou calibracao do tutorial.
- Persistencia, desfazer/refazer ou editor de fases.
- Integracao do concept art de Buneko como sprites.

## Riscos

- Perder estado ao trocar entre montagem, editor e tentativa.
- Reconectar sinais incorretamente durante a composicao de cenas.
- Alterar timing de runtime ou movimento sem intencao.
- Trocar testes por APIs publicas e deixar de cobrir uma integracao real.

## Resultado esperado

O MVP continua jogavel como antes, mas novas funcionalidades podem ser adicionadas por componentes e contratos locais, sem ampliar continuamente `BrainEditor` e `TutorialMission`.
