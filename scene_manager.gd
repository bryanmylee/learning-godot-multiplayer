extends Node2D

@export var player : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var index = 0
	for i in GameManager.players:
		var curr_player = player.instantiate()
		curr_player.name = str(GameManager.players[i].id)
		add_child(curr_player)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				curr_player.global_position = spawn.global_position
		index += 1
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
