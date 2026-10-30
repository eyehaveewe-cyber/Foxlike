extends "res://scripts/duel/duel_game.gd"
## Expanded campaign presentation. Session owns authoritative flight and outcomes.
const Session = preload("res://scripts/campaign/operation_session.gd")
const CampaignSave = preload("res://scripts/campaign/campaign_save.gd")
const Catalog = preload("res://scripts/campaign/operation_catalog.gd")
const Actor = preload("res://scripts/campaign/operation_actor.gd")
const Carrier = preload("res://scripts/arena_carrier.gd")
const Squadron = preload("res://scripts/flight_squadron.gd")
const Walker = preload("res://scripts/campaign/operation_walker.gd")
var session: RefCounted
var save := CampaignSave.new()
var actor_nodes: Dictionary = {}
var part_nodes: Dictionary = {}
var world_nodes: Node3D
var carrier_node: Node3D
var boss_node: Node3D
var campaign_ui: PanelContainer
var ui_stack: VBoxContainer
var caption: Label
var command_row: HBoxContainer
var notice := ""
var replay := false
var saved_stage := -1
var settled := false
var assignment_hold := 0.0
var assignment_held := false
var input_armed := true
var rebind := ""
var mouse_look := Vector2.ZERO
var last_device := "keyboard"
var elapsed_frame := 0.0
var last_music_boss := false
var stunt_request := ""
var cover_nodes: Dictionary = {}
var hazard_node: MeshInstance3D
var pad_rebind := ""
var rendered_boss := -1
var sound_wait := 0.0
var saved_checkpoint_revision := -1
var region_environment: WorldEnvironment
const KEYS := {"left":KEY_A,"right":KEY_D,"up":KEY_W,"down":KEY_S,"fire":KEY_SPACE,"boost":KEY_SHIFT,"brake":KEY_CTRL,"roll_left":KEY_Q,"roll_right":KEY_E,"missile":KEY_R,"nova":KEY_B,"ability":KEY_F,"formation":KEY_TAB,"target":KEY_T,"interact":KEY_I,"somersault":KEY_Z,"long_loop":KEY_X,"corkscrew":KEY_V}
const PAD := {"boost":JOY_BUTTON_RIGHT_SHOULDER,"brake":JOY_BUTTON_LEFT_SHOULDER,"roll_right":JOY_BUTTON_A,"missile":JOY_BUTTON_X,"nova":JOY_BUTTON_B,"ability":JOY_BUTTON_Y,"interact":JOY_BUTTON_DPAD_DOWN,"target":JOY_BUTTON_RIGHT_STICK,"formation":JOY_BUTTON_LEFT_STICK,"somersault":JOY_BUTTON_DPAD_UP,"long_loop":JOY_BUTTON_DPAD_LEFT,"corkscrew":JOY_BUTTON_DPAD_RIGHT,"pause":JOY_BUTTON_START}

func _ready() -> void:
	if "--test-save" in OS.get_cmdline_user_args(): save.path = "user://foxlike_expanded_test_save.json"
	save.load_file()
	mode = "menu"
	_setup_inputs()
	var environment := WorldEnvironment.new(); region_environment = environment
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("071424")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color("87a1c6")
	environment.environment.ambient_light_energy = .75
	add_child(environment)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45,-30,0); sun.light_energy = 1.8; add_child(sun)
	camera = Camera3D.new(); camera.fov = 67; camera.far = 2000; add_child(camera); camera.current = true
	camera.position = Vector3(120,110,200); camera.look_at(Vector3(0,75,0))
	audio = Sound.new(); add_child(audio); audio.set_muted(bool(save.data.muted)); audio.start_music(0)
	effects = Effects.new(); add_child(effects)
	world_nodes = Node3D.new(); add_child(world_nodes)
	carrier_node = Carrier.new(); world_nodes.add_child(carrier_node); carrier_node.setup(); carrier_node.scale = Vector3.ONE*2
	carrier_node.position = Vector3(0,75,0)
	var canvas := CanvasLayer.new(); add_child(canvas)
	overlay = DuelOverlay.new(); overlay.game = self; overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT); canvas.add_child(overlay)
	campaign_ui = PanelContainer.new(); campaign_ui.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	campaign_ui.position = Vector2(-450,-310); campaign_ui.size = Vector2(900,620)
	campaign_ui.add_theme_stylebox_override("panel",_hud_panel()); canvas.add_child(campaign_ui)
	var scroll := ScrollContainer.new(); campaign_ui.add_child(scroll)
	ui_stack = VBoxContainer.new(); ui_stack.custom_minimum_size.x = 840; ui_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL; ui_stack.add_theme_constant_override("separation",9); scroll.add_child(ui_stack)
	caption = Label.new(); caption.position = Vector2(30,25); caption.size = Vector2(1190,100); caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; canvas.add_child(caption)
	get_tree().root.size_changed.connect(_resize_ui)
	Input.joy_connection_changed.connect(func(_id: int, connected: bool):
		if not connected and mode=="flight": paused = true; input_armed = false; notice = "Controller disconnected. Reconnect or resume with keyboard."; _pause_menu()
	)
	_resize_ui(); _menu()

func _hud_panel() -> StyleBoxFlat:
	var panel := StyleBoxFlat.new(); panel.bg_color = Color(.015,.035,.065,.97); panel.border_color = Color("75b8c6"); panel.set_border_width_all(1); panel.set_content_margin_all(20); return panel

