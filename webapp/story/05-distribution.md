# Step 4 — Intersection Distribution

The **intersection distribution** is a scatter plot that visualizes how the geodesic crosses **curve 1**. Each crossing is represented as a point in a 2D space.

## Axes

- **Horizontal axis (position)**: the location along curve 1 where the crossing occurs, measured as the hyperbolic arc-length distance from a fixed reference point. The full range spans the length of curve 1.
- **Vertical axis (angle)**: the angle at which the geodesic crosses the curve, measured between the geodesic direction and the curve tangent. Values near $\pi/2$ indicate nearly perpendicular crossings.

## Color

Each point is colored by the **travel time** (hyperbolic distance) since the previous curve crossing, using a logarithmic color scale:
- **Blue/purple**: short travel time (the geodesic crossed another curve recently).
- **Yellow/white**: long travel time (the geodesic wandered far before returning to curve 1).

## What this reveals

By a classical result in ergodic theory, a generic geodesic on a hyperbolic surface is **equidistributed**: it crosses every curve with uniform distribution in both position and angle. The scatter plot provides visual evidence of this equidistribution — a well-mixed geodesic should fill the plot uniformly.

Deviations from uniformity can indicate:
- The geodesic is not yet long enough for ergodic mixing.
- The surface has special symmetries that create preferred crossing patterns.

**Try it**: run a long geodesic ($\geq 100$k) in fast mode, then click "Draw Distribution". The plot should appear approximately uniform. Compare with a short geodesic (1k) to see incomplete mixing.
