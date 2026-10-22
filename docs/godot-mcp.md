# Godot MCP obrigatorio

Obrigatorio desde 2026-10-22 para desenvolvimento, investigacao e validacao do Godot assistidos por agentes, conforme [ADR 016](decisions/ADR-016-required-godot-mcp.md). A integracao nao altera regras do jogo nem substitui GUT ou aceite manual.

## Regra de trabalho

1. No inicio do trabalho com Godot, confirmar que o cliente disponibiliza o servidor `godot` e chamar `get_godot_version` e `get_project_info` com o caminho absoluto de `braty/`. Registrar resultado e eventual bloqueio na entrega.
2. Usar o MCP nas operacoes Godot que ele suporta e que fazem parte do escopo autorizado: consulta de projeto, manipulacao de cenas e diagnosticos de execucao. Edicao de GDScript, Git e suite GUT continuam usando suas ferramentas proprias.
3. Para executar o jogo ou abrir o editor, anunciar a acao e obter autorizacao grafica nova antes de `run_project` ou `launch_editor`. A obrigatoriedade do MCP nao concede essa autorizacao. Apos uma execucao autorizada, examinar `output` e `errors` de `get_debug_output` e encerrar apenas o processo iniciado pelo MCP com `stop_project`.
4. Manter suite GUT, carregamento headless e aceite manual previstos na tarefa. Nao considerar contagem de arquivos, console sem erros ou consulta de versao como aceite visual/jogavel.
5. Se o MCP estiver indisponivel, registrar o bloqueio e restaurar a integracao antes do trabalho Godot dependente. Leitura do repositorio e documentacao podem continuar; nao declarar validacao MCP nem substituir silenciosamente a etapa obrigatoria por CLI.

A regra abrange todas as fases, PRDs, tarefas, assets e auditorias, inclusive trabalho futuro sobre entregas antigas. Nao reclassifica os testes historicos. Jogadores e o CI da suite GUT nao precisam instalar um cliente MCP para executar o jogo ou os testes.

## Configuracao em outra maquina

