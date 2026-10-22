# ADR 007: Godot and testing stack

> Fluxo de trabalho vigente: o [Godot MCP e obrigatorio](../godot-mcp.md) no desenvolvimento e na validacao assistidos por agentes. A regra complementa GUT e aceite manual e nao altera evidencias historicas deste documento.

## Decisao

O projeto usa Godot 4.4.1 com GDScript. Os testes automatizados usam GUT 9.4.0, instalado em `braty/addons/gut`.

## Motivo

GDScript atende o ritmo de iteracao do MVP. GUT 9.4.0 e a versao compativel com Godot 4.4.x e permite executar os testes pelo editor ou por terminal em modo headless.

## Consequencias

Logica deterministica deve ser implementada em scripts que possam ser testados sem cenas. A suite roda a partir da raiz Godot `braty/`. O repositorio deve executar o mesmo comando em um workflow de CI fixado em Godot 4.4.1; o GUT permanece vendorizado no projeto.
