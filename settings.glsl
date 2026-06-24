/* * ============================================================================
 * settings.glsl - Engine Configuration & Performance Presets
 * ============================================================================
 * Centralized control for quality and performance.
 * ----------------------------------------------------------------------------
 */

// --- Quality Tiers ---
// Sample counts per ray march. 
// FIXME: High setting kills mobile GPUs; watch out for heat throttling.
#define STEPS_HIGH 128
#define STEPS_MED  48
#define STEPS_LOW  16

// --- Temporal Stability ---
// Hysteresis for frame time. 
// TODO: 0.05 is just a guess; might need to tune this based on refresh rate.
#define SMOOTHING_FACTOR 0.05

// --- Performance Thresholds ---
// SPF targets.
// Note: 0.033 is 30fps, 0.016 is 60fps.
#define FPS_THRESHOLD_LOW 0.033 
#define FPS_THRESHOLD_MED 0.016 

// --- Debugging ---
// Toggle for diagnostics. 
// HACK: Heat-map output is messy, make sure to disable before final build.
#define DEBUG_MODE 1

/* * ----------------------------------------------------------------------------
 * Performance Tuning Insight:
 * Higher steps = better geometry but slower frametimes. The threshold logic 
 * below 0.033s is currently the only thing stopping total crashes on 
 * older hardware.
 */