extends Node3D

# Permite arrastar o nó "FernandoFlamingo" da cena Main para cá no Inspetor
@export var character: Node3D 
@export var base_speed: float = 5.0

@onready var anim_player: AnimationPlayer = null

func _ready() -> void:
	if character:
		# Pega o AnimationPlayer de dentro do personagem arrastado
		anim_player = character.get_node("AnimationPlayer")

func _process(delta: float) -> void:
	if not anim_player or not anim_player.is_playing():
		return

	var anim = anim_player.current_animation
	var rot_speed = 0.0

	if anim.begins_with("CharacterArmature|Walk") or anim.begins_with("CharacterArmature|Jump"):
		rot_speed = base_speed
	elif anim.begins_with("CharacterArmature|Run"):
		rot_speed = base_speed * 2.0
	else:
		rot_speed = 0.0

	if rot_speed > 0.0:
		rotate_x(-rot_speed * delta)
