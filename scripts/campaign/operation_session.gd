extends RefCounted
## Real-time operation authority. Scene nodes only display these resolved states.
const Catalog = preload("res://scripts/campaign/operation_catalog.gd")
const Actor = preload("res://scripts/campaign/operation_actor.gd")
const Pilot = preload("res://scripts/duel/duel_pilot.gd")
const Geometry = preload("res://scripts/duel/duel_geometry.gd")
const Weapons = preload("res://scripts/duel/duel_weapons.gd")
const Squadron = preload("res://scripts/flight_squadron.gd")
var definition: Dictionary = {}
var actors: Dictionary = {}
var stage := 0
var elapsed := 0.0
var stage_time := 0.0
var mode := "flight"
var reason := ""
var score := 0
var next_uid := 0
var cover: Array = []
var weapons := Weapons.new()
var checkpoint: Dictionary = {}
var facts := {"carrier":{"hull":100.0,"drive_overstrained":false,"parts_secured":false,"repaired":false},"rivals":{},"rescues":[],"companions":{}}
var events: Array[Dictionary] = []
var objectives: Array[String] = []
var settings: Dictionary = {}
var carrier_position := Vector3(0,75,0)
var door := 0.0
var recovery_phase := "request"
var recovery_attempts := 0
var repair_cargo := false
var core_hp := 0.0
var components: Dictionary = {}
var boss_kind := -1
var boss_position := Vector3(0,90,-130)
var reserve := 6
var boss_fire := 3.0
var hazard_phase := 0.0
var hazard_box := AABB()
var hazard_warning := false
var hazard_active := false
var wreck_phase := 0.0
var required_cargo := ""
var escaped := false
var quiet_time := 0.0
var interact_time := 0.0
var missiles := 6
var missile_wait := 0.0
var bombs := 3
var formation := 0
var selected := ""
var pending: Array[Dictionary] = []
var capital_warning := 0.0
var capital_aim := Vector3.ZERO
var capital_origin := Vector3.ZERO
var capital_gun := ""
var launcher_at := 8.0
var tank = preload("res://scripts/flight_tank.gd").new()
var tank_aim := 0.0
var ground_fire_wait := 0.0
var recovering_rival := ""
var forecast_time := 0.0
var repair_phase := "awaiting_parts"
var vessel_angle := 0.0
var vessel_state := 0
var checkpoint_revision := 0
var pickups: Array[Dictionary] = []
var rings := 0
var laser_level := 1

func ground_mode() -> bool: return definition.id=="cinder_corridor"

func begin(id: String, progress: Dictionary) -> void:
	definition = Catalog.definition(id)
	settings = progress.get("settings",Catalog.DEFAULTS).duplicate(true)
	settings.difficulty = progress.get("difficulty","Standard")
	facts.carrier.merge(progress.get("carrier",{}),true)
	facts.rivals = progress.get("rivals",{}).duplicate(true)
	facts.rescues = progress.get("rescues",[]).duplicate()
	facts.companions = progress.get("companion_condition",{}).duplicate(true)
	formation = int(progress.get("formation",0))
	_build_cover()
	var player := spawn("comet",0,"player",Vector3(100,80,180),100)
	if ground_mode(): player.kind = "tank"; player.vehicle.position = Vector3(0,-2,180); player.vehicle.speed = 12
	player.vehicle.pitch_hold = bool(settings.get("pitch_hold",true))
	var pair: Array = progress.get("companions",["latch","glint"])
	for i in range(pair.size()):
		var profile: Dictionary = Squadron.profile(pair[i])
		var wing = spawn(pair[i],0,"wingman",player.vehicle.position+Vector3((i*2-1)*15,3,20),float(profile.hp))
		var condition: Dictionary = facts.companions.get(pair[i],{})
		wing.hp = clampf(float(condition.get("hp",profile.hp)),1,float(profile.hp))
		# A new operation services a withdrawn airframe at Dragonfly. Its damage
		# remains visible; a retry never repairs or recreates it within a sortie.
		if condition.get("withdrawn",false): wing.hp = maxf(wing.hp,float(profile.hp)*.5)
	_enter()

func _build_cover() -> void:
	cover = [
		{"id":"anchor-west","box":AABB(Vector3(-90,0,-25),Vector3(42,60,60))},
		{"id":"anchor-east","box":AABB(Vector3(65,0,-40),Vector3(38,45,60))},
		{"id":"carrier-thorax","box":AABB(Vector3(-12,66,-38),Vector3(24,19,75))},
		{"id":"carrier-left-head","box":AABB(Vector3(-25,69,-67),Vector3(17,13,25))},
		{"id":"carrier-right-head","box":AABB(Vector3(8,69,-67),Vector3(17,13,25))}]
	if definition.id in ["viridia_blockade","viridia_last_ferry"]:
		cover.append({"id":"sea-wall","box":AABB(Vector3(-160,0,-90),Vector3(100,35,12))})
		if definition.id=="viridia_blockade" and not facts.get("crossing_open",false): cover.append({"id":"crossing-gate","box":AABB(Vector3(-165,35,-90),Vector3(105,55,12))})
	if definition.id.begins_with("aurora"):
		cover.append({"id":"ice-spire","box":AABB(Vector3(-22,0,-90),Vector3(35,85,24))})
		cover.append({"id":"low-ice-shelf","box":AABB(Vector3(-150,0,-70),Vector3(65,35,30))})
		cover.append({"id":"high-ice-wall","box":AABB(Vector3(120,0,-170),Vector3(25,120,70))})
	if ground_mode():
		cover = [{"id":"foundry-west","box":AABB(Vector3(-125,-3,-500),Vector3(15,35,820))},{"id":"foundry-east","box":AABB(Vector3(110,-3,-500),Vector3(15,35,820))}]
		for z in [-20.0,-200.0,-380.0]: cover.append({"id":"hover-barrier-%s"%z,"box":AABB(Vector3(-40,-3,z),Vector3(80,7,8))})

func spawn(id: String, team: int, kind: String, position: Vector3, hp: float = 72.0) -> RefCounted:
	if actors.has(id): return actors[id]
	var actor := Actor.new()
	actor.id = id; actor.uid = next_uid; next_uid += 1
	actor.team = team; actor.kind = kind; actor.hp = hp; actor.max_hp = hp
	actor.vehicle.reset(position,0.0 if team==0 else PI)
	actor.goal = Vector3(100,90,-120) if team==0 else carrier_position
	actor.pilot.reset(position)
	actor.pilot.time = elapsed
	actors[id] = actor
	return actor