func _resize_ui() -> void:
	var scale_ui: float = float(save.data.settings.get("ui_scale",1.0))
	caption.add_theme_font_size_override("font_size",roundi(18*scale_ui))
	campaign_ui.add_theme_font_size_override("font_size",roundi(17*scale_ui))
	var viewport := get_viewport().get_visible_rect().size
	campaign_ui.scale = Vector2.ONE*minf(1, minf(viewport.x/960,viewport.y/680))
	campaign_ui.position = (viewport-campaign_ui.size*campaign_ui.scale)*.5
	caption.size.x = maxf(100,viewport.x-60)

func _clear_menu() -> void:
	for child in ui_stack.get_children(): ui_stack.remove_child(child); child.queue_free()
	campaign_ui.show()

func _text(value: String, size: int = 18) -> void:
	var label := Label.new(); label.text = value; label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; label.add_theme_font_size_override("font_size",roundi(size*float(save.data.settings.ui_scale))); ui_stack.add_child(label)

func _button(text: String, action: Callable, disabled: bool = false) -> Button:
	var button := Button.new(); button.text = text; button.clip_text = true; button.custom_minimum_size.y = 35; button.disabled = disabled; button.pressed.connect(action); ui_stack.add_child(button); return button

func _menu() -> void:
	mode = "menu"; paused = false; _clear_menu()
	caption.text = ""; audio.start_music(0)
	_text("FOXLIKE / ASTERION FLIGHT",31)
	_text("Ten connected operations. One squadron. Keep the carrier and the people you rescue alive.")
	if not save.error.is_empty(): _text(save.error)
	_button("LAUNCH CAMPAIGN",func():
		if not save.error.is_empty(): _new_save_choice()
		else: _briefing(Catalog.IDS[0])
	).grab_focus()
	_button("CONTINUE / "+str(save.data.frontier),func():
		if not save.data.checkpoint.is_empty(): _launch(save.data.frontier,true)
		else: _briefing(save.data.frontier)
	,not save.error.is_empty())
	var roster: Array = Squadron.ROSTER.filter(func(p):return not Catalog.UNLOCKS.has(p.id) or save.data.completed.has(Catalog.UNLOCKS[p.id]))
	for slot in range(2):
		var choice := OptionButton.new()
		for pilot in roster: choice.add_item(("LEFT / " if slot==0 else "RIGHT / ")+pilot.name)
		choice.select(maxi(0,roster.map(func(p):return p.id).find(save.data.companions[slot])))
		choice.item_selected.connect(func(index: int):
			var other := 1-slot; var old: String = save.data.companions[slot]
			if save.data.companions[other]==roster[index].id: save.data.companions[other] = old
			save.data.companions[slot] = roster[index].id; save.write(); _menu()
		)
		ui_stack.add_child(choice)
	for i in range(Catalog.IDS.size()):
		var id: String = Catalog.IDS[i]
		_button("%02d / %s%s" % [i+1,Catalog.TITLES[i],"" if save.available(id) else " / LOCKED"],func():_briefing(id),not save.available(id))
	_button("PRACTICE DUEL",func():get_tree().change_scene_to_file("res://scenes/duel.tscn"))
	_button("PLANET ORBITS / PEACEFUL HUB",func():get_tree().set_meta("orbit_open_grid",true); get_tree().set_meta("orbit_muted",save.data.muted); get_tree().change_scene_to_file("res://scenes/orbit_hub.tscn"))
	_button("CONTROLS AND PRESENTATION",func():_settings_menu())

func _new_save_choice() -> void:
	_clear_menu(); _text(save.error)
	_button("KEEP SAVE / RETURN",func():_menu())
	_button("BACK UP AND START A NEW CAMPAIGN",func():
		save.error = ""; save.data = save.fresh(); save.write(); _briefing(Catalog.IDS[0])
	)

func _briefing(id: String) -> void:
	mode = "briefing"; _clear_menu()
	var mission := Catalog.definition(id)
	_text(mission.title,28)
	_text(" / ".join(mission.states.map(func(s):return str(s.text))))
	_text("Required cargo and Dragonfly loss cause failure. Optional recovery losses affect the debrief. Retry restores the last objective checkpoint.")
	_text("WASD/arrows or left stick: steer. Left mouse/RT: fire.\n%s: fire / %s: boost / %s: brake\n%s: target / %s: missile / %s: Nova / %s: interact\n%s tap: abilities, hold: assignments / %s: formation\n%s: somersault / %s: long loop / %s: corkscrew"%[_binding("fire"),_binding("boost"),_binding("brake"),_binding("target"),_binding("missile"),_binding("nova"),_binding("interact"),_binding("ability"),_binding("formation"),_binding("somersault"),_binding("long_loop"),_binding("corkscrew")])
	_button("LAUNCH / "+str(save.data.difficulty),func():_launch(id)).grab_focus()
	_button("DIFFICULTY / "+str(save.data.difficulty),func():
		var names := ["Cadet","Standard","Ace"]; save.data.difficulty = names[(names.find(save.data.difficulty)+1)%3]; save.write(); _briefing(id)
	)
	_button("RETURN TO FLIGHT DECK",func():_menu())

