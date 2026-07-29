real scaleFactor = 1.5;   // cm of brace-glyph height per 1 Asymptote user-unit of edge length
//scaleFactor is really important because it changes how big the braces are
size(17cm);
defaultpen(fontsize(11pt));

// ---------- place a real "{" (LaTeX) brace, enlarged + rotated ----------
// M            : edge midpoint (in user coordinates)
// desiredAngle : direction (degrees) the brace "tooth" should point,
//                measured the usual way (0 = +x, 90 = +y, ...)
// edgeLen      : length of the edge being braced (user units) -> sets glyph size
// offsetDist   : how far out from M to place the brace (user units)
// labelDist    : how far out from M to place the label (user units)
void placeBrace(pair M, real desiredAngle, real edgeLen,
                 real offsetDist, real labelDist, string lbl)
{
  pair outward = dir(desiredAngle);
  real rot = desiredAngle - 180;     // "\{" has its tooth pointing left (180) by default
  real Hcm = scaleFactor*edgeLen;
  label(rotate(rot)*Label("$\left\{\rule{0pt}{"+string(Hcm)+"cm}\right.$"),
        M + offsetDist*outward);
  label("$"+lbl+"$", M + labelDist*outward, fontsize(14pt));
}

// ---------- Sierpinski triangle (recursive) ----------
void sierpinski(pair A, pair B, pair C, int depth)
{
  if (depth == 0) {
    draw(A--B--C--cycle, linewidth(0.5));
  } else {
    pair AB = (A+B)/2, BC = (B+C)/2, CA = (C+A)/2;
    sierpinski(A, AB, CA, depth-1);
    sierpinski(AB, B, BC, depth-1);
    sierpinski(CA, BC, C, depth-1);
  }
}

// ---------- shared layout constants ----------
real gapShapeArrow = 0.3;
real arrowHalfLen  = 0.4;

// ======================================================
//  ROW 1  (Square)  -- row center line y = R1
// ======================================================
real R1 = 0;

real squareHalf = 0.5;
real bigSqX = -(arrowHalfLen + gapShapeArrow + squareHalf);

draw((bigSqX-0.5,R1-0.5)--(bigSqX+0.5,R1-0.5)--(bigSqX+0.5,R1+0.5)--(bigSqX-0.5,R1+0.5)--cycle,
     linewidth(0.8));
placeBrace((bigSqX-0.5,R1), 180, 1, 0.08, 0.55, "1");

// arrow, centered on the shared center line x = 0
draw((-arrowHalfLen,R1)--(arrowHalfLen,R1), Arrow(6));

// four sub-squares, size 1/2, with small gaps
real s   = 0.5;
real gap = 0.08;
real grpHalf = (2*s+gap)/2;
real smallGrpX = arrowHalfLen + gapShapeArrow + grpHalf;
real gx0 = smallGrpX - grpHalf;
real gy0 = R1 - grpHalf;

path smallsq = scale(s)*unitsquare;
draw(shift(gx0,        gy0       )*smallsq, linewidth(0.8));
draw(shift(gx0+s+gap,  gy0       )*smallsq, linewidth(0.8));
draw(shift(gx0,        gy0+s+gap)*smallsq, linewidth(0.8));
draw(shift(gx0+s+gap,  gy0+s+gap)*smallsq, linewidth(0.8));

placeBrace((gx0+s/2, gy0), -90, s, 0.08, 0.5, "\frac{1}{2}");

label("Square", (0, R1-1.05), fontsize(15pt));

// ======================================================
//  ROW 2  (Sierpinski's Triangle) -- row center line y = R2
// ======================================================
real R2 = -2.3;
real h1 = sqrt(3)/2;   // height factor for an equilateral triangle of base 1

real triHalf = 1;
real bigTriX = -(arrowHalfLen + gapShapeArrow + triHalf);

pair Ta = (bigTriX-1, R2-h1);
pair Tb = (bigTriX+1, R2-h1);
pair Tc = (bigTriX,   R2+h1);
sierpinski(Ta, Tb, Tc, 5);
placeBrace((Ta+Tc)/2, 150, 2, 0.08, 0.65, "1");

// arrow, centered on the shared center line x = 0
draw((-arrowHalfLen,R2)--(arrowHalfLen,R2), Arrow(6));

// three sub-triangles, base = 1, arranged with gaps
real gh   = 0.25;   // horizontal gap between the bottom two triangles
real gapv = 0.20;   // vertical gap between bottom row and top triangle
real smallGrpHalf = (2*1+gh)/2;
real smallGrpX = arrowHalfLen + gapShapeArrow + smallGrpHalf;
real bx = smallGrpX - smallGrpHalf;
real Y0 = R2 - h1 - gapv/2;

pair BL_a = (bx,          Y0), BL_b = (bx+1,        Y0), BL_c = (bx+0.5,       Y0+h1);
pair BR_a = (bx+1+gh,     Y0), BR_b = (bx+2+gh,      Y0), BR_c = (bx+1.5+gh,   Y0+h1);
pair TP_a = (bx+0.625,    Y0+h1+gapv), TP_b = (bx+1.625, Y0+h1+gapv),
     TP_c = (bx+1.125,    Y0+2*h1+gapv);

sierpinski(BL_a, BL_b, BL_c, 4);
sierpinski(BR_a, BR_b, BR_c, 4);
sierpinski(TP_a, TP_b, TP_c, 4);

placeBrace((TP_c+TP_b)/2, 30, 1, 0.08, 0.6, "\frac{1}{2}");

label("Sierpinski's Triangle", (0, R2-h1-0.75), fontsize(15pt));
