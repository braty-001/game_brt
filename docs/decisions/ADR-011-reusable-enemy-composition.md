# ADR 011: Composicao reutilizavel de inimigos

## Decisao

Inimigos de combate serao compostos por contratos pequenos, sem depender do laboratorio que os instancia:

- o personagem reutilizavel concentra ciclo de vida, locomocao e adaptacao entre cerebro e combate;
- o cerebro permanece uma regra deterministica independente de cena;
- atributos variaveis ficam exportados na cena do arquetipo, sem constantes de missao no personagem;
- apresentacao visual fica em um no filho substituivel;
- pontos de surgimento declaram cena, patrulha e direcao inicial na cena do nivel;
- sensores e resolucao de golpes consomem apenas o contrato publico do combatente, sem acessar estado interno de vida, arma ou controlador;
- o nivel continua responsavel por composicao, equipes, oclusao e ordem do passo fisico.

Um novo tipo de inimigo deve reutilizar esses contratos e fornecer apenas as variacoes reais de configuracao, cerebro ou apresentacao. Nao sera criada uma hierarquia de classes para variacoes ainda inexistentes.

## Motivo

O primeiro inimigo foi implementado como `LaboratoryEnemy` e reuniu regra, fisica, desenho e detalhes da missao. O nivel tambem passou a conhecer campos internos de Buneko e inimigos e a declarar patrulhas por tuplas no script. Isso impede reutilizar o mesmo arquetipo em outra cena sem copiar integracao e aumenta o risco de divergencia entre sensores, ataques e estado de derrota.

## Consequencias

- A PRD 016 preserva exatamente os atributos e comportamentos atuais.
- Novas cenas podem posicionar e configurar o arquetipo patrulheiro sem alterar seu script.
- Resolver golpes simultaneos continua sendo responsabilidade de um coordenador reutilizavel chamado pelo nivel.
- Buneko e inimigos expõem o mesmo contrato minimo de combate, apesar de manterem locomocoes e decisoes diferentes.
- Arte, novos tipos de inimigo, perseguicao, audicao e armas adicionais continuam fora do escopo.

Complementa ADRs 009 e 010.
