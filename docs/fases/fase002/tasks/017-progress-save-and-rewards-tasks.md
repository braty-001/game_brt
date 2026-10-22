# Tarefas: PRD 017 - Save e recompensas

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../../../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

Status geral: implementacao e validacao automatizada concluidas em 2026-10-20; aceite manual pendente, conforme evidencias na PRD.

- [x] Definir esquema/serializacao de estado, capacidades e grafo.
- [x] Implementar leitura validada, escrita recuperavel e erros.
- [x] Integrar marcos de tutorial/preparacao/checkpoint/edicao/conclusao.
- [x] Continuar pelo menu e restaurar checkpoint em processo novo.
- [x] Oferecer `Novo jogo` com confirmacao antes de substituir save valido; cancelar preserva progresso.
- [x] Conceder 10 uma unica vez junto da conclusao persistida.
- [x] Mostrar `+10 moedas` na primeira vitoria, recompensa ja recebida nas seguintes e saldo atual na selecao.
- [x] Cobrir round-trip, invalidade, falhas/versoes e idempotencia.
- [x] Rodar suite completa e carregamento em dados isolados: 45 scripts, 286 testes, 2073 assercoes, codigo 0 em 2026-10-20.
- [x] Inspecionar menu, selecao, vitoria e dialogo em janela Godot; capturas de 960x540, 1440x810 e 1600x900 com dados isolados.
- [ ] Aceite manual: fechar/reabrir em cada marco, ultimo programa, vida 10, inimigos e recompensa unica.
