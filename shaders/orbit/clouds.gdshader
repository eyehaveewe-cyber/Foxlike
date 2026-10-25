shader_type spatial;
render_mode unshaded, depth_draw_never;
uniform vec3 sun_direction = vec3(-0.7,0.35,0.6);
uniform float spin = 0.0;
uniform vec4 cloud_tint : source_color = vec4(1.0);
varying vec3 p;
varying vec3 n;
float h(vec3 v){return fract(sin(dot(v,vec3(127.1,311.7,74.7)))*43758.5453);}
float noise3(vec3 v){vec3 i=floor(v),f=fract(v);f=f*f*(3.0-2.0*f);return mix(mix(mix(h(i),h(i+vec3(1,0,0)),f.x),mix(h(i+vec3(0,1,0)),h(i+vec3(1,1,0)),f.x),f.y),mix(mix(h(i+vec3(0,0,1)),h(i+vec3(1,0,1)),f.x),mix(h(i+vec3(0,1,1)),h(i+vec3(1,1,1)),f.x),f.y),f.z);}
void vertex(){p=normalize(VERTEX);n=normalize((MODEL_MATRIX*vec4(NORMAL,0)).xyz);}
void fragment(){
 vec3 q=normalize(p);float c=cos(spin),s=sin(spin);q=vec3(c*q.x+s*q.z,q.y,-s*q.x+c*q.z);
 float warp=noise3(q*4.0)*2.4;vec3 v=q*16.0+vec3(warp,warp*.3,-warp);
 float a=noise3(v)*.50+noise3(v*2.07)*.27+noise3(v*4.1)*.13+noise3(v*8.2)*.07+noise3(v*16.4)*.03;
 float cloud=smoothstep(.49,.68,a);float sun=max(dot(normalize(n),normalize(sun_direction)),0.0);
 ALBEDO=mix(vec3(.055,.10,.16),mix(vec3(1.1,1.08,.98),cloud_tint.rgb,.22),sun);
 ALPHA=cloud*.88;
}
