class_name OrbitSystemChart
extends Control

signal body_selected(id: String)
signal selection_changed(id: String)

const GOLD := Color("c7a66d")
const AQUA := Color("74d9cf")
const STAR_POSITION := Vector2(-1300.0, -80.0)
const PLANET_SCRIPT := preload("res://scripts/orbit/pbr_planet_visual.gd")

var bodies: Array[Dictionary] = []
var current_id: String = ""
var visited: Array[String] = []
var completed: Array[String] = []
var available_ids: Array[String] = []
var mode: String = "route"
var selected_id: String = ""
var detail_mode: bool = false

var _visuals: Dictionary = {}
var _sun: OrbitPlanetVisual
var _detail_planet: OrbitPlanetVisual
var _camera: Vector2 = Vector2.ZERO
var _target_camera: Vector2 = Vector2.ZERO
var _zoom: float = 0.38
var _target_zoom: float = 0.38
var _fit_zoom: float = 0.38
var _hovered_id: String = ""
var _stars: Array[Dictionary] = []
var _rocks: Array[Dictionary] = []
var _clouds: Array[Dictionary] = []
var _body_signature: String = ""
var _clock: float = 0.0
var _dragging: bool = false
var _pawn_position: Vector2 = Vector2.ZERO
var _pawn_from: Vector2 = Vector2.ZERO
var _pawn_to: Vector2 = Vector2.ZERO
var _pawn_travel: float = 1.0
var _pawn_id: String = ""
var _last_size: Vector2 = Vector2.ZERO
var _font: Font

func _ready() -> void:
	clip_contents = true
	focus_mode = Control.FOCUS_ALL if mouse_filter != Control.MOUSE_FILTER_IGNORE else Control.FOCUS_NONE
	_font = ThemeDB.fallback_font
	_build_space()
	_sun = PLANET_SCRIPT.new()
	add_child(_sun)
	_sun.configure({"id": "helios", "kind": "sun", "color": Color("f5bc6b"), "accent": Color("ffebae"), "moons": 0}, 72.0)
	_detail_planet = PLANET_SCRIPT.new()
	add_child(_detail_planet)
	_detail_planet.visible = false
	_sync_visuals()
	reset_view()
	set_process(true)

func _build_space() -> void:
	var random := RandomNumberGenerator.new()
	random.seed = 982138
	for index in range(360):
		_stars.append({"point": Vector2(random.randf(), random.randf()), "size": random.randf_range(0.45, 1.4), "alpha": random.randf_range(0.16, 0.70), "phase": random.randf_range(0, TAU)})
	for belt in range(2):
		for index in range(260):
			var angle := random.randf_range(0.0, TAU)
			var orbit := (880.0 if belt == 0 else 1710.0) + random.randf_range(-70.0, 70.0)
			var center := STAR_POSITION + Vector2(cos(angle) * orbit, sin(angle) * orbit * 0.47)
			_rocks.append({"point": center, "size": random.randf_range(1.1, 5.5), "alpha": random.randf_range(0.20, 0.58), "angle": angle, "belt": belt})
	_clouds.append({"center": Vector2(-350, -350), "extent": Vector2(950, 650), "texture": _make_cloud(14, Color("357e84"))})
	_clouds.append({"center": Vector2(650, 350), "extent": Vector2(980, 690), "texture": _make_cloud(69, Color("916645"))})
	_clouds.append({"center": Vector2(940, -380), "extent": Vector2(680, 540), "texture": _make_cloud(33, Color("4e567f"))})

func _make_cloud(seed_value: int, tint: Color) -> ImageTexture:
	var noise := FastNoiseLite.new()
	noise.seed = seed_value
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.018
	noise.fractal_octaves = 4
	var image := Image.create(320, 220, false, Image.FORMAT_RGBA8)
	for y in range(220):
		for x in range(320):
			var normal := Vector2(float(x - 160) / 153.0, float(y - 110) / 102.0)
			var envelope := maxf(0.0, 1.0 - normal.length_squared())
			var field := noise.get_noise_2d(float(x), float(y)) * 0.5 + 0.5
			var alpha := pow(envelope, 1.5) * pow(field, 2.3) * 0.47
			var pixel := tint.lerp(Color("99bbc0"), field * 0.28)
			pixel.a = alpha
			image.set_pixel(x, y, pixel)
	return ImageTexture.create_from_image(image)

