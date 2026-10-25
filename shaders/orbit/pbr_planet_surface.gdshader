shader_type canvas_item;
render_mode unshaded;

// PlanetVisual renders a square ColorRect. A full sphere and its atmosphere
// fit inside that square, so the same material works for chart and close-up.
uniform vec4 base_color : source_color = vec4(0.24, 0.48, 0.72, 1.0);
uniform vec4 accent_color : source_color = vec4(0.64, 0.88, 0.94, 1.0);
uniform int surface_type = 0;
uniform float seed = 1.0;
uniform float spin = 0.0;
uniform float atmosphere : hint_range(0.0, 1.0) = 0.12;

float hash3(vec3 p) {
	p = fract(p * 0.1031);
	p += dot(p, p.yzx + 33.33);
	return fract((p.x + p.y) * p.z);
}

float noise3(vec3 p) {
	vec3 cell = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(
		mix(mix(hash3(cell), hash3(cell + vec3(1.0, 0.0, 0.0)), f.x),
			mix(hash3(cell + vec3(0.0, 1.0, 0.0)), hash3(cell + vec3(1.0, 1.0, 0.0)), f.x), f.y),
		mix(mix(hash3(cell + vec3(0.0, 0.0, 1.0)), hash3(cell + vec3(1.0, 0.0, 1.0)), f.x),
			mix(hash3(cell + vec3(0.0, 1.0, 1.0)), hash3(cell + vec3(1.0, 1.0, 1.0)), f.x), f.y), f.z);
}

float terrain(vec3 p) {
	float value = noise3(p) * 0.53;
	value += noise3(p * 2.07 + 7.3) * 0.27;
	value += noise3(p * 4.19 + 14.1) * 0.13;
	value += noise3(p * 8.37 + 22.4) * 0.07;
	return value;
}