func state() -> Dictionary: return definition.states[stage]
func player() -> RefCounted: return actors.comet
func living_hostiles() -> Array: return actors.values().filter(func(a):return a.team==1 and a.hp>0 and a.phase=="active")
func allies() -> Array: return actors.values().filter(func(a):return a.team==0 and a.id!="comet" and a.kind=="wingman")

func _enter() -> void:
	var current := state()
	stage_time = 0.0; interact_time = 0.0
	capital_warning = 0; boss_fire = 3.0
	hazard_phase = 0.0; wreck_phase = 0.0; quiet_time = 0.0
	if current.kind!="escape": weapons.reset()
	recovery_phase = "request"; recovery_attempts = 0
	pickups.clear()
	var supplies := ["ring","ammo","wing"] if stage%2==0 else ["ring","repair","nova"]
	for i in range(3):
		var point := Vector3(100-i*85,80+i*5,130-i*110)
		if ground_mode(): point = Vector3((i-1)*70,4,120-stage*180-i*45)
		pickups.append({"id":"%s_%d_%d"%[definition.id,stage,i],"kind":supplies[i],"point":Actor.vec(point)})
	required_cargo = ""
	if not current.get("keep_boss",false): core_hp = 0.0; components.clear(); boss_kind = -1
	for i in range(int(current.hostiles)):
		var id := "%s_%s_%d" % [definition.id,current.id,i]
		var point := Vector3(-150+i*45,115 if i%2==0 else 40,-140)
		var kind := "bomber" if i%3==0 else "fighter"
		if ground_mode():
			point = Vector3(-60+i*60,-2,-100-stage*180); kind = "tank"
			if current.get("walker",false) and i==1: kind = "walker"; point.y = 4
		pending.append({"id":id,"kind":kind,"point":Actor.vec(point),"hp":60 if i%3==0 else 72})
	for id in current.get("rivals",[]):
		if facts.rivals.get(id,"unseen") in ["disabled","lost","ejected"]: continue
		if facts.rivals.get(id)=="recovered": continue
		pending.append({"id":id,"kind":"interceptor","point":[-120+living_hostiles().size()*25,125,-150],"hp":100})
	if current.kind=="boss":
		boss_kind = int(current.boss)
		if ground_mode(): boss_position = Vector3(0,10,-450)
		core_hp = [260.0,290.0,360.0,300.0,320.0,420.0][boss_kind]
		var part_names: Array = current.parts
		for i in range(part_names.size()):
			components[part_names[i]] = {"hp":65.0,"point":Actor.vec(boss_position+Vector3((i%2*2-1)*22,(-1 if i<2 else 1)*13,5+i*7)),"disabled":false}
		if definition.id=="terminus_falling_yard":
			components["Jammed stabilizer"] = {"hp":65.0,"point":Actor.vec(boss_position+Vector3(36,-22,-15)),"disabled":false}
			for i in range(components.size()): components[components.keys()[i]].point = Actor.vec(boss_position+Vector3((i%2*2-1)*36,(-1 if i<2 else 1)*22,5+i*7))
		reserve = 6; boss_fire = 3.0; launcher_at = 8.0
	if current.kind=="control":
		for i in range(current.parts.size()): components[current.parts[i]] = {"hp":65.0,"point":[-120+i*235,85+i*25,-125],"disabled":false}
	if current.kind in ["escort","intercept","recovery"] and not current.get("player_recovery",false):
		var cargo_id: String = "lead_ferry" if definition.id=="viridia_last_ferry" else "parts_craft" if current.get("repair",false) else current.id+"_craft"
		var cargo := spawn(cargo_id,0 if current.kind!="intercept" else 1,"bomber",Vector3(0,75,-190) if current.kind=="recovery" else Vector3(-155,65,80),100)
		cargo.phase = "active"; cargo.waypoint = 0
		cargo.task = "transport"; cargo.critical = current.kind!="recovery"
		cargo.vehicle.profile = cargo.vehicle.profile.duplicate(true)
		cargo.vehicle.profile.cruise = 12.0; cargo.vehicle.profile.brake = 6.0; cargo.vehicle.profile.boost = 20.0
		cargo.vehicle.speed = 12.0; cargo.vehicle.velocity = cargo.vehicle.forward()*12
		cargo.path.assign([Vector3(-120,65,-30),Vector3(-120,90,-140),Vector3(0,75,-145),Vector3(0,74,-66)])
		if definition.id=="viridia_last_ferry":
			if current.id=="first_sector": cargo.path.assign([Vector3(-120,65,-30),Vector3(-120,90,-140)])
			else: cargo.path.assign([Vector3(0,75,-145),Vector3(0,74,-66)])
		if current.kind=="intercept": cargo.path.assign([Vector3(90,95,-130),Vector3(210,110,-200)]); cargo.team = 1
		if current.kind=="intercept": cargo.parts = {"Drive":{"hp":45.0,"offset":[0,0,6]}}
		if current.kind=="recovery": cargo.path.assign([Vector3(0,75,-145),Vector3(0,74,-100),Vector3(0,74,-66)])
		if current.kind=="recovery": cargo.vehicle.profile.cruise = 8.0; cargo.vehicle.profile.brake = 4.0; cargo.vehicle.profile.angular_rate = .8
		recovering_rival = ""
		if current.get("rival_recovery",false):
			for rival in facts.rivals:
				if facts.rivals[rival]=="disabled": recovering_rival = rival; break
		if ground_mode():
			cargo.vehicle.position = Vector3(-90,4,-400)
			cargo.path.assign([Vector3(-90,4,-450),Vector3(-80,4,-490),Vector3(0,4,-500)])
		required_cargo = cargo.id
		if current.get("optional",false):
			var optional := spawn(current.id+"_optional",0,"bomber",Vector3(-175,80,110),70)
			optional.task = "transport"; optional.path = cargo.path.duplicate(); optional.critical = false
			optional.vehicle.profile = cargo.vehicle.profile.duplicate(true)
	if current.id=="reassembly":
		var index := 0
		for rescued in facts.rescues:
			if index>=6: break
			var traffic := spawn("saved_"+str(rescued),0,"bomber",Vector3(150+index*15,105,60+index*10),100)
			traffic.task = "hold"; traffic.goal = Vector3(140+index*15,100,-100)
			traffic.vehicle.profile.cruise = 16.0; traffic.vehicle.profile.brake = 8.0
			index += 1
	events.append({"type":"objective","text":current.text})
	_admit()
	_build_cover()
	checkpoint_revision += 1; checkpoint = snapshot()