Instalar Node.js (requisito do pacote: >=18), npm e Godot 4.4.1. Obter o servidor [Coding-Solo/godot-mcp](https://github.com/Coding-Solo/godot-mcp), selecionar a revisao registrada abaixo, instalar suas dependencias e executar `npm run build` no diretorio do servidor. A instalacao fica fora do repositorio Buneko.

No cliente MCP, cadastrar um servidor chamado `godot` com transporte `stdio`:

- Executavel: caminho absoluto do `node` instalado.
- Argumento: caminho absoluto de `godot-mcp/build/index.js`.
- Ambiente: `GODOT_PATH` com caminho absoluto do executavel Godot 4.4.1.
- Parametro `projectPath` nas chamadas: caminho absoluto de `game_braty/braty` no checkout local.

Recarregar o cliente e realizar as duas consultas da regra de trabalho. Os caminhos desta maquina abaixo sao exemplos locais, nao valores portaveis. O lockfile local recebeu correcoes e difere do upstream; clonar a revisao sozinha nao reproduz essas correcoes. Revisar dependencias e registrar a revisao/lockfile utilizados ao preparar outro ambiente.

## Instalacao nesta maquina

- Fonte: https://github.com/Coding-Solo/godot-mcp
- Revisao: `1209744fad78f3998f98c7394fd0f6ef50da5281` (pacote `0.1.1`).
- Diretorio: `/home/braty/.local/share/godot-mcp`.
- Build: `npm run build --prefix /home/braty/.local/share/godot-mcp`.
- Node: `/home/braty/.nvm/versions/node/v20.20.2/bin/node`.
- Godot: `/home/braty/projetos/godot/godot` (`4.4.1`).
- Configuracao global do Codex: `/home/braty/.codex/config.toml`, servidor `godot`, transporte `stdio`, variavel `GODOT_PATH` apontando para o binario acima.
- Projeto: `/home/braty/projetos/vibe_projects/game_braty/braty`.

Consultar registro: `codex mcp get godot`. Remover registro: `codex mcp remove godot` (nao desinstala os arquivos). Se as ferramentas nao aparecerem na conversa atual, reiniciar o cliente Codex e consultar `/mcp` no CLI. A configuracao segue a [documentacao oficial de MCP](https://developers.openai.com/codex/mcp).

## Uso pratico

| Objetivo | Ferramentas |
| --- | --- |
| Localizar projeto e consultar estrutura/versao | `list_projects`, `get_project_info`, `get_godot_version` |
| Executar, ler console e encerrar o processo iniciado pelo MCP | `run_project`, `get_debug_output`, `stop_project` |
| Abrir o editor | `launch_editor` |
| Criar cena, adicionar nos e salvar variantes | `create_scene`, `add_node`, `save_scene` |
| Aplicar textura a Sprite2D | `load_sprite` |
| Consultar e atualizar identificadores de recursos | `get_uid`, `update_project_uids` |
| Exportar biblioteca de malhas 3D | `export_mesh_library` |

Exemplos de pedidos: "consulte a estrutura do Buneko pelo MCP", "execute a cena aprovada e leia os erros", "crie uma cena de demonstracao temporaria com um Label".

O servidor controla processos que ele inicia; nao e uma conexao de inspecao completa com qualquer editor ja aberto. Esta implementacao nao oferece ferramentas de screenshot, clique, leitura da arvore viva ou profiler. A ferramenta `get_project_info` conta arquivos, nao realiza auditoria semantica do codigo.

## Verificacao da instalacao

Handshake MCP e descoberta de 14 ferramentas verificados com cliente de protocolo local. Testadas consultas de versao, descoberta e estrutura do projeto real; criacao de cena `Node2D`, adicao de `Label` e salvamento de variante em `/tmp/buneko-godot-mcp-demo`. Conferido o conteudo dos arquivos gerados.

A demonstracao grafica autorizada executa a cena temporaria, captura uma mensagem e um aviso intencional e encerra o processo. Depois executa o Buneko com dados de usuario isolados, captura seu console e encerra o processo. Evidencias temporarias: `/tmp/buneko-godot-mcp-results.json` e `/tmp/buneko-godot-mcp-demo.log`; cliente usado: `/tmp/buneko-godot-mcp-demo.mjs`. Esses arquivos em `/tmp` nao sao duraveis.

Resultado: demonstracao concluida, cliente terminou com codigo 0 e ambas as chamadas de encerramento retornaram sucesso. No Buneko, o stdout trouxe sete diagnosticos prefixados `ERROR`: chamada de `BunekoAssemblyValidator.is_valid()` por instancia, tipos incompativeis em ternario e sombreamento de propriedades herdadas (`rotation`, `size` em tres contextos e `visible`). O campo `errors` estava vazio: e preciso examinar tambem `output`, pois ele representa stdout e pode conter diagnosticos. A captura nao informou caminhos/linhas desses pontos; causa e impacto jogavel nao foram investigados nesta instalacao. Nao foram corrigidos arquivos do jogo.

Na verificacao inicial, as chamadas foram feitas por cliente MCP de verificacao; a descoberta nativa foi confirmada posteriormente, conforme registro abaixo. Nao foram validados `launch_editor`, `load_sprite`, ferramentas de UID ou exportacao 3D. Nenhuma aprovacao visual/jogavel e inferida desses testes.

## Dependencias e limites

### Investigacao dos sete diagnosticos em 2026-10-22

Investigacao headless no checkout `master`, HEAD `4b7378b`, preservando as alteracoes locais da tarefa 020-06. A descoberta nativa nesta conversa foi confirmada por chamadas bem-sucedidas a `get_godot_version` e `get_project_info` para `braty/`.

O servidor inicia o jogo com `-d` (debug). A execucao headless com esse mesmo argumento reproduziu exatamente as sete mensagens em stdout e encerrou com codigo 0; sem `-d`, o carregamento encerrou com codigo 0 e sem essas mensagens. Os diagnosticos sao avisos de analise do GDScript apresentados com prefixo `ERROR` nesse modo, sem falha de parsing/carregamento reproduzida. O campo `errors` vazio do MCP indica apenas stderr vazio.

| Severidade nesta investigacao | Origem | Diagnostico e correcao recomendada |
| --- | --- | --- |
| Baixa | `braty/src/buneko/assembly/assembly_bench.gd:54` | Chamada de funcao estatica por instancia. Usar `AssemblyValidatorScript.is_valid(assembly)`. |
| Baixa | `braty/src/brain_editor/block_node.gd:135` | Ternario entre `VBoxContainer` e `HBoxContainer`. Separar a construcao em `if/else`, preservando a escolha e `_ports_box`. |
| Baixa | `braty/src/buneko/visual/buneko_visual.gd:79` | Variavel local `rotation` sombreia `Node2D.rotation`. Renomear para `pose_rotation`, mantendo a chave `rotation` do dicionario. |
| Baixa | `braty/src/menu/main_menu.gd:75` | Variavel local `size` sombreia `Control.size`. Renomear para `resolution_size`. |
| Baixa | `braty/src/menu/main_menu.gd:135` | Iterador `size` sombreia `Control.size`. Renomear para `resolution_size`. |
| Baixa | `braty/src/menu/main_menu.gd:139` | Parametro `size` sombreia `Control.size`. Renomear para `resolution_size`. |
| Baixa | `braty/src/campaign/combat/enemy_visual.gd:98` | Parametro `visible` sombreia `CanvasItem.visible`. Renomear para `target_visible`. |

Os scripts foram verificados individualmente com `--headless -d --check-only --script`, permitindo atribuir as mensagens aos arquivos acima. Nao foi reproduzido defeito de comportamento causado por esses avisos. Eles poluem os diagnosticos e podem dificultar a identificacao de uma falha real.

Validacao do checkout real: suite GUT completa com **46 scripts, 292 testes e 2121 assercoes**, todos aprovados, codigo 0; carregamento headless normal e debug com codigo 0; `git diff --check` aprovado. Dados de usuario isolados em `/tmp/buneko-mcp-diagnostics/`. Logs em `/tmp/buneko-mcp-diagnostics-gut.log` e `/tmp/buneko-mcp-diagnostics-debug.log`.

Uma copia experimental em `/tmp/buneko-mcp-diagnostics-proposed-fixes` recebeu somente as correcoes descritas na tabela. O carregamento headless com `-d` dessa copia encerrou com codigo 0, sem as sete mensagens. Isso verifica a remocao dos diagnosticos; a suite da copia corrigida nao foi executada. As correcoes nao foram aplicadas aos scripts do repositorio.

Uma tentativa adicional de inicializacao do editor headless encontrou restricao de sockets do ambiente (`ERR_CANT_CREATE`); ela nao e evidencia de defeito do jogo nem de validacao completa do editor. Nenhuma janela foi aberta e nenhum aceite visual/jogavel foi realizado.

Ordem recomendada para uma futura correcao: chamada estatica, construcao dos containers, renomeacoes locais e atualizacao desta evidencia; depois suite GUT completa, carregamento headless com `-d` e `git diff --check`. Risco principal: trocar uma referencia a propriedade herdada ou uma chave publica durante as renomeacoes. Preservar o dicionario de pose, nomes de sinais, condicoes e regras de jogo.

Aplicado `npm audit fix --ignore-scripts` sem forcar atualizacao principal e recompilado. O lockfile instalado difere do upstream pelas correcoes compativeis. Restou alerta alto no SDK MCP `0.6.0`: avisos GHSA-w48q-cv73-mx4w e GHSA-6prh-2h8m-c8cw relativos a HTTP/DNS rebinding e redirecionamentos de clientes HTTP/OAuth. A configuracao instalada utiliza exclusivamente `stdio`, sem servidor HTTP. Atualizar o SDK para a versao principal corrigida exige verificacao propria de compatibilidade.

Seguem vigentes as regras de `AGENTS.md`: mudancas de comportamento exigem planejamento e aprovacao; abrir janelas, capturar tela ou interagir graficamente exige autorizacao especifica. A instalacao nao concede aprovacao permanente para essas operacoes.

## Verificacao desta atualizacao documental — 2026-10-22

Consultas nativas repetidas com sucesso: `get_godot_version` retornou `4.4.1.stable.official.49a5bc7b6`; `get_project_info` reconheceu `braty/`, com 35 cenas, 223 scripts e 22 assets no checkout local. Essas contagens incluem o estado local e nao constituem auditoria de comportamento. Nenhuma janela foi aberta nesta atualizacao. Os resultados de GUT registrados acima pertencem a investigacao anterior; a atualizacao documental nao reexecutou a suite nem aplicou as correcoes propostas.
