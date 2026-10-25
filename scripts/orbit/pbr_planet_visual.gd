class_name OrbitPlanetVisual
extends Control

const PLANET_SHADER := preload("res://shaders/orbit/pbr_planet_surface.gdshader")

var body: Dictionary = {}
var radius: float = 36.0
var detailed: bool = false
var _sphere: ColorRect
var _surface: ShaderMaterial
var _ring_front: Control
var _moon_specs: Array[Dictionary] = []
var _moon_visuals: Array[ColorRect] = []
var _clock: float = 0.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sphere = ColorRect.new()
	_sphere.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_surface = ShaderMaterial.new()
	_surface.shader = PLANET_SHADER
	_sphere.material = _surface
	add_child(_sphere)
	_ring_front = Control.new()
	_ring_front.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_ring_front.draw.connect(_draw_foreground)
	add_child(_ring_front)
	_apply_surface()

func configure(data: Dictionary, display_radius: float, show_detail: bool = false) -> void:
	var changed: bool = body.get("id", "") != data.get("id", "")
	body = data
	radius = maxf(5.0, display_radius)
	detailed = show_detail
	if changed or _moon_specs.is_empty():
		_make_moons()
	if is_node_ready():
		_apply_surface()
	queue_redraw()
	if _ring_front != null:
		_ring_front.queue_redraw()

func set_radius(display_radius: float) -> void:
	radius = maxf(5.0, display_radius)
	if _sphere != null:
		_sphere.position = Vector2(-radius, -radius)
		_sphere.size = Vector2.ONE * radius * 2.0
		_update_moon_positions()
	queue_redraw()
	if _ring_front != null:
		_ring_front.queue_redraw()

func _apply_surface() -> void:
	_sphere.position = Vector2(-radius, -radius)
	_sphere.size = Vector2.ONE * radius * 2.0
	_surface.set_shader_parameter("base_color", body.get("color", Color("95b8ba")))
	_surface.set_shader_parameter("accent_color", body.get("accent", Color("d0cfb6")))
	_surface.set_shader_parameter("surface_type", _kind_index(str(body.get("kind", "rocky"))))
	_surface.set_shader_parameter("seed", float(str(body.get("id", "planet")).hash() % 10000) * 0.017)
	_surface.set_shader_parameter("atmosphere", 0.10 if _kind_index(str(body.get("kind", ""))) != 0 else 0.035)
	_sync_moon_visuals()

func _kind_index(kind: String) -> int:
	kind = kind.to_lower()
	if "sun" in kind or "star" in kind:
		return 7
	if "lava" in kind or "volcan" in kind or "magma" in kind:
		return 3
	if "desert" in kind or "arid" in kind:
		return 2
	if "ice" in kind or "frozen" in kind or "glacial" in kind:
		return 4
	if "storm" in kind or "toxic" in kind:
		return 6
	if "gas" in kind or "jovian" in kind or "giant" in kind:
		return 5
	if "ocean" in kind or "terrestrial" in kind or "earth" in kind or "garden" in kind:
		return 1
	return 0

func _make_moons() -> void:
	for visual in _moon_visuals:
		visual.queue_free()
	_moon_visuals.clear()
	_moon_specs.clear()
	var random := RandomNumberGenerator.new()
	random.seed = absi(str(body.get("id", "planet")).hash()) + 1889
	for index in range(int(body.get("moons", 0))):
		_moon_specs.append({
			"angle": random.randf_range(0.0, TAU),
			"orbit": 1.75 + float(index % 4) * 0.44 + random.randf_range(-0.1, 0.12),
			"radius": random.randf_range(0.06, 0.13),
			"shade": random.randf_range(0.43, 0.72),
			"speed": random.randf_range(0.006, 0.018) * (1.0 if index % 2 == 0 else -1.0),
			"craters": [Vector2(random.randf_range(-0.55, 0.55), random.randf_range(-0.45, 0.45)), Vector2(random.randf_range(-0.35, 0.35), random.randf_range(-0.35, 0.35))]
		})

func _sync_moon_visuals() -> void:
	if not _moon_visuals.is_empty() or _moon_specs.is_empty():
		_update_moon_positions()
		return
	for index in range(_moon_specs.size()):
		var moon := _moon_specs[index]
		var shade := float(moon.shade)
		var tint := Color(shade * 0.85, shade * 0.95, shade)
		var surface := ShaderMaterial.new()
		surface.shader = PLANET_SHADER
		surface.set_shader_parameter("base_color", tint)
		surface.set_shader_parameter("accent_color", tint.lightened(0.27))
		surface.set_shader_parameter("surface_type", 0)
		surface.set_shader_parameter("seed", float(index * 9 + str(body.get("id", "moon")).hash() % 999) * 0.03)
		surface.set_shader_parameter("atmosphere", 0.0)
		var visual := ColorRect.new()
		visual.mouse_filter = Control.MOUSE_FILTER_IGNORE
		visual.material = surface
		add_child(visual)
		move_child(visual, 0)
		_moon_visuals.append(visual)
	_update_moon_positions()

