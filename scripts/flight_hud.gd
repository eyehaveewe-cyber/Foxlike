class_name FoxFlightHUD
extends CanvasLayer
## Presentation only. Game state belongs to the flight controller.
signal action(name: String, value: Variant)

const INK := Color("08131c")
const PAPER := Color("f3ebd7")
const SOFT := Color("8ea9b7")
const ORANGE := Color("ff9d51")
const CYAN := Color("72dfdf")
const RED := Color("ff6868")

class GraphicLayer extends Control:
	var kind := "menu"
	var phase := 0.0
	func _draw() -> void:
		var s := size
		if kind == "menu":
			draw_colored_polygon(PackedVector2Array([Vector2.ZERO, Vector2(s.x*.51,0), Vector2(s.x*.42,s.y), Vector2(0,s.y)]), Color(.018,.044,.068,.94))
			draw_line(Vector2(s.x*.51,0), Vector2(s.x*.42,s.y), Color(.45,.82,.82,.22), 1.0)
			for i in range(12):
				var x := 31.0 + i * 35.0
				draw_line(Vector2(x,32),Vector2(x+15,32),Color(.95,.62,.33,.28),1.0)
			draw_rect(Rect2(31,66,4,64),Color("ff9d51"))
			draw_line(Vector2(32,s.y-40),Vector2(s.x-32,s.y-40),Color(.5,.72,.78,.22),1.0)
		elif kind == "modal":
			draw_rect(Rect2(Vector2.ZERO,s),Color(.015,.035,.055,.80))
			draw_line(Vector2(64,80),Vector2(s.x-64,80),Color(.45,.82,.82,.32),1.0)
			draw_line(Vector2(64,s.y-80),Vector2(s.x-64,s.y-80),Color(.45,.82,.82,.32),1.0)
		elif kind == "portrait":
			draw_rect(Rect2(Vector2.ZERO,s),Color("102b38"))
			draw_circle(s*.5,24,Color("384e5a"))
			draw_colored_polygon(PackedVector2Array([Vector2(21,21),Vector2(42,11),Vector2(63,21),Vector2(66,43),Vector2(55,62),Vector2(29,62),Vector2(18,43)]),Color("d8d8c9"))
			draw_colored_polygon(PackedVector2Array([Vector2(23,30),Vector2(61,30),Vector2(56,43),Vector2(28,43)]),Color("173e4e"))
			draw_line(Vector2(28,32),Vector2(56,32),Color("72dfdf"),2)
			draw_rect(Rect2(37,48,10,4),Color("627c88"))
			draw_line(Vector2(5,72),Vector2(78,72),Color("ff9d51"),2)
			for i in range(6):
				var h := 3.0 + absf(sin(phase*7+i*1.7))*8.0
				draw_rect(Rect2(11+i*11,81-h,5,h),Color("72dfdf"))

var _shell: Control
var _menu: Control
var _modal: Control
var _game: Control
var _pause: Control
var _comms: Control
var _portrait: GraphicLayer
var _speaker: Label
var _speech: Label
var _comms_remaining := 0.0
var _game_clock := 0.0
var _shield: ProgressBar
var _energy: ProgressBar
var _boss: ProgressBar
var _route: ProgressBar
var _boss_title: Label
var _score: Label
var _combo: Label
var _bombs: Label
var _speed: Label
var _stage: Label
var _objective: Label
var _roll: Label
var _maneuver: Label
var _lock_label: Label
var _wingmen: Label
var _shield_label: Label
var _energy_label: Label
var _best: Label
var _continue: Button
var _difficulty: Button
var _mute_menu: Button
var _mute_pause: Button
var _stage_buttons: Array[Button] = []
var _difficulty_value := "Standard"
var _muted := false
var _initialized := false

func _ready() -> void:
	_build()

func _build() -> void:
	if _initialized:
		return
	_initialized = true
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_shell = Control.new()
	_shell.name = "FlightInterface"
	_shell.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_shell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_shell)
	_menu = _layer("menu")
	_modal = _layer("modal")
	_game = _layer("")
	_pause = _layer("modal")
	_build_menu()
	_build_game()
	_build_pause()
	_modal.hide()
	_pause.hide()
	_game.hide()
	get_viewport().size_changed.connect(_resize)
	_resize()

