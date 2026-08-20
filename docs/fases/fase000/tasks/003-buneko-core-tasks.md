# Tarefas: PRD 003 - Buneko Basico, Montagem e Fisica

Status geral: concluido. PRDs 001 e 002 ja entregam o dominio da linguagem e do executor; esta PRD adicionou o nucleo do Buneko, a montagem basica e a ponte entre runtime e fisica.

## Ordem de implementacao

1. Modelo de montagem e atributos.
2. Interface de intencoes e adaptador para o executor.
3. Controlador fisico testavel do Buneko.
4. Cena visual jogavel do Buneko.
5. Bancada de montagem.
6. Integracao com runtime, editor e fase tutorial.

## Modificacoes planejadas

- [x] Criar o dominio de pecas, encaixes e montagem unica do MVP.
  - Arquivos previstos:
    - `braty/src/buneko/domain/part_slot.gd`
    - `braty/src/buneko/domain/buneko_part.gd`
    - `braty/src/buneko/domain/buneko_assembly.gd`
    - `braty/src/buneko/domain/buneko_assembly_validator.gd`
    - `braty/src/buneko/domain/base_buneko_parts.gd`
  - Regras:
    - O MVP possui exatamente tres encaixes: cabeca, corpo e locomocao.
    - Cada encaixe aceita somente uma peca compativel com seu slot.
    - A montagem so fica completa com os tres slots preenchidos.
    - A cabeca base representa o cerebro inicial de 5 RAM, sem alterar o modelo de RAM da PRD 001.
  - Aceite:
    - Cabeca, corpo e locomocao aceitam apenas a peca base compativel.
    - Montagem incompleta impede seguir para a programacao.
    - Peca instalada no slot errado gera erro de validacao claro.
  - Testes:
    - `braty/tests/unit/buneko/domain/test_buneko_assembly.gd`
    - Compatibilidade por slot.
    - Montagem incompleta.
    - Montagem completa.
    - Troca/remocao de peca preservando consistencia.

- [x] Expor atributos basicos do Buneko sem criar equipamentos ou upgrades jogaveis.
  - Arquivos previstos:
    - `braty/src/buneko/domain/buneko_attributes.gd`
    - `braty/src/buneko/domain/buneko_attribute_resolver.gd`
  - Regras:
    - Atributos iniciais incluem velocidade de andar, velocidade de correr, impulso de pulo, gravidade e forca.
    - Os valores podem ser ajustados por prototipo, mas devem existir em um ponto unico de resolucao.
    - Pecas futuras poderao modificar atributos sem alterar o executor ou o editor de cerebro.
  - Aceite:
    - A montagem base resolve um conjunto de atributos valido.
    - O runtime continua enviando apenas acoes; nao conhece atributos nem pecas concretas.
  - Testes:
    - `braty/tests/unit/buneko/domain/test_buneko_attributes.gd`
    - Resolucao dos atributos base.
    - Extensao por modificador de peca simulado.

- [x] Definir a interface de intencoes entre programa e fisica.
  - Arquivos previstos:
    - `braty/src/buneko/runtime/buneko_motor.gd`
    - `braty/src/buneko/runtime/buneko_action_dispatcher.gd`
  - Regras:
    - `ProgramBlockKind.WALK` solicita andar.
    - `ProgramBlockKind.RUN` solicita correr.
    - `ProgramBlockKind.JUMP` solicita pular.
    - `ProgramBlockKind.TURN` solicita virar.
    - O dispatcher retorna `ActionDispatchResult.YIELDED` quando a intencao foi aceita para a simulacao.
    - Pulo recusado por falta de apoio nao deve quebrar o programa; deve ser uma acao sem impulso fisico.
  - Aceite:
    - Andar, correr, virar e pular ficam separados da logica do executor.
    - O executor nao depende de cenas Godot nem de `CharacterBody2D`.
  - Testes:
    - `braty/tests/unit/buneko/runtime/test_buneko_action_dispatcher.gd`
    - Traducao de cada bloco de acao.
    - Direcao preservada no motor.
    - Pulo com e sem permissao.

- [x] Implementar o controlador fisico do Buneko.
  - Arquivos previstos:
    - `braty/src/buneko/physics/buneko_physics_controller.gd`
    - `braty/src/buneko/physics/buneko_character.gd`
  - Regras:
    - O controlador mantem direcao atual, velocidade atual, estado de apoio e queda.
    - Andar aplica velocidade horizontal na direcao atual.
    - Correr aplica velocidade horizontal maior que andar.
    - Virar inverte direcao sem deslocamento direto.
    - Pular aplica impulso somente quando apoiado.
    - A fisica decide o resultado permitido por gravidade, colisao e ambiente.
  - Aceite:
    - O Buneko responde a andar, correr, virar e pular de acordo com a fisica.
    - Pulo no ar nao produz novo impulso.
    - Colisoes e queda para fora do nivel geram resultados consistentes.
  - Testes:
    - `braty/tests/unit/buneko/physics/test_buneko_physics_controller.gd`
    - Direcao inicial e inversao.
    - Intencao de andar/correr produz velocidade esperada.
    - Pulo so e aceito quando apoiado.
  - Verificacao manual:
    - Executar cena de teste e validar movimento, impacto, bordas e queda.