func _launch(id: String, resume_checkpoint: bool = false) -> void:
	session = Session.new(); session.begin(id,save.data)
	if resume_checkpoint and not session.restore(save.data.checkpoint): notice = "Checkpoint could not be restored. Restarting this operation from its briefing."; _briefing(id); return
	replay = save.data.completed.has(id)
	mode = "flight"; paused = false; settled = false; input_armed = false; saved_stage = -1; saved_checkpoint_revision = -1; last_music_boss = false
	_disarm_controls()
	campaign_ui.hide(); actor_nodes.clear(); part_nodes.clear(); shot_nodes.clear(); cover_nodes.clear()
	for child in world_nodes.get_children():
		if child!=carrier_node: world_nodes.remove_child(child); child.queue_free()
	boss_node = null
	rendered_boss = -1
	hazard_node = box_mesh(world_nodes,Vector3.ZERO,Vector3.ONE,Color("ffb260"))
	var haze: StandardMaterial3D = hazard_node.material_override
	haze.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA; haze.albedo_color.a = .15; haze.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	box_mesh(world_nodes,Vector3(0,-5,0),Vector3(1000,4,1000),Color("102c40"))
	# Reuse the existing regional sky palette. Solid encounter geometry stays
	# authored once in Session; streaming rail scenery is not collision scenery.
	var backdrop := preload("res://scripts/flight_world.gd").new()
	world_nodes.add_child(backdrop); backdrop.stage = int(session.definition.music); backdrop._build_lighting()
	for child in backdrop.get_children():
		if child is WorldEnvironment:
			region_environment.environment = child.environment; backdrop.remove_child(child); child.queue_free()
	var colors := [Color("397780"),Color("5e9aaf"),Color("41475c"),Color("875744"),Color("37566a"),Color("506e80")]
	world_nodes.set_meta("cover_color",colors[int(session.definition.music)])
	for i in range(-8,9):
		box_mesh(world_nodes,Vector3(i*40,-2,0),Vector3(.3,.2,800),Color("24536a"))
		box_mesh(world_nodes,Vector3(0,-2,i*40),Vector3(800,.2,.3),Color("24536a"))
	vehicles[0] = session.player().vehicle
	audio.start_operation_music(id); audio.set_muted(save.data.muted)
	_sync_actors(0); _update_camera(0,true)
	overlay.queue_redraw()

func pressed(action: String) -> bool:
	return Input.is_physical_key_pressed(int(save.data.bindings.get(action,KEYS[action])))

func pad_button(action: String) -> int: return int(save.data.pad_bindings.get(action,PAD[action]))

func _pad_label(action: String) -> String:
	var labels := {JOY_BUTTON_A:"Bottom face",JOY_BUTTON_B:"Right face",JOY_BUTTON_X:"Left face",JOY_BUTTON_Y:"Top face",JOY_BUTTON_BACK:"Back",JOY_BUTTON_START:"Start",JOY_BUTTON_GUIDE:"Guide",JOY_BUTTON_LEFT_STICK:"Left stick press",JOY_BUTTON_RIGHT_STICK:"Right stick press",JOY_BUTTON_LEFT_SHOULDER:"Left bumper",JOY_BUTTON_RIGHT_SHOULDER:"Right bumper",JOY_BUTTON_DPAD_UP:"D-pad up",JOY_BUTTON_DPAD_DOWN:"D-pad down",JOY_BUTTON_DPAD_LEFT:"D-pad left",JOY_BUTTON_DPAD_RIGHT:"D-pad right"}
	return labels.get(pad_button(action),"Button "+str(pad_button(action)))

func _binding(action: String) -> String:
	if last_device=="controller" and PAD.has(action): return _pad_label(action)
	return OS.get_keycode_string(int(save.data.bindings.get(action,KEYS.get(action,KEY_ESCAPE))))

