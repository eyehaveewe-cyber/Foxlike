extends RefCounted
## Observation -> delayed memory -> intent -> route -> shared bounded steering.
## No player controller, input, energy or hidden transform is available to decide().
const Geometry = preload("res://scripts/duel/duel_geometry.gd")
const RECOGNITION_DELAY := 0.45
const DECISION_INTERVAL := 0.25
const VISUAL_RANGE := 260.0
const ATTACK_RANGE := 180.0
var state := "acquire"
var reason := "Visible staging approach"
var route := "high setup"
var time := 0.0
var entered := 0.0
var decision_at := 0.0
var observation_queue: Array[Dictionary] = []
var memory: Dictionary = {}
var last_seen := -1000.0
var visible := false
var pending_visible := false
var goal := Vector3.ZERO
var committed_direction := Vector3.FORWARD
var last_credible := 0.0
var evasion_side := 1.0
var reaction: Dictionary = {}
var transitions: Array[Dictionary] = []
var intent: Dictionary = {"steer":Vector2.ZERO,"boost":false,"brake":false,"roll":0.0,"fire":false}
var route_waypoint := Vector3.INF

func reset(staging: Vector3) -> void:
	state = "acquire"
	reason = "Visible staging approach"
	route = "high setup"
	time = 0.0
	entered = 0.0
	decision_at = 0.0
	last_seen = -1000.0
	last_credible = 0.0
	goal = staging
	memory.clear()
	observation_queue.clear()
	transitions.clear()
	reaction.clear()
	visible = false
	route_waypoint = Vector3.INF
	pending_visible = false
	intent = {"steer":Vector2.ZERO,"boost":false,"brake":false,"roll":0.0,"fire":false}

static func sensor(observer_position: Vector3, observer_forward: Vector3, target_position: Vector3, target_velocity: Vector3, shots: Array, cover: Array, now: float) -> Dictionary:
	var offset := target_position-observer_position
	var contact_visible := offset.length()<=VISUAL_RANGE and observer_forward.dot(offset.normalized())>-.25 and Geometry.first_cover(observer_position,target_position,cover).is_empty()
	var observed: Dictionary = {"at":now,"visible":contact_visible}
	if contact_visible:
		observed["position"] = target_position
		observed["velocity"] = target_velocity
	var threats: Array[Dictionary] = []
	for shot in shots:
		if int(shot.owner)!=0: continue
		var difference: Vector3 = shot.position-observer_position
		if difference.length()>115.0 or observer_forward.dot(difference.normalized())<-.3: continue
		if not Geometry.first_cover(observer_position,shot.position,cover).is_empty(): continue
		var flight: Vector3 = shot.velocity
		var approach := -difference.dot(flight)/maxf(1.0,flight.length_squared())
		if approach>.05 and approach<1.4 and (difference+flight*approach).length()<10.0:
			threats.append({"position":Vector3(shot.position),"velocity":flight,"at":now})
	observed["threats"] = threats
	return observed

func feed(observed: Dictionary) -> void:
	observation_queue.append(observed.duplicate(true))
	while observation_queue.size()>90: observation_queue.pop_front()

