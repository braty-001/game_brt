# Tarefas: PRD 014 - Selecao e preparacao

Status geral: implementacao e validacao automatizada concluidas em 2026-09-09; aceite manual pendente.

- [x] Registrar escopo e ADR 010 antes do codigo.
- [x] Parametrizar RAM em calculo, validacao, runtime, paineis e pseudocodigo; padrao 5.
- [x] Criar catalogo/estado e briefing com minimapa aproximado, objetivo e checkpoint.
- [x] Reutilizar editor com 10 RAM e confirmacao; preservar rascunho ao navegar.
- [x] Integrar conclusao tutorial/campanha via raiz de navegacao preservando montagem/programa.
- [x] Cobrir 5/6 e 10/11, erros estruturais, pseudocodigo e runtime.
- [x] Cobrir desbloqueio, navegacao real, preservacao e tres tamanhos.
- [x] Executar suite completa, carregamento headless e git diff --check.
- [ ] Aceite manual: concluir tutorial, ler briefing/legenda, editar com 10, apagar/reconectar, confirmar, voltar pelo menu e conferir preservacao. Repetir layout/clique/arraste em 960x540, 1440x810 e 1600x900.

Headless nao comprova usabilidade. Entrega termina na preparacao; fechar processo ainda encerra estado da campanha.

Retorno do usuario em 2026-09-09: selecao e mapa do laboratorio aprovados visualmente. Edicao completa com 10 RAM e preservacao permanecem sem aceite manual explicito. A PRD 015 acrescenta entrada no percurso jogavel.

## Resultado automatizado

- Godot 4.4.1 / GUT 9.4.0: 40 scripts, 210 testes e 1008 assercoes aprovados, processo encerrado com codigo 0.
- Cena principal `res://scenes/campaign/game_flow.tscn` carregou em headless e encerrou com codigo 0; continua apresentando o menu inicial.
- `git diff --check` sem erros.
- Testes novos: limites de RAM/diagnosticos/pseudocodigo/runtime; tutorial -> campanha -> editor -> menu por sinais; rascunhos invalidos e montagem preservados; controles, gaveta com rolagem e pseudocodigo acessiveis nos tres viewports.
- Correcao de layout: detalhes do inspetor rolam na preparacao; gaveta/pseudocodigo flutuam fora do recorte do canvas. Tutorial mantem o modo anterior.
- Nenhuma janela grafica foi aberta nesta implementacao. Validacao manual acima continua pendente.

## Como testar esta entrega

1. Abrir `braty/project.godot` e executar o projeto (F6 na cena tutorial isolada nao exercita a raiz de navegacao; usar F5).
2. Iniciar, montar Buneko, carregar um exemplo valido e concluir o tutorial.
3. Conferir briefing e legenda das tres areas aproximadas de inimigos; ler aviso da pausa especial.
4. Preparar cerebro; observar contador com 10 RAM, editar/apagar/reconectar, abrir gaveta e pseudocodigo. Confirmar retorna ao briefing.
5. Voltar ao menu e usar Campanha; conferir rascunho preservado na sessao. A PRD 015 permite entrar no percurso apos confirmar; combate/checkpoint da 016 estao integrados parcialmente, enquanto save em disco ainda aguarda a 017.