func _sync_visuals() -> void:
	var signature := ""
	for body in bodies:
		signature += str(body.get("id", "")) + ":" + str(body.get("moons", 0)) + ";"
	if signature == _body_signature:
		return
	_body_signature = signature
	for visual in _visuals.values():
		visual.queue_free()
	_visuals.clear()
	for body in bodies:
		var visual := PLANET_SCRIPT.new()
		add_child(visual)
		visual.configure(body, float(body.get("radius", 40.0)) * _zoom)
		_visuals[str(body.get("id", ""))] = visual
	if _detail_planet != null:
		move_child(_detail_planet, get_child_count() - 1)
	if not current_id.is_empty() and _pawn_id.is_empty():
		_pawn_position = _body_position(current_id)
		_pawn_to = _pawn_position
		_pawn_id = current_id

func _body_position(id: String) -> Vector2:
	for body in bodies:
		if str(body.get("id", "")) == id:
			return Vector2(body.get("position", Vector2.ZERO))
	return Vector2.ZERO

func _body_data(id: String) -> Dictionary:
	for body in bodies:
		if str(body.get("id", "")) == id:
			return body
	return {}

func world_to_screen(point: Vector2) -> Vector2:
	return size * 0.5 + (point - _camera) * _zoom

func screen_to_world(point: Vector2) -> Vector2:
	return _camera + (point - size * 0.5) / _zoom

func _overview_bounds() -> Rect2:
	var bounds := Rect2(STAR_POSITION - Vector2(170, 170), Vector2(340, 340))
	for body in bodies:
		var point := Vector2(body.get("position", Vector2.ZERO))
		var padding := maxf(100.0, float(body.get("radius", 45.0)) * 2.4)
		bounds = bounds.expand(point - Vector2.ONE * padding)
		bounds = bounds.expand(point + Vector2.ONE * padding)
	return bounds

func reset_view() -> void:
	detail_mode = false
	selected_id = ""
	if _detail_planet != null:
		_detail_planet.visible = false
	var bounds := _overview_bounds()
	_target_camera = bounds.get_center()
	_fit_zoom = clampf(minf(maxf(size.x - 130.0, 100.0) / bounds.size.x, maxf(size.y - 130.0, 100.0) / bounds.size.y), 0.20, 0.70)
	_target_zoom = _fit_zoom
	if _last_size == Vector2.ZERO:
		_camera = _target_camera
		_zoom = _target_zoom
	queue_redraw()

func set_overview() -> void:
	reset_view()

func focus_body(id: String, close_up: bool = true) -> void:
	var body := _body_data(id)
	if body.is_empty():
		return
	selected_id = id
	selection_changed.emit(id)
	if close_up:
		detail_mode = true
		var world_radius := float(body.get("radius", 45.0))
		var preferred_radius := 205.0 if mouse_filter == Control.MOUSE_FILTER_IGNORE else 180.0
		_target_zoom = clampf(preferred_radius / world_radius, 1.1, 6.2)
		var target_screen := Vector2(size.x * (0.43 if mouse_filter == Control.MOUSE_FILTER_IGNORE else 0.38), size.y * (0.46 if mouse_filter == Control.MOUSE_FILTER_IGNORE else 0.49))
		_target_camera = Vector2(body.get("position", Vector2.ZERO)) - (target_screen - size * 0.5) / _target_zoom
		_detail_planet.configure(body, world_radius * _zoom, true)
		_detail_planet.visible = true
	else:
		detail_mode = false
		_target_camera = Vector2(body.get("position", Vector2.ZERO))
		_target_zoom = maxf(_fit_zoom, 0.55)
	queue_redraw()

func travel_pawn(id: String) -> void:
	if _body_data(id).is_empty():
		return
	_pawn_from = _pawn_position
	_pawn_to = _body_position(id)
	_pawn_travel = 0.0
	_pawn_id = id
	current_id = id
	queue_redraw()

func zoom_by(factor: float) -> void:
	if detail_mode:
		return
	_target_zoom = clampf(_target_zoom * factor, _fit_zoom * 0.70, 1.8)

