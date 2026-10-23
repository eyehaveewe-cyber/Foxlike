class_name FoxFlightOverlay
extends Control
## Lightweight projected targeting. This layer never captures input.

const CYAN: Color = Color("9cf5ff")
const ORANGE: Color = Color("ffb36b")
var _camera: Camera3D
var _aim: Vector3 = Vector3(0, 0, -80)
var _enemies: Array = []
var _lock_target: Node3D
var _lock_progress: float = 0.0
var _flash: float = 0.0
var _roll: float = 0.0
var _time: float = 0.0


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(delta: float) -> void:
	_time += delta
	queue_redraw()


func set_targets(camera: Camera3D, aim: Vector3, enemies: Array, lock_target: Node3D, lock_progress: float, flash: float, roll: float) -> void:
	_camera = camera
	_aim = aim
	_enemies = enemies
	_lock_target = lock_target
	_lock_progress = clampf(lock_progress, 0.0, 1.0)
	_flash = clampf(flash, 0.0, 1.0)
	_roll = clampf(roll, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	if not is_instance_valid(_camera) or not visible:
		return
	var screen: Vector2 = size
	if screen.x < 1.0:
		screen = get_viewport_rect().size
	var center: Vector2 = screen * 0.5
	var scale_factor: float = minf(screen.x / 1280.0, screen.y / 720.0)
	if _arena_enabled: _draw_radar(screen,scale_factor)
	var point: Vector2 = _camera.unproject_position(_aim)
	if _camera.is_position_behind(_aim):
		point = center
	point.x = clampf(point.x, 32.0, screen.x - 32.0)
	point.y = clampf(point.y, 32.0, screen.y - 32.0)
	var radius: float = 17.0 * scale_factor
	var gap: float = 6.0 * scale_factor
	var aim_color: Color = CYAN
	aim_color.a = 0.85
	draw_arc(point, radius + 7.0 * scale_factor, PI * 0.1, PI * 0.4, 10, Color(CYAN, 0.22), 1.0, true)
	draw_arc(point, radius + 7.0 * scale_factor, PI * 1.1, PI * 1.4, 10, Color(CYAN, 0.22), 1.0, true)
	for axis: Vector2 in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		draw_line(point + axis * gap, point + axis * radius, Color(0.025, 0.08, 0.12, 0.75), 4.0 * scale_factor, true)
		draw_line(point + axis * gap, point + axis * radius, aim_color, 1.4 * scale_factor, true)
	draw_circle(point, 1.8 * scale_factor, Color(1, 1, 0.92, 0.95))
	# An unobtrusive boresight distinguishes ship heading from the aiming point.
	draw_circle(center, 2.0 * scale_factor, Color(CYAN, 0.25), false, 1.0, true)
	var shown: int = 0
	for candidate: Variant in _enemies:
		if not is_instance_valid(candidate) or not candidate is Node3D:
			continue
		var enemy: Node3D = candidate as Node3D
		if enemy == _lock_target:
			continue
		if _camera.is_position_behind(enemy.global_position):
			continue
		var location: Vector2 = _camera.unproject_position(enemy.global_position)
		if location.x < 45.0 or location.x > screen.x - 45.0 or location.y < 95.0 or location.y > screen.y - 95.0:
			if shown < 3:
				_draw_edge_arrow(location, screen, scale_factor)
				shown += 1
			continue
		var distance: float = _camera.global_position.distance_to(enemy.global_position)
		var half_size: float = clampf(1400.0 / maxf(distance, 20.0), 7.0, 24.0) * scale_factor
		_draw_brackets(location, half_size, Color(1.0, 0.62, 0.36, 0.42), scale_factor, 0.35)
	if is_instance_valid(_lock_target) and not _camera.is_position_behind(_lock_target.global_position):
		var lock_point: Vector2 = _camera.unproject_position(_lock_target.global_position)
		var lock_radius: float = lerpf(46.0, 25.0, _lock_progress) * scale_factor
		var lock_color: Color = ORANGE.lerp(CYAN, _lock_progress)
		_draw_brackets(lock_point, lock_radius, lock_color, 1.8 * scale_factor, 0.4)
		if _lock_progress > 0.01:
			draw_arc(lock_point, lock_radius + 7.0 * scale_factor, -PI * 0.5, -PI * 0.5 + TAU * _lock_progress, 40, lock_color, 2.0 * scale_factor, true)
		if _lock_progress >= 0.99:
			var pulse: float = 0.55 + sin(_time * 8.0) * 0.2
			draw_circle(lock_point, 3.0 * scale_factor, Color(CYAN, pulse), false, 1.0, true)
	if _flash > 0.01:
		_draw_damage_edges(screen, _flash)
	if _roll > 0.01:
		var roll_color: Color = Color(CYAN, _roll * 0.5)
		draw_arc(center, screen.y * 0.32, _time * 9.0, _time * 9.0 + PI * 0.7, 32, roll_color, 2.0, true)
		draw_arc(center, screen.y * 0.32, _time * 9.0 + PI, _time * 9.0 + PI * 1.7, 32, roll_color, 2.0, true)


func _draw_brackets(point: Vector2, radius: float, color: Color, width: float, length_ratio: float) -> void:
	var length: float = radius * length_ratio
	for x: float in [-1.0, 1.0]:
		for y: float in [-1.0, 1.0]:
			var corner: Vector2 = point + Vector2(x, y) * radius
			draw_line(corner, corner - Vector2(x * length, 0), color, width, true)
			draw_line(corner, corner - Vector2(0, y * length), color, width, true)


func _draw_edge_arrow(location: Vector2, screen: Vector2, scale_factor: float) -> void:
	var center: Vector2 = screen * 0.5
	var direction: Vector2 = (location - center).normalized()
	var maximum: Vector2 = screen * 0.5 - Vector2(48.0, 110.0)
	var factor: float = minf(maximum.x / maxf(absf(direction.x), 0.001), maximum.y / maxf(absf(direction.y), 0.001))
	var point: Vector2 = center + direction * factor
	var across: Vector2 = direction.orthogonal() * 4.0 * scale_factor
	var tail: Vector2 = point - direction * 9.0 * scale_factor
	draw_line(tail + across, point, Color(ORANGE, 0.5), 1.5, true)
	draw_line(tail - across, point, Color(ORANGE, 0.5), 1.5, true)


func _draw_damage_edges(screen: Vector2, intensity: float) -> void:
	for i: int in range(12):
		var inset: float = float(i) * 6.0
		var alpha: float = intensity * (1.0 - float(i) / 12.0) * 0.16
		var color: Color = Color(1.0, 0.19, 0.13, alpha)
		draw_rect(Rect2(Vector2(inset, inset), screen - Vector2.ONE * inset * 2.0), color, false, 6.0)

var _arena_enabled := false
var _radar_contacts: Array[Vector2] = []
var _radar_carrier := Vector2.ZERO
var _radar_boss := Vector2.INF
var _radar_player := Vector2.ZERO
var _radar_heading := 0.0

func set_arena(enabled: bool, navigation: RefCounted, carrier: Vector3, enemies: Array, boss: Vector3) -> void:
	_arena_enabled = enabled
	_radar_contacts.clear()
	if not enabled: return
	_radar_player = Vector2(navigation.position.x,navigation.position.z)
	_radar_heading = navigation.heading
	_radar_carrier = Vector2(carrier.x,carrier.z)
	_radar_boss = Vector2(boss.x,boss.z)
	for enemy in enemies:
		if enemy.has("arena_pos"):
			var point: Vector3 = enemy.arena_pos
			_radar_contacts.append(Vector2(point.x,point.z))

func _draw_radar(screen: Vector2, factor: float) -> void:
	var center := Vector2(screen.x-112.0*factor,screen.y-218.0*factor)
	var radius := 78.0*factor
	var unit := radius/210.0
	draw_circle(center,radius+7.0*factor,Color(.015,.04,.065,.88))
	draw_circle(center,radius,Color(CYAN,.55),false,1.5,true)
	draw_line(center-Vector2(radius,0),center+Vector2(radius,0),Color(CYAN,.16),1.0)
	draw_line(center-Vector2(0,radius),center+Vector2(0,radius),Color(CYAN,.16),1.0)
	var carrier := center+_radar_carrier*unit
	draw_rect(Rect2(carrier-Vector2(4,6)*factor,Vector2(8,12)*factor),CYAN)
	for point in _radar_contacts:
		draw_circle(center+point*unit,3.5*factor,Color("ff765f"))
	if _radar_boss.is_finite():
		var point := center+_radar_boss*unit
		draw_circle(point,6.5*factor,ORANGE,false,2.0,true)
	var point := center+_radar_player*unit
	var forward := Vector2(-sin(_radar_heading),-cos(_radar_heading))
	var side := forward.orthogonal()
	draw_colored_polygon(PackedVector2Array([point+forward*7.0*factor,point-forward*4.0*factor+side*4.0*factor,point-forward*4.0*factor-side*4.0*factor]),Color.WHITE)
