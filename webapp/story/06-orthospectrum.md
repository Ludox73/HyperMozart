# Step 5 — Orthospectrum Estimation (Monte Carlo)

The **orthospectrum** of a hyperbolic surface (relative to a pants decomposition) is the set of lengths of all geodesic arcs that are perpendicular to the cutting curves at both endpoints. These arcs are called **orthogeodesics**, and their lengths form a discrete, countable set that encodes geometric information about the surface.

## Monte Carlo estimation

Computing the orthospectrum analytically is difficult. Instead, HyperMozart uses a statistical approach:

1. **Random sampling**: a large number of random geodesic segments are generated (500k–2M samples).
2. **Perpendicularity test**: for each segment, the algorithm checks whether the initial and final crossing angles are close to $\pi/2$ (within a tolerance).
3. **Length histogram**: the lengths of near-perpendicular arcs are binned and counted.
4. **Peak detection**: the CDF (cumulative distribution function) of these lengths reveals steps — each step corresponds to an orthospectrum element.

The estimation is **progressive**: clicking "Estimate Next Element" computes one orthospectrum element at a time, refining the CDF curve.

## Output

- **Table**: lists the estimated orthospectrum elements with their lengths and the probability (relative frequency) of each.
- **CDF chart**: shows the cumulative distribution of orthogeodesic lengths. Flat regions indicate gaps in the spectrum; sharp rises indicate orthospectrum elements.

## Separating vs. Nonseparating detection

The structure of the orthospectrum differs between separating and nonseparating decompositions. The "Guess sep/nonsep" button uses the estimated orthospectrum to predict which decomposition type was used — providing evidence that the orthospectrum carries topological information.

**Try it**: after running a long geodesic, click "Estimate Next Element" several times. Watch the CDF chart build up step by step. Then try "Guess sep/nonsep" to see if the algorithm correctly identifies your decomposition type.