void fragment() {
	vec2 disc = (UV - vec2(0.5)) / 0.44;
	float radius = length(disc);
	float edge_width = max(fwidth(radius), 0.001);
	float sphere_alpha = 1.0 - smoothstep(1.0 - edge_width, 1.0 + edge_width, radius);
	vec3 light_dir = normalize(vec3(-0.58, -0.48, 0.68));
	vec3 atmosphere_color = mix(base_color.rgb, accent_color.rgb, 0.66);
	float glow = pow(max(0.0, 1.0 - abs(radius - 1.012) / 0.115), 2.2);
	float glow_alpha = glow * (surface_type == 7 ? 0.6 : atmosphere * 0.8);
	vec3 final_color = atmosphere_color;
	float final_alpha = glow_alpha;

	if (radius < 1.0 + edge_width) {
		vec3 normal = vec3(disc, sqrt(max(0.0, 1.0 - dot(disc, disc))));
		// Longitude/latitude give moving bands their geography. The terrain
		// sample is wrapped back onto a sphere to avoid a longitude seam.
		float longitude = atan(normal.x, normal.z) + spin * TAU;
		float latitude = asin(clamp(normal.y, -1.0, 1.0));
		vec3 globe = vec3(sin(longitude) * cos(latitude), sin(latitude), cos(longitude) * cos(latitude));
		vec3 sample_pos = globe * 4.5 + vec3(seed * 1.37, seed * 0.71, seed * 2.11);
		float broad = terrain(sample_pos);
		float fine = noise3(sample_pos * 8.0);
		float detail = noise3(sample_pos * 21.0);
		vec3 surface = mix(base_color.rgb * 0.55, accent_color.rgb, smoothstep(0.22, 0.8, broad));
		float specular = 0.025;

		if (surface_type == 0) {
			// Battered rock: mineral patches, small pitted rims and dust.
			float pits = smoothstep(0.66, 0.79, fine);
			float rims = smoothstep(0.56, 0.65, fine) * (1.0 - smoothstep(0.66, 0.73, fine));
			surface *= 0.79 + detail * 0.29 - pits * 0.35 + rims * 0.12;
		} else if (surface_type == 1) {
			// Ocean shelf, irregular continents, cloud streaks and polar ice.
			float land = smoothstep(0.49, 0.515, broad);
			vec3 ocean = base_color.rgb * (0.5 + broad * 0.8);
			vec3 continent = mix(accent_color.rgb * 0.55, accent_color.rgb, fine);
			surface = mix(ocean, continent, land);
			float coast = smoothstep(0.482, 0.494, broad) * (1.0 - smoothstep(0.514, 0.526, broad));
			surface = mix(surface, accent_color.rgb * 1.15, coast * 0.36);
			float cloud = smoothstep(0.58, 0.75, terrain(sample_pos * vec3(1.2, 2.8, 1.2) + 19.0));
			surface = mix(surface, vec3(0.92, 0.98, 1.0), cloud * 0.67);
			float ice = smoothstep(0.83, 0.98, abs(globe.y) + broad * 0.12);
			surface = mix(surface, vec3(0.86, 0.96, 1.0), ice);
			specular = mix(0.2, 0.025, land);
		} else if (surface_type == 2) {
			// Arid highlands, pale salt flats and long wind-cut dunes.
			float dunes = sin(latitude * 58.0 + broad * 14.0 + longitude * 6.0) * 0.5 + 0.5;
			surface = mix(base_color.rgb * 0.66, accent_color.rgb, broad);
			surface *= 0.79 + fine * 0.2 + dunes * 0.15;
			surface = mix(surface, accent_color.rgb * 1.15, smoothstep(0.64, 0.76, broad) * 0.6);
		} else if (surface_type == 3) {
			// Black volcanic plates with emissive rivers at their edges.
			float fissure = 1.0 - smoothstep(0.015, 0.052, abs(broad - 0.49));
			float lava = fissure * smoothstep(0.3, 0.7, fine);
			surface = base_color.rgb * (0.16 + broad * 0.4 + detail * 0.14);
			surface += accent_color.rgb * lava * 1.65;
			specular = 0.035;
		} else if (surface_type == 4) {
			// Glacial fields crossed by blue fractures and frozen ridges.
			float crack = 1.0 - smoothstep(0.01, 0.04, abs(broad - 0.5));
			surface = mix(base_color.rgb, accent_color.rgb, broad * 0.65 + 0.28);
			surface *= 0.86 + detail * 0.2;
			surface = mix(surface, base_color.rgb * 0.32, crack * 0.72);
			specular = 0.14;
		} else if (surface_type == 5 || surface_type == 6) {
			// Atmospheric bands wrap around the globe, with a large vortex.
			float turbulence = terrain(sample_pos * vec3(1.1, 0.55, 1.1) + 9.0);
			float bands = sin(latitude * 32.0 + turbulence * 8.0 + sin(latitude * 9.0) * 1.3) * 0.5 + 0.5;
			float narrow = sin(latitude * 92.0 + turbulence * 17.0) * 0.5 + 0.5;
			surface = mix(base_color.rgb * 0.64, accent_color.rgb, bands * 0.72 + narrow * 0.16);
			float spot_lon = sin(longitude - seed * 0.6 - 0.48) * 3.6;
			vec2 storm_coord = vec2(spot_lon, (latitude - 0.22) * 10.0);
			float spot_radius = length(storm_coord);
			float vortex = sin(spot_radius * 24.0 + atan(storm_coord.y, storm_coord.x) * 3.0 + broad * 5.0) * 0.5 + 0.5;
			float spot = (1.0 - smoothstep(0.45, 1.15, spot_radius)) * smoothstep(-0.1, 0.25, cos(longitude - seed * 0.6 - 0.48));
			surface = mix(surface, mix(base_color.rgb * 0.38, accent_color.rgb, vortex), spot * 0.88);
			if (surface_type == 6) {
				float storms = smoothstep(0.57, 0.76, broad);
				surface = mix(surface, accent_color.rgb * 1.25, storms * 0.56);
			}
			specular = 0.04;
		} else if (surface_type == 7) {
			// Incandescent granules: the star is self lit, with limb darkening.
			float granules = smoothstep(0.24, 0.8, fine * 0.6 + detail * 0.4);
			surface = mix(base_color.rgb * 0.78, accent_color.rgb * 1.2, granules);
			surface += accent_color.rgb * smoothstep(0.61, 0.78, broad) * 0.42;
		}

		float diffuse = max(dot(normal, light_dir), 0.0);
		float light = 0.055 + pow(diffuse, 0.82) * 1.1;
		vec3 lit = surface * light;
		float reflected = pow(max(dot(reflect(-light_dir, normal), vec3(0.0, 0.0, 1.0)), 0.0), 24.0);
		lit += vec3(0.82, 0.92, 1.0) * reflected * specular;
		float rim = pow(1.0 - normal.z, 3.5) * atmosphere;
		lit += atmosphere_color * rim * (0.4 + diffuse * 0.9);
		if (surface_type == 3) {
			float emissive_fissure = (1.0 - smoothstep(0.015, 0.052, abs(broad - 0.49))) * smoothstep(0.3, 0.7, fine);
			lit += accent_color.rgb * emissive_fissure * 0.32;
		}
		if (surface_type == 7) {
			lit = surface * (0.8 + normal.z * 0.25);
			glow_alpha = glow * 0.6;
		}
		final_color = lit;
		final_alpha = max(sphere_alpha, glow_alpha);
	}
	COLOR = vec4(final_color, final_alpha);
}
