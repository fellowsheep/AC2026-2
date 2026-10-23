extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	# Configura o loop linear para as animações de locomoção
	if anim_player.has_animation("CharacterArmature|Walk"):
		anim_player.get_animation("CharacterArmature|Walk").loop_mode = Animation.LOOP_LINEAR
		
	if anim_player.has_animation("CharacterArmature|Run"):
		anim_player.get_animation("CharacterArmature|Run").loop_mode = Animation.LOOP_LINEAR
		
	if anim_player.has_animation("CharacterArmature|Idle"):
		anim_player.get_animation("CharacterArmature|Idle").loop_mode = Animation.LOOP_LINEAR


func _process(_delta: float) -> void:
	# 1. Leitura das entradas do jogador
	if Input.is_action_just_pressed("pular"):
		playback.travel("CharacterArmature|Jump")
	elif Input.is_action_pressed("correr"):
		playback.travel("CharacterArmature|Run")
	elif Input.is_action_pressed("caminhar"):
		playback.travel("CharacterArmature|Walk")
	# 2. Só retorna ao Idle se NÃO estiver a executar nenhuma fase do pulo
	else:
		print("cai aqui")
		playback.travel("CharacterArmature|Idle")
