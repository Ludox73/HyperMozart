# Step 1 — Building the Surface

The first step is to choose the **decomposition type** and the **Fenchel–Nielsen coordinates** that define the surface.

## Parameters

- **Decomposition type**: *Separating* or *Nonseparating*. This determines the combinatorial gluing pattern of the four hexagons.
- **Curve lengths** $L_1, L_2, L_3 \in [1, 7]$: the hyperbolic lengths of the three cutting geodesics. These control the shape of the hexagons — longer curves produce thinner, more elongated hexagons.
- **Twist parameters** $T_1, T_2, T_3 \in [0\%, 100\%]$: the fraction of a full Dehn twist applied when gluing across each curve. At $0\%$ the gluing is "aligned"; at $50\%$ the pants are shifted by half the curve length.

## What happens

When you adjust the sliders, the app:

1. Computes four right-angled hyperbolic hexagons whose alternating side lengths match $L_1, L_2, L_3$.
2. Builds the Möbius transformations (hyperbolic isometries) that identify hexagon sides according to the chosen gluing pattern.
3. Displays the hexagons in the **Poincaré disk model**, where geodesics appear as circular arcs orthogonal to the unit circle.

The four canvases below show the four hexagons. Colored sides indicate the three cutting curves:
- **Red** sides belong to curve 1
- **Green** sides belong to curve 2
- **Blue** sides belong to curve 3

Sides of the same color (and between paired hexagons) are identified by the gluing isometries.

**Try it**: change the curve lengths and observe how the hexagon shapes deform. Set all lengths equal to see the most symmetric configuration.