func _unhandled_input(event: InputEvent) -> void:
	if not pad_rebind.is_empty() and event is InputEventJoypadButton and event.pressed:
		for action in PAD:
			if action!=pad_rebind and pad_button(action)==event.button_index: notice = "That controller button is assigned to "+action; _settings_menu(); return
		save.data.pad_bindings[pad_rebind] = event.button_index; pad_rebind = ""; save.write(); _settings_menu(); return
	if not rebind.is_empty() and event is InputEventKey and event.pressed and not event.echo:
		var key := int(event.physical_keycode)
		if key==KEY_ESCAPE: rebind = ""; _settings_menu(); return
		if key in [KEY_M,KEY_1,KEY_2,KEY_3,KEY_4]: notice = "That key is reserved for mute or assignments"; _settings_menu(); return
		for action in KEYS:
			if action!=rebind and int(save.data.bindings.get(action,KEYS[action]))==key: notice = "That key is already assigned to "+action; _settings_menu(); return
		save.data.bindings[rebind] = key; rebind = ""; save.write(); _settings_menu(); return
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT): mouse_look = Vector2(event.relative.x,-event.relative.y)*.025
	if event is InputEventKey and event.pressed and not event.echo:
		last_device = "keyboard"
		if event.physical_keycode==KEY_ESCAPE and mode=="flight": paused = not paused; input_armed = false; _pause_menu() if paused else campaign_ui.hide()
		if event.physical_keycode==KEY_M:
			save.data.muted = not save.data.muted; audio.set_muted(save.data.muted); save.write()
		if mode=="flight" and not paused and input_armed:
			for name in ["somersault","long_loop","corkscrew"]:
				if event.physical_keycode==int(save.data.bindings.get(name,KEYS[name])): stunt_request = name
			if event.physical_keycode==int(save.data.bindings.get("target",KEY_T)): _cycle_target()
			if event.physical_keycode==int(save.data.bindings.get("formation",KEY_TAB)): session.formation = (session.formation+1)%3; notice = Squadron.FORMATIONS[session.formation]
			if assignment_held and assignment_hold>=.35 and event.physical_keycode in [KEY_1,KEY_2,KEY_3,KEY_4]:
				session.assign(["attack","protect","cover","regroup"][int(event.physical_keycode)-KEY_1],session.selected)
			if event.physical_keycode==int(save.data.bindings.get("missile",KEY_R)): session.missile()
			if event.physical_keycode==int(save.data.bindings.get("nova",KEY_B)): _nova()
			if event.physical_keycode==int(save.data.bindings.get("roll_left",KEY_Q)): _roll_request = -1
			if event.physical_keycode==int(save.data.bindings.get("roll_right",KEY_E)): _roll_request = 1
	if event is InputEventJoypadButton and event.pressed:
		last_device = "controller"
		if event.button_index==pad_button("pause") and mode=="flight": paused = not paused; input_armed = false; _pause_menu() if paused else campaign_ui.hide(); return
		if mode!="flight" or paused or not input_armed: return
		if assignment_held and assignment_hold>=.35 and event.button_index in [JOY_BUTTON_DPAD_UP,JOY_BUTTON_DPAD_RIGHT,JOY_BUTTON_DPAD_DOWN,JOY_BUTTON_DPAD_LEFT]:
			session.assign({JOY_BUTTON_DPAD_UP:"attack",JOY_BUTTON_DPAD_RIGHT:"protect",JOY_BUTTON_DPAD_DOWN:"cover",JOY_BUTTON_DPAD_LEFT:"regroup"}[event.button_index],session.selected); return
		for name in ["somersault","long_loop","corkscrew"]:
			if event.button_index==pad_button(name): stunt_request = name
		if event.button_index==pad_button("target"): _cycle_target()
		if event.button_index==pad_button("formation"): session.formation = (session.formation+1)%3
		if event.button_index==pad_button("missile"): session.missile()
		if event.button_index==pad_button("nova"): _nova()
		if event.button_index==pad_button("roll_right"): _roll_request = 1