func _admit() -> void:
	while not pending.is_empty() and living_hostiles().size()<8:
		var entry: Dictionary = pending.pop_front()
		var point := Actor.point(entry.point)
		if point.distance_to(player().vehicle.position)<80: point.x = -signf(player().vehicle.position.x)*180
		var actor = spawn(entry.id,1,entry.kind,point,float(entry.hp))
		if actor.kind=="walker": actor.parts = {"Gun":{"hp":30.0,"offset":[0,3,-5]},"Left leg":{"hp":30.0,"offset":[-3,-2,0]},"Right leg":{"hp":30.0,"offset":[3,-2,0]}}
		if ground_mode(): actor.vehicle.profile.cruise = 0; actor.vehicle.profile.brake = 0; actor.vehicle.speed = 0; actor.vehicle.velocity = Vector3.ZERO

func advance(dt: float, request: Dictionary) -> void:
	if mode!="flight": return
	elapsed += dt; stage_time += dt; quiet_time += dt
	missile_wait = maxf(0.0,missile_wait-dt)
	_admit()
	_update_hazards(dt)
	ground_fire_wait = maxf(0,ground_fire_wait-dt)
	var hostile_firing := 0
	for actor in actors.values():
		if actor.phase=="secured" and not ground_mode() and definition.id!="viridia_last_ferry":
			var berth: int = maxi(0,facts.rescues.find(actor.id))
			actor.vehicle.position = actor.vehicle.position.move_toward(carrier_position+Vector3((berth%4-1.5)*6,-2,-35+floori(berth/4.0)*9),dt*3)
			continue
		if actor.hp<=0 or actor.phase in ["secured","disabled","withdrawn","lost"]: continue
		actor.grace = maxf(0.0,actor.grace-dt)
		actor.cooldown = maxf(0.0,actor.cooldown-dt)
		actor.burst_wait = maxf(0.0,actor.burst_wait-dt)
		var intent := request if actor.id=="comet" else _intent(actor,dt)
		if ground_mode() and actor.id=="comet": _ground_player(dt,intent)
		elif ground_mode() and actor.kind=="tank": actor.vehicle.previous_position = actor.vehicle.position
		else: actor.vehicle.step(dt,intent,cover,float(definition.radius),float(definition.height))
		if actor.kind=="wingman" and actor.burst>0 and actor.burst_wait<=0:
			weapons.launch(actor.uid,0,actor.vehicle.muzzle(),actor.vehicle.forward(),7,120,2)
			actor.burst -= 1; actor.burst_wait = .09
		for event in actor.vehicle.events:
			if str(event).begins_with("collision:"): hurt(actor.id,18.0,"Solid structure collision")
		if bool(intent.get("fire",false)):
			if actor.team==1:
				if hostile_firing>=(1 if settings.difficulty=="Cadet" else 3 if settings.difficulty=="Ace" else 2): continue
				hostile_firing += 1
			if ground_mode() and actor.id=="comet":
				if ground_fire_wait<=0:
					weapons.launch(actor.uid,0,actor.vehicle.position+Vector3(0,2,-3),Vector3(0,sin(tank_aim),-cos(tank_aim)))
					ground_fire_wait = .18
			elif actor.kind=="wingman":
				var count := weapons.shots.size()
				if weapons.fire(actor.uid,actor.vehicle,cover,0):
					var profile: Dictionary = Squadron.profile(actor.id)
					weapons.cooldowns[actor.uid] = float(profile.interval)/(1+.22*(actor.level-1))
					for i in range(count,weapons.shots.size()): weapons.shots[i].damage = 6*float(profile.damage)*(1+.4*(actor.level-1))
			else:
				var count := weapons.shots.size()
				if weapons.fire(actor.uid,actor.vehicle,cover,actor.team):
					actor.vehicle.events.append("fired")
					if actor.id=="comet":
						for i in range(count,weapons.shots.size()): weapons.shots[i].damage = 6*(1+.4*(laser_level-1))
	var active := actors.values().filter(func(a):return a.hp>0 and a.phase=="active")
	for i in range(active.size()):
		for j in range(i+1,active.size()):
			var a = active[i]; var b = active[j]
			if Geometry.sphere_time(a.vehicle.previous_position-b.vehicle.previous_position,a.vehicle.position-b.vehicle.position,Vector3.ZERO,a.radius+b.radius)!=INF:
				hurt(a.id,18,"Aircraft contact with "+b.id); hurt(b.id,18,"Aircraft contact with "+a.id)
	var bodies: Array = []
	for actor in actors.values():
		if actor.hp>0 and actor.phase=="active": bodies.append({"id":actor.uid,"team":actor.team,"position":actor.vehicle.position,"previous":actor.vehicle.previous_position,"radius":actor.radius})
		if actor.hp>0 and actor.phase=="active":
			for name in actor.parts:
				if actor.parts[name].hp>0:
					var point: Vector3 = actor.vehicle.position+actor.vehicle.orientation()*Actor.point(actor.parts[name].offset)
					bodies.append({"id":2000+actor.uid*8+actor.parts.keys().find(name),"team":actor.team,"position":point,"previous":point,"radius":2.5})
	# Capital component surfaces participate in the same nearest swept hit order.
	if core_hp>0 or not components.is_empty():
		for name in components:
			if components[name].hp>0:
				var index := components.keys().find(name)
				bodies.append({"id":1000+index,"team":1,"position":Actor.point(components[name].point),"previous":Actor.point(components[name].point),"radius":7.0})
		if core_hp>0: bodies.append({"id":1100,"team":1,"position":boss_position,"previous":boss_position,"radius":12.0})
	for impact in weapons.step(dt,bodies,cover):
		if str(impact.cover).begins_with("carrier-") and int(impact.team)==1: facts.carrier.hull = maxf(0,float(facts.carrier.hull)-float(impact.damage)*.3)
		if float(impact.blast_radius)>0:
			for actor in actors.values():
				if int(impact.target)>=2000 and actor.uid==int((int(impact.target)-2000)/8): continue
				if actor.team!=int(impact.team) and actor.vehicle.position.distance_to(impact.point)<float(impact.blast_radius): hurt(actor.id,float(impact.damage),"Missile area blast")
		if impact.target>=2000:
			for actor in actors.values():
				if actor.uid==int((impact.target-2000)/8): damage_actor_part(actor.id,actor.parts.keys()[(impact.target-2000)%8],float(impact.damage))
		elif impact.target>=1000:
			if impact.target==1100: damage_core(float(impact.damage))
			else: damage_component(components.keys()[impact.target-1000],float(impact.damage))
		else:
			for actor in actors.values():
				if actor.uid==impact.target: hurt(actor.id,float(impact.damage),"Enemy firing pass" if impact.owner!=player().uid else "COMET firing pass")
	if request.get("missile",false): missile()
	if request.get("bomb",false): nova()
	_collect_supplies()
	_update_objective(dt,request)

