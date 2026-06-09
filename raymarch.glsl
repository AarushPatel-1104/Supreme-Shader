/* * ============================================================================
 * Raymarch.glsl - The Geometry Engine
 * ============================================================================
 * This module defines the world's physical presence through Signed Distance 
 * Fields (SDFs) and provides the mathematical backbone for light interaction.
 * ----------------------------------------------------------------------------
 */

// [1] SDF (Signed Distance Field)
// Defines the labyrinth's shape. We use the modulo operator to create an 
// infinite repeating grid of spheres, ensuring memory efficiency.
float map(vec3 p) {
    vec3 q = mod(p, 4.0) - 2.0; 
    return length(q) - 1.0; 
}

// [2] PROCEDURAL COLORING
// Generates vibrant, smooth color transitions based on spatial coordinates
// using a cosine-based palette oscillator.
vec3 getColor(vec3 p) {
    return 0.5 + 0.5 * cos(p * 0.5 + vec3(0, 2, 4));
}

// [3] SURFACE NORMALS
// Calculates the gradient of the distance field. This determines how light 
// "bounces" off the surface by checking the change in distance in 3D space.
vec3 getNormal(vec3 p) {
    vec2 e = vec2(0.01, 0.0);
    float d = map(p);
    vec3 n = d - vec3(map(p - e.xyy), map(p - e.yxy), map(p - e.yyx));
    return normalize(n);
}

// [4] RAY-MARCHER: The Core Loop
// Steps the ray along its trajectory until it detects a collision or reaches
// the maximum draw distance. Performance is dictated by the dynamic step count.
float rayMarch(vec3 ro, vec3 rd, int maxSteps) {
    float totalDistance = 0.0;
    for(int i = 0; i < maxSteps; i++) {
        vec3 p = ro + rd * totalDistance;
        float d = map(p);
        totalDistance += d;
        // Optimization: Early exit if we hit a surface or exceed max render distance.
        if(d < 0.001 || totalDistance > 100.0) break;
    }
    return totalDistance;
}

/* * ----------------------------------------------------------------------------
 * Conceptual Understanding:
 */