func _notification(what: int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_OUT and mode=="flight":
		paused = true; input_armed = false
		if is_instance_valid(ui_stack): notice = "Focus lost. Flight paused safely."; _pause_menu()

func _nova() -> void:
	if session==null or session.bombs<=0 or paused: return
	session.nova(); audio.sfx("explosion")

func _cycle_target() -> void:
	var ids: Array = session.living_hostiles().filter(func(a):return Geometry.first_cover(session.player().vehicle.position,a.vehicle.position,session.cover).is_empty()).map(func(a):return a.id)
	for actor in session.living_hostiles():
		if not Geometry.first_cover(session.player().vehicle.position,actor.vehicle.position,session.cover).is_empty(): continue
		for part in actor.parts:
			if actor.parts[part].hp>0: ids.append(actor.id+":"+part)
	ids.append_array(session.components.keys().filter(func(key):return session.components[key].hp>0))
	if session.core_hp>0: ids.append("CORE")
	if not ids.is_empty(): session.selected = ids[(ids.find(session.selected)+1)%ids.size()]

func _request(dt: float) -> Dictionary:
	var axis := Vector2(float(pressed("right"))-float(pressed("left")),float(pressed("up"))-float(pressed("down")))
	if Input.is_physical_key_pressed(KEY_LEFT): axis.x = -1
	if Input.is_physical_key_pressed(KEY_RIGHT): axis.x = 1
	if Input.is_physical_key_pressed(KEY_UP): axis.y = 1
	if Input.is_physical_key_pressed(KEY_DOWN): axis.y = -1
	var pads := Input.get_connected_joypads(); var pad := -1 if pads.is_empty() else int(pads[0])
	if pad>=0:
		var stick := Vector2(Input.get_joy_axis(pad,JOY_AXIS_LEFT_X),-Input.get_joy_axis(pad,JOY_AXIS_LEFT_Y))
		if stick.length()>.18: axis = stick.limit_length(); last_device = "controller"
	if mouse_look.length()>.05: axis = mouse_look.limit_length(); mouse_look = Vector2.ZERO
	var fire := pressed("fire") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or (pad>=0 and Input.get_joy_axis(pad,JOY_AXIS_TRIGGER_RIGHT)>.3)
	var boost := pressed("boost") or (pad>=0 and Input.is_joy_button_pressed(pad,pad_button("boost")))
	var brake := pressed("brake") or (pad>=0 and Input.is_joy_button_pressed(pad,pad_button("brake")))
	if not input_armed:
		var held_control := false
		for action in KEYS:
			if pressed(action): held_control = true
		for action in PAD:
			if pad>=0 and Input.is_joy_button_pressed(pad,pad_button(action)): held_control = true
		if not held_control and not fire and not boost and not brake and axis.length()<.1: input_armed = true
		else: return {}
	var held := pressed("ability") or (pad>=0 and Input.is_joy_button_pressed(pad,pad_button("ability")))
	if held:
		assignment_hold = assignment_hold+dt if assignment_held else 0.0
	elif assignment_held:
		if assignment_hold<.35: _ability()
		assignment_hold = 0
	assignment_held = held
	var request := {"steer":axis.limit_length(),"fire":fire,"boost":boost,"brake":brake,"roll":_roll_request,"maneuver":stunt_request,"interact":pressed("interact") or (pad>=0 and Input.is_joy_button_pressed(pad,pad_button("interact")))}
	stunt_request = ""
	_roll_request = 0
	return request

func _ability() -> void:
	for actor in session.allies():
		if actor.hp<=0 or actor.cooldown>0: continue
		var profile: Dictionary = Squadron.profile(actor.id)
		var target = session.actors.get(session.selected)
		if profile.ability=="guard":
			var goal: Vector3 = session.player().vehicle.position+session.player().vehicle.forward()*18
			if actor.vehicle.position.distance_to(goal)>90 or not Geometry.first_cover(actor.vehicle.position,goal,session.cover,4).is_empty(): notice = actor.id+" cannot reach that guard intercept"; continue
			actor.task = "cover"; actor.goal = goal; actor.cooldown = profile.cooldown
		elif target!=null and target.hp>0:
			if actor.vehicle.position.distance_to(target.vehicle.position)>180 or actor.vehicle.forward().dot(actor.vehicle.position.direction_to(target.vehicle.position))<.9 or not Geometry.first_cover(actor.vehicle.position,target.vehicle.position,session.cover).is_empty(): notice = actor.id+" needs a firing approach"; continue
			actor.task = "attack"; actor.target = target.id; actor.cooldown = profile.cooldown
			match str(profile.ability):
				"burst": actor.burst = 6; actor.burst_wait = 0
				"missile": session.weapons.launch(actor.uid,0,actor.vehicle.muzzle(),actor.vehicle.forward(),55,140,6,target.uid)
				"nova":
					session.weapons.launch(actor.uid,0,actor.vehicle.muzzle(),actor.vehicle.forward(),65,100,4,target.uid)

func _process(delta: float) -> void:
	elapsed_frame += delta
	_publish_web_state()
	if mode!="flight" or session==null or paused: return
	var dt := minf(delta,.05)
	var request := _request(dt)
	sound_wait = maxf(0,sound_wait-dt)
	if request.get("fire",false) and sound_wait<=0: audio.sfx("laser"); sound_wait = .14
	session.advance(dt,request)
	for event in session.events:
		notice = event.get("text",notice)
		if event.type=="hit":
			audio.sfx("hit")
			if event.get("id","")=="comet": _hit_flash = .8
			if actor_nodes.has(event.get("id","")) and actor_nodes[event.id].has_method("hit_flash"): actor_nodes[event.id].hit_flash()
		elif event.type=="pickup": audio.sfx("pickup")
		elif event.type=="warning": audio.sfx("warning")
		elif event.type in ["component","debrief"]: audio.sfx("explosion")
	session.events.clear(); _hit_flash = maxf(0,_hit_flash-dt*2)
	_sync_actors(dt); _update_camera(dt)
	overlay.queue_redraw()
	caption.text = "%s / %s\n%s\nShield %.0f / Energy %.0f / Missiles %d / Nova %d / %s\n%s" % [session.definition.title,session.state().id,session.state().text,session.player().hp,session.player().vehicle.energy,session.missiles,session.bombs,Squadron.FORMATIONS[session.formation],"HOLD "+_binding("ability")+": 1/↑ attack / 2/→ protect / 3/↓ cover / 4/← regroup" if assignment_hold>=.35 else notice]
	if session.selected in session.components: caption.text += "\nTARGET / "+session.selected+" / "+str(session.components[session.selected].hp)
	elif session.actors.has(session.selected): caption.text += "\nTARGET / "+session.selected+" / "+str(session.actors[session.selected].hp)
	elif session.selected.contains(":"):
		var parts: PackedStringArray = str(session.selected).split(":")
		if session.actors.has(parts[0]) and session.actors[parts[0]].parts.has(parts[1]): caption.text += "\nTARGET / "+session.selected+" / "+str(session.actors[parts[0]].parts[parts[1]].hp)
	if session.core_hp>0: caption.text += "\nCORE %.0f / %s" % [session.core_hp,"OPEN" if session.core_open() else "ARMORED"]
	if session.boss_kind==5 and fmod(session.stage_time,28)>=16 and fmod(session.stage_time,28)<20: caption.text += " / OPENING IN %.1fs"%(20-fmod(session.stage_time,28))
	if session.hazard_warning: caption.text += "\nDANGER FORECAST: leave the marked slab before it flashes; both side exits stay open"
	if session.forecast_time>0: caption.text += "\nMAJOR SECTION SEPARATION IN %.1fs / follow either marked side corridor"%session.forecast_time
	if session.definition.id=="anchorage_defense": caption.text += "\nREPAIR / "+session.repair_phase.replace("_"," ")
	if not session.player().vehicle.denied.is_empty(): caption.text += "\n"+session.player().vehicle.denied
	caption.text += "\nScore %d / Rings %d / Lasers Mk %d"%[session.score,session.rings,session.laser_level]
	caption.text += " / Dragonfly %.0f"%session.facts.carrier.hull
	if not session.required_cargo.is_empty(): caption.text += " / REQUIRED CARGO %.0f"%session.actors[session.required_cargo].hp
	if session.checkpoint_revision!=saved_checkpoint_revision:
		saved_stage = session.stage; saved_checkpoint_revision = session.checkpoint_revision; save.checkpoint(session.checkpoint,replay)
	var boss_music: bool = session.core_hp>0
	if boss_music!=last_music_boss: audio.start_operation_music(session.definition.id,boss_music); last_music_boss = boss_music
	if session.mode in ["won","lost"]:
		mode = session.mode
		if mode=="won" and not settled: save.settle(session.definition.id,session.score,session.facts,replay); settled = true
		_result_menu()

func _publish_web_state() -> void:
	if not OS.has_feature("web"): return
	if not bool(JavaScriptBridge.eval("new URLSearchParams(location.search).get('qa')==='1'")): return
	var bounds := campaign_ui.get_global_rect()
	var data := {"mode":mode.to_upper(),"paused":paused,"music_track":audio._current_track,"music_playing":audio._music.playing,"music_position":audio._music.get_playback_position(),"music_muted":audio.muted,"menu_visible":campaign_ui.visible,"menu_bounds":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y],"viewport":[get_viewport().get_visible_rect().size.x,get_viewport().get_visible_rect().size.y]}
	if session!=null:
		var vehicle = session.player().vehicle
		data.merge({"mission":session.definition.id,"stage":session.stage,"shield":session.player().hp,"player_x":vehicle.position.x,"player_y":vehicle.position.y,"player_z":vehicle.position.z,"energy":vehicle.energy,"maneuver":vehicle.maneuver.kind,"flight_time":session.elapsed,"shots_fired":session.weapons.next_id,"missiles":session.missiles,"hostiles":session.living_hostiles().size(),"input_armed":input_armed})
	JavaScriptBridge.eval("window.__foxlikeQA="+JSON.stringify(data))