func _collect_supplies() -> void:
	var own = player().vehicle
	for i in range(pickups.size()-1,-1,-1):
		var item: Dictionary = pickups[i]
		if Geometry.sphere_time(own.previous_position,own.position,Actor.point(item.point),6)==INF: continue
		match str(item.kind):
			"ring":
				rings += 1; player().hp = minf(player().max_hp,player().hp+15)
				if rings%3==0: laser_level = mini(3,laser_level+1)
			"ammo": missiles = mini(8,missiles+3)
			"repair": player().hp = minf(player().max_hp,player().hp+25); missiles = mini(8,missiles+2)
			"nova": bombs = mini(3,bombs+1)
			"wing":
				for wing in allies():
					if wing.hp<=0 or wing.phase=="withdrawn": continue
					wing.level = mini(3,wing.level+1); wing.hp = minf(wing.max_hp,wing.hp+10); wing.cooldown = maxf(0,wing.cooldown-3)
		score += 200 if item.kind=="ring" else 100
		events.append({"type":"pickup","text":str(item.kind).to_upper()+" collected / +"+str(200 if item.kind=="ring" else 100)})
		pickups.remove_at(i)

func nova() -> void:
	if bombs<=0 or mode!="flight": return
	bombs -= 1
	for actor in living_hostiles():
		if actor.vehicle.position.distance_to(player().vehicle.position)<90: hurt(actor.id,80,"Nova blast")
	weapons.shots = weapons.shots.filter(func(s):return s.team==0 or s.position.distance_to(player().vehicle.position)>90)

func _intent(actor: RefCounted, dt: float) -> Dictionary:
	var own = actor.vehicle
	var goal: Vector3 = actor.goal
	var fire := false
	if actor.task=="transport":
		if actor.hp<actor.max_hp*.5:
			own.profile.cruise = 8.0; own.profile.brake = 4.0
		if actor.waypoint<actor.path.size():
			goal = actor.path[actor.waypoint]
			if own.position.distance_to(goal)<(5 if actor.waypoint==actor.path.size()-1 else 15):
				actor.waypoint += 1
		else:
			actor.phase = "secured"
			if not facts.rescues.has(actor.id): facts.rescues.append(actor.id)
			return {"brake":true}
	elif actor.task=="hold": goal = actor.goal
	elif ground_mode() and actor.kind=="tank":
		var aim: Vector3 = own.position.direction_to(player().vehicle.position)
		own.heading = atan2(-aim.x,-aim.z); own.pitch = asin(clampf(aim.y,-1,1))
		return {"brake":true,"fire":actor.cooldown<=0 and stage_time>2.4}
	elif ground_mode() and actor.kind=="walker":
		var phase := fmod(stage_time,9.0)
		var legs_ok: bool = actor.parts.get("Left leg",{}).get("hp",0)>0 and actor.parts.get("Right leg",{}).get("hp",0)>0
		actor.vehicle.profile.cruise = 5.0 if legs_ok else 0.0
		actor.vehicle.profile.brake = 0.0; actor.vehicle.profile.boost = 5.0
		actor.vehicle.profile.pitch_limit = 0.0
		actor.vehicle.pitch = 0
		var visible := Geometry.first_cover(own.position+Vector3(0,4,0),player().vehicle.position+Vector3(0,2,0),cover).is_empty()
		if phase<4.0:
			if visible: actor.goal = player().vehicle.position
			return {"steer":Pilot.steer_to(own,Vector3(actor.goal.x,own.position.y,actor.goal.z)),"fire":false}
		# Plant before the warned shot. The body cannot snap after the aim locks.
		var aligned: bool = own.forward().dot(own.position.direction_to(actor.goal))>.94
		return {"brake":true,"fire":phase>6.4 and phase<6.8 and aligned and visible and actor.parts.get("Gun",{}).get("hp",0)>0}
	elif actor.team==1:
		var target = player()
		if actor.kind=="bomber":
			var cargo = actors.get(required_cargo)
			if cargo!=null and cargo.team==0 and cargo.hp>0: target = cargo
			elif own.position.distance_to(carrier_position)<180:
				goal = carrier_position+Vector3(0,5,-160)
				return {"steer":Pilot.steer_to(own,goal),"fire":own.forward().dot(own.position.direction_to(carrier_position))>.96}
		var sensed := Pilot.sensor(own.position,own.forward(),target.vehicle.position,target.vehicle.velocity,weapons.shots,cover,elapsed)
		actor.pilot.feed(sensed)
		var intent: Dictionary = actor.pilot.update(dt,own,cover,float(definition.radius),float(definition.height))
		if actor.id in ["rook","shrike","slate"] and actor.hp<25:
			if actor.task!="withdraw": events.append({"type":"rival","text":actor.id+" damaged / attempting withdrawal"})
			actor.task = "withdraw"
			var exit := Vector3(float(definition.radius)-85,115,-60)
			if own.position.distance_to(exit)<18: actor.phase = "withdrawn"; facts.rivals[actor.id] = "withdrawn"
			return {"steer":Pilot.steer_to(own,exit),"boost":own.energy>30,"fire":false}
		if actor.id=="rook" and actor.pilot.visible and fmod(stage_time,18.0)<7:
			var lure := Vector3(160,45,-110)
			return {"steer":Pilot.steer_to(own,lure),"boost":own.energy>40,"fire":false}
		if actor.id=="shrike" and actor.pilot.state in ["acquire","approach"] and own.position.y<float(definition.height)*.65:
			return {"steer":Pilot.steer_to(own,Vector3(own.position.x,float(definition.height)*.78,-90)),"brake":false,"fire":false}
		if actor.id=="slate":
			for partner in living_hostiles():
				if partner.id in ["rook","shrike"] and partner.hp<50 and own.position.distance_to(partner.vehicle.position)<180:
					return {"steer":Pilot.steer_to(own,partner.vehicle.position+partner.vehicle.forward()*35),"fire":intent.fire}
		var radio_active: bool = components.has("Contact antenna") and not components["Contact antenna"].disabled
		if radio_active and not actor.pilot.visible:
			for reporter in living_hostiles():
				if reporter!=actor and reporter.pilot.visible and reporter.pilot.observed_age()<.75 and own.position.distance_to(reporter.vehicle.position)<360:
					return {"steer":Pilot.steer_to(own,reporter.pilot.predicted_contact()),"fire":false}
		return intent
	else:
		var index := allies().find(actor)
		if actor.hp<actor.max_hp*.2 or actor.task=="withdraw":
			actor.task = "withdraw"
			var retreat := carrier_position+Vector3(110,25,80)
			if own.position.distance_to(retreat)<25:
				actor.phase = "withdrawn"; facts.companions[actor.id] = {"hp":actor.hp,"withdrawn":true}
			return {"steer":Pilot.steer_to(own,retreat),"brake":true}
		goal = player().vehicle.position+player().vehicle.orientation()*Squadron.offset(formation,maxi(index,0))
		if ground_mode(): goal = player().vehicle.position+Vector3(130 if fmod(elapsed+index*6,12)<6 else -130,45,-70)
		if actor.task=="protect": goal = carrier_position+Vector3((index*2-1)*45,30,-50)
		if actor.task=="cover": goal = player().vehicle.position+player().vehicle.forward()*18+Vector3((index*2-1)*6,0,0)
		if actor.task=="attack" and components.has(actor.target) and components[actor.target].hp>0:
			goal = Actor.point(components[actor.target].point)
			fire = own.position.distance_to(goal)<180 and own.forward().dot(own.position.direction_to(goal))>.96 and Geometry.first_cover(own.position,goal,cover).is_empty()
		var target = actors.get(actor.target)
		if actor.task=="attack" and target!=null and target.hp>0:
			goal = actor.goal
			if Geometry.first_cover(own.position,target.vehicle.position,cover).is_empty(): actor.goal = target.vehicle.position; goal = actor.goal
		elif actor.task!="attack":
			for enemy in living_hostiles():
				if own.position.distance_to(enemy.vehicle.position)<120 and own.forward().dot(own.position.direction_to(enemy.vehicle.position))>.94:
					target = enemy; break
		if target!=null and target.hp>0:
			fire = own.position.distance_to(target.vehicle.position)<180 and own.forward().dot(own.position.direction_to(target.vehicle.position))>.96 and Geometry.first_cover(own.position,target.vehicle.position,cover,.15).is_empty()
	if not Geometry.first_cover(own.position,goal,cover,4).is_empty():
		goal = Vector3(actor.route_side*135,maxf(95,own.position.y),-110 if own.position.z>0 else 100)
		actor.target = actor.target if actor.task=="attack" else ""
	for other in actors.values():
		if other==actor or other.hp<=0 or other.phase!="active": continue
		var relative: Vector3 = other.vehicle.position-own.position
		var closing: Vector3 = other.vehicle.velocity-own.velocity
		var time := clampf(-relative.dot(closing)/maxf(closing.length_squared(),.01),0,2)
		if (relative+closing*time).length()<12: return {"steer":Vector2(-1,0),"brake":true,"fire":false}
	return {"steer":Pilot.steer_to(own,goal),"brake":own.position.distance_to(goal)<45,"fire":fire}

