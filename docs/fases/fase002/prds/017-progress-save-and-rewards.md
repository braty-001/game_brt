# PRD 017: Save de progresso e recompensas

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../../../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

Status: implementacao e validacao automatizada concluidas em 2026-10-20; aceite manual de fechamento/reabertura, interface e recompensa pendente. O usuario priorizou a entrega apos sua avaliacao jogavel das PRDs 018/019 e confirmou o plano e as escolhas do menu/saldo antes da implementacao.

## Objetivo e dados

Continuar campanha/checkpoint depois de fechar o jogo preservando dinheiro, montagem/capacidades de cabeca e corpo (incluindo locomocao), RAM concedida, arma, programa com parametros/condicoes/posicoes, missao, tutorial concluido, checkpoint e apresentacao vista.

## Regras

- Primeira chegada a saida paga 10; repeticoes nao pagam. Abates/preparacao nao pagam. Persistir dinheiro e primeira conclusao juntos.
- Reabrir no checkpoint restaura vida 10, bastao/ultimo programa e tres inimigos vivos nas posicoes iniciais; apresentacao nao repete.
- Antes da coleta, continuar do inicio. Preservar rascunhos invalidos mas bloquear execucao ate correcao.
- Persistir marcos e confirmacao/saida da edicao; preservar ultima edicao no fechamento normal sem depender exclusivamente da notificacao de sair.
- Arquivo versionado em user:// com escrita recuperavel/atomica e validacao de esquema/IDs; nunca carregar objetos executaveis arbitrarios.
- Ausente inicia jogo novo; corrompido/incompativel nao trava nem sobrescreve silenciosamente progresso recuperavel. Falha de escrita informa que nao salvou.
- Configuracoes de tela permanecem independentes.
- Com save valido, o menu oferece `Continuar` e `Novo jogo`. `Novo jogo` pede confirmacao explicita antes de substituir o progresso existente; cancelar preserva o save.
- A primeira vitoria mostra `+10 moedas` no painel de conclusao; vitorias seguintes informam que a recompensa ja foi recebida. A selecao da campanha mostra o saldo atual.

## Criterios, testes e riscos

Testar round-trip de montagem/grafo, ausente/corrompido/versao desconhecida, falha de escrita, recompensa unica, checkpoint, vida/inimigos restaurados, rascunho invalido, cancelamento/confirmacao de `Novo jogo` e saldo. Dados isolados para testes. Manual: fechar/reabrir antes/depois da coleta, editar/retomar, vencer duas vezes e conferir painel e saldo.

Riscos: perda de codigo, duplicacao de recompensa e IDs antigos. Save restaura ponto de retorno, nao simulacao no meio de um golpe (ADR 010).

## Plano tecnico para aprovacao

1. Definir contrato de dados versionado e serializacao validada para sessao, montagem por IDs conhecidos e grafo de blocos/conexoes/condicoes/parametros/posicoes. Alterar `campaign_session.gd` e adicionar um adaptador de persistencia em `braty/src/campaign/`; testar round-trip e rejeicao de dados malformados sem executar objetos carregados.
2. Integrar leitura e escrita recuperavel em `game_flow.gd`: carregar ao iniciar, salvar nos marcos e na ultima edicao, manter configuracoes de tela independentes. Integrar `campaign_selection.gd`, `tutorial_mission.gd` e `laboratory_mission.gd` somente nos pontos necessarios para capturar estado e primeira vitoria. Adicionar mensagem de falha de escrita visivel, sem afirmar progresso salvo quando houver erro.
3. Expor `Continuar` e `Novo jogo` com confirmacao no menu existente e restaurar checkpoint em processo novo com vida 10, bastao, programa e tres inimigos reiniciados. Nao persistir fisica/animacao no meio da tentativa. Persistir primeira conclusao e saldo de 10 juntos, impedindo pagamento duplicado. Exibir `+10 moedas` somente na primeira vitoria e saldo na selecao.
4. Cobrir em testes de `braty/tests/unit/campaign/` e `braty/tests/unit/menu/`: ausente, corrompido, versao incompativel, falha de escrita, rascunho invalido, checkpoint, continuacao e recompensa unica. Usar `user://` isolado nos testes; rodar a suite GUT completa, carregamento headless e `git diff --check`. Fazer aceite manual de fechamento/reabertura e dinheiro com autorizacao grafica nova.

Riscos de integracao: sobrescrever progresso recuperavel depois de uma leitura invalida; perder a ultima alteracao no editor; confiar em IDs ou parametros desconhecidos; salvar conclusao e dinheiro em operacoes separadas; fazer o menu anunciar continuacao quando o arquivo nao puder ser carregado. Confirmar arquivos finais, ordem, testes e riscos com o usuario antes de alterar comportamento.

## Evidencia de implementacao de 2026-10-20

- `campaign_save_codec.gd` codifica dados JSON versionados e valida montagem por IDs conhecidos, fase/RAM de campanha, grafo, condicoes, parametros, checkpoint, saldo e primeira conclusao. Rascunhos incompletos retornam ao editor sem liberar execucao.
- `campaign_save_store.gd` grava em arquivo temporario no mesmo diretorio e renomeia sobre o save; leitura invalida bloqueia novas gravacoes automaticas e preserva o arquivo ate confirmacao explicita de `Novo jogo`.
- `GameFlow`, menu, selecao e missao integram continuacao, nova campanha confirmada, salvamento nos marcos/edicoes, restauracao do checkpoint e recompensa unica. A primeira vitoria mostra `+10 moedas`; repeticoes indicam recompensa ja recebida; a selecao mostra saldo.
- Suite GUT completa apos o ajuste final: **45 scripts, 286 testes e 2073 assercoes**, todos aprovados, codigo 0, com dados de usuario isolados em `/tmp/buneko-prd017/`. Carregamento headless da cena principal e `git diff --check` aprovados. Testes cobrem ausente/corrompido/versao desconhecida, IDs invalidos, falha de escrita, rascunho, ultima edicao, checkpoint em novo `GameFlow`, nova campanha e idempotencia apos reabertura.
- Com autorizacao grafica explicita, uma janela local do Godot exibiu menu, selecao, painel de vitoria e dialogo de `Novo jogo`. Capturas em subviewports reais de 960x540, 1440x810 e 1600x900 foram inspecionadas; texto, saldo de 10 moedas, recompensa e botoes estavam legiveis e contidos. As capturas ficaram em `/tmp/buneko-prd017/visual-*.png` com dados de usuario isolados.
- Ainda falta o roteiro manual de fechar/reabrir o processo em cada marco, confirmar o dialogo por clique real, vencer duas vezes e avaliar mensagens de falha e sensacao de uso. A inspeção grafica dirigida e os testes automatizados nao estabelecem esse aceite.

## Fora do escopo

Cloud, perfis multiplos, loja/precos, missoes 1.2/1.3 e economia adicional.
