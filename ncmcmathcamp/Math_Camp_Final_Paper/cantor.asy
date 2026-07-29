// Cantor Set Construction
size(300, 200);

int levels = 5;          // number of iterations to display
real lineLength = 12;    // length of the initial segment
real ySpacing = 1;       // vertical spacing between levels
real lineWidth = 2;      // thickness of drawn segments

// Recursive function: draws segments for the Cantor set at a given level
void cantor(real x1, real x2, int level, real y) {
    // Draw the current segment
    draw((x1, y) -- (x2, y), linewidth(lineWidth));

    if (level < levels - 1) {
        real third = (x2 - x1) / 3;
        // Recurse on the left third
        cantor(x1, x1 + third, level + 1, y - ySpacing);
        // Recurse on the right third (middle third removed)
        cantor(x2 - third, x2, level + 1, y - ySpacing);
    }
}

// Start the construction at level 0
cantor(0, lineLength, 0, 0);

// Optional: label each level on the left
for (int i = 0; i < levels; ++i) {
    label("$n=" + string(i) + "$", (-1.5, -i * ySpacing), W, fontsize(8pt));
}