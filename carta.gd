extends ColorRect

# SINAL: A carta vai "gritar" isto quando for clicada
# Ela envia-se a si própria (self) como parâmetro
signal fui_clicada(carta_visual)

@onready var texto_label = $Label 

# Variável para guardar os dados (As, 7, Rei...) dentro deste nó
var meus_dados = {}

func definir_dados(dados_da_carta):
	meus_dados = dados_da_carta # Guardamos para usar depois
	
	var texto_final = dados_da_carta["tipo"] + "\n" + dados_da_carta["naipe"]
	texto_label.text = texto_final
	
	if dados_da_carta["naipe"] == "Copas" or dados_da_carta["naipe"] == "Ouros":
		texto_label.modulate = Color(1, 0, 0)
	else:
		texto_label.modulate = Color(0, 0, 0)

# FUNÇÃO NATIVA DA GODOT: Deteta eventos de Input (teclado/rato) neste nó
func _gui_input(event):
	# Se for um evento do rato... E for um clique (pressed)... E for o botão Esquerdo (1)...
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Clicaste no: ", meus_dados["tipo"])
		# Emitimos o sinal para avisar a Mesa (Baralho.gd)
		fui_clicada.emit(self)
