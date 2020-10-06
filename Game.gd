extends Node

var LevelScene = load("res://Level.tscn")
onready var LongPress = $LongPress
onready var description_label = $UI/Description_Container/MarginContainer/description_label
onready var description_container = $UI/Description_Container
onready var button_container = $UI/MarginContainer/VBoxContainer/ButtonContainer

var lock_player = true

func _ready():
	var level = get_node("Level")
	var player = level.player
	player.connect("update_hp", self, "on_player_update_hp")
	level.connect("update_level", self, "on_update_level")
	lock_player = false
	AudioServer.set_bus_mute(0, true)


func on_player_update_hp(hp):
	var hearts = $UI/MarginContainer/VBoxContainer/HealthSpriteContainer.get_children()
		
	for i in range(0, hearts.size()):
		if i < hp:
			hearts[i].visible = true
		else:
			hearts[i].visible = false

func on_update_level(level):
	var level_label = $UI/MarginContainer/VBoxContainer/coins_levels_values/MarginContainer2/level_value
	level_label.text = str(level)
	pass


func _on_Button_pressed():
	get_node("Level").new_level()
	get_node("Level").player.hp = 3
	on_player_update_hp(3)
	pass


func _on_Button1_button_up():
	if not LongPress.is_stopped():
		LongPress.stop()
		call_spell(0)


func _on_Button1_button_down():
	var player = get_node("Level").player
	description_label.text = player.spells.spells[0].desc
	LongPress.start()


func _on_Button2_button_down():
	var player = get_node("Level").player
	description_label.text = player.spells.spells[1].desc
	LongPress.start()


func _on_Button2_button_up():
	if not LongPress.is_stopped():
		LongPress.stop()
		call_spell(1)


func _on_Button3_button_down():
	var player = get_node("Level").player
	description_label.text = player.spells.spells[2].desc
	LongPress.start()


func _on_Button3_button_up():
	if not LongPress.is_stopped():
		LongPress.stop()
		call_spell(2)


func _on_Button4_button_down():
	var player = get_node("Level").player
	description_label.text = player.spells.spells[3].desc
	LongPress.start()


func _on_Button4_button_up():
	if not LongPress.is_stopped():
		LongPress.stop()
		call_spell(3)


func _on_Button5_button_down():
	var player = get_node("Level").player
	description_label.text = player.spells.spells[4].desc
	LongPress.start()


func _on_Button5_button_up():
	if not LongPress.is_stopped():
		LongPress.stop()
		call_spell(4)


func _on_Button6_button_down():
	var player = get_node("Level").player
	description_label.text = player.spells.spells[5].desc
	LongPress.start()


func _on_Button6_button_up():
	if not LongPress.is_stopped():
		LongPress.stop()
		call_spell(5)


func _on_Button7_button_down():
	var player = get_node("Level").player
	description_label.text = player.spells.spells[6].desc
	LongPress.start()


func _on_Button7_button_up():
	if not LongPress.is_stopped():
		LongPress.stop()
		call_spell(6)


func _on_LongPress_timeout():
	description_container.visible = true
	lock_player = true
	disable_buttons()
	

func _input(event):
	if (event is InputEventMouseButton) and not event.pressed:
		description_container.visible = false
		lock_player = false
		enable_buttons()


func call_spell(spell_index):
	var player = get_node("Level").player
	player.spells.spells[spell_index].spell.call_func()
	player.spells.spells[spell_index].cooldown = player.spells.spells[spell_index].uses * 6 + 10
	print(player.spells.spells[spell_index].cooldown)
	player.spells.spells[spell_index].uses += 1
	player.update_spell_ui()


func disable_buttons():
	for b in button_container.get_children():
		b.disabled = true

func enable_buttons():
	var player = get_node("Level").player
	var buttons = button_container.get_children()
	var i = 0
	for s in player.spells.spells:
		buttons[i].text = s.name
		if s.cooldown <= 0:
			buttons[i].disabled = false
		else:
			buttons[i].disabled = true

		i += 1
