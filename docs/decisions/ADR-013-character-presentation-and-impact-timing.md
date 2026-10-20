# ADR 013: Apresentacao do corpo proprio e tempo de impacto

Status: implementada automaticamente em 2026-09-14; aceite manual da apresentacao ainda pendente.

## Contexto

As PRDs 015/016 compartilham visao entre sensores e neblina e resolvem combate/checkpoint em tempo de simulacao. O cone encobre partes do proprio personagem e o feedback minimo impede observar golpes e derrota. A PRD 018 precisa alterar apresentacao sem conceder percepcao extra e introduzir pausas curtas sem quebrar runtime, simultaneidade ou restauracao.

## Decisao proposta

- Separar a visibilidade do corpo/arma do jogador da visibilidade do mundo. Apenas seu visual e reacoes locais podem ficar acima da mascara no laboratorio; objetos, inimigos, corpos inimigos e sensores conservam cone/oclusao da ADR 012.
- Apresentacao consome fases reais e resultados confirmados de combate por contratos pequenos. Animacao, som e efeitos nao escolhem alvos nem aplicam dano.
- Uma pausa de impacto comeca depois de todo o lote simultaneo ser resolvido. Runtime, IA, fisica e golpes suspendem juntos; um relogio independente encerra a pausa, mantendo interface responsiva.
- O coordenador da tentativa controla suspensao/restauracao. Um personagem ou efeito nao altera sozinho o tempo global. Qualquer escala modificada deve ser restaurada exatamente ao valor anterior.
- Pausa manual prevalece sobre fim de efeito. Editor, checkpoint, encerramento e troca de cena cancelam efeitos/callbacks pendentes; nao podem retomar uma tentativa encerrada.
- Derrota logica e imediata. Apresentacao da derrota do Buneko tem uma janela curta antes do retorno atual; durante ela nao ha execucao ou combate. Corpos inimigos podem persistir visualmente sem voltar a ser combatentes.
- Peso inicial modifica somente visual e audio. Aceleracao, gravidade, impulso e recuo fisico exigem calibracao posterior explicitamente planejada.
- Espelhamento por direcao pertence ao no visual dos personagens. Nao aplicar escala X negativa ao `CharacterBody2D`: a decomposicao da transformacao apos movimento fisico pode inverter o desenho em viradas posteriores. Correcao aprovada e incorporada em 2026-09-16, preservando direcao logica, sensores e colisoes.

## Consequencias

A ADR 012 continua governando percepcao do mundo. A excecao do corpo proprio deve ser testada sem ampliar sensores ou revelar inimigos. A ADR 010 conserva vida, dano, ciclo, simultaneidade e conteudo do checkpoint; a PRD 018 acrescenta apenas a janela de apresentacao anterior ao retorno.

Os detalhes e parametros iniciais estao na [PRD 018](../fases/fase002/prds/018-character-readability-and-combat-weight.md). A pausa de impacto implementada nesta PRD usa relogio monotono e suspensao explicita da simulacao, sem alterar `Engine.time_scale`. A [ADR 015](ADR-015-visible-danger-time-cue.md) registra separadamente a breve desaceleracao posterior da PRD 020 ao Buneko ver um inimigo. Aceite visual e sonoro permanece distinto de testes automatizados. A decisao nao inclui nova camera, audicao jogavel ou refatoracao de cerebros NPC.
