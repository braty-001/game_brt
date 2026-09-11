class_name CampaignMissionCatalog
extends RefCounted

const LABORATORY_ID := "laboratory_escape"
const INITIAL_RAM := 10
const FIRST_COMPLETION_REWARD := 10

static func laboratory_briefing() -> Dictionary:
	return {
		"id": LABORATORY_ID,
		"title": "MISSAO 1 / ESCAPAR DO LABORATORIO",
		"objective": "Alcance a saida no andar superior esquerdo. Voce pode evitar os inimigos: derrotar todos nao e necessario.",
		"route": "Comece embaixo a esquerda. Suba os degraus a direita pulando e retorne pela parte de cima.",
		"equipment": "10 RAM para preparar o cerebro | Visao basica\nBastao encontrado no inicio | 3 inimigos",
		"checkpoint": "Ao coletar o bastao, esta missao pausa para apresentar a arma e permitir editar o programa. Depois, derrotas retornam a esse checkpoint. Essa pausa e especial desta apresentacao.",
		"reward": "Recompensa: 10 de dinheiro na primeira conclusao",
	}

static func approximate_enemy_regions() -> Array[Rect2]:
	# Regioes de inteligencia do briefing, nao coordenadas de spawn do nivel.
	return [
		Rect2(0.43, 0.64, 0.22, 0.20),
		Rect2(0.25, 0.23, 0.20, 0.20),
		Rect2(0.55, 0.23, 0.20, 0.20),
	]
