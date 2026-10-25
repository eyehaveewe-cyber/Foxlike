shader_type spatial;
render_mode unshaded;
uniform vec3 sun_direction = vec3(-0.7,0.35,0.6);
uniform float spin = 0.0;
uniform int surface_type = 0;
uniform int detail_level = 0;
uniform float seed = 0.0;
uniform vec4 base_color : source_color = vec4(.25,.45,.3,1.0);
uniform vec4 accent_color : source_color = vec4(.7,.8,.7,1.0);
varying vec3 unit_pos;
varying vec3 world_normal;
float hash(vec3 p){ p=fract(p*0.3183099+vec3(.13,.21,.31));p*=17.0;return fract(p.x*p.y*p.z*(p.x+p.y+p.z)); }
float noise3(vec3 p){vec3 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(mix(hash(i),hash(i+vec3(1,0,0)),f.x),mix(hash(i+vec3(0,1,0)),hash(i+vec3(1,1,0)),f.x),f.y),mix(mix(hash(i+vec3(0,0,1)),hash(i+vec3(1,0,1)),f.x),mix(hash(i+vec3(0,1,1)),hash(i+vec3(1,1,1)),f.x),f.y),f.z);}
float fbm(vec3 p){float n=0.0,a=.5;for(int i=0;i<5;i++){if(i>=5-detail_level)break;n+=noise3(p)*a;p=p*2.07+vec3(7.1,3.8,5.2);a*=.49;}return n;}
void vertex(){unit_pos=normalize(VERTEX);world_normal=normalize((MODEL_MATRIX*vec4(NORMAL,0.0)).xyz);}
void fragment(){
 vec3 p=normalize(unit_pos);float c=cos(spin),s=sin(spin);p=vec3(c*p.x+s*p.z,p.y,-s*p.x+c*p.z);
 float continents=fbm(p*3.2+vec3(13.4+seed,6.8,1.0));float detail=fbm(p*28.0+vec3(seed));
 float land=smoothstep(.484,.514,continents);float mountain=smoothstep(.55,.72,continents+detail*.1);
 float latitude=abs(p.y);float polar=smoothstep(.77,.93,latitude+detail*.09);
 vec3 water=mix(vec3(.012,.065,.12),vec3(.025,.22,.30),smoothstep(.44,.50,continents));
 vec3 terrain=mix(vec3(.085,.21,.13),vec3(.29,.36,.18),smoothstep(.30,.62,detail));
 terrain=mix(terrain,vec3(.43,.36,.24),mountain);terrain=mix(terrain,vec3(.68,.77,.75),pow(mountain,3.0));
 float beach=(1.0-smoothstep(.512,.533,continents))*land;terrain=mix(terrain,vec3(.53,.48,.31),beach*.8);
 terrain*= detail_level<2 ? .91+noise3(p*160.0)*.18 : 1.0;
 vec3 ground=mix(water,terrain,land);ground=mix(ground,vec3(.78,.89,.92),polar);
 if(surface_type==1){
   float cells=length(fract(p*19.0+vec3(seed))-.5);
   float crater=smoothstep(.16,.24,cells)*(1.0-smoothstep(.26,.36,cells));
   ground=mix(base_color.rgb*.45,accent_color.rgb,detail)*(.75+crater*.23);
 }
 if(surface_type==2){float dunes=.5+.5*sin(p.y*110.0+detail*25.0);ground=mix(base_color.rgb*.6,accent_color.rgb,detail*.7+dunes*.12);}
 if(surface_type==3){ground=mix(vec3(.005,.05,.14),base_color.rgb,smoothstep(.25,.75,detail));land=0.0;polar=0.0;}
 if(surface_type==4){float fissure=1.0-smoothstep(.025,.075,abs(noise3(p*28.0+vec3(seed))-.5));ground=mix(base_color.rgb*.16,accent_color.rgb*vec3(1.3,.55,.15),fissure);}
 if(surface_type==5){float storms=fbm(p*10.0+vec3(sin(p.y*20.0)*2.0,seed,0));ground=mix(base_color.rgb*.3,accent_color.rgb,smoothstep(.25,.7,storms));land=1.0;}
 if(surface_type==6){float bands=.5+.5*sin(p.y*55.0+detail*6.0+seed);ground=mix(base_color.rgb*.55,accent_color.rgb,bands*.8);land=1.0;}
 if(surface_type==7){float cracks=1.0-smoothstep(.012,.045,abs(fbm(p*12.0+vec3(seed))-.46));ground=mix(base_color.rgb*.65,accent_color.rgb,smoothstep(.25,.7,detail));ground=mix(ground,base_color.rgb*.35,cracks*.20);land=1.0;}
 if(surface_type==8){ground=mix(base_color.rgb*.08,base_color.rgb*.5,detail);land=1.0;}
 if(surface_type==9){float facets=pow(noise3(floor(p*80.0)+vec3(seed)),3.0);ground=mix(base_color.rgb*.25,accent_color.rgb,facets);land=1.0;}
 float sunlight=dot(normalize(world_normal),normalize(sun_direction));float day=smoothstep(-.12,.18,sunlight);
 vec3 lit=ground*(.065+max(sunlight,0.0)*1.5);lit+=ground*vec3(.03,.08,.16)*(1.0-day);
 vec3 view_world=normalize((INV_VIEW_MATRIX*vec4(VIEW,0.0)).xyz);
 float glint=pow(max(dot(reflect(-normalize(sun_direction),normalize(world_normal)),view_world),0.0),100.0)*(1.0-land)*(1.0-polar);
 lit+=vec3(1.0,.85,.62)*glint*.7;
 float settlements=pow(noise3(p*240.0),20.0)*smoothstep(.49,.54,continents)*(1.0-mountain)*(1.0-polar);
 lit+=vec3(1.0,.57,.21)*settlements*6.0*(1.0-day)*(surface_type==0 ? 1.0 : 0.0);
 if(surface_type==4)lit+=ground*.6;
 if(surface_type==9)lit+=ground*.12;
 float limb=pow(1.0-max(dot(normalize(NORMAL),normalize(VIEW)),0.0),3.0);
 lit+=vec3(.065,.23,.43)*limb*day;
 ALBEDO=lit;
}