func _ground_player(dt: float, request: Dictionary) -> void:
	var actor = player(); var own = actor.vehicle
	var axis: Vector2 = request.get("steer",Vector2.ZERO)
	tank.advance(dt,bool(request.get("boost",false)))
	tank_aim = move_toward(tank_aim,axis.y*.65,dt*2)
	var gate := -20.0-stage*180.0
	if state().kind=="boss": gate = -350
	if state().kind=="escort": gate = -480
	var distance := (5.0 if request.get("brake",false) else 12.0)*dt
	var point: Vector3 = own.position+Vector3(axis.x*25*dt,0,-distance if own.position.z>gate else 0)
	point.x = clampf(point.x,-100,100); point.y = tank.height
	var hit := Geometry.first_cover(own.position,point,cover,2)
	own.previous_position = own.position
	if hit.is_empty(): own.position = point
	else: own.denied = "GROUND OBSTACLE / HOVER OR TAKE THE SIDE ROUTE"
	own.velocity = (own.position-own.previous_position)/maxf(dt,.000001)
	own.speed = own.velocity.length(); own.heading = 0; own.pitch = 0; own.bank = 0
	own.energy = tank.fuel

func hurt(id: String, amount: float, source: String) -> void:
	if not actors.has(id): return
	var actor = actors[id]
	if actor.hp<=0 or actor.grace>0 or actor.vehicle.protected(): return
	if actor.team==0 and not source.begins_with("Arranged"): amount *= .72 if settings.get("difficulty")=="Cadet" else 1.2 if settings.get("difficulty")=="Ace" else 1.0
	actor.hp = maxf(0,actor.hp-amount); actor.grace = .8 if "collision" in source.to_lower() or "contact" in source.to_lower() or "storm" in source.to_lower() else .06
	events.append({"type":"hit","id":id,"text":id+" / "+source})
	if actor.kind=="wingman": facts.companions[id] = {"hp":actor.hp,"withdrawn":actor.hp<=0}
	if actor.hp>0: return
	quiet_time = 0
	if id=="comet": fail(source); return
	if actor.team==1:
		score += 100
		if id in ["rook","shrike","slate"]:
			facts.rivals[id] = "disabled"; actor.phase = "disabled"
	if actor.critical: fail("Required craft lost: "+id)
	else: events.append({"type":"withdrawal","text":id+" withdrawn / "+source})

func damage_actor_part(id: String, part: String, amount: float) -> void:
	if not actors.has(id) or not actors[id].parts.has(part): return
	var actor = actors[id]
	actor.parts[part].hp = maxf(0,actor.parts[part].hp-amount)
	if actor.parts[part].hp<=0:
		events.append({"type":"component","text":id+" / "+part+" disabled"})
		if part=="Drive" and actor.id==required_cargo:
			actor.phase = "disabled"; actor.critical = false

func assign(task: String, target: String = "") -> bool:
	if not task in ["attack","protect","cover","regroup"] or (task=="attack" and not actors.has(target) and not components.has(target)):
		events.append({"type":"denial","text":"No valid assignment target"}); return false
	for actor in allies():
		if actor.hp<=0: continue
		actor.task = task; actor.target = target
		if task=="attack": actor.goal = actors[target].vehicle.position if actors.has(target) else Actor.point(components[target].point)
	events.append({"type":"assignment","text":task.to_upper()+" acknowledged"})
	return true