func update(dt: float, own: RefCounted, cover: Array, radius: float, ceiling: float) -> Dictionary:
	time += dt
	# Recognition is tied to the observation timestamp, never to an unseen input.
	while not observation_queue.is_empty() and time-float(observation_queue[0].at)>=RECOGNITION_DELAY:
		var observed: Dictionary = observation_queue.pop_front()
		visible = bool(observed.visible)
		if visible:
			memory = {"position":observed.position,"velocity":observed.velocity,"at":observed.at}
			last_seen = float(observed.at)
		var threats: Array = observed.get("threats",[])
		if not threats.is_empty() and state!="evade" and not own.boundary:
			reaction = threats[0].duplicate(true)
			var local_velocity: Vector3 = own.orientation().inverse()*Vector3(reaction.velocity)
			evasion_side = 1.0 if local_velocity.x<=0.0 else -1.0
			goal = own.position+own.orientation()*Vector3(evasion_side*65.0,-12.0,-65.0)
			_transition("evade","Observed projectile after %.2fs recognition" % (time-float(reaction.at)))
	if time>=decision_at:
		decision_at = time+DECISION_INTERVAL
		_decide(own,cover,radius,ceiling)
	var destination := goal
	if state=="commit" and visible and observed_age()<.85 and not memory.is_empty():
		var lead: Vector3 = predicted_contact()+Vector3(memory.velocity)*minf(.75,own.position.distance_to(predicted_contact())/210.0)
		var desired: Vector3 = (lead-own.position).normalized()
		var correction := committed_direction.angle_to(desired)
		# A narrow firing corridor permits tracking a pass, never a reversing chase.
		var adjusted := committed_direction.slerp(desired,minf(1.0,deg_to_rad(8.0)/maxf(.001,correction)))
		destination = own.position+adjusted*160.0

	if route_waypoint.is_finite() and own.position.distance_to(route_waypoint)<16.0:
		route_waypoint = Vector3.INF
	var obstruction := Geometry.first_cover(own.position,destination,cover,7.0)
	if state!="commit" and (not obstruction.is_empty() or route_waypoint.is_finite()):
		if not route_waypoint.is_finite():
			var side := -1.0 if own.position.x<0.0 else 1.0
			if absf(own.position.x)<60.0:
				route_waypoint = Vector3(side*75.0,own.position.y,own.position.z)
			else:
				route_waypoint = Vector3(side*75.0,own.position.y,65.0 if goal.z>=0.0 else -65.0)
		destination = route_waypoint
		route = "port cover waypoint" if route_waypoint.x<0 else "starboard cover waypoint"
	else:
		if state!="search": route = "committed line" if state=="commit" else ("extension" if state=="extend" else "clear approach")
	var ahead: Vector3 = own.position+own.forward()*maxf(28.0,own.velocity.length()*1.4)
	if not Geometry.first_cover(own.position,ahead,cover,6.0).is_empty() and state!="commit":
		route = "body clearance / brake and separate"
		if own.position.distance_to(Vector3(Geometry.first_cover(own.position,ahead,cover,6.0).point))<28.0 and state!="blocked":
			_transition("blocked","Body-width lookahead blocks the approach")
	# Observed relative velocity predicts near aircraft contact. Pass starboard
	# consistently; this remains a request through the same angular constraints.
	if visible and not memory.is_empty() and state!="commit":
		var relative_position: Vector3 = predicted_contact()-Vector3(own.position)
		var relative_velocity: Vector3 = Vector3(memory.velocity)-Vector3(own.velocity)
		var closest_time := clampf(-relative_position.dot(relative_velocity)/maxf(1.0,relative_velocity.length_squared()),0.0,2.0)
		if closest_time>0.0 and (relative_position+relative_velocity*closest_time).length()<18.0:
			destination = own.position+own.orientation()*Vector3(65.0,0,-40.0)
			route = "observed aircraft / starboard separation"
	var steering := steer_to(own,destination)
	var age := observed_age()
	var predicted := predicted_contact()
	var offset: Vector3 = predicted-own.position
	var angle: float = own.forward().angle_to(offset.normalized()) if offset.length()>.1 else PI
	var lead_target := predicted+(Vector3(memory.velocity)*minf(.75,offset.length()/210.0) if not memory.is_empty() else Vector3.ZERO)
	var firing_angle: float = own.forward().angle_to((lead_target-own.position).normalized())
	var fire := Vector2(predicted.x,predicted.z).length()<radius-80.0 and state=="commit" and visible and age<.85 and offset.length()<=ATTACK_RANGE and firing_angle<deg_to_rad(5.0)
	if fire: last_credible = time
	intent = {"steer":steering,"boost":state=="extend" and own.energy>25.0,"brake":route_waypoint.is_finite() or state in ["search","blocked"] or (state=="approach" and offset.length()<90.0),"roll":evasion_side if state=="evade" and time-entered<.35 else 0.0,"fire":fire}
	return intent

