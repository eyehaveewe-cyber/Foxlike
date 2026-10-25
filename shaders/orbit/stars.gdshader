shader_type sky;
float hash(vec3 p){return fract(sin(dot(p,vec3(127.1,311.7,74.7)))*43758.5453);}
void sky(){
 vec3 direction=normalize(EYEDIR);vec3 p=direction*420.0;vec3 cell=floor(p);vec3 f=fract(p)-.5;
 float id=hash(cell);float point=1.0-smoothstep(.025,.16,length(f));float stars=point*step(.978,id)*(0.5+id);
 vec3 p2=direction*170.0;vec3 f2=fract(p2)-.5;float bright=(1.0-smoothstep(.018,.07,length(f2)))*step(.995,hash(floor(p2)));
 float band=pow(max(0.0,1.0-abs(direction.y*.8+direction.x*.28+.11)),18.0);
 vec3 haze=vec3(.007,.011,.025)+vec3(.013,.012,.022)*band;
 vec3 star_color=mix(vec3(.59,.75,1.0),vec3(1.0,.87,.65),hash(cell+31.0));
 COLOR=haze+star_color*stars+vec3(.8,.9,1.0)*bright*2.0;
}
