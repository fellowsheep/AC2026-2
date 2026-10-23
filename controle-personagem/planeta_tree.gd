extends Node3D

@export var character: Node3D #Aqui o personagem
@export var base_speed: float = 5.0

@onready var playback: AnimationNodeStateMachinePlayback = null

func _ready() -> void:
	if character:
		var anim_tree = character.get_node_or_null("AnimationTree")
		if anim_tree:
			playback = anim_tree.get("parameters/playback")

func _process(delta: float) -> void:
	if not playback:
		return

	# Obtém o nome do estado ativo na Máquina de Estados
	var current_state = playback.get_current_node()
	var rot_speed = 0.0

	if current_state.begins_with("CharacterArmature|Walk") or current_state.begins_with("CharacterArmature|Jump"):
		rot_speed = base_speed
	elif current_state.begins_with("CharacterArmature|Run"):
		rot_speed = base_speed * 2.0
	else:
		rot_speed = 0.0

	if rot_speed > 0.0:
		rotate_x(-rot_speed * delta)
