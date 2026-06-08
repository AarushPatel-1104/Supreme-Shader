//This function defines the geometry of the world float map(vec3 p){
    //A simple sphere at the centre of the world return lenth(p) - 1.0;}

//This function "marches" the ray ti find an object
float rayMarch(vec3 ro, vec3 rd, int maxSteps){
    float totalDistance = 0.0;
    for(int i = 0; i < maxSteps; i++){
        vec3 p = ro + rd * totalDistance;
        float d = map(p);
        totalDistance += d;
    //stop if it wents too far or hits something
        if(d < 0.001 || totalDistance > 100.0) break;
    }
    return totalDistance
}