# Buneko

Jogo 2D de plataforma e programação feito em **Godot 4.4.1 com GDScript**. Você monta um Buneko, programa seu cérebro com blocos e observa como ele resolve a missão. O personagem executa o programa: o jogador ajusta a lógica e a montagem entre as tentativas.

## Como funciona

1. Leia o objetivo e prepare o Buneko.
2. Conecte ações e condições no editor visual de cérebro.
3. Execute o programa e observe o resultado.
4. Volte ao editor para corrigir a estratégia e tente novamente.

O orçamento de memória faz parte do desafio: o tutorial oferece **5 RAM** e a primeira missão da campanha oferece **10 RAM**. Cada bloco alcançável custa uma unidade; parâmetros e condições selecionados dentro de um bloco não custam RAM adicional.

## Estado do projeto

O projeto está em desenvolvimento e já inclui:

- Tutorial com montagem, editor visual e execução contínua do programa.
- Menu principal, configurações de tela e seleção/preparação da campanha.
- Missão de fuga de um laboratório com plataformas, visão direcional e três inimigos.
- Combate corpo a corpo, coleta de bastão e checkpoint mantido durante a sessão.
- Painéis de coleta e conclusão, com navegação por escolha do jogador.
- Testes automatizados de domínio e integração com GUT e workflow no GitHub Actions.

O aceite manual ampliado da interface, física e apresentação de combate ainda está pendente nas listas de tarefas. Testes automatizados não substituem essa validação.

**Ainda planejados:** persistência do progresso e recompensa única (PRD 017), loja, upgrades compráveis, audição jogável e recursos avançados opcionais de programação. O checkpoint atual não representa um save persistente.

## Executar localmente

Instale o **Godot 4.4.1**, versão padrão com suporte a GDScript. O projeto usa o renderizador Forward Plus. Os comandos abaixo pressupõem que o executável `godot` esteja disponível no `PATH`.

```bash
git clone https://github.com/braty-001/game_brt.git
cd game_brt
godot --editor --path braty
```

Também é possível importar `braty/project.godot` pelo gerenciador de projetos do Godot e executar com **F6 para a cena atual** ou **F5 para o jogo completo**. Para iniciar diretamente pelo terminal:

```bash
godot --path braty
```

Execute os comandos a partir da raiz do repositório. A raiz do projeto Godot é **`braty/`**.

## Testes

O **GUT 9.4.0** já está incluído em `braty/addons/gut`; não é necessário instalá-lo separadamente.

Suíte completa, sem abrir janela:

```bash
godot --headless --path braty \
  -s addons/gut/gut_cmdln.gd \
  -gdir=res://tests/unit -ginclude_subdirs -gexit
```

Verificação de carregamento da cena principal:

```bash
godot --headless --path braty --quit-after 2
```

O [workflow de testes](.github/workflows/godot-tests.yml) executa essas verificações com Godot 4.4.1 em pushes e pull requests.

## Estrutura

```text
braty/
  project.godot       Projeto Godot
  scenes/            Cenas e composição das telas
  src/               Domínio, execução, personagens e interface
  tests/unit/        Testes automatizados
  addons/gut/        Framework de testes
docs/
  foundations.md     Fundamentos e regras do projeto
  fases/             PRDs e listas de tarefas por fase
  decisions/         Decisões de arquitetura (ADRs)
  backlog.md         Ideias e capacidades futuras
```

## Documentação e contribuição

- [Fundamentos do projeto](docs/foundations.md)
- [Campanha: entregas, estado e decisões](docs/fases/fase002/README.md)
- [Coleta do bastão e conclusão da missão](docs/fases/fase002/prds/019-baton-pickup-and-mission-completion.md)
- [Tarefas e validação manual dessa entrega](docs/fases/fase002/tasks/019-baton-pickup-and-mission-completion-tasks.md)
- [Backlog](docs/backlog.md)
- [Decisões de arquitetura](docs/decisions/)
- [Instruções de trabalho no repositório](AGENTS.md)

Antes de mudar comportamentos, consulte os fundamentos, a PRD, a lista de tarefas e as ADRs correspondentes. Atualize a documentação e aprove o escopo antes da implementação. Mantenha regras determinísticas testáveis e registre separadamente a validação automatizada e o aceite manual.
