# PRD 017: Save de progresso e recompensas

Status: escopo aprovado; implementacao futura apos integracao 014 a 016.

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

## Criterios, testes e riscos

Testar round-trip de montagem/grafo, ausente/corrompido/versao desconhecida, falha de escrita, recompensa unica, checkpoint, vida/inimigos restaurados e rascunho invalido. Dados isolados para testes. Manual: fechar/reabrir antes/depois da coleta, editar/retomar, vencer duas vezes e conferir dinheiro.

Riscos: perda de codigo, duplicacao de recompensa e IDs antigos. Save restaura ponto de retorno, nao simulacao no meio de um golpe (ADR 010).

## Fora do escopo

Cloud, perfis multiplos, loja/precos, missoes 1.2/1.3 e economia adicional.