func _resize() -> void:
	# The project scales a 1280 x 720 reference viewport; preserve it on other aspects.
	var view := get_viewport().get_visible_rect().size
	var factor := minf(view.x/1280.0,view.y/720.0)
	_shell.size = Vector2(1280,720)
	_shell.scale = Vector2.ONE * factor
	_shell.position = (view - _shell.size*factor)*.5
	for item in [_menu,_modal,_game,_pause]:
		item.size = Vector2(1280,720)
		item.queue_redraw()

func _layer(kind: String) -> Control:
	var out: Control
	if kind.is_empty():
		out = Control.new()
	else:
		var graphic := GraphicLayer.new()
		graphic.kind = kind
		out = graphic
	out.size = Vector2(1280,720)
	out.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shell.add_child(out)
	return out

func _label(parent: Node, text_value: String, point: Vector2, width: float, font_size: int = 18, color: Color = PAPER) -> Label:
	var out := Label.new()
	out.text = text_value
	out.position = point
	out.size = Vector2(width,30)
	out.add_theme_font_size_override("font_size",font_size)
	out.add_theme_color_override("font_color",color)
	out.add_theme_color_override("font_shadow_color",Color(0,0,0,.6))
	out.add_theme_constant_override("shadow_offset_x",1)
	out.add_theme_constant_override("shadow_offset_y",2)
	out.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(out)
	return out

func _paragraph(parent: Node, value: String, point: Vector2, dimensions: Vector2, font_size: int = 17, color: Color = SOFT) -> Label:
	var out := _label(parent,"",point,dimensions.x,font_size,color)
	out.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	out.text = value
	out.size = dimensions
	return out

func _style(color: Color, border: Color, width: int = 1) -> StyleBoxFlat:
	var out := StyleBoxFlat.new()
	out.bg_color = color
	out.border_color = border
	out.set_border_width_all(width)
	out.content_margin_left = 16
	out.content_margin_right = 16
	out.content_margin_top = 9
	out.content_margin_bottom = 9
	return out

func _button(parent: Node, value: String, point: Vector2, dimensions: Vector2, command: String, payload: Variant = null, primary: bool = false) -> Button:
	var out := Button.new()
	out.text = value
	out.position = point
	out.size = dimensions
	out.alignment = HORIZONTAL_ALIGNMENT_LEFT
	out.add_theme_font_size_override("font_size",18 if dimensions.y>43 else (11 if dimensions.x<150 else 14))
	out.add_theme_color_override("font_color",INK if primary else PAPER)
	out.add_theme_color_override("font_hover_color",INK)
	out.add_theme_color_override("font_pressed_color",INK)
	out.add_theme_color_override("font_disabled_color",Color("506574"))
	out.add_theme_stylebox_override("normal",_style(ORANGE if primary else Color(.04,.105,.145,.91),ORANGE if primary else Color(.30,.50,.58,.35)))
	out.add_theme_stylebox_override("hover",_style(CYAN,CYAN))
	out.add_theme_stylebox_override("pressed",_style(PAPER,PAPER))
	out.add_theme_stylebox_override("focus",_style(Color(0,0,0,0),PAPER,2))
	out.add_theme_stylebox_override("disabled",_style(Color(.04,.07,.09,.55),Color(.2,.3,.34,.25)))
	if dimensions.x<150:
		for state in ["normal","hover","pressed","focus","disabled"]:
			var narrow_style := out.get_theme_stylebox(state)
			narrow_style.content_margin_left = 8
			narrow_style.content_margin_right = 8
	out.pressed.connect(func(): action.emit(command,payload))
	parent.add_child(out)
	out.size = dimensions
	return out

func _bar(parent: Node, point: Vector2, dimensions: Vector2, color: Color) -> ProgressBar:
	var out := ProgressBar.new()
	out.position = point
	out.size = dimensions
	out.show_percentage = false
	out.max_value = 100
	out.value = 100
	out.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var background := StyleBoxFlat.new()
	background.bg_color = Color(.02,.07,.10,.8)
	background.border_color = Color(.4,.6,.7,.3)
	background.set_border_width_all(1)
	background.set_content_margin_all(0)
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_content_margin_all(0)
	out.add_theme_stylebox_override("background",background)
	out.add_theme_stylebox_override("fill",fill)
	parent.add_child(out)
	# Reapply dimensions after replacing the default theme, whose initial minimum
	# otherwise leaves a 26px-high bar even after hiding its percentage label.
	out.size = dimensions
	return out

