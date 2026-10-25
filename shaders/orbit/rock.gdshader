shader_type spatial;
render_mode depth_draw_opaque;
uniform float reveal : hint_range(0.0,1.0) = 1.0;
uniform float mineral = .3;
varying vec3 point;
void vertex(){point=VERTEX;}
void fragment(){
 float grain=sin(point.x*17.0+sin(point.z*23.0))*sin(point.y*21.0+sin(point.x*13.0));
 float veins=pow(abs(sin(point.x*7.0+point.y*11.0+sin(point.z*8.0))),15.0);
 ALBEDO=mix(vec3(.16,.18,.21),vec3(.37,.32,.26),mineral)+grain*.04+veins*vec3(.04,.065,.08);
 ROUGHNESS=.93;METALLIC=.12;ALPHA=reveal;
}
