extends Node2D

signal projectile_complete

onready var level = get_parent()


func _ready():
	$projectilesprite.visible = false
	level.connect("level_ready", self, "on_level_ready")


func _process(delta):
	pass


func on_level_ready():
	level.player.connect('projectile_spawn', self, "on_projectile_spawn")
	connect('projectile_complete', level.player, "on_projectile_complete")


func on_projectile_spawn(coords_start, coords_end):
	var distance = coords_start.distance_to(coords_end)
	$projectilesprite.position = coords_start
	$Tween.interpolate_property($projectilesprite, "position", coords_start, coords_end, distance/1000, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$projectilesprite.visible = true
	print($projectilesprite)
	$Tween.start()
	
	yield($Tween, "tween_all_completed")
	$projectilesprite.visible = false
	emit_signal("projectile_complete")
	