func _backplate(parent: Node, point: Vector2, dimensions: Vector2, opacity: float = .58) -> void:
	var plate := Panel.new()
	plate.position = point
	plate.size = dimensions
	plate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	plate.add_theme_stylebox_override("panel",_style(Color(.015,.04,.065,opacity),Color(.3,.6,.65,.15)))
	parent.add_child(plate)

func _build_menu() -> void:
	_label(_menu,"ASTERION DEFENCE FORCE     /     FLIGHT 04",Vector2(64,58),500,13,CYAN)
	_label(_menu,"FOXLIKE",Vector2(58,88),520,88,PAPER)
	_label(_menu,"A S T E R I O N   F L I G H T",Vector2(64,190),470,20,ORANGE)
	_paragraph(_menu,"Three pilots. One last flight.\nBreak the siege across the Asterion system.",Vector2(64,239),Vector2(390,60),19,PAPER)
	_button(_menu,"LAUNCH CAMPAIGN     >",Vector2(64,322),Vector2(364,53),"new_run",null,true)
	_continue = _button(_menu,"CONTINUE FLIGHT",Vector2(64,387),Vector2(364,47),"continue")
	_label(_menu,"MISSION SELECT",Vector2(64,455),350,12,SOFT)
	for i in range(3):
		_stage_buttons.append(_button(_menu,["01 / VIRIDIA","02 / AURORA","03 / TERMINUS"][i],Vector2(64+i*124,482),Vector2(116,38),"stage",i))
	_difficulty = _button(_menu,"STANDARD",Vector2(64,540),Vector2(177,37),"cycle_difficulty")
	# Difficulty cycles locally, then emits the public difficulty action.
	for connection in _difficulty.pressed.get_connections():
		_difficulty.pressed.disconnect(connection.callable)
	_difficulty.pressed.connect(_cycle_difficulty)
	_mute_menu = _button(_menu,"SOUND ON",Vector2(251,540),Vector2(177,37),"mute")
	_best = _label(_menu,"BEST SORTIE   000000",Vector2(64,592),380,14,CYAN)
	_label(_menu,"WASD / ARROWS steer  SPACE / LMB fire  Q / E roll  SHIFT boost  CTRL brake",Vector2(64,625),1050,12,SOFT)
	_label(_menu,"B  nova    R / RMB  missile    F  wingman assist    C  chatter    M  mute    ESC  pause",Vector2(64,646),1050,12,SOFT)
	_label(_menu,"STUNTS  hold SHIFT / RB + tap LEFT somersault / DOWN long loop / RIGHT corkscrew",Vector2(64,668),1110,10,SOFT)
	_label(_menu,"GAMEPAD  left stick steer / RT fire / A roll / X missile / B nova / Y assist / RB boost / LB brake / START pause",Vector2(64,686),755,9,SOFT)
	_label(_menu,"ARROW MK I",Vector2(935,73),290,14,CYAN)
	_label(_menu,"SQUADRON LEAD  /  COMET",Vector2(935,98),290,11,SOFT)
	_label(_menu,"A PROJECT BARREL ROLL FLIGHT",Vector2(836,689),380,11,SOFT)
	_label(_menu,"01—03  /  COMPLETE ARCADE CAMPAIGN",Vector2(64,689),650,11,SOFT)
	_button(_menu,"EXIT",Vector2(1130,633),Vector2(90,35),"quit")