func missile() -> void:
	if missiles<=0 or missile_wait>0: return
	var own = player().vehicle
	if selected.contains(":"):
		var names := selected.split(":")
		if actors.has(names[0]) and actors[names[0]].phase=="active" and actors[names[0]].parts.has(names[1]) and actors[names[0]].parts[names[1]].hp>0:
			var actor = actors[names[0]]
			var point: Vector3 = actor.vehicle.position+actor.vehicle.orientation()*Actor.point(actor.parts[names[1]].offset)
			if own.position.distance_to(point)<250 and own.forward().dot(own.position.direction_to(point))>.92 and Geometry.first_cover(own.position,point,cover).is_empty():
				missiles -= 1; missile_wait = 2.5; weapons.launch(player().uid,0,own.muzzle(),own.forward(),55,140,6,2000+actor.uid*8+actor.parts.keys().find(names[1]))
		return
	var target = actors.get(selected)
	if target!=null and target.hp>0 and target.phase=="active" and own.position.distance_to(target.vehicle.position)<250 and own.forward().dot(own.position.direction_to(target.vehicle.position))>.92 and Geometry.first_cover(own.position,target.vehicle.position,cover).is_empty():
		missiles -= 1; missile_wait = 2.5
		weapons.launch(player().uid,0,own.muzzle(),own.forward(),55,140,6,target.uid)
	elif selected in components and components[selected].hp>0:
		var point: Vector3 = Actor.point(components[selected].point)
		if own.position.distance_to(point)<250 and own.forward().dot(own.position.direction_to(point))>.92:
			missiles -= 1; missile_wait = 2.5
			weapons.launch(player().uid,0,own.muzzle(),own.forward(),55,140,6,1000+components.keys().find(selected))
	elif selected=="CORE" and core_hp>0 and own.position.distance_to(boss_position)<250 and own.forward().dot(own.position.direction_to(boss_position))>.92:
		missiles -= 1; missile_wait = 2.5; weapons.launch(player().uid,0,own.muzzle(),own.forward(),55,140,6,1100)

func damage_component(name: String, amount: float) -> void:
	if not components.has(name) or components[name].hp<=0: return
	components[name].hp = maxf(0,float(components[name].hp)-amount)
	if components[name].hp<=0:
		components[name].disabled = true
		events.append({"type":"component","text":name+" disabled"})
		if name=="Crossing cannon": facts.crossing_open = true
		if name=="Support thruster": facts["support_thruster_lost"] = true
		if definition.id=="terminus_falling_yard":
			var next: int = 0
			if components.get("Runaway drive",{}).get("disabled",false): next = 1
			if next==1 and components.get("Coupling",{}).get("disabled",false): next = 2
			if next==2 and components.get("Jammed stabilizer",{}).get("disabled",false): next = 3
			if next>vessel_state:
				vessel_state = next
				events.append({"type":"objective","text":["","Spin arrested. Counter-trim coupling is exposed.","Lower stabilizer accessible. Release the jammed stabilizer.","Diversion stabilized. The release remains confirmed."][vessel_state]})
				checkpoint_revision += 1; checkpoint = snapshot()

func core_open() -> bool:
	if boss_kind==5:
		return components.get("Core shield",{}).get("disabled",false) or fmod(stage_time,28.0)>=20.0
	if components.has("Core shield") and components["Core shield"].disabled: return true
	if boss_kind in [0,1,3]: return components.values().any(func(c):return c.hp<=0)
	if components.has("Drive regulator") and components["Drive regulator"].disabled: return fmod(stage_time,10.0)>4.0
	if boss_kind==2: return components.values().any(func(c):return c.hp<=0) and fmod(stage_time,12)>6
	return components.values().all(func(c):return c.hp<=0)

func damage_core(amount: float) -> void:
	if core_hp<=0: return
	core_hp = maxf(0,core_hp-amount*(1.0 if core_open() else .08))
	if core_hp<=0:
		score += 3000; boss_kind = -1
		for name in components: components[name].disabled = true
		if definition.id=="terminus_siege": facts.carrier.drive_overstrained = true

func _update_hazards(dt: float) -> void:
	_build_cover()
	if definition.id=="terminus_falling_yard" and state().id=="spin_control":
		var old := boss_position
		if vessel_state==0:
			vessel_angle = deg_to_rad(15)*sin(stage_time/6.0)
			boss_position.y = maxf(70,90-stage_time*.12)
		elif vessel_state>=2: vessel_angle = move_toward(vessel_angle,0,dt*.025)
		for name in components: components[name].point = Actor.vec(Actor.point(components[name].point)+boss_position-old)
		var solid := Transform3D(Basis(Vector3.BACK,vessel_angle),boss_position)*AABB(Vector3(-28,-7,-40),Vector3(56,14,80))
		cover.append({"id":"industrial-hull","box":solid,"visual":false})
	elif boss_kind==2 and core_hp>0 and not components.get("Drive regulator",{}).get("disabled",true):
		var shift := Vector3(22*sin(stage_time*.12)-boss_position.x,0,0)
		boss_position += shift
		for name in components: components[name].point = Actor.vec(Actor.point(components[name].point)+shift)
	var carrier_shift := carrier_position-Vector3(0,75,0)
	for entry in cover:
		if str(entry.id).begins_with("carrier-"): entry.box.position += carrier_shift
	hazard_phase += dt
	var storm: bool = state().get("storm",false) and not components.get("Storm control",{}).get("disabled",false)
	var phase := fmod(hazard_phase,24.0)
	hazard_box = AABB(Vector3(-25,15,-180),Vector3(50,float(definition.height)-25,300))
	hazard_warning = storm and phase>=7 and phase<15
	hazard_active = storm and phase>=15 and phase<18
	if definition.id=="terminus_falling_yard" and state().id=="spin_control":
		var pulse := fmod(stage_time,25.0)
		hazard_box = AABB(Vector3(-40,30,-180),Vector3(80,45,100))
		hazard_warning = pulse>=4 and pulse<10
		hazard_active = pulse>=10 and pulse<15
	if hazard_active:
		for actor in actors.values():
			if actor.phase=="active" and hazard_box.grow(actor.radius).has_point(actor.vehicle.position): hurt(actor.id,22,"Forecast storm front")
	if state().kind=="escape":
		wreck_phase += dt
		forecast_time = maxf(0,12-wreck_phase)
		for i in range(3):
			var offset: float = maxf(0,minf(wreck_phase-12,15))*(2.0+i*.6)
			cover.append({"id":"major-wreck-%d"%i,"box":AABB(Vector3(-100+i*50+offset,25+i*12,-90-i*45),Vector3(26,48,18))})
	if core_hp>0:
		if boss_kind==1:
			for index in range(components.size()): components[components.keys()[index]].point = Actor.vec(boss_position+Basis(Vector3.UP,PI)*preload("res://scripts/ship_model.gd").rime_tip(elapsed,index)*2)
		boss_fire -= dt
		if capital_warning>0:
			capital_warning -= dt
			if capital_warning<=0:
				var gun_alive: bool = components.has(capital_gun) and not components[capital_gun].disabled
				if gun_alive:
					for offset in [-5.0,0.0,5.0]: weapons.launch(3000,1,capital_origin+Vector3(offset,0,0),capital_origin.direction_to(capital_aim),12,120,4)
		if boss_fire<=0 and capital_warning<=0:
			boss_fire = 4.5
			var active_guns := components.keys().filter(func(name):return not components[name].disabled and (name.contains("cannon") or name.contains("battery") or name.contains("mortar") or name.contains("arm") or name.contains("tracker") or name.contains("sweep") or name.contains("gun") or name.contains("Lance")))
			active_guns = active_guns.filter(func(name):return not (name=="High tracker" and player().vehicle.position.y<80) and not (name=="Low sweep" and player().vehicle.position.y>80))
			if not active_guns.is_empty() and player().vehicle.position.distance_to(boss_position)<250 and Geometry.first_cover(Actor.point(components[active_guns[0]].point),player().vehicle.position,cover).is_empty():
				capital_gun = active_guns[0]
				capital_warning = 6.0; capital_origin = Actor.point(components[capital_gun].point); capital_aim = player().vehicle.position
				events.append({"type":"warning","text":"CAPITAL BATTERY CHARGING / cross the marked line"})
		var launcher: String = "Launch bay" if components.has("Launch bay") else "Pursuit launcher"
		if components.has(launcher) and not components[launcher].disabled and reserve>0 and stage_time>=launcher_at:
			var active_pair := living_hostiles().any(func(a):return a.id.begins_with("launcher_"))
			if not active_pair and living_hostiles().size()<=6:
				for i in range(mini(2,reserve)):
					var id := "launcher_%s_%d_%d"%[state().id,reserve,i]
					spawn(id,1,"fighter",boss_position+Vector3((i*2-1)*28,10,35),60)
				reserve -= 2; launcher_at = stage_time+12
	if float(facts.carrier.hull)<=0: fail("Dragonfly hull lost")

