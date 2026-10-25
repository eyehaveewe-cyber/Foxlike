shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never;
uniform vec4 tint : source_color = vec4(.8,.7,.5,1.0);
uniform vec3 sun_direction = vec3(-.85,.22,.42);
varying vec3 local;
void vertex(){local=VERTEX;}
void fragment(){
 float r=length(local.xz);
 float gaps=smoothstep(1.52,1.54,r)*(1.0-smoothstep(1.61,1.63,r));
 float bands=.5+.5*sin(r*280.0+sin(r*47.0)*2.0);
 ALBEDO=tint.rgb*(.38+bands*.45);
 ALPHA=(.22+bands*.38)*(1.0-gaps*.94)*smoothstep(1.28,1.32,r)*(1.0-smoothstep(2.10,2.15,r));
}
