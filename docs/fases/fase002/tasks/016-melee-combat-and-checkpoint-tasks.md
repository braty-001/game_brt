# Tarefas: PRD 016 - Combate e checkpoint

Status geral: implementacao parcial integrada em 2026-09-11. Componentes e fluxos focados passam; rota completa de 10 RAM, suite verde e aceite manual pendentes.

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
- [ ] Concluir a cobertura integrada: dano/contato/alcance/morte/pausa/AI/guardas passam; a solucao completa de 10 RAM ainda termina antes da saida.
- [ ] Obter suite GUT verde. O carregamento headless e `git diff --check` ja passam.
- [ ] Aceite manual: bater, esquivar, fugir sem matar, perder/retentar e conferir feedback.

## Resultado automatizado de 2026-09-11

- Godot 4.4.1 / GUT 9.4.0: 44 scripts, 239 testes e 1645 assercoes.
- 238 testes aprovados e 1 teste reprovado; processo encerrado com codigo 1.
- O unico teste reprovado e `test_combat_route_uses_exactly_ten_ram_kills_and_escapes_repeatedly`: nas cinco repeticoes internas, o resultado foi `finished` em vez de `escaped`, aproximadamente em `x=643`, no piso superior.
- Os outros 10 testes de `test_laboratory_combat.gd` passam, incluindo checkpoint, capacidades, dano, simultaneidade, oclusao, contato inofensivo, restauracao e pausa.
- Cena principal carregada em headless com codigo 0; `git diff --check` sem erros.
- Nenhuma janela grafica foi aberta. Aceite visual e de sensacao de jogo permanece pendente.
