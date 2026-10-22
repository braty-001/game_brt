# Buneko

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](docs/godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

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

## Como jogar

### Primeira partida

1. No menu principal, clique em **Iniciar**. Em **Configuracoes**, você pode ajustar o tamanho da janela.
2. Na montagem, clique nas peças para instalar **cabeça, corpo e locomoção**. Depois clique em **Confirmar montagem**.
3. No editor do cérebro, use **Carregar exemplo** para começar com um programa que você pode estudar e modificar. Essa opção substitui o programa atual.
4. Observe as conexões a partir de **INICIO** e o indicador de RAM. Ajuste os blocos e corrija os problemas indicados pela validação.
5. Clique em **Executar tentativa** e observe o Buneko. Durante a fase, ele se movimenta pelas instruções do programa, sem controle direto pelo teclado.
6. Use **Pausar** e **Retomar** para observar a execução. **Parar e editar** permite revisar a estratégia. Conclua o tutorial para acessar a campanha.

### Montando seu próprio programa

- Abra **Blocos** para adicionar instruções. Selecione uma saída vazia para inserir um bloco conectado; para ligar blocos existentes, selecione a saída de um e a entrada do outro.
- Use ações como andar, pular e virar. Selecione o bloco para ajustar os parâmetros disponíveis no painel de propriedades.
- Use **IF** para decidir com base em uma condição e **WHILE** para repetir enquanto a condição for verdadeira. As condições consultam os sensores disponíveis, como caminho livre, buraco ou objetivo visível.
- Acompanhe o custo de RAM e os avisos de validação antes de executar. Blocos soltos não fazem parte do caminho de execução iniciado em **INICIO**.
- Use **Organizar** para arrumar os blocos e **Código** para consultar o pseudocódigo. **Mover**, os botões de zoom e **Centralizar** ajudam a navegar pelo editor.
- O botão **×** remove um bloco. **Zerar cerebro** remove todos os blocos e conexões; use quando quiser recomeçar.

### Primeira missão: escapar do laboratório

1. Na seleção da campanha, leia o objetivo e a planta. As marcações dos inimigos indicam posições aproximadas.
2. Clique em **Preparar cerebro / 10 RAM**, ajuste o programa e use **Confirmar preparo**. Depois escolha **Entrar no laboratorio**.
3. O percurso começa no andar inferior, à esquerda. Suba pelas plataformas à direita e alcance a saída no andar superior, à esquerda. Eliminar os inimigos é opcional.
4. Ao coletar o bastão, a simulação fica suspensa e aparece **Bastao adquirido!**. Leia a explicação e clique em **Editar cerebro** para continuar o preparo.
5. Com o bastão, ficam disponíveis **Atacar** e condições de inimigo visível ou ao alcance. Confirme o programa e entre novamente para continuar do checkpoint.
6. Após uma derrota no checkpoint, o Buneko recupera a vida e conserva bastão e programa; os três inimigos voltam às posições iniciais. O programa recomeça do início.
7. Ao chegar à saída, o painel **Missao concluida!** oferece **Voltar a selecao** e **Rever cerebro**.

O Buneko só percebe o que está dentro de sua visão frontal e sem bloqueio por paredes ou pisos. Considere a direção para a qual ele está virado ao programar condições de visão.

**Progresso da sessão:** o save persistente ainda não foi implementado. Não conte com a recuperação da campanha ou do checkpoint depois de fechar o jogo.

## Desenvolvimento com agentes

O **Godot MCP e obrigatorio** para desenvolvimento e validacao do Godot assistidos por agentes. Configure o servidor `godot` e confirme `get_godot_version` e `get_project_info` antes de trabalhar no motor. Consulte o [guia de instalacao e uso](docs/godot-mcp.md) e a [ADR 016](docs/decisions/ADR-016-required-godot-mcp.md).

Essa integracao e uma ferramenta de desenvolvimento; executar o jogo como jogador e rodar a suite GUT no CI continuam usando Godot diretamente.

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
