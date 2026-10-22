# Tarefas: PRD 016 - Combate e checkpoint

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../../../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

Status geral: comportamento automatizado, composicao reutilizavel de inimigos e deteccao frontal integrados ate 2026-09-14; aceite manual pendente.

Melhorias de peso, leitura de ataques/dano/derrota e demonstracao de ataque inimigo foram implementadas automaticamente nas [tarefas 018](018-character-readability-and-combat-weight-tasks.md). O aceite manual desta PRD permanece aberto.

Ordem: atualizar contratos; ampliar linguagem/editor por contexto; implementar regras deterministicas de vida/golpe; integrar Buneko/inimigos/nivel; ligar coleta-editor-checkpoint; testar fisica/IA/pausa/restauracao e suite completa.

Arquivos principais: dominio/runtime/editor de blocos; `src/campaign/combat/`; cena/script do laboratorio; `campaign_session.gd`, selecao e exemplos; testes de programacao e campanha.

Riscos: ultrapassar 10 RAM, dano duplicado ou atraves de piso, inimigo preso em borda, simulacao continuando durante edicao e perda do grafo na transicao do checkpoint.

- [x] Definir alcance, intervalo, preparacao e simultaneidade dos golpes.
- [x] Implementar vida, bastao e golpe unico por execucao.
- [x] Integrar Atacar, consultas visuais e requisitos de arma/capacidade.
- [x] Criar tres cerebros de patrulha/aproximacao/ataque sem busca persistente.
- [x] Integrar deteccao a oclusao 015.
- [x] Implementar coleta, pausa didatica, edicao e retomada do programa.
- [x] Restaurar checkpoint, vida/inimigos e preservar arma/programa na derrota.
- [x] Concluir a cobertura integrada: dano/contato/alcance/morte/pausa/AI/guardas e solucao completa de 10 RAM passam.
  - O grafo de referencia preserva 10 RAM e a regressao verifica explicitamente salto aceito, saida do chao e pouso durante a travessia.
  - A correcao permaneceu no exemplo da missao, sem mudar o runtime compartilhado.
- [x] Obter suite GUT verde e carregamento headless.
- [x] Extrair o personagem inimigo reutilizavel e manter cerebro, estado de combate e visual com responsabilidades separadas.
- [x] Declarar arquetipo, patrulhas e direcoes nos pontos de surgimento da cena do laboratorio.
- [x] Fazer sensores e resolucao simultanea de golpes dependerem apenas do contrato publico dos combatentes.
- [x] Cobrir configuracao, isolamento entre instancias, contrato de combate e regressao integral da missao.
- [x] Integrar o cone frontal compartilhado a deteccao de cada inimigo sem aplicar a geometria visual aos golpes.
- [x] Cobrir deteccao pela frente, aproximacao pelas costas, virada, perda de visao e regressao de simultaneidade/oclusao.
- [ ] Aceite manual: bater, esquivar, fugir sem matar, perder/retentar e conferir feedback.

## Melhoria de coleta aprovada em 2026-09-16

Execucao e aceite centralizados nas [tarefas 019](019-baton-pickup-and-mission-completion-tasks.md). Implementada e validada automaticamente em 2026-09-16; aceite manual pendente. Evidencias historicas desta lista permanecem preservadas.

## Resultado automatizado final de 2026-09-11 (historico)

- Godot 4.4.1 / GUT 9.4.0: 44 scripts, 243 testes e 1677 assercoes, todos aprovados com codigo 0.
- `test_combat_route_uses_exactly_ten_ram_kills_and_escapes_repeatedly` conclui as cinco repeticoes internas e comprova salto aceito, saida do chao, pouso, ao menos um inimigo derrotado e chegada com vida.
- Suite de campanha: 6 scripts, 40 testes e 850 assercoes, todos aprovados.
- Cena principal carregada em headless com codigo 0.
- `git diff --check` concluido sem erros.
- Nenhuma janela grafica foi aberta. Aceite visual e de sensacao de jogo permanece pendente.

## Evidencias direcionais de 2026-09-14

- Cada inimigo consulta visibilidade com sua propria posicao e direcao; um alvo atras permanece indetectado ate entrar no cone apos a virada.
- A resolucao de golpes usa uma consulta separada de linha desobstruida e preserva alcance/direcao do ataque, simultaneidade e bloqueio por parede/piso.
- O exemplo curto de combate passou a aproximar enquanto ve e atacar apenas ao alcance, usando 4/10 RAM; a rota integrada continua com exatamente 10/10 RAM.
- Testes focados de combate: 15 testes e 93 assercoes; campanha e suite completa passaram com os totais registrados nas tarefas 015.
