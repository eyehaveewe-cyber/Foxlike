extends Control
## PBR's complete catalog, thumbnail renderer and route chart; free orbit access.
signal selected(id: String)
signal dismissed
const Catalog = preload("res://scripts/orbit/pbr_catalog.gd")
const Visual = preload("res://scripts/orbit/pbr_planet_visual.gd")
const Chart = preload("res://scripts/orbit/pbr_system_chart.gd")
var panel: PanelContainer
var grid: GridContainer
var chart: Control
var view_button: Button
var current_id := "viridia"
var cards: Dictionary = {}
var contents: VBoxContainer

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade := ColorRect.new()
	shade.color = Color(.005,.012,.025,.88)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)
	panel = PanelContainer.new()
	panel.size = Vector2(1080,690)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("0d1926")
	style.border_color = Color("39535e")
	style.set_border_width_all(1)
	style.set_content_margin_all(22)
	panel.add_theme_stylebox_override("panel",style)
	add_child(panel)
	contents = VBoxContainer.new()
	contents.add_theme_constant_override("separation",14)
	panel.add_child(contents)
	var header := HBoxContainer.new()
	contents.add_child(header)
	var title := Label.new()
	title.text = "ASTERION  /  CHOOSE AN ORBIT"
	title.add_theme_font_size_override("font_size",25)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	view_button = Button.new()
	view_button.text = "SYSTEM CHART"
	view_button.pressed.connect(toggle_view)
	header.add_child(view_button)
	var close := Button.new()
	close.text = "RESUME / P"
	close.pressed.connect(func(): dismissed.emit())
	header.add_child(close)
	var hint := Label.new()
	hint.text = "Twelve worlds from Project Barrel Roll. Select a world to depart from its observatory."
	hint.add_theme_color_override("font_color",Color("9eb9c6"))
	contents.add_child(hint)
	grid = GridContainer.new()
	grid.columns = 4
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation",12)
	grid.add_theme_constant_override("v_separation",12)
	contents.add_child(grid)
	for body in Catalog.planets():
		var card := Button.new()
		card.custom_minimum_size = Vector2(250,128)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.size_flags_vertical = Control.SIZE_EXPAND_FILL
		card.tooltip_text = "Enter "+body.name+" orbit. Every catalogued moon is a physical destination."
		card.pressed.connect(func(): selected.emit(body.id))
		grid.add_child(card)
		cards[body.id] = card
		var visual := Visual.new()
		visual.position = Vector2(50,62)
		card.add_child(visual)
		visual.configure(body,27.0)
		_label(card,body.name,Vector2(101,29),18,body.accent)
		_label(card,body.kind,Vector2(101,57),12,Color("b0c8d3"))
		_label(card,"%02d MOONS%s" % [body.moons," / RINGS" if body.ringed else ""],Vector2(101,82),11,Color("8bc6cc"))
		_label(card,"ENTER ORBIT  >",Vector2(101,108),11,Color("e2d4ac"))
	var footer := Label.new()
	footer.text = "93 physical moons across 12 sectors  /  N waypoint  /  F face target  /  T travel drive\nSelecting an orbit moves to its station. Moon journeys within that orbit are continuous flight."
	footer.add_theme_font_size_override("font_size",12)
	footer.add_theme_color_override("font_color",Color("98b7c7"))
	contents.add_child(footer)
	get_viewport().size_changed.connect(_resize)
	panel.resized.connect(_resize)
	_resize()
	hide()

func _label(parent: Control, value: String, at: Vector2, font_size: int, color: Color) -> void:
	var label := Label.new()
	label.text = value
	label.position = at
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)

func open(id: String) -> void:
	current_id = id
	show()
	cards[id].grab_focus()
	for key in cards: cards[key].modulate = Color("b8faff") if key==id else Color.WHITE
	if chart!=null:
		chart.current_id = id
		chart.set_process(chart.visible)
		chart.set_process_unhandled_key_input(chart.visible)

func close() -> void:
	hide()
	if chart!=null:
		chart.set_process(false)
		chart.set_process_unhandled_key_input(false)

func toggle_view() -> void:
	if chart==null:
		chart = Chart.new()
		chart.custom_minimum_size = Vector2(1030,408)
		chart.size_flags_vertical = Control.SIZE_EXPAND_FILL
		chart.bodies = Catalog.planets()
		chart.mode = "explore"
		chart.current_id = current_id
		for body in chart.bodies: chart.available_ids.append(body.id)
		chart.body_selected.connect(func(id: String): selected.emit(id))
		contents.add_child(chart)
		contents.move_child(chart,3)
		chart.hide()
	grid.visible = not grid.visible
	chart.visible = not grid.visible
	chart.set_process(chart.visible)
	chart.set_process_unhandled_key_input(chart.visible)
	view_button.text = "PLANET GRID" if chart.visible else "SYSTEM CHART"

func _resize() -> void:
	var view := get_viewport().get_visible_rect().size
	var factor := minf(1.0,minf(view.x/1140.0,view.y/750.0))
	panel.scale = Vector2.ONE*factor
	panel.position = (view-panel.size*factor)*.5
