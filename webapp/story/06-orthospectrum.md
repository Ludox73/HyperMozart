This is the cumulative distribution function (CDF) of the set of gaps between notes.

figure

Intuitively, one reads out the orthospectrum as being the set of non-smooth points of the CDF -- there is also the issue of multiplicity. For example, the bottom of the orthospectrum of $X\setminus\Gamma$ is the last point where CDF=0. When we have found an element in the orthospectrum we predict the contribution to the CDF from arcs of that length (multiplicity 1), substract it from CDF to get a new CDF. We then repeat the process with the new CDF.

Below you see how this is numerically implemented. When you press _Estimate Next Element_, the CDF is shown in white, the predicted contribution in blue, and the difference in red. When you do it again, this is applied to the red distribution which is now white. You can click on the estimated values to see the previous steps. After computing a few elements in the orthospectrum you can also compare the initical CDF with the sum of the estimated ones. 

Besides this, while the melody was computed we recorded the lengths of those segments which are almost orthogonal to $\Gamma$. This lengths are shown in blue in the strip below the graphs. The lengths of elements in the orthospectrum (estimated as we just described) appear, as they are being calculated, in red. 