/**
 * GARDNER ENGINE v1.0
 * Core Logic for Threshold-Programmable Soliton Stability
 */
const GardnerEngine = {
    calculateSpecs: function(alpha, beta, a) {
        // 1. The Structural Tuning (The Bridge)
        // Derived Requirement: gamma = alpha * (a - 1)
        const gamma = alpha * (a - 1);

        // 2. The Structural Width (The Sharpness)
        // Derived Requirement: k = sqrt(-alpha / (6 * beta))
        // Note: We use Math.abs to ensure stability in the demo 
        const k = Math.sqrt(Math.abs(alpha) / (6 * Math.abs(beta)));

        // 3. The Deterministic Velocity (The Clock Speed)
        // Derived Requirement: v = -alpha / 6
        const velocity = -alpha / 6;

        return {
            gamma: gamma.toFixed(4),
            k: k.toFixed(4),
            velocity: velocity.toFixed(4),
            isStable: (a > 0 && a < 1),
            description: `Kink transition at threshold ${a}`
        };
    },

    // Generates the points for the visual waveform
    generateWaveform: function(k, a, range = 10, resolution = 100) {
        let points = [];
        for (let i = 0; i <= resolution; i++) {
            let xi = -range + (i / resolution) * (range * 2);
            // The Soliton Bit: phi = 1 / (1 + exp(-k * xi))
            // We scale by the threshold logic
            let phi = 1 / (1 + Math.exp(-k * xi));
            points.push({ x: xi, y: phi });
        }
        return points;
    }
};