func _build_game() -> void:
	_backplate(_game,Vector2(18,16),Vector2(345,115))
	_backplate(_game,Vector2(397,16),Vector2(486,75),.36)
	_backplate(_game,Vector2(1000,16),Vector2(260,108),.36)
	_label(_game,"COMET  /  ARROW MK I",Vector2(30,22),300,13,CYAN)
	_shield_label = _label(_game,"SHIELD  100",Vector2(30,47),260,15,PAPER)
	_shield = _bar(_game,Vector2(30,75),Vector2(248,8),CYAN)
	_energy_label = _label(_game,"ENGINE  100",Vector2(30,89),230,12,SOFT)
	_energy = _bar(_game,Vector2(30,113),Vector2(173,5),ORANGE)
	_roll = _label(_game,"ROLL READY",Vector2(216,91),160,11,ORANGE)
	_maneuver = _label(_game,"STUNT READY  /  30 ENERGY",Vector2(30,131),350,11,CYAN)
	_stage = _label(_game,"01 / VIRIDIA",Vector2(460,22),360,19,PAPER)
	_stage.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_route = _bar(_game,Vector2(476,53),Vector2(328,3),Color(.45,.75,.78,.65))
	_objective = _label(_game,"BREAK THE BLOCKADE",Vector2(390,65),500,12,SOFT)
	_objective.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_score = _label(_game,"000000",Vector2(1000,25),248,33,PAPER)
	_score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_combo = _label(_game,"",Vector2(985,69),262,15,ORANGE)
	_combo.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_bombs = _label(_game,"NOVA   03",Vector2(1000,98),248,14,CYAN)
	_bombs.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_boss_title = _label(_game,"",Vector2(420,102),440,14,ORANGE)
	_boss_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss = _bar(_game,Vector2(420,131),Vector2(440,8),ORANGE)
	_boss.hide()
	_lock_label = _label(_game,"",Vector2(520,475),240,15,CYAN)
	_lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_speed = _label(_game,"CRUISE / 100",Vector2(1050,616),195,13,SOFT)
	_speed.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_wingmen = _label(_game,"LATCH 100     GLINT 100",Vector2(30,650),700,12,CYAN)
	_label(_game,"SHIFT + A/LEFT flip · S/DOWN loop · D/RIGHT corkscrew  |  SPACE fire · Q/E roll · CTRL brake · B nova · R missile · F assist · ESC pause",Vector2(30,687),1210,11,SOFT)
	_comms = Control.new()
	_comms.position = Vector2(30,520)
	_comms.size = Vector2(610,103)
	_comms.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_game.add_child(_comms)
	var backdrop := Panel.new()
	backdrop.size = Vector2(610,103)
	backdrop.add_theme_stylebox_override("panel",_style(Color(.025,.065,.095,.87),Color(.4,.75,.8,.25)))
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_comms.add_child(backdrop)
	_portrait = GraphicLayer.new()
	_portrait.kind = "portrait"
	_portrait.position = Vector2(8,8)
	_portrait.size = Vector2(84,87)
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_comms.add_child(_portrait)
	_speaker = _label(_comms,"LATCH / WING TWO",Vector2(107,10),465,13,ORANGE)
	_speech = _paragraph(_comms,"",Vector2(107,37),Vector2(483,60),18,PAPER)
	_comms.hide()

func _build_pause() -> void:
	_label(_pause,"FLIGHT HOLD",Vector2(440,147),500,46,PAPER)
	_label(_pause,"The squadron is waiting for your signal.",Vector2(440,216),520,17,SOFT)
	_button(_pause,"RESUME FLIGHT     >",Vector2(440,280),Vector2(400,52),"resume",null,true)
	_button(_pause,"RETRY MISSION",Vector2(440,346),Vector2(400,45),"retry")
	_mute_pause = _button(_pause,"SOUND ON",Vector2(440,405),Vector2(400,45),"mute")
	_button(_pause,"RETURN TO FLIGHT DECK",Vector2(440,464),Vector2(400,45),"menu")
	_label(_pause,"ESC  resume",Vector2(440,540),400,14,CYAN)

func _cycle_difficulty() -> void:
	var choices: Array[String] = ["Cadet","Standard","Ace"]
	_difficulty_value = choices[(choices.find(_difficulty_value)+1)%choices.size()]
	_difficulty.text = _difficulty_value.to_upper()
	action.emit("difficulty",_difficulty_value)

func _fade(item: CanvasItem) -> void:
	item.modulate.a = 0.0
	create_tween().tween_property(item,"modulate:a",1.0,.24)

