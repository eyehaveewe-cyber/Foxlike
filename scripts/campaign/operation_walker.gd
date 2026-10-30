extends "res://scripts/campaign/pbr_ground_walker.gd"
## Root-distance adapter for the pinned PBR visual model. No tactical rules imported.
var travelled := 0.0
var previous_root := Vector3.ZERO
var gun: Node3D
var planted := [false,false]
var anchors: Array[Vector3] = [Vector3.ZERO,Vector3.ZERO]
var recoil := 0.0

func _ready() -> void:
	super._ready()
	set_process(false)
	gun = box(body,"CommittedGun",Vector3(.45,.5,2.8),Color("4c6675"),Vector3(0,4.05,-2.5))
	set_meta("asset_contract",{"source_blob":"56c53e4afdd37745f9be8ef589150c1e9b1c71bd","forward":"-Z","up":"+Y","pose":"root_distance / planted / gun_recoil","root_authority":"operation_session","reset":"reset_pose","part_ids":["ArmoredBody","LeftHip","RightHip","LeftKnee","RightKnee","LeftAnkle","RightAnkle","LeftFoot","RightFoot","CommittedGun"]})
	previous_root = global_position

func resolve_pose(distance: float, moving: bool, fired: bool, leg_disabled: bool, dt: float = .016) -> void:
	if global_position.distance_to(previous_root)>8: planted = [false,false]
	previous_root = global_position
	travelled += maxf(0,distance)
	var cycle_distance := 2*STRIDE*absf(scale.z)/.6
	sample_at(travelled/maxf(cycle_distance,.01),1.0 if moving and not leg_disabled else 0.0)
	for i in range(legs.size()):
		var step := fposmod(travelled/cycle_distance+(0 if i==0 else .5),1)
		var stance := not moving or leg_disabled or step<.6
		if stance and not planted[i]: anchors[i] = global_transform*foot_targets[i]
		planted[i] = stance
		if not stance: continue
		var foot := global_transform.affine_inverse()*anchors[i]
		var ankle := foot+Vector3(0,ANKLE_HEIGHT-FOOT_REST,.1)
		var hip: Vector3 = hip_points[i]
		var span: Vector3 = ankle-hip
		var direction := span.normalized()
		var bend := sqrt(maxf(0,THIGH_LENGTH*THIGH_LENGTH-span.length_squared()*.25))
		var knee := (hip+ankle)*.5+Vector3(0,direction.z,-direction.y).normalized()*bend
		place_link(legs[i].upper,hip,knee); place_link(legs[i].lower,knee,ankle)
		legs[i].knee.position = knee; legs[i].ankle.position = ankle; legs[i].foot.position = foot
		foot_targets[i] = foot; knee_points[i] = knee; ankle_points[i] = ankle
	if fired: recoil = .3
	else: recoil = move_toward(recoil,0,dt*1.2)
	if is_instance_valid(gun): gun.position.z = -2.5+recoil

func reset_pose() -> void:
	travelled = 0; sample_at(0,0)
	planted = [false,false]; recoil = 0
	if is_instance_valid(gun): gun.position.z = -2.5
