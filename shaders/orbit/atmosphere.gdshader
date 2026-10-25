shader_type spatial;
render_mode unshaded, cull_front, blend_add, depth_draw_never;
uniform vec3 sun_direction = vec3(-0.7,0.35,0.6);
varying vec3 normal_world;
void vertex(){normal_world=normalize((MODEL_MATRIX*vec4(NORMAL,0)).xyz);}
void fragment(){
 float rim=pow(1.0-abs(dot(normalize(NORMAL),normalize(VIEW))),4.2);
 float day=smoothstep(-.3,.4,dot(normalize(normal_world),normalize(sun_direction)));
 ALBEDO=mix(vec3(.012,.04,.10),vec3(.075,.39,.79),day);
 ALPHA=rim*.62;
}
