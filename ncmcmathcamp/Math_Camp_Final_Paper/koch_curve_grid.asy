// koch_curve_grid.asy
// Shows the Koch curve construction at iterations n = 0, 1, 2, 3
// arranged in a 2x2 grid, in the style of a construction-sequence figure.
// Compile with: asy -f pdf koch_curve_grid.asy

size(360, 260);

// Recursively compute the vertices of the Koch curve from A to B.
pair[] kochPoints(pair A, pair B, int level) {
    pair[] pts;

    if (level == 0) {
        pts.push(A);
        pts.push(B);
        return pts;
    }

    pair d  = (B - A) / 3;
    pair p0 = A;
    pair p1 = A + d;
    pair p3 = A + 2*d;
    pair p2 = p1 + rotate(60) * d;   // apex of the equilateral bump
    pair p4 = B;

    pair[] s1 = kochPoints(p0, p1, level-1);
    pair[] s2 = kochPoints(p1, p2, level-1);
    pair[] s3 = kochPoints(p2, p3, level-1);
    pair[] s4 = kochPoints(p3, p4, level-1);

    for (int i = 0; i < s1.length - 1; ++i) pts.push(s1[i]);
    for (int i = 0; i < s2.length - 1; ++i) pts.push(s2[i]);
    for (int i = 0; i < s3.length - 1; ++i) pts.push(s3[i]);
    for (int i = 0; i < s4.length; ++i)     pts.push(s4[i]);

    return pts;
}

// Draws one Koch-curve panel of the given iteration level, with its
// baseline starting at "origin", and a centered label underneath.
void drawKoch(pair origin, int level, string labeltext) {
    pair A = origin;
    pair B = origin + (10,0);

    pair[] pts = kochPoints(A, B, level);

    guide g = pts[0];
    for (int i = 1; i < pts.length; ++i) {
        g = g -- pts[i];
    }

    draw(g, linewidth(0.8) + black);
    label(labeltext, origin + (5, -1.8));
}

// ---- 2x2 grid layout ----
real dx = 14;   // horizontal spacing between panels
real dy = 6.0;  // vertical spacing between rows

drawKoch((0,  dy), 0, "n = 0");
drawKoch((dx, dy), 1, "n = 1");
drawKoch((0,  0),  2, "n = 2");
drawKoch((dx, 0),  3, "n = 3");
