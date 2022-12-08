#version 460
out vec4 fragColor; //color para cada fragmento

uniform vec2 u_resolution;
uniform float u_time;

float map(vec3 p) { //sdf esfera
    return length(p) - 3.0 / 5;
}

vec3 getNormal(vec3 p) { //en cualquier punto de la superficie del sdf el gradiente es el mismo que la normal del obj en ese punto 
    vec2 e = vec2(1.0 / 100, 0);

    return normalize(map(p) -\
             vec3(map(p - e.xyy), map(p - e.yxy), map(p - e.yyx)));                   
}

vec3 get_P(float dist, vec3 rd, vec3 ro) {
    return dist * rd + ro;
}

float rayMarch(vec3 ro, vec3 rd) {
    float dist = 0;

    for (int i = 0; i < 256; i++) {
        float hit = map(get_P(dist, rd, ro)); //vector p, distancia mas corta al obj
        dist += hit;

        if (dist > 100 || abs(hit) < 1e-4) i = 256; //rompe bucle cuando esta lo suf cerca del obj o cuando el rayo escapa de la escena
    }

    return dist;
}

vec3 render() { //color basado en la posicion del pixel en la pantalla
    vec3 col = vec3(0), ro = vec3(0, 0, -1), rd = normalize(vec3((2 * gl_FragCoord.xy - u_resolution.xy) / u_resolution.y, 1)); //inicia negro, centra el origen de la pantalla, origen_Rayo, dir_Rayo
    float dist = rayMarch(ro, rd); //dist al obj

    if (dist < 100) col += (getNormal(get_P(dist, rd, ro)) + 1) / 2; //suma la distancia al color resultante
                
    return col;
}

void main() {
    fragColor = vec4(render(), 1);
}
