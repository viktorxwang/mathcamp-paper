size(11cm,8cm);
import graph;

// Colors
pen bluepen = rgb(0.10,0.10,0.65)+linewidth(2.2pt);
pen redpen  = rgb(0.65,0.10,0.10)+linewidth(2.2pt);
pen axispen = black+linewidth(1pt);

real xmax = 10;
real ymax = 8;
real sdim = 5.2;     // position of s = dim_H(A)
real ytop = 6.6;      // height of the "+infinity" plateau
real ybase = 0;       // the s-axis level (H^s(A)=0 line sits on axis)
real ydot = 2.6;       // height of the finite dot

// Axes
draw((0,0)--(0,ymax), axispen, Arrow(6));
draw((0,0)--(xmax,0), redpen, Arrow(6));

// Axis labels
label("$\mathcal{H}^s(A)$", (0,ymax), N);
label("$s$", (xmax,0), E);

// Dashed vertical line at s = dim_H(A)
draw((sdim,0)--(sdim,ytop+0.6), dashed);

// Blue plateau: H^s(A) = +infinity for s < dim
draw((0.05,ytop)--(sdim,ytop), bluepen);
label("$\mathcal{H}^s(A)=+\infty$", ( (0.05+sdim)/2, ytop), N, blue);

// Red segment already drawn as part of axis beyond sdim; emphasize/re-draw for s > dim
draw((sdim,0)--(xmax-0.1,0), redpen);
label("$\mathcal{H}^s(A)=0$", ( (sdim+xmax-0.1)/2, 0), N, rgb(0.65,0.10,0.10));

// Dot at critical dimension with finite measure
dot((sdim,ydot), black+linewidth(4pt));
label("$0<\mathcal{H}^s(A)<\infty$", (sdim,ydot), E);

// s = dim_H(A) label under axis
label("$s=\dim_{\mathcal{H}}(A)$", (sdim,0), S);