func _sync_actors(dt: float) -> void:
	for entry in session.cover:
		if str(entry.id).begins_with("carrier-"): continue
		if not cover_nodes.has(entry.id): cover_nodes[entry.id] = box_mesh(world_nodes,entry.box.get_center(),entry.box.size,world_nodes.get_meta("cover_color",Color("37566a")))
		cover_nodes[entry.id].visible = entry.get("visual",true)
		cover_nodes[entry.id].position = entry.box.get_center()
		cover_nodes[entry.id].mesh.size = entry.box.size
	hazard_node.visible = session.hazard_warning or session.hazard_active
	hazard_node.position = session.hazard_box.get_center(); hazard_node.mesh.size = session.hazard_box.size
	carrier_node.position = session.carrier_position; carrier_node.pose(session.door,session.elapsed); carrier_node.set_damage(float(session.facts.carrier.hull)/100)
	for actor in session.actors.values():
		if not actor_nodes.has(actor.id):
			var rig: Node3D = Walker.new() if actor.kind=="walker" else Ship.new()
			world_nodes.add_child(rig)
			if actor.kind=="walker": rig.scale = Vector3.ONE*2
			else: rig.setup(actor.kind,Color("ff765e") if actor.team==1 else Color("85d7ee"))
			if actor.kind!="walker": rig._facing = 0.0; rig.visual.rotation.y = 0.0
			actor_nodes[actor.id] = rig
		var rig: Node3D = actor_nodes[actor.id]
		rig.visible = actor.hp>0 or actor.phase=="disabled"
		rig.position = actor.vehicle.position; rig.basis = actor.vehicle.orientation()
		if actor.kind=="walker":
			rig.position.y -= 7
			if rig.get_meta("checkpoint_revision",-1)!=session.checkpoint_revision: rig.reset_pose(); rig.set_meta("checkpoint_revision",session.checkpoint_revision)
			rig.resolve_pose(actor.vehicle.position.distance_to(actor.vehicle.previous_position),actor.vehicle.speed>1,actor.vehicle.events.has("fired"),actor.parts.get("Left leg",{}).get("hp",0)<=0 or actor.parts.get("Right leg",{}).get("hp",0)<=0,dt)
			rig.gun.visible = actor.parts.get("Gun",{}).get("hp",0)>0
		else:
			rig.animate(session.elapsed,dt,actor.vehicle.bank,0.0,actor.vehicle.speed/38,actor.vehicle.roll_angle(),1-actor.hp/actor.max_hp)
			if actor.hp<actor.max_hp or actor.task in ["transport","hold"]:
				var phase: String = "abort" if actor.task=="hold" else "alignment" if actor.task=="transport" else "damaged"
				preload("res://scripts/campaign/airframe_pose.gd").apply(rig,phase,fmod(session.stage_time,2)/2,1-actor.hp/actor.max_hp,not bool(session.settings.get("camera_roll",false)))
			if actor.id=="comet" and session.ground_mode() and rig._parts.has("tank_turret"): rig._parts.tank_turret.rotation.x = -session.tank_aim
	if session.core_hp>0 and rendered_boss!=session.boss_kind:
		if is_instance_valid(boss_node): boss_node.queue_free()
		boss_node = Ship.new(); world_nodes.add_child(boss_node); boss_node.setup("boss%d" % [session.boss_kind+1]); boss_node.scale = Vector3.ONE*2
		rendered_boss = session.boss_kind
	if is_instance_valid(boss_node):
		boss_node.visible = session.core_hp>0 or (session.state().kind=="escape" and session.stage_time<12)
		boss_node.position = session.boss_position; boss_node.rotation.z = session.vessel_angle if session.definition.id=="terminus_falling_yard" else .025*session.stage_time if session.state().kind=="escape" else 0.0
		boss_node.animate(session.elapsed,dt,0,0,1)
		for index in range(mini(boss_node.weak_points.size(),session.components.size())): boss_node.weak_points[index].visible = not session.components[session.components.keys()[index]].disabled
	for name in session.components:
		if not part_nodes.has(name): part_nodes[name] = box_mesh(world_nodes,Actor.point(session.components[name].point),Vector3(9,9,9),Color("ffb467"))
		part_nodes[name].visible = not session.components[name].disabled
		part_nodes[name].position = Actor.point(session.components[name].point)
	for name in part_nodes:
		if not session.components.has(name): part_nodes[name].hide()
	for actor in session.actors.values():
		for name in actor.parts:
			var id: String = actor.id+":"+name
			if not part_nodes.has(id): part_nodes[id] = box_mesh(world_nodes,Vector3.ZERO,Vector3.ONE*3,Color("ffd38c"))
			part_nodes[id].visible = actor.hp>0 and actor.phase=="active" and actor.parts[name].hp>0
			part_nodes[id].position = actor.vehicle.position+actor.vehicle.orientation()*Actor.point(actor.parts[name].offset)
	for item in session.pickups:
		var id: String = "pickup:"+item.id
		if not part_nodes.has(id):
			var mesh := MeshInstance3D.new()
			if item.kind=="ring":
				var ring := TorusMesh.new(); ring.inner_radius = 2; ring.outer_radius = 3; ring.rings = 24; ring.ring_segments = 8; mesh.mesh = ring; mesh.rotation.x = PI*.5
			else:
				var cube := BoxMesh.new(); cube.size = Vector3.ONE*3; mesh.mesh = cube
			var colors := {"ring":Color("f7cf76"),"ammo":Color("76e2fa"),"repair":Color("8be19f"),"wing":Color("c7a0ff"),"nova":Color("ff8374")}
			mesh.material_override = material(colors[item.kind],true); world_nodes.add_child(mesh); part_nodes[id] = mesh
		part_nodes[id].visible = true; part_nodes[id].position = Actor.point(item.point)
	var ids := []
	for shot in session.weapons.shots:
		ids.append(shot.id)
		if not shot_nodes.has(shot.id): shot_nodes[shot.id] = box_mesh(world_nodes,shot.position,Vector3(.25,.25,2.4),Color("ff9274") if shot.team==1 else Color("75efff"))
		shot_nodes[shot.id].position = shot.position
		if shot_nodes[shot.id].position.distance_to(shot.position+shot.velocity)>.01: shot_nodes[shot.id].look_at(shot.position+shot.velocity)
	for id in shot_nodes.keys():
		if not ids.has(id): shot_nodes[id].queue_free(); shot_nodes.erase(id)

