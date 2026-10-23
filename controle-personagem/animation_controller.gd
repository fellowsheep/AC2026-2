extends Node3D

# Referência ao nó que toca as animações
@onready var anim_player = $AnimationPlayer

# Controla se o astronauta está no ar
var is_jumping = false

func _ready():
	# Estado inicial
	anim_player.play("CharacterArmature|Idle")
	
func _process(_delta: float) -> void:
# Se qualquer uma das 3 etapas do pulo estiver tocando, aguarda terminar
	if anim_player.is_playing() and anim_player.current_animation.begins_with("CharacterArmature|Jump"):
		return

	# Disparo de animações conforme as ações do Input Map
	if Input.is_action_just_pressed("pular"):
		is_jumping = true
		anim_player.play("CharacterArmature|Jump")
		anim_player.queue("CharacterArmature|Jump_Idle")
		anim_player.queue("CharacterArmature|Jump_Land")
	elif Input.is_action_pressed("correr"):
		anim_player.play("CharacterArmature|Run")
	elif Input.is_action_pressed("caminhar"):
		anim_player.play("CharacterArmature|Walk")
	else:
		anim_player.play("CharacterArmature|Idle")

func _on_animation_finished(anim_name: StringName) -> void:
	# Libera o controle apenas quando a última etapa do pulo terminar
	if anim_name == "CharacterArmature|Jump_Land":
		is_jumping = false
