/* * ============================================================================
 * settings.glsl - Engine Configuration & Performance Presets
 * ============================================================================
 * Centralized control hub for quality tiers, performance heuristics, and
 * debugging utilities. Adjust these constants to balance visual fidelity 
 * against target frame rates.
 * ----------------------------------------------------------------------------
 */

// --- Quality Tiers ---
// Defines the number of samples per ray march. Higher values increase 
// geometric accuracy and reduce artifacts at a higher GPU cost.
#define STEPS_HIGH 128
#define STEPS_MED  48
#define STEPS_LOW  16

// --- Temporal Stability ---
// Hysteresis coefficient for frame time monitoring. Used to dampen sudden 
// spikes in performance data for smoother quality transitions.
#define SMOOTHING_FACTOR 0.05

// --- Performance Thresholds ---
// Defined in seconds per frame (SPF).
// FPS_THRESHOLD_LOW: Target for 30 FPS (0.033s)
// FPS_THRESHOLD_MED: Target for 60 FPS (0.016s)
#define FPS_THRESHOLD_LOW 0.033 
#define FPS_THRESHOLD_MED 0.016 

// --- Debugging ---
// Toggle for engine diagnostics. Set to 1 to enable on-screen performance 
// metrics and heat-map visualization of step counts.
#define DEBUG_MODE 1

/* * ----------------------------------------------------------------------------
 * Performance Tuning Insight:
 */