func _update_camera(dt: float, immediate: bool = false) -> void:
	if session==null: return
	vehicles[0] = session.player().vehicle
	cover = session.cover; elapsed = session.elapsed
	reduced_motion = true
	super._update_camera(dt,immediate)
	if bool(session.settings.get("boost_fov",false)): camera.fov = lerpf(camera.fov,67.0+(session.player().vehicle.speed-38)*.18,1-exp(-dt*4))
	if bool(session.settings.get("camera_shake",false)) and _hit_flash>0: camera.position += Vector3(sin(elapsed*33),cos(elapsed*27),0)*_hit_flash*.12
	if bool(session.settings.get("camera_roll",false)): camera.rotation.z = session.player().vehicle.bank*.1

func draw_overlay(surface: Control) -> void:
	if session==null: return
	var font := ThemeDB.fallback_font
	for actor in session.actors.values():
		if actor.id=="comet" or actor.hp<=0 or camera.is_position_behind(actor.vehicle.position): continue
		if actor.team==1 and (camera.position.distance_to(actor.vehicle.position)>300 or not Geometry.first_cover(session.player().vehicle.position,actor.vehicle.position,session.cover).is_empty()): continue
		var screen: Vector2 = camera.unproject_position(actor.vehicle.position)
		var color := Color("ff947d") if actor.team==1 else Color("85e4e8")
		surface.draw_circle(screen,8,color,false,2)
		surface.draw_string(font,screen+Vector2(12,-8),actor.id+" / "+("ABOVE" if actor.vehicle.position.y>session.player().vehicle.position.y+8 else "BELOW" if actor.vehicle.position.y<session.player().vehicle.position.y-8 else "LEVEL"),HORIZONTAL_ALIGNMENT_LEFT,-1,14,color)
	var target := Vector3(110,95,80)
	var target_label := "REGROUP / DRAGONFLY"
	if session.state().kind in ["combat","rival","ground"]:
		target = session.player().vehicle.position+session.player().vehicle.forward()*110
		target_label = "SEARCH / ABOVE AND BELOW"
		for actor in session.living_hostiles():
			if Geometry.first_cover(session.player().vehicle.position,actor.vehicle.position,session.cover).is_empty(): target = actor.vehicle.position; target_label = "CLEAR DEFENSE"; break
	if session.state().kind=="boss": target = session.boss_position; target_label = "CORE / "+("OPEN" if session.core_open() else "ARMORED")
	if session.state().kind=="control":
		for name in session.components:
			if session.components[name].hp>0: target = Actor.point(session.components[name].point); target_label = "DISABLE / "+name; break
	if session.state().kind=="escort" and not session.required_cargo.is_empty(): target = session.actors[session.required_cargo].vehicle.position; target_label = "PROTECT / REQUIRED CARGO"
	if session.state().kind=="intercept" and not session.required_cargo.is_empty(): target = session.actors[session.required_cargo].vehicle.position; target_label = "DISABLE REAR DRIVE"
	if session.state().kind=="interact": target = Actor.point(session.state().point); target_label = "HOLD "+_binding("interact")+" / RECOVER INFORMATION"
	if session.state().id=="codes" and session.actors.has("intercept_craft"): target = session.actors.intercept_craft.vehicle.position
	if session.state().kind=="escape": target = Vector3(150,65,120); target_label = "ESCAPE / SAFE SECTOR"
	if session.state().get("player_recovery",false): target = Vector3(0,74,-66); target_label = "ALIGN AND ENTER BAY"
	if not camera.is_position_behind(target):
		var screen: Vector2 = camera.unproject_position(target)
		surface.draw_rect(Rect2(screen-Vector2(10,10),Vector2(20,20)),Color("f7d38c"),false,2)
		surface.draw_string(font,screen+Vector2(15,0),target_label,HORIZONTAL_ALIGNMENT_LEFT,-1,16,Color("f7d38c"))
	for name in session.components:
		var point := Actor.point(session.components[name].point)
		if session.components[name].hp<=0 or camera.is_position_behind(point): continue
		var screen: Vector2 = camera.unproject_position(point)
		surface.draw_string(font,screen,name+" / "+str(roundi(session.components[name].hp)),HORIZONTAL_ALIGNMENT_CENTER,-1,14,Color("ffd38c"))
	if session.capital_warning>0 and not camera.is_position_behind(session.capital_origin) and not camera.is_position_behind(session.capital_aim):
		surface.draw_line(camera.unproject_position(session.capital_origin),camera.unproject_position(session.capital_aim),Color("ff8768"),3)
		surface.draw_circle(camera.unproject_position(session.capital_aim),18,Color("ff8768"),false,3)
	surface.draw_line(surface.size*.5-Vector2(10,0),surface.size*.5+Vector2(10,0),Color.WHITE)
	surface.draw_line(surface.size*.5-Vector2(0,10),surface.size*.5+Vector2(0,10),Color.WHITE)
	if session.hazard_warning or session.hazard_active:
		for point in [session.hazard_box.position,session.hazard_box.end]:
			if not camera.is_position_behind(point): surface.draw_circle(camera.unproject_position(point),18,Color("ffb260"),false,3)

