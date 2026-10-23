extends RefCounted
## Analytic swept collision shared by movement, weapons, sight and camera.
## All arguments are world coordinates; padding covers the complete airframe.
static func sweep_box(a: Vector3, b: Vector3, box: AABB, padding: float = 0.0) -> Dictionary:
	var bounds := box.grow(padding)
	var delta := b-a
	var enter := 0.0
	var leave := 1.0
	var normal := Vector3.ZERO
	if bounds.has_point(a):
		var nearest := INF
		for axis in range(3):
			for sign_value in [-1.0,1.0]:
				var face: float = bounds.position[axis] if sign_value<0 else bounds.end[axis]
				var distance: float = absf(a[axis]-face)
				if distance<nearest:
					nearest = distance
					normal = Vector3.ZERO
					normal[axis] = sign_value
		return {"t":0.0,"point":a,"normal":normal,"inside":true}
	for axis in range(3):
		if absf(delta[axis])<0.000001:
			if a[axis]<bounds.position[axis] or a[axis]>bounds.end[axis]: return {}
			continue
		var first: float = (bounds.position[axis]-a[axis])/delta[axis]
		var last: float = (bounds.end[axis]-a[axis])/delta[axis]
		var side := -1.0
		if first>last:
			var swap := first
			first = last
			last = swap
			side = 1.0
		if first>enter:
			enter = first
			normal = Vector3.ZERO
			normal[axis] = side
		leave = minf(leave,last)
		if enter>leave: return {}
	if enter<0.0 or enter>1.0: return {}
	return {"t":enter,"point":a+delta*enter,"normal":normal,"inside":false}

static func first_cover(a: Vector3, b: Vector3, cover: Array, padding: float = 0.0) -> Dictionary:
	var closest: Dictionary = {}
	for item in cover:
		var hit := sweep_box(a,b,item.box,padding)
		if not hit.is_empty() and (closest.is_empty() or float(hit.t)<float(closest.t)):
			closest = hit
			closest["id"] = item.id
	return closest

static func sphere_time(a: Vector3, b: Vector3, center: Vector3, radius: float) -> float:
	var movement := b-a
	var from_center := a-center
	var c := from_center.length_squared()-radius*radius
	if c<=0: return 0.0
	var aa := movement.length_squared()
	if aa<0.000001: return INF
	var bb := 2.0*from_center.dot(movement)
	var discriminant := bb*bb-4.0*aa*c
	if discriminant<0: return INF
	var t := (-bb-sqrt(discriminant))/(2.0*aa)
	return t if t>=0.0 and t<=1.0 else INF