func _decide(own: RefCounted, cover: Array, radius: float, ceiling: float) -> void:
	var age := observed_age()
	var predicted := predicted_contact()
	var offset: Vector3 = predicted-own.position
	var distance := offset.length()
	var angle: float = own.forward().angle_to(offset.normalized()) if distance>.1 else PI
	if state=="commit" and Vector2(predicted.x,predicted.z).length()>radius-80.0:
		_begin_extend(own,"Leave the recovery belt free for a fair rejoin",ceiling)
	if own.boundary:
		route = "controller boundary recovery"
		return
	match state:
		"acquire":
			if not memory.is_empty():
				_transition("approach" if visible and age<.9 else "search","Recognized visual contact" if visible and age<.9 else "Recognition arrived after sight loss; search stored exit")
		"approach":
			if age>1.3:
				_transition("search","Sight lost; search last observed exit")
			elif distance<ATTACK_RANGE and own.forward().angle_to((predicted+Vector3(memory.velocity)*minf(.75,distance/210.0)-own.position).normalized())<deg_to_rad(5.0) and visible:
				# Freeze a pass line. Later player movement can defeat this commitment.
				var lead: Vector3 = Vector3(memory.velocity)*minf(.75,distance/210.0)
				committed_direction = (predicted+lead-own.position).normalized()
				goal = own.position+committed_direction*230.0
				_transition("commit","Attack line committed; no hidden tracking")
			elif time-last_credible>5.0 and time-entered>4.0:
				_begin_extend(own,"Poor pursuit; open distance for a new pass",ceiling)
			else:
				var behind: Vector3 = Vector3(memory.velocity).normalized()*(-40.0 if distance<95.0 else 0.0)
				goal = predicted+behind+Vector3(memory.velocity)*minf(.75,distance/210.0)+Vector3(0,18.0 if time-entered<.65 and distance>150.0 else 0.0,0)
		"commit":
			if time-entered>2.6 or own.position.distance_to(goal)<45.0 or (not visible and age>1.1):
				_begin_extend(own,"Missed pass remains committed; extending to rejoin",ceiling)
		"extend":
			if time-entered>3.4:
				_transition("search" if age>1.3 else "approach","Extension complete; reassess observed contact")
		"search":
			if visible and age<.9: _transition("approach","Reacquired visible contact")
			else:
				var phase := int((time-entered)/2.0)%4
				var search_offsets := [Vector3(-65,15,30),Vector3(65,25,-30),Vector3(65,-12,65),Vector3(-65,5,-65)]
				goal = predicted+search_offsets[phase]
				route = "last-known exit %d" % (phase+1)
		"evade":
			if time-entered>1.1: _begin_extend(own,"Observed shot evasion complete",ceiling)
		"blocked":
			if time-entered>1.5: _begin_extend(own,"Blocked route separated; choose a new approach",ceiling)
	goal.y = clampf(goal.y,10.0,ceiling-10.0)
	var planar := Vector2(goal.x,goal.z).limit_length(radius-75.0)
	goal.x = planar.x
	goal.z = planar.y

func _begin_extend(own: RefCounted, why: String, ceiling: float) -> void:
	var side: Vector3 = own.orientation()*Vector3(50.0 if own.position.x<0 else -50.0,0,0)
	goal = own.position+own.forward()*150.0+side
	goal.y = clampf(own.position.y+20.0,12.0,ceiling-12.0)
	_transition("extend",why)

func _transition(next: String, why: String) -> void:
	if state==next: return
	transitions.append({"at":time,"from":state,"to":next,"reason":why,"observed_at":last_seen,"contact_age":observed_age()})
	if next=="commit": route_waypoint = Vector3.INF
	state = next
	reason = why
	entered = time

func observed_age() -> float:
	return time-last_seen

func predicted_contact() -> Vector3:
	if memory.is_empty(): return goal
	# Never extrapolate beyond the declared 0.75-second memory horizon.
	return Vector3(memory.position)+Vector3(memory.velocity)*clampf(time-float(memory.at),0.0,.75)

static func steer_to(own: RefCounted, target: Vector3) -> Vector2:
	var difference: Vector3 = target-own.position
	var desired_yaw := atan2(-difference.x,-difference.z)
	var desired_pitch := atan2(difference.y,Vector2(difference.x,difference.z).length())
	return Vector2(-angle_difference(own.heading,desired_yaw)*2.1,(desired_pitch-own.pitch)*2.1).limit_length()
