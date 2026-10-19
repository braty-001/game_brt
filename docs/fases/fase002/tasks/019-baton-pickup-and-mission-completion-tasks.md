# Tarefas: PRD 019 - Coleta do bastao e conclusao perceptiveis

Status: 019-01 a 019-04 concluidas em 2026-09-16; 019-05 (aceite manual) pendente.

Fonte de verdade: [PRD 019](../prds/019-baton-pickup-and-mission-completion.md).

## 019-01 - Contratos e aprovacao

- [x] Conferir `master`/`5b4d8ed` e preservar documentacao local de FUT-001/ADR 014.
- [x] Ler foundations, PRDs/listas pertinentes e ADRs 010/013.
- [x] Apresentar comportamento, arquivos, ordem, testes e riscos; obter aprovacao para implementar.
- [x] Criar PRD/lista dedicadas e consolidar referencias em 015/016/indice.

## 019-02 - Apresentar a coleta

- [x] Compor painel responsivo, titulo, explicacao e botao `Editar cerebro` na cena.
- [x] Suspender a tentativa na coleta real; aguardar escolha e bloquear controles ao fundo.
- [x] Cancelar efeitos temporais, impedir retomada e emitir navegacao apenas uma vez.
- [x] Preservar grafo, capacidades e checkpoint sem repetir introducao na reentrada.

## 019-03 - Apresentar conclusao e navegacao

- [x] Mostrar vitoria apenas em `escaped`, mantendo diagnosticos dos outros resultados.
- [x] Oferecer `Voltar a selecao` e `Rever cerebro` via sinais para GameFlow.
- [x] Preservar estado da sessao e impedir transicoes duplicadas.
- [x] Definir foco inicial e navegacao de teclado; manter controles ao fundo indisponiveis.

## 019-04 - Validacao automatizada

- [x] Coleta real, espera sem progresso/dano, confirmacao unica, desbloqueio e reentrada sem introducao.
- [x] Vitoria pela rota real, resultado persistente, falhas sem vitoria e ambas as escolhas finais.
- [x] Confirmar preservacao de grafo/montagem/checkpoint no fluxo integrado e ausencia de callbacks residuais.
- [x] Verificar limites dos paineis/textos/botoes e foco nas tres resolucoes suportadas.
- [x] Rodar testes focados, suite completa, cinco repeticoes de combate/fuga em 10 RAM, carregamento headless e `git diff --check`.
- [x] Atualizar status/documentacao com numeros e limites da evidencia obtida.

## 019-05 - Aceite manual

- [ ] Obter nova autorizacao antes de abrir/focar janela, capturar imagens ou interagir com GUI.
- [ ] Em 960x540, 1440x810 e 1600x900: coletar, ler sem pressa, confirmar com mouse/teclado e retomar com bastao.
- [ ] Conferir mundo visivel ao fundo, controles bloqueados, foco claro e textos/botoes sem cortes.
- [ ] Concluir percurso e usar as duas opcoes finais, identificando claramente a vitoria.
- [ ] Registrar aceite do usuario sobre perceptibilidade e ritmo; se distancia da coleta ainda incomodar, propor calibracao separada.

Conclusao: CA-01 a CA-06 automatizados e CA-07 aceito manualmente. Execucao headless nunca marca 019-05 como concluida.

## Evidencias automatizadas de 2026-09-16

Snapshot: `master`, HEAD `5b4d8ed`, alteracoes locais desta entrega e documentos FUT-001/ADR 014 preservados. Nenhum novo commit ou publicacao nesta execucao.

- Campanha: 6 scripts, 66 testes e 1077 assercoes, todos aprovados, codigo 0. Log: `/tmp/buneko-prd019/campaign-final.log`.
- Suite completa: 44 scripts, 272 testes e 1962 assercoes, todos aprovados, codigo 0. Log: `/tmp/buneko-prd019/full.log`.
- Cinco repeticoes reais da rota de combate/fuga em exatamente 10 RAM e dez repeticoes da referencia de percurso mantidas.
- Coleta real aguarda escolha sem progresso/dano, bloqueia controles ao fundo e abre editor uma vez; reentrada conserva arma e nao repete o painel.
- Ambas as escolhas finais preservam grafo/montagem/checkpoint. Queda, programa invalido, fim prematuro e guarda nao mostram vitoria. A restauracao apos derrota nao mostra introducao.
- Pausa de impacto anterior a coleta e cancelada sem retomada atras do painel.
- Limites do painel, textos, botoes e foco verificados em SubViewports de 960x540, 1440x810 e 1600x900, para coleta e vitoria. Isso nao comprova aparencia nem usabilidade.
- Carregamento da cena principal em headless aprovado, codigo 0; log `/tmp/buneko-prd019/load.log`. `git diff --check` aprovado.
- A primeira rodada encontrou esperas de teste anteriores ao passo fisico e corte do painel de coleta em 960x540. As esperas passaram a observar o resultado com limite de quadros; a descricao foi encurtada, preservando capacidades e checkpoint. As rodadas finais acima passaram.
- Nenhuma janela grafica, captura ou interacao de desktop foi executada. O aceite 019-05 permanece aberto.

Comandos finais (raiz do repositorio; diretorios temporarios previamente criados):

```bash
XDG_DATA_HOME=/tmp/buneko-prd019/data XDG_CONFIG_HOME=/tmp/buneko-prd019/config /home/braty/projetos/godot/godot --headless --path braty -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit/campaign -ginclude_subdirs -gexit
XDG_DATA_HOME=/tmp/buneko-prd019/data XDG_CONFIG_HOME=/tmp/buneko-prd019/config /home/braty/projetos/godot/godot --headless --path braty -s addons/gut/gut_cmdln.gd -gdir=res://tests/unit -ginclude_subdirs -gexit
XDG_DATA_HOME=/tmp/buneko-prd019/load-data XDG_CONFIG_HOME=/tmp/buneko-prd019/load-config /home/braty/projetos/godot/godot --headless --path braty --quit-after 10
git diff --check
```
