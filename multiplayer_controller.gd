extends Control

const SERVER_ID = 1

@export var Address = "127.0.0.1"
@export var Port = 8910

var peer : ENetMultiplayerPeer
var compression := ENetConnection.COMPRESS_RANGE_CODER

# Called when the node enters the scene tree for the first time.
func _ready():
	# called on server and clients when a connection is made.
	multiplayer.peer_connected.connect(on_player_connected)
	# called on server and clients when a connection is closed.
	multiplayer.peer_disconnected.connect(on_player_disconnected)
	# called on client only when a connection is made.
	multiplayer.connected_to_server.connect(on_connected_to_server)
	# called on server when a connection fails.
	multiplayer.connection_failed.connect(on_connection_failed)
	
	if "--server" in OS.get_cmdline_args():
		host_game()


func on_player_connected(id: int):
	print("Player connected " + str(id))

func on_player_disconnected(id: int):
	print("Player disconnected " + str(id))

func on_connected_to_server():
	print("Connected to server!")
	send_player_information.rpc_id(SERVER_ID, $LineEdit.text, multiplayer.get_unique_id())

@rpc("reliable", "any_peer")
func send_player_information(name: String, id: int):
	if not GameManager.players.has(id):
		GameManager.players[id] = {
			"name": name,
			"id": id,
			"score": 0,
		}
	if multiplayer.is_server():
		for i in GameManager.players:
			send_player_information.rpc(GameManager.players[i].name, i)


func on_connection_failed():
	print("Couldn't connect to server...")


func host_game():
	peer = ENetMultiplayerPeer.new()
	
	var error = peer.create_server(Port, 32)
	if error != OK:
		print("Cannot host: " + error)
		return
	
	peer.get_host().compress(compression)
	
	# Configure the game to use our local peer server as our game server.
	# This is only for the player that is hosting the game.
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players...")


func _on_host_button_down():
	host_game()
	send_player_information($LineEdit.text, multiplayer.get_unique_id())


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, Port)
	peer.get_host().compress(compression)
	multiplayer.set_multiplayer_peer(peer)


func _on_start_button_down():
	# We need to send an RPC to the multiplayer server.
	start_game.rpc() # .rpc() will call the function as an RPC
	# start_game.rpc_id(1) # .rpc_id() will call the function on a specific client.

@rpc("reliable", "any_peer", "call_local") # instructs the call to be made locally too
func start_game():
	var scene = load("res://test_level.tscn").instantiate()
	get_tree().root.add_child(scene)
	self.hide()