func _process(delta: float) -> void:
	_clock += delta
	_sync_visuals()
	if size != _last_size:
		_last_size = size
		if not detail_mode:
			reset_view()
		else:
			focus_body(selected_id)
	if mouse_filter != Control.MOUSE_FILTER_IGNORE and not detail_mode and not _dragging:
		var direction := Vector2.ZERO
		if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT):
			direction.x -= 1.0
		if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT):
			direction.x += 1.0
		if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP):
			direction.y -= 1.0
		if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN):
			direction.y += 1.0
		_target_camera += direction.normalized() * delta * 520.0 / maxf(_zoom, 0.3)
	var smoothing := 1.0 - exp(-delta * 6.5)
	_camera = _camera.lerp(_target_camera, smoothing)
	_zoom = lerpf(_zoom, _target_zoom, smoothing)
	if _pawn_travel < 1.0:
		_pawn_travel = minf(1.0, _pawn_travel + delta * 0.75)
		var t := _pawn_travel * _pawn_travel * (3.0 - 2.0 * _pawn_travel)
		_pawn_position = _pawn_from.lerp(_pawn_to, t)
	elif _pawn_id.is_empty() and not current_id.is_empty():
		_pawn_id = current_id
		_pawn_position = _body_position(current_id)
	_update_planet_positions()
	queue_redraw()

func _update_planet_positions() -> void:
	if _sun == null:
		return
	_sun.visible = not detail_mode
	_sun.position = world_to_screen(STAR_POSITION)
	_sun.set_radius(90.0 * _zoom)
	for body in bodies:
		var visual: OrbitPlanetVisual = _visuals.get(str(body.get("id", "")))
		if visual == null:
			continue
		visual.visible = not detail_mode
		visual.position = world_to_screen(Vector2(body.get("position", Vector2.ZERO)))
		visual.set_radius(float(body.get("radius", 40.0)) * _zoom)
	if detail_mode and not selected_id.is_empty():
		var body := _body_data(selected_id)
		_detail_planet.visible = true
		_detail_planet.position = world_to_screen(Vector2(body.get("position", Vector2.ZERO)))
		_detail_planet.set_radius(float(body.get("radius", 40.0)) * _zoom)
	else:
		_detail_planet.visible = false

func _hit_body(point: Vector2) -> String:
	var nearest_id := ""
	var nearest_distance := INF
	for body in bodies:
		var center := world_to_screen(Vector2(body.get("position", Vector2.ZERO)))
		var hit_radius := maxf(22.0, float(body.get("radius", 40.0)) * _zoom * 1.15)
		var distance := center.distance_to(point)
		if distance < hit_radius and distance < nearest_distance:
			nearest_id = str(body.get("id", ""))
			nearest_distance = distance
	return nearest_id

