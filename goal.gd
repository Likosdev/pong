extends Area2D
class_name Goal

signal scored(side : String)
@export_enum("PLAYER_A", "PLAYER_B") var side: String

func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		scored.emit(self.side)
