/* * ============================================================================
 * Raymarch.glsl - The Geometry Engine
 * ============================================================================
 * Core logic for rendering volumes via SDFs.
 * ----------------------------------------------------------------------------
 */

// this will blow ur gpu as it did with me

// [1] SDF (Signed Distance Field)
float map(vec3 p) {
    // 12.0 spacing is arbitrary. Need to figure out a better way to handle 
    // tiling without the repeating sphere artifacts.
    vec3 q = mod(p + 6.0, 12.0) - 6.0; 
    return length(q) - 2.5; 
}

// [2] PROCEDURAL COLORING
vec3 getColor(vec3 p) {
    vec3 q = mod(p + 6.0, 12.0) - 6.0;
    return 0.5 + 0.5 * sin(q * 0.5 + vec3(0, 2, 4));
}

// [3] SURFACE NORMALS
// Gradient estimation. 
// FIXME: 0.01 step size is too coarse for distant objects; get moire 
// patterns if I don't use a smaller delta.
vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.01, 0.0);
    float d = map(p);
    vec3 n = d - vec3(map(p - e.xyy), map(p - e.yxy), map(p - e.yyx));
    return normalize(n);
}

// [4] RAY-MARCHER: The Core Loop
float rayMarch(vec3 ro, vec3 rd, int maxSteps) {
    float totalDistance = 0.0;
    for(int i = 0; i < maxSteps; i++) {
        vec3 p = ro + rd * totalDistance;
        float d = map(p);
        totalDistance += d;
        
        // TODO: This early exit kills performance if maxSteps is too high.
        // Need to implement dithered stepping to hide artifacts at lower counts.
        if(d < 0.001 || totalDistance > 100.0) break;
    }
    return totalDistance;
}

// finally ended this hecky thing, i drew every drop of my blooc out from me