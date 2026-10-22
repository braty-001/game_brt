# Tarefas: PRD 009 - Sinal Luminoso de Acao do Buneko

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../../../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

Status geral: implementado para validacao visual. Acompanhar e `NEXT` foram removidos; a cabeca do Buneko recebe pulsos luminosos por mudanca de acao e recusa. Falta validar manualmente contraste e ritmo na fase.

## Ordem de implementacao

1. Remover Acompanhar e `NEXT` do editor e da fase.
2. Simplificar o fluxo de runtime da missao para executar somente tentativas normais.
3. Adicionar estado temporario de luz ao visual do Buneko.
4. Disparar a luz por mudanca de acao ou recusa.
5. Cobrir remocao, transicoes e fisica com testes.
6. Validar visualmente ritmo, contraste e legibilidade na fase.

## Modificacoes planejadas

- [x] Remover o modo Acompanhar.
  - Arquivos previstos:
    - `braty/src/brain_editor/brain_editor.gd`
    - `braty/src/tutorial/tutorial_mission.gd`
    - `braty/src/programming/runtime/program_runtime.gd`
    - testes de editor, runtime e tutorial afetados.
  - Regras:
    - Remover `FollowButton`, `NextButton`, sinais e estado de acompanhamento.
    - `Executar tentativa` continua sendo o unico inicio de fase.
    - Pausar, retomar, parar e voltar preservam o comportamento atual.
  - Aceite:
    - Nenhum controle ou caminho de Acompanhar permanece visivel ou referenciado.
    - A tentativa normal volta a executar sem pausas automaticas.
  - Status: concluido; sinais, botoes, estado de acompanhamento e caminho de runtime foram removidos.

- [x] Criar pulso luminoso na cabeca do Buneko.
  - Arquivos previstos:
    - `braty/src/buneko/visual/buneko_visual.gd`
    - `braty/src/buneko/visual/buneko_simple_parts.gd`
    - `braty/src/buneko/physics/buneko_character.gd`
    - testes visuais ou de cena afetados.
  - Regras:
    - Expor uma chamada simples para iniciar um pulso por tipo de feedback.
    - O efeito deve ter duracao fixa curta, voltar ao visual neutro e sobreviver a redraws.
    - O desenho permanece procedimental e localizado na cabeca.
  - Aceite:
    - Cada cor aparece e desaparece de forma previsivel.
    - O efeito nao altera colisao, escala, direcao ou fisica do Buneko.
  - Status: concluido no `BunekoVisual`; o halo procedimental dura `0.18 s` e volta ao visual neutro.

- [x] Conectar transicoes do runtime ao pulso.
  - Arquivos previstos:
    - `braty/src/tutorial/tutorial_mission.gd`
    - `braty/src/programming/runtime/program_runtime.gd`
    - `braty/src/buneko/physics/buneko_character.gd`
    - testes de runtime e fluxo tutorial afetados.
  - Regras:
    - Comparar a acao efetiva atual com a anterior.
    - Ignorar repeticoes consecutivas de `Andar` e outras acoes iguais.
    - Disparar vermelho para acao recusada.
  - Aceite:
    - `WHILE -> Andar` nao pisca repetidamente.
    - `Andar -> Pular -> Andar [rapido]` produz pulsos coerentes sem mudar a trajetoria.
    - Pulo fora do chao produz pulso vermelho.
  - Status: concluido; `TutorialMission` observa acao efetiva e recusa sem alterar o runtime ou a fisica.

- [x] Atualizar documentacao de movimento.
  - Arquivos previstos:
    - `docs/fases/fase000/prds/008-brain-and-responsive-movement.md`
    - `docs/fases/fase000/tasks/008-brain-and-responsive-movement-tasks.md`
    - `docs/fases/fase000/tasks/000-mvp-tasks.md`
  - Regras:
    - Registrar que Acompanhar foi substituido por sinal luminoso.
    - Remover roteiro e criterios de `NEXT`.
  - Aceite:
    - PRD 008 nao contradiz a PRD 009.
  - Status: concluido.

- [ ] Validar PRD 009.
  - Testes automatizados:
    - Executar suite GUT completa. Concluido: 35 scripts, 188 testes e 752 assercoes em 2026-09-04.
    - Cobrir remocao de controles, transicoes de acao e acao recusada.
  - Verificacao manual:
    - Executar `WHILE caminho livre -> Andar` e verificar ausencia de flicker.
    - Executar transicao para `Pular` e depois `Andar [rapido]` e verificar luzes coerentes com movimento normal.
    - Forcar pulo no ar e verificar luz vermelha.
    - Retornar ao editor e iniciar nova tentativa para verificar reset visual.

## Criterio para declarar a PRD 009 concluida

- Acompanhar e `NEXT` foram removidos sem quebrar a tentativa normal.
- Mudancas de acao e recusas recebem pulso luminoso legivel.
- Repeticao de `WHILE` nao gera poluicao visual.
- O efeito nao muda a fisica nem a ordem do programa.
- Suite automatizada passa e validacao manual aprova contraste e ritmo.
