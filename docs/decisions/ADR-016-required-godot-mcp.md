# ADR 016: Godot MCP obrigatorio no trabalho assistido por agentes

Status: aceita em 2026-10-22 por solicitacao do usuario; abrange todas as fases do projeto.

## Contexto

O servidor Coding-Solo/godot-mcp foi instalado e verificado para o Buneko. O usuario determinou que seu uso fosse obrigatorio e documentado em todo o projeto. A integracao fornece consultas e operacoes sobre o Godot, mas nao cobre todos os tipos de teste ou inspecao.

## Decisao

- O servidor MCP `godot` e obrigatorio no desenvolvimento, investigacao e validacao do Godot assistidos por agentes. O [guia operacional](../godot-mcp.md) concentra configuracao, verificacao inicial, ferramentas e limites.
- Iniciar trabalho Godot com `get_godot_version` e `get_project_info` apontando para o caminho absoluto de `braty/`; registrar sucesso ou bloqueio. Usar o MCP nas operacoes suportadas dentro do escopo autorizado.
- Indisponibilidade deve ser explicitada e resolvida antes das atividades Godot dependentes; leitura do repositorio e documentacao podem prosseguir sem declarar validacao MCP.
- Permanecem obrigatorios os testes GUT/headless e o aceite manual aplicavel, conforme [ADR 007](ADR-007-godot-testing-stack.md). O MCP nao substitui essas evidencias.
- Operacoes graficas continuam exigindo autorizacao explicita nova. A instalacao e esta decisao nao autorizam abrir editor/jogo, capturar telas ou interagir com janelas.
- A regra e de desenvolvimento: nao adiciona dependencia ao jogo distribuido nem ao CI GUT e nao altera regras de produto, RAM, sensores ou execucao de programas.

## Consequencias

AGENTS.md, fundamentos, README, skill de auditoria, PRDs, tarefas e demais documentos do projeto apontam para a mesma regra. Documentacao vendorizada de terceiros permanece intacta. Referencias em documentos antigos orientam o trabalho futuro e nao atestam uso retroativo do MCP.

Configuracoes globais e instalacoes locais nao sao publicadas como parte do jogo. Outros ambientes devem configurar e verificar seu proprio servidor seguindo o guia. A revisao instalada e suas limitacoes ficam registradas ali; atualizacoes do servidor exigem nova verificacao.

## Validacao desta decisao

Em 2026-10-22, as consultas nativas de versao e projeto retornaram sucesso com Godot 4.4.1 e raiz `braty/`. A entrega altera somente documentacao; nao representa novo aceite visual ou nova execucao da suite GUT.
