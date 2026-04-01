# Step 6 — Arcs and Homotopy Classes

While the Monte Carlo orthospectrum uses random sampling, the **arc analysis** takes a complementary approach: it collects *specific* short geodesic arcs found during the main geodesic computation, and classifies them by their **combinatorial type** (homotopy class).

## What is an arc?

An **arc** is a geodesic segment that starts on one cutting curve and ends on another (or the same) cutting curve. Each arc is characterized by:

- **Length**: hyperbolic length of the segment.
- **Initial angle**: the angle at which the arc departs from the starting curve.
- **Final angle**: the angle at which the arc arrives at the ending curve.
- **Crossing sequence**: the ordered list of hexagon sides crossed by the arc. Two arcs with the same crossing sequence are in the same **combinatorial class** (they are homotopic relative to the cutting curves).

## Arc save filters

During the geodesic computation, arcs are saved if they satisfy the specified filters:

- **Length range**: only save arcs within a given length interval.
- **Angle ranges**: only save arcs whose initial and final angles fall within specified bounds. The "Almost perpendicular" preset filters for angles near $\pi/2$.

## Orthospectrum from arcs

The "Compute Orthospectrum" button in this section groups saved arcs by their combinatorial class and reports the **shortest representative** of each class. This gives a combinatorial orthospectrum — a list of distinct arc types ordered by length.

Unlike the Monte Carlo method, this approach:
- Identifies each orthospectrum element with a specific *geometric object* (the arc and its crossing sequence).
- Can distinguish elements that have the same length but different combinatorial types.
- Depends on the geodesic having found representative arcs during its traversal.

## Visualization

Clicking on a row in the arcs table draws the corresponding arc on the mini hexagon canvases, showing exactly how it traverses the surface.

**Try it**: run a long geodesic with the "Almost perpendicular" arc filter, then explore the saved arcs table. Click "One per class" to see only the shortest arc in each homotopy class. Compare the arc-based orthospectrum with the Monte Carlo estimate.
