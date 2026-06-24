# Supreme-Shader
## Dev Log
I built this because I was tired of standard shaders either killing my frame rate or looking boring. I wanted to see if I could inject actual 3D geometry into Minecraft on my own machine—an MX330 laptop—without needing a top-tier rig. It’s been a massive headache of buffer handoffs and "silent" GPU failures, but it’s finally doing what I wanted it to do.

## What’s in here
Custom Raymarching: It’s not just post-processing; I’m marching rays through space to define shapes via SDFs.

Hybrid Pipeline: Runs as a shader pass, reading depth and color data to composite volumes into the world.

Self-Optimization: Quality scales down automatically if frame times spike, so it doesn't completely freeze your game.

Visual Polish: I’ve added light-reactive normals and chromatic aberration to give it that "expensive" look without the compute cost.

## Lessons Learned- ofc I learned not u (The "Ugly" Hacks)
Getting this into Minecraft's renderer was a nightmare because the pipeline is essentially a black box.

Buffer Handoffs: I had to manually manage buffer mapping to keep the engine from dropping my work or overwriting it. It’s not elegant, but it keeps the data flowing.

Temporal Blending: You’ll notice some "ghosting" when moving too fast. That’s because I’m mixing frames to save on compute overhead. It’s a 1:4 frame-mix hack that makes the output look way more expensive than it actually is.

The "Invalid Operation" Trap: If you hit an OpenGL 1282 error, check your uniforms. I spent hours debugging this, and it usually comes down to a naming mismatch or a shader pass trying to sample a texture that isn't bound yet. (I was not able to solve it so if you face the same, then THIS IS THE END)

## Hardware & Status
Hardware: It’s built and tested on an MX330. If you’re running this on an integrated GPU (iGPU), expect a fight—you’ll definitely need to lower the quality tiers in settings.glsl because the register pressure on the memory bus is real. (Come on, only AMD igpus)

Status: Version 1.0 (It works on my machine, which is all that matters for now).

# Installation
Requirements: Needs Iris or OptiFine. (better to have fabric+sodium+lithium+iris)

## Running

1. Download the Zip- which you have, i suppose, as you are reading this.
2. Rename the first folder in zip to shaders : must be the same or it wont work.
3. Go to vide0 settings then select te Supreme-Shader.zip

## Known Issues
Git History: My early commits were named "Main Shader Files" because I didn't realize I was pushing actual changes. It’s a mess, but the code is functional.

Jitter: The temporal blend is a work-in-progress. It's a bit "ghosty" right now, and I’m still tuning the hysteresis coefficient.

### TODO:

[ ] Fix the temporal jitter.

[ ] Add better noise functions to the map(p) shape definition.

[ ] Clean up the logic for depth-aware blending.

# For Help

1. Comment on github I may reply, suggestions are overuled, oh sry I mean accepted

2. Umm, nvm no second option.

## Idiotism Overload WARNING!!!!!!!
### DONT SCROLL DOWN
#
#
#
#
#
#
#
#
#
#
#
#
#
#
THIS IS THE END.
HOLD UR BREATH AND WAIT TILL 10,
FEEL THE SHADERS WORKING THEN,
HEAR UR GPU BURST WIH PAIN.