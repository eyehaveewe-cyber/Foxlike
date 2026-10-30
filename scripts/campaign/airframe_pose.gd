extends RefCounted
## Portable local pose, downstream of either game's resolved movement/damage.
## No roots, health, AP, cells, target selection or random state enter this API.
const CONTRACT := {"version":1,"forward":"-Z","up":"+Y","phases":["damaged","abort","rejoin","alignment","secured"],"inputs":["phase","progress","damage","reduced"],"reset":"apply alignment at progress 1, retaining confirmed damage","maximum_bank":.18}

static func apply(model: Node3D, phase: String, progress: float, damage: float, reduced: bool = false) -> void:
	var wound := clampf(damage,0,1)
	var pulse := sin(PI*clampf(progress,0,1))
	var bank := -.08*wound
	if not reduced and phase in ["abort","rejoin"]: bank += .1*pulse*(1 if phase=="abort" else -1)
	model.visual.rotation.z += bank
	for flap in model._flaps:
		if flap.position.x<0: flap.rotation.x += wound*.18
	for flame in model._flames:
		if flame.position.x<0: flame.scale.z *= 1-wound*.5
	model.set_meta("resolved_recovery_phase",phase)