func _update_objective(dt: float, request: Dictionary) -> void:
	if mode!="flight": return
	var current := state()
	var complete := false
	match str(current.kind):
		"combat","ground","rival": complete = living_hostiles().is_empty() and pending.is_empty()
		"control": complete = components.values().all(func(c):return c.hp<=0) and living_hostiles().is_empty() and pending.is_empty()
		"boss":
			complete = core_hp<=0
			if definition.id=="viridia_blockade" and components.get("Crossing cannon",{}).get("disabled",false): complete = true
			if definition.id=="terminus_falling_yard":
				complete = vessel_state>=3
				if complete: facts["vessel_stabilized"] = true
		"escort":
			complete = not required_cargo.is_empty() and actors[required_cargo].phase=="secured"
			if current.get("keep_boss",false): complete = complete and core_hp<=0
			if complete and current.get("repair",false): repair_cargo = true; facts.carrier.parts_secured = true; repair_phase = "cargo_latched"
			if complete and definition.id=="terminus_siege": facts.carrier.drive_overstrained = true
		"intercept":
			var courier = actors.get(required_cargo)
			if courier!=null and courier.phase=="disabled": complete = true
			elif courier!=null and courier.phase=="secured": fail("Courier reached the departure corridor")
		"interact":
			var point := Actor.point(current.point)
			if current.id=="codes" and actors.has("intercept_craft"): point = actors.intercept_craft.vehicle.position
			if player().vehicle.position.distance_to(point)<30 and request.get("interact",false): interact_time += dt
			complete = interact_time>=2
		"recovery":
			var craft = actors.get(required_cargo)
			var blocked := living_hostiles().any(func(a):return a.vehicle.position.distance_to(Vector3(0,75,-100))<65)
			if craft!=null and craft.hp<=0: recovery_phase = "lost"; complete = true
			elif blocked and craft!=null:
				if recovery_phase!="holding": recovery_attempts += 1; events.append({"type":"recovery_abort","text":"Bay approach blocked. Craft holding for another attempt."})
				recovery_phase = "holding"; craft.task = "hold"; craft.goal = Vector3(-130,105,-130); door = move_toward(door,0,dt)
			else:
				if craft!=null: craft.task = "transport"
				recovery_phase = "final_approach"; door = move_toward(door,1,dt)
				complete = craft!=null and craft.phase=="secured"
			if current.get("player_recovery",false): complete = player().vehicle.position.distance_to(Vector3(0,74,-66))<18 and not blocked
			if complete: recovery_phase = "secured"; door = 0
			if current.get("rival_recovery",false):
				if recovering_rival.is_empty(): complete = true
				elif complete and recovery_phase=="secured": facts.rivals[recovering_rival] = "recovered"
		"return": complete = player().vehicle.position.distance_to(Vector3(110,95,80))<35 or (ground_mode() and facts.carrier.parts_secured)
		"departure":
			repair_phase = "installation_protected" if stage_time<3 else "function_check" if stage_time<6 else "departure_ready"
			if living_hostiles().is_empty():
				facts.carrier.repaired = repair_cargo or facts.carrier.parts_secured
				if facts.carrier.repaired: facts.carrier.drive_overstrained = false
				if repair_phase=="departure_ready": carrier_position.z -= 8*dt
			complete = carrier_position.z< -120 and living_hostiles().is_empty()
		"escape": complete = player().vehicle.position.distance_to(Vector3(150,65,120))<35
		"ending": complete = quiet_time>6 and player().vehicle.position.distance_to(Vector3(110,95,80))<70
	if complete: next_stage()

func next_stage() -> void:
	if mode!="flight": return
	if definition.id=="viridia_last_ferry" and state().id=="holding" and actors.has("lead_ferry") and actors.lead_ferry.hp>0 and not facts.get("ferry_service_used",false):
		actors.lead_ferry.hp = maxf(actors.lead_ferry.hp,45)
		facts.ferry_service_used = true
		events.append({"type":"objective","text":"Shelter crew completed the ferry's emergency hull patch. Remaining damage still slows it."})
	objectives.append(state().id)
	if definition.id=="cinder_corridor" and state().id=="parts": facts.carrier.parts_secured = true
	if stage==definition.states.size()-1:
		for wing in allies(): facts.companions[wing.id] = {"hp":wing.hp,"withdrawn":wing.hp<=0 or wing.phase=="withdrawn"}
		mode = "won"; events.append({"type":"debrief","text":"Operation settled"}); return
	stage += 1
	_enter()

func fail(message: String) -> void:
	if mode!="flight": return
	mode = "lost"; reason = message
	events.append({"type":"failure","text":message})

func ending_text() -> String:
	var lines: Array[String] = ["Crown is silent. Dragonfly leads the surviving ships beyond the storm."]
	lines.append("The replacement drive holds steady." if facts.carrier.repaired else "The crew keeps the drive under watch for the journey home.")
	if facts.carrier.hull<40: lines.append("The hull carries the scars of the evacuation; the people aboard are alive.")
	lines.append("%d rescued craft have a place in the returning convoy."%facts.rescues.size())
	for id in ["rook","shrike","slate"]:
		var outcome: String = facts.rivals.get(id,"unseen")
		if outcome=="recovered": lines.append(id.capitalize()+" is safely accounted for aboard the recovery flight.")
		elif outcome=="withdrawn": lines.append(id.capitalize()+" broke away from the fight; no later return is assumed.")
		elif outcome=="disabled": lines.append(id.capitalize()+"'s aircraft was disabled. Recovery remains unconfirmed.")
	return "\n".join(lines)

