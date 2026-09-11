# PRD 013: Menu Inicial e Configuracoes de Tela

Status: concluida em 2026-09-04; validacoes automatizada e visual aprovadas.

Evolucao: PRD 014 envolve este menu numa raiz de navegacao para conduzir tutorial e campanha. Esta PRD registra a entrega original de menu/configuracoes; a nova integracao e validada nas tarefas 014.

## Problema

O jogo inicia diretamente na montagem do tutorial. Isso funciona para o MVP, mas nao oferece uma entrada clara para o jogador nem um lugar seguro para configuracoes compartilhadas pelas proximas missoes.

## Objetivo

Adicionar uma tela inicial simples, coerente com a identidade visual atual, com acesso ao tutorial existente e a configuracao persistente do tamanho da janela.

## Experiencia do jogador

Ao abrir o jogo, o jogador encontra o titulo `Buneko` e dois comandos principais:

- `Iniciar` abre o fluxo atual de montagem e tutorial.
- `Configuracoes` abre um painel na mesma tela para escolher o tamanho da janela.

O painel oferece `960x540`, `1440x810` e `1600x900`. `Aplicar` altera a janela e salva a escolha. `Voltar` retorna ao menu principal. Na proxima inicializacao, a escolha valida e reaplicada automaticamente.

## Regras

- A cena principal do projeto passa a ser o menu.
- `Iniciar` carrega `tutorial_mission.tscn` sem alterar o fluxo do tutorial.
- Somente resolucoes 16:9 explicitamente suportadas podem ser aplicadas.
- A resolucao padrao e `1600x900`.
- Preferencias sao armazenadas em `user://display_settings.cfg`.
- Arquivo ausente, corrompido ou com resolucao nao suportada usa o padrao sem impedir a inicializacao.
- A aplicacao de tamanho deve ser ignorada com seguranca pelo display headless usado nos testes.
- A interface usa o tema e os tokens visuais existentes.

## Criterios de aceite

- O jogo abre no menu inicial.
- `Iniciar` leva ao tutorial atual.
- `Configuracoes` alterna para o painel de resolucao e `Voltar` retorna ao menu.
- As tres resolucoes aparecem com rotulos claros.
- `Aplicar` persiste uma resolucao suportada.
- Uma nova instancia das configuracoes recupera o valor persistido.
- Configuracao invalida volta para `1600x900`.
- Menu e painel permanecem operaveis em `960x540`, `1440x810` e `1600x900`.
- Suite GUT completa e carregamento headless da nova cena principal passam.

## Fora do escopo

- Tela cheia, VSync, qualidade grafica ou selecao de monitor.
- Volume, idioma, controles ou acessibilidade avancada.
- Selecao de missoes, segunda missao, campanha ou save de progresso.
- Novos assets, sprites ou animacoes.

## Riscos

- O gerenciador de janelas pode posicionar ou limitar a janela de forma diferente entre sistemas.
- Alterar a cena principal pode esconder erros de navegacao que testes unitarios isolados nao capturam.
- Persistencia invalida nao pode bloquear o menu.
- O menor tamanho pode comprimir controles ou texto.

## Resultado esperado

O jogo passa a ter uma entrada reconhecivel e um primeiro ponto de configuracao reutilizavel. A futura selecao de missoes podera ser adicionada depois de `Iniciar`, sem acoplar configuracoes ao tutorial.