func show_menu(progress: Dictionary) -> void:
	_build()
	_menu.show()
	_modal.hide()
	_game.hide()
	_pause.hide()
	_comms.hide()
	_comms_remaining = 0
	var unlocked := clampi(int(progress.get("unlocked",1)),1,3)
	_continue.disabled = unlocked < 2
	for i in range(3):
		_stage_buttons[i].disabled = i>=unlocked
	_best.text = "BEST SORTIE   %06d" % int(progress.get("best",0))
	_difficulty_value = str(progress.get("difficulty","Standard"))
	_difficulty.text = _difficulty_value.to_upper()
	set_muted(bool(progress.get("muted",false)))
	_fade(_menu)
	# Keyboard focus remains on launch even when Continue is unavailable.
	for child in _menu.get_children():
		if child is Button and child.text.begins_with("LAUNCH"):
			child.grab_focus()

func _clear_modal() -> void:
	for child in _modal.get_children():
		_modal.remove_child(child)
		child.queue_free()
	_menu.hide()
	_game.hide()
	_pause.hide()
	_modal.show()
	_fade(_modal)

func show_briefing(stage: Dictionary) -> void:
	_build()
	_clear_modal()
	_label(_modal,"MISSION BRIEFING   /   %02d",Vector2(82,111),1000,15,CYAN).text = "MISSION BRIEFING   /   %02d" % (int(stage.get("index",0))+1)
	_label(_modal,str(stage.get("title","VIRIDIA")),Vector2(78,153),1110,62,PAPER)
	_label(_modal,str(stage.get("subtitle","RETURN TO THE SKIES")).to_upper(),Vector2(82,242),1090,19,ORANGE)
	_paragraph(_modal,str(stage.get("description","")),Vector2(82,291),Vector2(790,112),23,PAPER)
	_label(_modal,"FLIGHT OBJECTIVE",Vector2(82,440),700,12,CYAN)
	_paragraph(_modal,str(stage.get("objective","Clear the route and destroy the command ship.")),Vector2(82,468),Vector2(780,65),19,SOFT)
	var launch := _button(_modal,"LAUNCH SQUADRON     >",Vector2(82,560),Vector2(360,54),"launch",null,true)
	_button(_modal,"FLIGHT DECK",Vector2(459,560),Vector2(200,54),"menu")
	launch.grab_focus()
	_label(_modal,"COMET     /     LATCH     /     GLINT",Vector2(82,664),1050,13,SOFT)

func show_result(result: Dictionary) -> void:
	_build()
	_clear_modal()
	var success := bool(result.get("success",false))
	var final_flight := bool(result.get("final",false)) and success
	var title := "ASTERION IS FREE" if final_flight else ("MISSION COMPLETE" if success else "FLIGHT LOST")
	_label(_modal,"FLIGHT RECORDER   /   " + str(result.get("stage_name","")),Vector2(82,112),1000,14,CYAN)
	_label(_modal,title,Vector2(78,158),1120,56,PAPER if success else RED)
	_paragraph(_modal,"The blockade is broken. Three callsigns return across an open sky." if final_flight else ("Route secured. The squadron is ready for the next jump." if success else "Your wingmen recovered the flight recorder. Refit and try again."),Vector2(82,243),Vector2(950,75),21,SOFT)
	_label(_modal,"SORTIE SCORE",Vector2(82,354),400,14,CYAN)
	_label(_modal,"%06d" % int(result.get("score",0)),Vector2(78,386),430,64,PAPER)
	_label(_modal,"TARGETS",Vector2(516,354),200,14,CYAN)
	_label(_modal,str(result.get("kills",0)),Vector2(512,386),200,57,PAPER)
	_label(_modal,"RANK",Vector2(790,354),200,14,CYAN)
	_label(_modal,str(result.get("rank","-")),Vector2(786,386),200,57,ORANGE)
	_label(_modal,"MISSION BONUS   +%d" % int(result.get("bonus",0)),Vector2(82,478),800,15,ORANGE)
	var primary := _button(_modal,"RETURN HOME     >" if final_flight else ("NEXT MISSION     >" if success else "RETRY MISSION     >"),Vector2(82,560),Vector2(362,54),"menu" if final_flight else ("next" if success else "retry"),null,true)
	if not final_flight:
		_button(_modal,"FLIGHT DECK",Vector2(462,560),Vector2(220,54),"menu")
	primary.grab_focus()
	_label(_modal,"FLY AGAIN. FIND YOUR LINE. BRING EVERYONE HOME.",Vector2(82,664),1000,13,SOFT)

