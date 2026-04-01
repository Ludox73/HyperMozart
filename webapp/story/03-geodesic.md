# Step 2 — Running a Geodesic

A **geodesic** on a hyperbolic surface is the analogue of a straight line — it is the shortest path between nearby points. On our surface built from hexagons, a geodesic is a sequence of hyperbolic line segments, each contained in one hexagon, connected by the gluing maps at the boundaries.

## How the computation works

1. **Starting point**: a random direction is chosen at the barycenter of hexagon 0.
2. **Warm-up phase** (1000 hyperbolic length units): the geodesic bounces through the hexagons to ensure ergodic mixing before data collection begins.
3. **Main loop**: at each step, the algorithm:
   - Finds the **first intersection** of the current geodesic ray with the boundary of the current hexagon (by intersecting the geodesic circle with the six side circles).
   - Applies the **pairing transformation** (a Möbius map, possibly with a twist) to move to the paired hexagon.
   - Records whether the crossed side belongs to one of the three cutting curves.
4. The process continues until the total geodesic length reaches the specified maximum.

## Parameters

- **Max length**: total hyperbolic length to trace (from 1k to 10M units). Longer geodesics produce more intersection data and better statistics.
- **Drawing speed**: controls the animation pace in visual mode.
- **Fast mode**: skips the drawing animation for faster computation. Recommended for long geodesics ($\geq 100$k).

## Active curves

You can select which of the three cutting curves to track. Only crossings with active curves are recorded for music and statistics. Typically all three are active.

**Try it**: start with a short geodesic (10k–100k) in visual mode to see the trajectory, then switch to fast mode for longer runs.