func _gui_input(event: InputEvent) -> void:
	if detail_mode:
		return
	if event is InputEventMouseMotion:
		if _dragging:
			_target_camera -= event.relative / _zoom
			_camera = _target_camera
		else:
			_hovered_id = _hit_body(event.position)
			mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if not _hovered_id.is_empty() else Control.CURSOR_ARROW
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			_dragging = event.pressed
			accept_event()
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var hit := _hit_body(event.position)
			if not hit.is_empty():
				grab_focus()
				selected_id = hit
				selection_changed.emit(hit)
				body_selected.emit(hit)
				accept_event()
		if event.pressed and (event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			var point_before: Vector2 = _target_camera + (event.position - size * 0.5) / _target_zoom
			var factor := 1.15 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1.0 / 1.15
			_target_zoom = clampf(_target_zoom * factor, _fit_zoom * 0.70, 1.8)
			_target_camera = point_before - (event.position - size * 0.5) / _target_zoom
			accept_event()

func _unhandled_key_input(event: InputEvent) -> void:
	if mouse_filter == Control.MOUSE_FILTER_IGNORE:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == KEY_HOME:
			reset_view()
			get_viewport().set_input_as_handled()

func _orbit_points(orbit_radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(101):
		var angle := TAU * float(index) / 100.0
		points.append(world_to_screen(STAR_POSITION + Vector2(cos(angle) * orbit_radius, sin(angle) * orbit_radius * 0.47)))
	return points

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color("080f1b"))
	if _font == null:
		return
	_draw_stars()
	for cloud in _clouds:
		var extent := Vector2(cloud.extent) * _zoom
		var center := world_to_screen(Vector2(cloud.center))
		draw_texture_rect(cloud.texture, Rect2(center - extent * 0.5, extent), false, Color(1, 1, 1, 0.7 if detail_mode else 1.0))
	if detail_mode:
		_draw_detail()
		return
	for orbit_radius in [360.0, 570.0, 880.0, 1160.0, 1440.0, 1710.0, 2040.0, 2350.0]:
		draw_polyline(_orbit_points(orbit_radius), Color(0.43, 0.58, 0.66, 0.11), 1.0, true)
	_draw_asteroids()
	_draw_routes()
	_draw_map_labels()
	_draw_pawn()
	_draw_coordinates()

func _draw_stars() -> void:
	for star in _stars:
		var point := Vector2(star.point) * size
		var parallax := _camera * 0.009
		point.x = fposmod(point.x - parallax.x, maxf(size.x, 1.0))
		point.y = fposmod(point.y - parallax.y, maxf(size.y, 1.0))
		var alpha := float(star.alpha) * (0.88 + sin(_clock * 0.35 + float(star.phase)) * 0.12)
		draw_circle(point, float(star.size), Color(0.63, 0.74, 0.84, alpha))
		if float(star.size) > 1.32:
			draw_line(point - Vector2(3.0, 0.0), point + Vector2(3.0, 0.0), Color(0.73, 0.85, 0.92, alpha * 0.22), 1.0)
			draw_line(point - Vector2(0.0, 3.0), point + Vector2(0.0, 3.0), Color(0.73, 0.85, 0.92, alpha * 0.22), 1.0)

func _draw_asteroids() -> void:
	for rock in _rocks:
		var point := world_to_screen(Vector2(rock.point))
		if not Rect2(Vector2(-10, -10), size + Vector2(20, 20)).has_point(point):
			continue
		var rock_size := maxf(0.7, float(rock.size) * _zoom)
		var color := Color(0.62, 0.60, 0.56, float(rock.alpha))
		var points := PackedVector2Array([point + Vector2(-rock_size, -rock_size * 0.4), point + Vector2(rock_size * 0.4, -rock_size), point + Vector2(rock_size, rock_size * 0.3), point + Vector2(-rock_size * 0.2, rock_size)])
		draw_colored_polygon(points, color)

func _draw_routes() -> void:
	var drawn: Dictionary = {}
	for body in bodies:
		var id := str(body.get("id", ""))
		for target in body.get("routes", []):
			var target_id := str(target)
			if _body_data(target_id).is_empty():
				continue
			var key := "|".join([id, target_id] if id < target_id else [target_id, id])
			if drawn.has(key):
				continue
			drawn[key] = true
			var start := world_to_screen(Vector2(body.get("position", Vector2.ZERO)))
			var end := world_to_screen(_body_position(target_id))
			var direction := (end - start).normalized()
			start += direction * maxf(23.0, float(body.get("radius", 40.0)) * _zoom * 1.35)
			end -= direction * maxf(23.0, float(_body_data(target_id).get("radius", 40.0)) * _zoom * 1.35)
			var active := (id == current_id and target_id in available_ids) or (target_id == current_id and id in available_ids)
			var cleared := id in completed and target_id in completed
			var color := Color(AQUA, 0.62) if cleared else (Color(GOLD, 0.69) if active else Color(0.36, 0.48, 0.59, 0.35))
			if mode == "explore":
				color.a *= 0.4
			var length := start.distance_to(end)
			var dash := 8.0
			var gap := 7.0
			for distance in range(0, int(length), int(dash + gap)):
				draw_line(start + direction * float(distance), start + direction * minf(float(distance) + dash, length), color, 1.2 if active else 0.8, true)
			if active:
				var middle := start.lerp(end, 0.57)
				var side := direction.orthogonal()
				draw_polyline(PackedVector2Array([middle - direction * 5.0 + side * 4.0, middle, middle - direction * 5.0 - side * 4.0]), color, 1.3, true)

func _draw_map_labels() -> void:
	for body in bodies:
		var id := str(body.get("id", ""))
		var center := world_to_screen(Vector2(body.get("position", Vector2.ZERO)))
		var radius := float(body.get("radius", 40.0)) * _zoom
		var highlighted := id == _hovered_id or id == selected_id
		var available := id in available_ids
		var complete := id in completed
		var color := AQUA if complete else (GOLD if available or id == current_id else Color("a9b8c5"))
		if highlighted:
			draw_arc(center, maxf(radius * 1.08, 22.0), 0.0, TAU, 52, Color(color, 0.80), 1.2, true)
			draw_arc(center, maxf(radius * 1.08, 22.0) + 5.0, -PI * 0.75, -PI * 0.2, 16, Color(color, 0.35), 1.0, true)
		if id == current_id:
			draw_arc(center, maxf(radius * 1.1, 23.0) + 6.0, 0.2, PI - 0.2, 24, Color(GOLD, 0.50), 1.0, true)
		var text_position := center + Vector2(-60.0, maxf(radius * 1.3, 26.0) + 10.0)
		var name := str(body.get("name", id)).to_upper()
		var name_width := _font.get_string_size(name, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x
		text_position.x = center.x - name_width * 0.5
		draw_string(_font, text_position, name, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color)
		var subtitle := str(body.get("kind", "WORLD")).to_upper() + "  ·  " + str(body.get("moons", 0)) + " MOONS"
		var sub_width := _font.get_string_size(subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x
		draw_string(_font, Vector2(center.x - sub_width * 0.5, text_position.y + 15.0), subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color(0.58, 0.69, 0.76, 0.72))
		if complete:
			draw_circle(center + Vector2(radius * 0.7, -radius * 0.7), 5.0, Color("10282d"))
			draw_polyline(PackedVector2Array([center + Vector2(radius * 0.7 - 2, -radius * 0.7), center + Vector2(radius * 0.7, -radius * 0.7 + 2), center + Vector2(radius * 0.7 + 3, -radius * 0.7 - 2)]), AQUA, 1.1, true)
	var sun_screen := world_to_screen(STAR_POSITION)
	draw_string(_font, sun_screen + Vector2(-23, 90.0 * _zoom + 20.0), "SOLARIS", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(GOLD, 0.75))

func _draw_pawn() -> void:
	if current_id.is_empty():
		return
	var point := world_to_screen(_pawn_position)
	if _pawn_travel >= 1.0:
		var body := _body_data(current_id)
		point += Vector2(-maxf(29.0, float(body.get("radius", 40.0)) * _zoom * 1.12), -maxf(25.0, float(body.get("radius", 40.0)) * _zoom * 0.85))
	var direction := (_pawn_to - _pawn_from).normalized() if _pawn_travel < 1.0 else Vector2(1.0, -0.22)
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT
	var side := direction.orthogonal()
	var engine := point - direction * 7.0
	draw_circle(engine, 7.0, Color(0.35, 0.86, 0.83, 0.12))
	draw_line(engine, engine - direction * (9.0 + sin(_clock * 9.0) * 2.0), Color(AQUA, 0.65), 2.5, true)
	draw_colored_polygon(PackedVector2Array([point + direction * 10.0, point - direction * 7.0 + side * 5.5, point - direction * 4.0, point - direction * 7.0 - side * 5.5]), GOLD.lightened(0.23))
	draw_circle(point + direction * 2.0, 1.8, Color("173a4d"))

func _draw_coordinates() -> void:
	var color := Color(0.39, 0.55, 0.63, 0.20)
	for corner in [Vector2(22, 22), Vector2(size.x - 22, 22), Vector2(22, size.y - 22), Vector2(size.x - 22, size.y - 22)]:
		var inward := Vector2(1.0 if corner.x < size.x * 0.5 else -1.0, 1.0 if corner.y < size.y * 0.5 else -1.0)
		draw_line(corner, corner + Vector2(inward.x * 18.0, 0.0), color, 1.0)
		draw_line(corner, corner + Vector2(0.0, inward.y * 18.0), color, 1.0)

func _draw_detail() -> void:
	if selected_id.is_empty():
		return
	var body := _body_data(selected_id)
	var center := world_to_screen(Vector2(body.get("position", Vector2.ZERO)))
	var radius := float(body.get("radius", 40.0)) * _zoom
	var marker_color := Color(GOLD, 0.32)
	draw_arc(center, radius * 1.05, -1.23, -0.35, 38, marker_color, 1.0, true)
	draw_arc(center, radius * 1.05, 1.85, 2.75, 38, marker_color, 1.0, true)
	var x := center.x - radius * 1.15
	var y := center.y - radius * 1.15
	draw_line(Vector2(x, y), Vector2(x + 38, y), marker_color, 1.0)
	draw_line(Vector2(x, y), Vector2(x, y + 18), marker_color, 1.0)
	draw_string(_font, Vector2(x, y - 13), "ORBITAL RECONNAISSANCE", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(GOLD, 0.70))
	var footer := "SATELLITES   " + str(body.get("moons", 0)).pad_zeros(2) + "    /    " + str(body.get("kind", "WORLD")).to_upper()
	draw_string(_font, Vector2(center.x - radius * 1.0, center.y + radius * 1.52), footer, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.58, 0.72, 0.80, 0.75))
