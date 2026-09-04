# Tarefas: PRD 013 - Menu Inicial e Configuracoes de Tela

Status geral: concluido em 2026-09-04; validacoes automatizada e visual aprovadas.

## Ordem de implementacao

1. Registrar experiencia, escopo e limites.
2. Implementar catalogo e persistencia das resolucoes.
3. Criar a composicao estavel do menu em cena.
4. Ligar navegacao e aplicacao das configuracoes.
5. Alterar a cena principal.
6. Cobrir regras e integracao com testes.
7. Validar headless e solicitar teste visual ao usuario.

## Modificacoes planejadas

- [x] Registrar PRD 013 e tarefas antes do codigo.

- [x] Implementar configuracoes de tela.
  - Criar `braty/src/settings/display_settings.gd`.
  - Oferecer somente `960x540`, `1440x810` e `1600x900`.
  - Salvar e carregar `user://display_settings.cfg`.
  - Recuperar com o padrao quando os dados forem invalidos.
  - Nao chamar operacoes de janela no display headless.
  - Resultado: `DisplaySettings` concentra catalogo, rotulos, persistencia, fallback e aplicacao segura das tres resolucoes.

- [x] Criar menu inicial.
  - Criar `braty/scenes/menu/main_menu.tscn`.
  - Criar `braty/src/menu/main_menu.gd`.
  - Compor menu principal e painel de configuracoes na cena.
  - Reutilizar `buneko_theme.tres` e `BunekoDesignTokens`.
  - Resultado: a hierarquia estavel fica em `main_menu.tscn`; o script apenas vincula controles, estilos e acoes.

- [x] Integrar navegacao.
  - `Iniciar` carrega a missao tutorial atual.
  - `Configuracoes` e `Voltar` alternam paineis sem trocar de cena.
  - `Aplicar` atualiza o resumo e persiste a escolha.
  - `braty/project.godot` passa a iniciar pelo menu.
  - Resultado: o menu e a nova cena principal e `Iniciar` agenda a troca para `tutorial_mission.tscn`.

- [x] Adicionar testes.
  - Cobrir catalogo, rotulos, persistencia e fallback.
  - Cobrir estrutura do menu, alternancia dos paineis e pedido de inicio.
  - Cobrir layout de referencia em `960x540`.
  - Resultado: 9 testes novos e 31 assercoes cobrem configuracoes e menu.

- [x] Validar automaticamente a PRD 013.
  - Executar testes focados.
  - Executar suite GUT completa.
  - Carregar a nova cena principal em headless.
  - Executar `git diff --check`.
  - Resultado em 2026-09-04: 37 scripts, 197 testes e 783 assercoes passaram; a nova cena principal carregou em headless.

- [x] Validar visualmente a PRD 013.
  - Abrir `Configuracoes`, aplicar cada uma das tres resolucoes e confirmar que o menu continua operavel.
  - Reiniciar o jogo e confirmar que a resolucao escolhida foi preservada.
  - Usar `Iniciar` e confirmar que o tutorial atual abre normalmente.
  - Resultado em 2026-09-04: o usuario executou o teste manual e aprovou a experiencia do menu e das configuracoes.

## Criterio para conclusao

- O jogo inicia pelo menu e preserva o tutorial existente.
- Configuracoes validas persistem e dados invalidos possuem fallback.
- Testes automatizados e carregamento headless passam.
- A operacao visual das tres resolucoes e confirmada manualmente.