func _update_moon_positions() -> void:
	for index in range(_moon_visuals.size()):
		var moon := _moon_specs[index]
		var angle := float(moon.angle) + _clock * float(moon.speed)
		var point := Vector2(cos(angle) * radius * float(moon.orbit), sin(angle) * radius * float(moon.orbit) * 0.33).rotated(-0.22)
		var moon_radius := maxf(1.8, radius * float(moon.radius))
		_moon_visuals[index].position = point - Vector2.ONE * moon_radius
		_moon_visuals[index].size = Vector2.ONE * moon_radius * 2.0
		_moon_visuals[index].visible = detailed

func _process(delta: float) -> void:
	if not is_visible_in_tree(): return
	_clock += delta
	if _surface != null:
		_surface.set_shader_parameter("spin", _clock * 0.008)
	if detailed:
		_update_moon_positions()
		queue_redraw()

func _ellipse_points(orbit_radius: float, from_angle: float, to_angle: float, count: int = 70) -> PackedVector2Array:
	var points := PackedVector2Array()
	for index in range(count + 1):
		var angle := lerpf(from_angle, to_angle, float(index) / float(count))
		var point := Vector2(cos(angle) * orbit_radius, sin(angle) * orbit_radius * 0.33)
		points.append(point.rotated(-0.22))
	return points

func _draw_ring_half(front: bool) -> void:
	if not bool(body.get("ringed", false)):
		return
	var from_angle := 0.0 if front else PI
	var to_angle := PI if front else TAU
	var palette := Color(body.get("accent", Color("cab897")))
	for index in range(16):
		var ring_radius := radius * (1.24 + float(index) * 0.035)
		var alpha := 0.23 + sin(float(index) * 1.8) * 0.11
		var shade := palette.lerp(Color("344354"), 0.20 if front else 0.50)
		shade.a = alpha
		draw_polyline(_ellipse_points(ring_radius, from_angle, to_angle), shade, maxf(0.8, radius * 0.017), true)
	var edge_color := palette
	edge_color.a = 0.35 if front else 0.16
	draw_polyline(_ellipse_points(radius * 1.80, from_angle, to_angle), edge_color, maxf(0.7, radius * 0.005), true)

func _draw_foreground() -> void:
	# Draw through the overlay's canvas item so the nearest half crosses the sphere.
	if not bool(body.get("ringed", false)):
		return
	var palette := Color(body.get("accent", Color("cab897")))
	for index in range(16):
		var ring_radius := radius * (1.24 + float(index) * 0.035)
		var shade := palette.lerp(Color("344354"), 0.12)
		shade.a = 0.32 + sin(float(index) * 1.8) * 0.10
		_ring_front.draw_polyline(_ellipse_points(ring_radius, 0.0, PI), shade, maxf(0.8, radius * 0.017), true)

func _draw() -> void:
	_draw_ring_half(false)
	if _moon_specs.is_empty():
		return
	var orbit_alpha := 0.16 if detailed else 0.11
	for orbit in range(4):
		if orbit >= _moon_specs.size():
			break
		draw_polyline(_ellipse_points(radius * (1.75 + float(orbit) * 0.44), 0.0, TAU), Color(0.45, 0.65, 0.72, orbit_alpha), 0.7, true)
	for moon in _moon_specs:
		if detailed:
			continue
		var angle := float(moon.angle) + _clock * float(moon.speed)
		var point := Vector2(cos(angle) * radius * float(moon.orbit), sin(angle) * radius * float(moon.orbit) * 0.33).rotated(-0.22)
		var moon_radius := maxf(1.8, radius * float(moon.radius))
		var shade := float(moon.shade)
		var tint := Color(shade * 0.88, shade * 0.96, shade)
		draw_circle(point, moon_radius + 1.0, Color(0.40, 0.60, 0.72, 0.15))
		draw_circle(point, moon_radius, tint.darkened(0.46))
		draw_circle(point + Vector2(-moon_radius * 0.24, -moon_radius * 0.18), moon_radius * 0.80, tint)
		for crater in moon.craters:
			draw_circle(point + Vector2(crater) * moon_radius, maxf(0.7, moon_radius * 0.18), tint.darkened(0.27))