func show_pause(paused: bool) -> void:
	_build()
	_pause.visible = paused
	if paused:
		_fade(_pause)
		for child in _pause.get_children():
			if child is Button:
				child.grab_focus()
				break

func show_gameplay() -> void:
	_build()
	_menu.hide()
	_modal.hide()
	_pause.hide()
	_game.show()
	_fade(_game)

func set_muted(muted: bool) -> void:
	_muted = muted
	if _mute_menu != null:
		_mute_menu.text = "SOUND OFF" if muted else "SOUND ON"
	if _mute_pause != null:
		_mute_pause.text = "SOUND OFF" if muted else "SOUND ON"

func update_hud(data: Dictionary) -> void:
	_build()
	var shield_value := clampf(float(data.get("shield",100)),0,100)
	var energy_value := clampf(float(data.get("energy",100)),0,100)
	_shield.value = shield_value
	_energy.value = energy_value
	_shield_label.text = "SHIELD  %03d" % ceili(shield_value)
	_shield_label.modulate = RED if shield_value<25 else Color.WHITE
	_energy_label.text = "ENGINE  %03d" % ceili(energy_value)
	_score.text = "%06d" % int(data.get("score",0))
	var combo_value := int(data.get("combo",0))
	_combo.text = "CHAIN  ×%d" % combo_value if combo_value>1 else ""
	_bombs.text = "NOVA   %02d" % clampi(int(data.get("bombs",0)),0,9)
	_stage.text = str(data.get("stage_name",""))
	_objective.text = str(data.get("objective",""))
	_route.value = clampf(float(data.get("progress",0)),0,1)*100
	_speed.text = "VELOCITY  %03d" % int(data.get("speed",100))
	_roll.text = "ROLL READY" if bool(data.get("roll_ready",true)) else "ROLL RECHARGING"
	_roll.modulate.a = 1.0 if bool(data.get("roll_ready",true)) else .5
	var maneuver_name := str(data.get("maneuver",""))
	var maneuver_wait := float(data.get("maneuver_cooldown",0.0))
	_maneuver.text = maneuver_name if not maneuver_name.is_empty() else ("STUNT RECHARGE  %.1fs" % maneuver_wait if maneuver_wait > 0.0 else ("STUNT READY  /  30 ENERGY" if bool(data.get("maneuver_ready",true)) else "STUNT NEEDS 30 ENERGY / NO ROLL"))
	var boss_hp := float(data.get("boss_hp",-1))
	_boss.visible = boss_hp>=0
	_boss_title.visible = boss_hp>=0
	_boss.value = clampf(boss_hp,0,1)*100
	_boss_title.text = str(data.get("boss_name",""))
	var lock_value := float(data.get("lock",0))
	_lock_label.text = "TARGET LOCKED" if lock_value>=.99 else ("ACQUIRING  %02d%%" % int(lock_value*100) if lock_value>.03 else "")
	var wing_text: Array[String] = []
	var wing_data: Variant = data.get("wingmen",[])
	if wing_data is Array:
		for entry: Variant in wing_data:
			if entry is Dictionary:
				var hp := int(entry.get("hp",100))
				wing_text.append(str(entry.get("callsign","WING"))+"  "+("RTB" if hp<=0 else str(hp)))
	_wingmen.text = "     /     ".join(wing_text)
	if data.has("muted"):
		set_muted(bool(data.muted))

func say(speaker: String, text_value: String, duration: float = 5.0) -> void:
	_build()
	_speaker.text = speaker.to_upper() + "   /   SQUADRON RADIO"
	_speech.text = text_value
	_comms_remaining = maxf(1.0,duration)
	_comms.show()
	_fade(_comms)

func _process(delta: float) -> void:
	if not _initialized:
		return
	_game_clock += delta
	if _comms_remaining>0 and not _pause.visible:
		_comms_remaining = maxf(0,_comms_remaining-delta)
		_portrait.phase = _game_clock
		_portrait.queue_redraw()
		if _comms_remaining<.4:
			_comms.modulate.a = _comms_remaining/.4
		if _comms_remaining<=0:
			_comms.hide()
