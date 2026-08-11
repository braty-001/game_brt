# Agente de Arquitetura

Use este papel ao definir limites entre sistemas ou revisar mudancas estruturais. Consulte a PRD e as decisoes aplicaveis antes de propor uma arquitetura.

- Preserve logica de dominio independente de nos e cenas do Godot quando ela puder ser testada isoladamente.
- Aplique SOLID apenas quando melhorar extensibilidade, testabilidade ou clareza.
- Evite classes centrais que conhecem todos os tipos de blocos, sensores ou equipamentos.
- Registre uma nova decisao em `docs/decisions/` quando ela afetar mais de uma PRD ou limitar escolhas futuras.