func snapshot() -> Dictionary:
	return {"version":1,"mission":definition.id,"stage":stage,"elapsed":elapsed,"stage_time":stage_time,"score":score,"next_uid":next_uid,"actors":actors.values().map(func(a):return a.snapshot()),"facts":facts.duplicate(true),"objectives":objectives.duplicate(),"core_hp":core_hp,"components":components.duplicate(true),"boss_kind":boss_kind,"reserve":reserve,"repair_cargo":repair_cargo,"required_cargo":required_cargo,"missiles":missiles,"bombs":bombs,"formation":formation,"carrier_position":Actor.vec(carrier_position),"settings":settings.duplicate(true),"pending":pending.duplicate(true),"tank":{"height":tank.height,"vertical_speed":tank.vertical_speed,"fuel":tank.fuel,"exhausted":tank.exhausted},"recovering_rival":recovering_rival,"boss_position":Actor.vec(boss_position),"vessel_angle":vessel_angle,"vessel_state":vessel_state,"repair_phase":repair_phase,"pickups":pickups.duplicate(true),"rings":rings,"laser_level":laser_level}

func restore(record: Dictionary) -> bool:
	if record.get("version")!=1 or not record.get("mission","") in Catalog.IDS: return false
	var candidate := Catalog.definition(record.mission)
	if int(record.get("stage",-1))<0 or int(record.stage)>=candidate.states.size(): return false
	for key in ["elapsed","stage_time","score","next_uid","core_hp","boss_kind","reserve","missiles","bombs","formation"]:
		if not _number(record.get(key)): return false
	for key in ["repair_cargo"]:
		if not record.get(key) is bool: return false
	if not record.get("required_cargo") is String: return false
	if not record.get("pickups") is Array or not _number(record.get("rings")) or not _number(record.get("laser_level")): return false
	for item in record.pickups:
		if not item is Dictionary or not item.get("id") is String or not item.get("kind") in ["ring","ammo","wing","repair","nova"] or not _vector(item.get("point")): return false
	if not _vector(record.get("boss_position")) or not _number(record.get("vessel_angle")) or not _number(record.get("vessel_state")) or not record.get("repair_phase") is String: return false
	for key in ["facts","components","settings"]:
		if not record.get(key) is Dictionary: return false
	for key in ["actors","objectives","carrier_position"]:
		if not record.get(key) is Array: return false
	if record.actors.size()>256 or not _vector(record.carrier_position): return false
	if not record.facts.get("carrier") is Dictionary or not record.facts.get("rivals") is Dictionary or not record.facts.get("rescues") is Array: return false
	if not _number(record.facts.carrier.get("hull")): return false
	for name in record.components:
		var part: Variant = record.components[name]
		if not part is Dictionary or not _number(part.get("hp")) or not _vector(part.get("point")) or not part.get("disabled") is bool: return false
	var seen := {}
	var uids := {}
	for entry in record.actors:
		if not entry is Dictionary or not entry.get("motion") is Dictionary: return false
		for key in ["id","kind","task","target","phase"]:
			if not entry.get(key) is String: return false
		for key in ["uid","team","hp","max_hp","cooldown","waypoint","level","radius","grace","route_side"]:
			if not _number(entry.get(key)): return false
		if seen.has(entry.id) or uids.has(entry.uid) or int(entry.uid)<0 or int(entry.uid)>1024: return false
		seen[entry.id] = true
		uids[entry.uid] = true
		if not entry.get("critical") is bool or entry.max_hp<=0 or entry.hp<0 or entry.hp>entry.max_hp or entry.radius<=0: return false
		if not entry.phase in ["active","secured","disabled","withdrawn","lost"]: return false
		for key in ["position","previous_position","velocity"]:
			if not _vector(entry.motion.get(key)): return false
		for key in ["heading","pitch","speed","energy","roll_time","roll_wait","roll_direction","bank","angular_rate","boundary_side","boundary_events","contact_cooldown"]:
			if not _number(entry.motion.get(key)): return false
		for key in ["depleted","boundary","pitch_hold"]:
			if not entry.motion.get(key) is bool: return false
		if not entry.get("path") is Array or not _vector(entry.get("goal")): return false
		for point in entry.path:
			if not _vector(point): return false
		if entry.waypoint<0 or entry.waypoint>entry.path.size(): return false
		if not entry.get("profile") is Dictionary: return false
		for key in Actor.Vehicle.PROFILE:
			if key=="id": continue
			if not _number(entry.profile.get(key)) or entry.profile[key]<0: return false
		if entry.profile.angular_rate<=0 or entry.profile.extent<=0 or entry.profile.extent>12: return false
		if not entry.get("parts",{}) is Dictionary: return false
		for name in entry.get("parts",{}):
			var part: Variant = entry.parts[name]
			if not part is Dictionary or not _number(part.get("hp")) or not _vector(part.get("offset")): return false
	if not seen.has("comet"): return false
	definition = candidate
	actors.clear(); weapons.reset(); events.clear()
	for entry in record.actors:
		var actor = Actor.restore(entry); actors[actor.id] = actor
	for key in ["stage","elapsed","stage_time","score","next_uid","facts","objectives","core_hp","components","boss_kind","reserve","repair_cargo","required_cargo","missiles","bombs","formation","settings"]: set(key,record[key])
	for actor in actors.values(): actor.pilot.time = elapsed
	pending.clear()
	for entry in record.get("pending",[]): pending.append(entry)
	for key in record.get("tank",{}): tank.set(key,record.tank[key])
	recovering_rival = str(record.get("recovering_rival",""))
	carrier_position = Actor.point(record.carrier_position); boss_position = Actor.point(record.boss_position)
	vessel_angle = record.vessel_angle; vessel_state = int(record.vessel_state); repair_phase = record.repair_phase
	pickups.clear()
	for item in record.pickups: pickups.append(item.duplicate(true))
	rings = int(record.rings); laser_level = clampi(int(record.laser_level),1,3)
	hazard_phase = stage_time; wreck_phase = stage_time
	mode = "flight"; reason = ""; door = 0; recovery_phase = "request"; boss_fire = 3.0
	_update_hazards(0); checkpoint_revision += 1; checkpoint = record.duplicate(true)
	return true

static func _number(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))

static func _vector(value: Variant) -> bool:
	return value is Array and value.size()==3 and value.all(func(v):return _number(v))
