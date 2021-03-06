
extends CanvasLayer

const MASK_MAXY = 56
const MASK_MINY = 112
const MASK_BOOST_MAXX = -48
const MASK_BOOST_MINX = 80

export(Color) var bg_from
export(Color) var bg_to

export(float) var max_height = -500
export(float) var min_height = 500

func _ready():
	Globals.set("GUI", self)
	set_gas_porcentage(1)
	set_boost_porcentage(0)
	
	draw_level_length()
	get_node("transitions/Polygon2D").show() # I hid the transition polygon so It won't show while editing

func draw_level_length():
	var f = get_node("panel/level/from").get_global_pos() - get_node("panel/level").get_pos()
	var t = get_node("panel/level/to").get_global_pos() - get_node("panel/level").get_pos()
	
	var points = [Vector2(f.x, f.y - 2), Vector2(t.x, t.y - 2), Vector2(t.x, t.y + 2), Vector2(f.x, f.y + 2)]
	get_node("panel/level/Polygon2D").set_polygon(Vector2Array(points))

func set_gas_porcentage(gas):
	gas = clamp(gas, 0, 1)
	var pos = get_node("gas_mask").get_pos()
	pos.y = MASK_MAXY + ((MASK_MINY - MASK_MAXY) * (1 - gas))
	get_node("gas_mask").set_pos(pos)
	
	Globals.get("GUI/Messages").show_gas_low(gas < 0.3)

func set_boost_porcentage(boost):
	boost = clamp(boost, 0, 1)
	var pos = get_node("boost_mask").get_pos()
	pos.x = MASK_BOOST_MAXX + ((MASK_BOOST_MINX - MASK_BOOST_MAXX) * boost)
	get_node("boost_mask").set_pos(pos)
	if boost == 0:
		get_node("panel/boost").hide()
	else:
		get_node("panel/boost").show()

func set_level_porcentage(porc):
	var text = str(porc)
	var from = get_node("panel/level/from").get_global_pos()
	var to = get_node("panel/level/to").get_global_pos()
	
	get_node("panel/level/Sprite").set_global_pos(from.linear_interpolate(to, porc) + Vector2(0, 16))

func set_background_color(position):
	var from = min_height
	var to = max_height
	var pos = clamp(position.y, to, from)
	var p = (pos - from) / (to-from)
	var color = bg_from.linear_interpolate(bg_to, p)
	
	get_node("background/Polygon2D").set_color(color)

func show_health():
	get_node("Controls/Actions/btn_health").show()

func show_speed_up(show):
	if show:
		get_node("Controls/Directions/btn_speed").show()
	else:
		get_node("Controls/Directions/btn_speed").hide()

func show_game_over(message = ""):
	get_node("GameOverControl").setMessage(message)
	get_node("GameOverControl").show()

func _on_btn_health_pressed():
	Globals.get("Player").use_health()
	get_node("Controls/Actions/btn_health").hide()

func fadeAndReload():
	get_node("transitions/AnimationPlayer").play("fadeout")

func _on_AnimationPlayer_finished():
	if get_node("transitions/AnimationPlayer").get_current_animation() == "fadeout":
		get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().change_scene("res://scenes/screens/main/main_menu.scn")