- [x] Criar a cena visual jogavel do Buneko.
  - Arquivos previstos:
    - `braty/scenes/buneko/buneko.tscn`
    - `braty/scenes/buneko/buneko_test_stage.tscn`
  - Regras:
    - A cena usa `CharacterBody2D`, colisao e um visual placeholder legivel.
    - A orientacao visual acompanha a direcao atual.
    - Propriedades fisicas ficam exportadas para ajuste de prototipo.
    - A cena de teste contem chao, parede/borda simples e area de queda.
  - Aceite:
    - O personagem tem comportamento de plataforma consistente na fase teste.
    - Queda fora da area jogavel emite sinal ou estado consumivel pela missao.
  - Verificacao:
    - Movimento observavel para andar e correr.
    - Virar sem deslocamento inesperado.
    - Pulo no chao e tentativa de pulo no ar.
    - Colisao com chao e bordas.
    - Queda abaixo da area jogavel.
  - Status: cena inicial criada e validada por teste headless de carregamento e intencoes. Inspecao visual fina permanece como polimento futuro.

- [x] Criar a bancada de montagem e fluxo para seguir ao editor de cerebro.
  - Arquivos previstos:
    - `braty/src/buneko/assembly/assembly_slot_view.gd`
    - `braty/src/buneko/assembly/assembly_bench.gd`
    - `braty/scenes/buneko/assembly_bench.tscn`
  - Regras:
    - A bancada mostra tres encaixes: cabeca, corpo e locomocao.
    - O MVP oferece apenas as pecas basicas correspondentes.
    - O jogador pode encaixar, remover e confirmar a montagem.
    - Confirmar fica bloqueado ate a montagem estar completa.
  - Aceite:
    - O jogador enxerga e instala o conjunto basico antes de programar.
    - O fluxo entrega uma montagem valida para o proximo passo.
  - Verificacao manual:
    - Encaixar cada peca.
    - Tentar confirmar montagem incompleta.
    - Remover e reinstalar peca.
    - Confirmar montagem completa.

- [x] Integrar Buneko, runtime e sensores necessarios para a PRD 005.
  - Arquivos previstos:
    - `braty/src/buneko/runtime/buneko_sensor_reader.gd`
    - ponto de composicao da tentativa da missao, a definir na PRD 004/005.
  - Regras:
    - O runtime usa `BunekoActionDispatcher` para comandar o personagem.
    - O leitor de sensores observa o mundo por contrato pequeno, sem acoplar o editor a cenas.
    - Condicoes visuais necessarias ao tutorial, como buraco a frente e objetivo, ficam preparadas para a PRD 005.
  - Aceite:
    - A tarefa pendente da PRD 002, "Integrar o executor ao adaptador de fisica do Buneko", pode ser concluida.
    - Falha por queda pode chamar `ProgramRuntime.fail_externally()` durante uma tentativa.
  - Testes:
    - Testes unitarios com dublas para leitura de sensores.
    - Integracao leve do dispatcher com motor falso.
  - Verificacao manual:
    - Programa simples com andar move o Buneko.
    - Programa com virar altera direcao.
    - Programa com pular so salta quando apoiado.

## Dependencias e limites

- A PRD 003 depende dos contratos ja existentes em `braty/src/programming/runtime/`.
- A bancada pode ser implementada antes do editor final da PRD 004, mas o botao de seguir deve expor um sinal ou metodo simples para o fluxo futuro.
- A geometria definitiva do buraco, objetivo final e roteiro tutorial pertencem a PRD 005.
- Nao implementar equipamentos alternativos, upgrades jogaveis, economia, persistencia ou editor de fases nesta PRD.

## Criterio para declarar a PRD 003 concluida

- [x] Todos os testes unitarios novos passam junto com a suite existente.
- [x] O Buneko base pode ser montado em tres encaixes e confirmado.
- [x] Um `ProgramRuntime` consegue acionar andar, correr, virar e pular por meio do dispatcher do Buneko.
- [x] A cena de teste demonstra gravidade, colisao, pulo bloqueado no ar e queda fora da area jogavel.
- [x] As verificacoes da PRD 003 estao cobertas por testes headless ou registradas como polimento visual futuro.