func _disarm_controls() -> void:
	input_armed = false; assignment_held = false; assignment_hold = 0; stunt_request = ""; _roll_request = 0; mouse_look = Vector2.ZERO

func _pause_menu() -> void:
	_disarm_controls()
	_clear_menu(); _text("FLIGHT PAUSED",28); _text(notice)
	_button("RESUME",func():paused = false; input_armed = false; campaign_ui.hide()).grab_focus()
	_button("RETRY CHECKPOINT",func():session.restore(session.checkpoint); paused = false; mode = "flight"; input_armed = false; campaign_ui.hide())
	_button("CONTROLS AND PRESENTATION",func():_settings_menu())
	_button("RETURN TO FLIGHT DECK",func():_menu())

func _result_menu() -> void:
	_clear_menu(); _text("OPERATION COMPLETE" if mode=="won" else "OPERATION FAILED",28)
	_text(session.reason if mode=="lost" else "Carrier hull %.0f. Repair parts %s. Drive repaired %s. Rescues %d. Rival outcomes %s." % [session.facts.carrier.hull,str(session.facts.carrier.parts_secured),str(session.facts.carrier.repaired),session.facts.rescues.size(),str(session.facts.rivals)])
	if mode=="won" and session.definition.id=="tempest_crown": _text(session.ending_text())
	if mode=="lost": _button("RETRY LAST CHECKPOINT",func():session.restore(session.checkpoint); mode = "flight"; paused = false; input_armed = false; campaign_ui.hide()).grab_focus()
	elif int(session.definition.index)<Catalog.IDS.size()-1: _button("NEXT OPERATION",func():_briefing(Catalog.IDS[int(session.definition.index)+1])).grab_focus()
	_button("RESTART OPERATION",func():_briefing(session.definition.id))
	_button("RETURN TO FLIGHT DECK",func():_menu())

func _settings_menu() -> void:
	_clear_menu(); _text("CONTROLS AND PRESENTATION",28); _text(notice)
	for action in KEYS:
		_button(action.to_upper()+" / "+OS.get_keycode_string(int(save.data.bindings.get(action,KEYS[action]))),func():rebind = action; notice = "Press an unused key for "+action; _text(notice))
	_text("CONTROLLER / left stick steers, RT fires. Select an action, then press a free button.")
	for action in PAD:
		_button(action.to_upper()+" / "+_pad_label(action),func():pad_rebind = action; notice = "Press an unused controller button for "+action; _text(notice))
	for setting in ["pitch_hold","camera_roll","camera_shake","boost_fov"]:
		var toggle := CheckButton.new(); toggle.text = setting.replace("_"," "); toggle.button_pressed = bool(save.data.settings[setting])
		toggle.toggled.connect(func(value: bool):
			save.data.settings[setting] = value
			save.write()
			if session!=null:
				session.settings[setting] = value
				session.player().vehicle.pitch_hold = bool(save.data.settings.pitch_hold)
		); ui_stack.add_child(toggle)
	_button("UI SCALE / "+str(save.data.settings.ui_scale),func():save.data.settings.ui_scale = 1.5 if float(save.data.settings.ui_scale)<1.5 else 1.0; save.write(); _resize_ui(); _settings_menu())
	_button("RESTORE DEFAULT BINDINGS",func():save.data.bindings = {}; save.data.pad_bindings = {}; save.write(); _settings_menu())
	_button("BACK",func():_pause_menu() if mode=="flight" else _menu())

func _exit_tree() -> void:
	if is_instance_valid(audio): audio.stop_music()
