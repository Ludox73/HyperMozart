# HyperMozart

**HyperMozart** is an interactive tool for exploring geodesics on genus-2 hyperbolic surfaces.

A **genus-2 surface** is a closed surface with two "holes" — topologically equivalent to a double torus. In hyperbolic geometry, such surfaces carry a rich structure: every free homotopy class of closed curves contains a unique geodesic, and the set of lengths of these geodesics (the *length spectrum*) encodes deep geometric information.

## Pants decomposition

Every genus-2 surface can be decomposed into two **pairs of pants** (three-holed spheres) by cutting along three simple closed geodesics. The lengths $L_1, L_2, L_3$ of these cutting curves, together with *twist parameters* $T_1, T_2, T_3$ that describe how the pants are glued, form the **Fenchel–Nielsen coordinates** — a complete parameterization of the moduli space.

There are two topologically distinct ways to decompose a genus-2 surface into pants:

- **Separating decomposition**: one of the three cutting curves separates the surface into two components.
- **Nonseparating decomposition**: none of the cutting curves separates the surface.

## From pants to hexagons

Each pair of pants can be further decomposed into two **right-angled hyperbolic hexagons**. The surface is thus built from **four hexagons**, glued along their sides according to specific combinatorial rules. This is the representation used by HyperMozart.

## What this tool computes

Given the Fenchel–Nielsen coordinates, HyperMozart:

1. Constructs the four hexagons in the Poincaré disk model.
2. Shoots a geodesic ray and tracks it as it crosses hexagon boundaries.
3. Records each intersection with the three cutting curves.
4. Converts the intersection sequence into music.
5. Estimates the orthospectrum via Monte Carlo sampling.
6. Identifies short geodesic arcs and their homotopy classes.

Each of these steps is demonstrated interactively in the sections below.
