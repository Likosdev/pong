extends Control
class_name Main

const PLAYFIELD = preload("res://playfield.tscn")
const PLACEHOLDER_WORLD = preload("res://placeholder_world.tscn")

@onready var h_slider: HSlider = $Menu/VBoxContainer/HBoxContainer/HSlider


@onready
var loaded_world : Node2D = $PlaceholderWorld

@onready
var menu: VBoxContainer = $Menu
@onready 
var label_points_to_win: Label = %"LabelPointsToWin"
@onready 
var option_button: OptionButton = $Menu/VBoxContainer/HBoxContainer2/OptionButton



enum GameMode {
	MAIN_MENU,
	SETTINGS_MENU,
	PLAYER_VS_AI,
	PLAYER_VS_PLAYER
}

var current_mode : GameMode = GameMode.MAIN_MENU

func _ready() -> void:
	label_points_to_win.text = "Score {0} to win".format([int(h_slider.value)])

func load_playfield():
	loaded_world.queue_free()
	await get_tree().process_frame
	menu.hide()
	loaded_world = PLAYFIELD.instantiate()
	add_child(loaded_world)
	(loaded_world as PlayField).setup(
		self.current_mode, 
		h_slider.value,
		option_button.selected
	)
	
func _on_btn_play_vs_ai_button_down() -> void:
	current_mode = GameMode.PLAYER_VS_AI
	load_playfield()

func _on_btn_pvp_button_down() -> void:
	current_mode = GameMode.PLAYER_VS_PLAYER
	load_playfield()

func _on_btn_quit_button_down() -> void:
	get_tree().quit(0)

func _on_h_slider_value_changed(value: float) -> void:
	label_points_to_win.text = "Score {0} to win".format([int(value)])
