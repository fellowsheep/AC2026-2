extends Node3D

@onready var anim_player = $AnimationPlayer
@onready var cubo_1: Node3D = $Cubo1
@onready var cubo_2: Node3D = $Cubo2



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	anim_player.play("cubo_move") # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		anim_player.play("cubo_move")
		cubo_1.girar()
		cubo_2.girar()
