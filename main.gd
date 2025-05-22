extends Control
class_name Main

const PLAYFIELD = preload("res://playfield.tscn")
const PLACEHOLDER_WORLD = preload("res://placeholder_world.tscn")

@onready
var loaded_world : Node2D = $PlaceholderWorld

@onready
var menu: VBoxContainer = $Menu

enum GameMode {
	MAIN_MENU,
	SETTINGS_MENU,
	PLAYER_VS_AI,
	PLAYER_VS_PLAYER
}

var current_mode : GameMode = GameMode.MAIN_MENU

func load_playfield():
	loaded_world.queue_free()
	await get_tree().process_frame
	menu.hide()
	loaded_world = PLAYFIELD.instantiate()
	add_child(loaded_world)
	match current_mode:
		GameMode.PLAYER_VS_AI:
			loaded_world.set_up_vs_ai()
		GameMode.PLAYER_VS_PLAYER:
			loaded_world.set_up_pvp()

func _on_btn_play_vs_ai_button_down() -> void:
	current_mode = GameMode.PLAYER_VS_AI
	load_playfield()

func _on_btn_pvp_button_down() -> void:
	current_mode = GameMode.PLAYER_VS_PLAYER
	load_playfield()


func _on_btn_quit_button_down() -> void:
	get_tree().quit(0)
