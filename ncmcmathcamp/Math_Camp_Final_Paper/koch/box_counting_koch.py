"""
box counting method

This program also returns a graph that linear regression can be applied to.

@author: Viktor Wang
@datetime: 7/26/2026
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle


# ----------------------------------------------------------------------
# 1. Build the Koch snowflake curve
# ----------------------------------------------------------------------
def koch_segment(p1, p2, depth):
    """Recursively subdivide segment p1->p2 into a Koch curve, returning
    a list of points (including p1 but not p2)."""
    if depth == 0:
        return [p1]

    p1 = np.array(p1, dtype=float)
    p2 = np.array(p2, dtype=float)
    delta = (p2 - p1) / 3.0
    a = p1
    b = p1 + delta
    d = p1 + 2 * delta

    # peak point of the bump: rotate the middle-third vector by -60 degrees
    angle = -np.pi / 3
    rot = np.array([[np.cos(angle), -np.sin(angle)],
                     [np.sin(angle),  np.cos(angle)]])
    c = b + rot.dot(delta)

    pts = []
    pts += koch_segment(a, b, depth - 1)
    pts += koch_segment(b, c, depth - 1)
    pts += koch_segment(c, d, depth - 1)
    pts += koch_segment(d, p2, depth - 1)
    return pts


def koch_snowflake(depth, size=1.0):
    """Return an (N, 2) array of points tracing the closed Koch snowflake."""
    height = size * np.sqrt(3) / 2
    p1 = (0.0, height * 2 / 3)
    p2 = (-size / 2, -height / 3)
    p3 = (size / 2, -height / 3)

    pts = []
    pts += koch_segment(p1, p2, depth)
    pts += koch_segment(p2, p3, depth)
    pts += koch_segment(p3, p1, depth)
    pts.append(p1)  # close the loop
    return np.array(pts)


# ----------------------------------------------------------------------
# 2. Box counting
# ----------------------------------------------------------------------
def count_boxes(points, box_size, bounds):
    """Count grid boxes of side `box_size` that contain at least one
    point of the curve. Returns (count, set_of_box_indices)."""
    xmin, xmax, ymin, ymax = bounds
    ix = np.floor((points[:, 0] - xmin) / box_size).astype(int)
    iy = np.floor((points[:, 1] - ymin) / box_size).astype(int)
    boxes = set(zip(ix.tolist(), iy.tolist()))
    return len(boxes), boxes


# ----------------------------------------------------------------------
# 3. Build the figure
# ----------------------------------------------------------------------
def main():
    depth = 4          # recursion depth used for the drawn outline
    sample_depth = 8    # extra recursion for a dense point cloud used in counting

    curve = koch_snowflake(depth)
    dense_curve = koch_snowflake(sample_depth)  # dense points -> accurate box counts

    xmin, ymin = dense_curve.min(axis=0) - 0.05
    xmax, ymax = dense_curve.max(axis=0) + 0.05
    bounds = (xmin, xmax, ymin, ymax)
    span = max(xmax - xmin, ymax - ymin)

    # box sizes to visualize, as fractions of the bounding-box span
    box_fractions = [1 / 4, 1 / 8, 1 / 16, 1 / 32]
    box_sizes = [span * f for f in box_fractions]

    fig = plt.figure(figsize=(14, 10))
    gs = fig.add_gridspec(2, 4, height_ratios=[1, 0.9])

    counts = []
    for i, bs in enumerate(box_sizes):
        ax = fig.add_subplot(gs[0, i])
        n_boxes, boxes = count_boxes(dense_curve, bs, bounds)
        counts.append(n_boxes)

        # highlight grid boxes that intersect the curve
        for (bx, by) in boxes:
            rect = Rectangle((xmin + bx * bs, ymin + by * bs), bs, bs,
                              facecolor="#ffb703", edgecolor="#8d6708",
                              linewidth=0.4, alpha=0.55, zorder=1)
            ax.add_patch(rect)

        # faint full grid for context
        n_lines_x = int(np.ceil((xmax - xmin) / bs)) + 1
        n_lines_y = int(np.ceil((ymax - ymin) / bs)) + 1
        for k in range(n_lines_x):
            ax.axvline(xmin + k * bs, color="grey", lw=0.3, zorder=0)
        for k in range(n_lines_y):
            ax.axhline(ymin + k * bs, color="grey", lw=0.3, zorder=0)

        # the snowflake outline itself
        ax.plot(curve[:, 0], curve[:, 1], color="#023e8a", lw=1.3, zorder=2)

        ax.set_xlim(xmin, xmax)
        ax.set_ylim(ymin, ymax)
        ax.set_aspect("equal")
        ax.set_xticks([])
        ax.set_yticks([])
        ax.set_title(f"\u03b5 = span/{int(1/box_fractions[i])}\nN(\u03b5) = {n_boxes}",
                     fontsize=11)

  
    ax_log = fig.add_subplot(gs[1, 1:3])
    inv_eps = 1.0 / np.array(box_sizes)
    log_inv_eps = np.log(inv_eps)
    log_N = np.log(counts)

    slope, intercept = np.polyfit(log_inv_eps, log_N, 1)
    theoretical = np.log(4) / np.log(3)

    ax_log.scatter(log_inv_eps, log_N, color="#023e8a", zorder=3, label="measured N(\u03b5)")
    fit_x = np.linspace(log_inv_eps.min(), log_inv_eps.max(), 50)
    ax_log.plot(fit_x, slope * fit_x + intercept, color="#e63946", lw=1.5,
                label=f"fit slope D \u2248 {slope:.3f}")

    ax_log.set_xlabel("log(1/\u03b5)")
    ax_log.set_ylabel("log N(\u03b5)")
    ax_log.set_title(
        f"Box-counting dimension estimate: D \u2248 {slope:.3f}"
        f"   (theoretical log4/log3 \u2248 {theoretical:.3f})",
        fontsize=11
    )
    ax_log.legend(loc="upper left", fontsize=9)
    ax_log.grid(alpha=0.3)

    fig.suptitle("Box-Counting Method Applied to the Koch Snowflake",
                 fontsize=15, fontweight="bold")
    fig.tight_layout(rect=[0, 0, 1, 0.95])
    fig.savefig("koch_box_counting.png", dpi=200, bbox_inches="tight")

    print("Saved figure to koch_box_counting.png")
    print("Box counts:", counts)
    print(f"Estimated dimension D \u2248 {slope:.4f}")
    print(f"Theoretical dimension (log4/log3) \u2248 {theoretical:.4f}")


if __name__ == "__main__":
    main()
