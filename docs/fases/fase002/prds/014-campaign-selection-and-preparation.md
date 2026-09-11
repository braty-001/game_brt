# PRD 014: Selecao da campanha e preparacao

Status: implementacao e validacao automatizada concluidas em 2026-09-09; aceite manual pendente nas tarefas 014.

## Objetivo e experiencia

Concluir tutorial leva a selecao da campanha. Jogador consulta missao 1, Escapar do laboratorio, e prepara o cerebro com 10 RAM antes da futura entrada no nivel.

## Escopo e regras

- Raiz de navegacao compoe menu/tutorial/campanha por sinais; tutorial continua com 5 RAM.
- Conclusao libera campanha na sessao; falha nao libera.
- Briefing mostra objetivo de escapar (abates opcionais), recompensa unica de 10, tres inimigos aproximados (1 embaixo, 2 em cima), bastao/checkpoint, inicio/saida a esquerda e escada a direita.
- Minimap e esquema com regioes de possivel presenca e legenda, sem coordenadas exatas.
- Aviso explica pausa especial da primeira coleta para adaptar programa e retorno ao checkpoint apos derrota.
- Editor existente recebe 10 RAM; confirmar preparacao nao executa simulacao isolada.
- Na preparacao, detalhes do inspetor podem rolar em telas pequenas; comandos de voltar/zerar e confirmacao permanecem acessiveis. O canvas mantem pan/zoom.
- Gaveta e pseudocodigo da preparacao ficam em sobreposicoes fora do recorte do canvas; se excederem a altura da janela, permitem rolagem. Esta adaptacao complementa a PRD 011 para o novo espaco de preparacao.
- Montagem e programa do tutorial sao preservados. Jogador pode reaproveitar, apagar e substituir.
- Voltar preserva rascunho incompleto; confirmar exige programa valido. Dez blocos alcancaveis aceitos, onze recusados; pseudocodigo segue mesmo limite.
- Voltar pelo menu na sessao reabre campanha. Save entre processos pertence a 017.

## Limite desta entrega

Confirmar preparacao retorna ao briefing. A PRD 015 acrescenta entrada no percurso do laboratorio, exemplo proprio e consultas visuais por contexto; combate depende de 016. Briefing informa disponibilidade nesta versao; nunca executar tutorial como se fosse laboratorio. Preparacao nao concede dinheiro.

## Arquivos e ordem

1. Docs da fase e ADR 010.
2. Parametrizar program_ram_calculator, program_validator, program_runtime, paineis, pseudocodigo e brain_editor.
3. Catalogo/estado e cenas em src/campaign e scenes/campaign.
4. Raiz de navegacao, sinal de conclusao do tutorial e entrada do projeto.
5. Testes e validacao.

## Criterios de aceite e testes

- Menu -> tutorial -> conclusao -> selecao, com montagem/grafo preservados, sem importar campanha no editor.
- Briefing fiel e operavel em 960x540, 1440x810 e 1600x900.
- Voltar/reabrir editor/menu preserva blocos, condicoes, parametros, conexoes e posicoes.
- Cobrir 5/6 e 10/11 RAM, erros estruturais com 10, pseudocodigo, runtime, confirmacao e navegacao por sinais.
- Suite GUT e carregamento headless passam; aceite manual de layout/clique/arraste obrigatorio.

## Riscos e fora do escopo

Divergencia entre limites, perda de grafo ao liberar cenas e controles comprimidos. Combate, nevoa jogavel, persistencia, pagamento e loja pertencem a outras entregas.
