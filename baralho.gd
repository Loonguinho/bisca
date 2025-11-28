extends Node

var carta_visual_jogador_temp = null
var modelo_carta = preload("res://card.tscn") 

# --- LIGAÇÕES COM A CENA (UI) ---
# O $LabelPontosJogador procura o nó com esse nome na cena
@onready var label_player = $LabelPontosJogador
@onready var label_cpu = $LabelPontosCPU

var pontos_jogador = 0
var pontos_cpu = 0
var naipes = ["Ouros", "Espadas", "Copas", "Paus"]
var tipos = ["2", "3", "4", "5", "6", "Dama", "Valete", "Rei", "7", "As"]
var valores_pontos = {"As": 11, "7": 10, "Rei": 4, "Valete": 3, "Dama": 2, "6": 0, "5": 0, "4": 0, "3": 0, "2": 0}

var baralho = []
var mao_jogador = []
var mao_cpu = []
var carta_trunfo = {}

func _ready():
	criar_baralho()
	dar_cartas_iniciais()
	desenhar_trunfo_na_mesa() # <--- NOVO: Mostra o trunfo!
	desenhar_minha_mao()

func criar_baralho():
	baralho.clear()
	for n in naipes:
		for i in range(tipos.size()):
			var nome_tipo = tipos[i]
			baralho.append({"naipe": n, "tipo": nome_tipo, "valor": valores_pontos[nome_tipo], "poder": i})
	randomize()
	baralho.shuffle()

func dar_cartas_iniciais():
	mao_jogador.clear()
	mao_cpu.clear()
	for i in range(3):
		mao_jogador.append(baralho.pop_back())
		mao_cpu.append(baralho.pop_back())
	carta_trunfo = baralho.pop_back()
	baralho.push_front(carta_trunfo) 

# --- NOVA FUNÇÃO: Desenhar o Trunfo ---
func desenhar_trunfo_na_mesa():
	var visual_trunfo = modelo_carta.instantiate()
	add_child(visual_trunfo)
	
	# Colocamos o trunfo no canto direito, meio da tela
	visual_trunfo.position = Vector2(900, 300)
	
	# Vamos rodá-lo 90 graus (PI/2 radianos) para parecer que está debaixo do baralho
	visual_trunfo.rotation = PI / 2 
	
	visual_trunfo.definir_dados(carta_trunfo)
	
	# Importante: Como é apenas visualização, ignoramos o rato nele
	visual_trunfo.mouse_filter = Control.MOUSE_FILTER_IGNORE


func desenhar_minha_mao():
	for filho in get_children():
		# Cuidado para não apagar o Trunfo! Verificamos se NÃO é o trunfo pela posição
		# (Ou podiamos usar grupos, mas assim é mais rápido para agora)
		if filho.has_method("definir_dados") and filho.position.y == 400:
			filho.queue_free()
	
	var pos_x = 100
	var pos_y = 400 
	
	for carta_dados in mao_jogador:
		var nova_carta_visual = modelo_carta.instantiate() 
		add_child(nova_carta_visual)
		
		nova_carta_visual.position = Vector2(pos_x, pos_y)
		pos_x += 120 
		nova_carta_visual.definir_dados(carta_dados)
		nova_carta_visual.fui_clicada.connect(_on_carta_jogada)

func _on_carta_jogada(carta_visual):
	if carta_visual_jogador_temp != null:
		return

	carta_visual_jogador_temp = carta_visual
	carta_visual.position = Vector2(450, 300)
	carta_visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mao_jogador.erase(carta_visual.meus_dados)
	
	jogada_do_cpu()

func jogada_do_cpu():
	await get_tree().create_timer(1.0).timeout
	
	if mao_cpu.size() > 0:
		var indice_aleatorio = randi() % mao_cpu.size()
		var dados_carta_cpu = mao_cpu[indice_aleatorio]
		mao_cpu.remove_at(indice_aleatorio)
		
		var carta_visual_cpu = modelo_carta.instantiate()
		add_child(carta_visual_cpu)
		carta_visual_cpu.definir_dados(dados_carta_cpu)
		carta_visual_cpu.position = Vector2(650, 300)
		
		finalizar_ronda(carta_visual_jogador_temp, carta_visual_cpu)
	else:
		print("O CPU não tem mais cartas!")

func finalizar_ronda(visual_player, visual_cpu):
	var d_player = visual_player.meus_dados
	var d_cpu = visual_cpu.meus_dados
	
	var vencedor = ""
	var naipe_trunfo = carta_trunfo["naipe"]
	var pontos_mesa = d_player["valor"] + d_cpu["valor"]
	
	# Lógica de Vencedor
	var player_usou_trunfo = (d_player["naipe"] == naipe_trunfo)
	var cpu_usou_trunfo = (d_cpu["naipe"] == naipe_trunfo)
	
	if player_usou_trunfo and not cpu_usou_trunfo:
		vencedor = "Jogador"
	elif cpu_usou_trunfo and not player_usou_trunfo:
		vencedor = "CPU"
	elif d_player["naipe"] == d_cpu["naipe"]:
		if d_player["poder"] > d_cpu["poder"]:
			vencedor = "Jogador"
		else:
			vencedor = "CPU"
	else:
		vencedor = "Jogador"

	# Atribuir pontos e ATUALIZAR UI
	if vencedor == "Jogador":
		pontos_jogador += pontos_mesa
	else:
		pontos_cpu += pontos_mesa
	
	# --- NOVO: Atualizar o texto na tela ---
	label_player.text = "Eu: " + str(pontos_jogador)
	label_cpu.text = "CPU: " + str(pontos_cpu)
	
	print("Placar UI Atualizado.")
	
	await get_tree().create_timer(2.0).timeout
	visual_player.queue_free()
	visual_cpu.queue_free()
	carta_visual_jogador_temp = null
	pescar_cartas()

func pescar_cartas():
	if baralho.size() == 0:
		return
	
	if baralho.size() > 0:
		mao_jogador.append(baralho.pop_back())
	if baralho.size() > 0:
		mao_cpu.append(baralho.pop_back())
		
	desenhar_minha_mao()
