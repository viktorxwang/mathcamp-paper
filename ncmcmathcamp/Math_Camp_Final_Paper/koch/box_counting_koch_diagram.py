"""
Box-counting dimension of the Koch snowflake.

@author: Viktor Wang
@datetime: 7/26/2026
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle


def koch_curve(p1, p2, level):
    """Create points for one Koch curve segment."""
    if level == 0:
        return [np.array(p1)]

    p1 = np.array(p1, dtype=float)
    p2 = np.array(p2, dtype=float)

    third = (p2 - p1) / 3

    a = p1
    b = p1 + third
    d = p1 + 2 * third

    rotation = np.array([
        [np.cos(-np.pi / 3), -np.sin(-np.pi / 3)],
        [np.sin(-np.pi / 3), np.cos(-np.pi / 3)]
    ])

    c = b + rotation @ third

    points = []
    points.extend(koch_curve(a, b, level - 1))
    points.extend(koch_curve(b, c, level - 1))
    points.extend(koch_curve(c, d, level - 1))
    points.extend(koch_curve(d, p2, level - 1))

    return points


def make_snowflake(level, side_length=1):
    """Generate the closed Koch snowflake."""
    height = side_length * np.sqrt(3) / 2

    top = (0, 2 * height / 3)
    left = (-side_length / 2, -height / 3)
    right = (side_length / 2, -height / 3)

    points = []
    points.extend(koch_curve(top, left, level))
    points.extend(koch_curve(left, right, level))
    points.extend(koch_curve(right, top, level))

    points.append(np.array(top))

    return np.array(points)


def occupied_boxes(points, size, bounds):
    """Return the boxes touched by the curve."""
    xmin, xmax, ymin, ymax = bounds

    x_index = np.floor((points[:, 0] - xmin) / size).astype(int)
    y_index = np.floor((points[:, 1] - ymin) / size).astype(int)

    boxes = set(zip(x_index, y_index))

    return len(boxes), boxes


def draw_box_grid(ax, boxes, size, bounds):
    xmin, xmax, ymin, ymax = bounds

    for x, y in boxes:
        rectangle = Rectangle(
            (xmin + x * size, ymin + y * size),
            size,
            size,
            facecolor="orange",
            edgecolor="brown",
            alpha=0.5,
            linewidth=0.4
        )
        ax.add_patch(rectangle)

    nx = int(np.ceil((xmax - xmin) / size))
    ny = int(np.ceil((ymax - ymin) / size))

    for i in range(nx + 1):
        ax.axvline(
            xmin + i * size,
            color="gray",
            linewidth=0.3
        )

    for i in range(ny + 1):
        ax.axhline(
            ymin + i * size,
            color="gray",
            linewidth=0.3
        )


def main():

    # A lower depth is used for drawing, while a higher depth gives
    # more points for estimating the dimension.
    drawing_level = 4
    counting_level = 8

    snowflake = make_snowflake(drawing_level)
    counting_points = make_snowflake(counting_level)

    xmin = counting_points[:, 0].min() - 0.05
    xmax = counting_points[:, 0].max() + 0.05
    ymin = counting_points[:, 1].min() - 0.05
    ymax = counting_points[:, 1].max() + 0.05

    bounds = (xmin, xmax, ymin, ymax)

    width = max(xmax - xmin, ymax - ymin)

    grid_sizes = [
        width / 4,
        width / 8,
        width / 16,
        width / 32
    ]

    fig, axes = plt.subplots(
        1,
        4,
        figsize=(14, 4)
    )

    box_counts = []

    for ax, size in zip(axes, grid_sizes):

        count, boxes = occupied_boxes(
            counting_points,
            size,
            bounds
        )

        box_counts.append(count)

        draw_box_grid(
            ax,
            boxes,
            size,
            bounds
        )

        ax.plot(
            snowflake[:, 0],
            snowflake[:, 1],
            color="blue",
            linewidth=1.2
        )

        ax.set_xlim(xmin, xmax)
        ax.set_ylim(ymin, ymax)
        ax.set_aspect("equal")

        ax.set_xticks([])
        ax.set_yticks([])

        ax.set_title(
            f"epsilon = 1/{round(width/size)}\nN = {count}"
        )

    plt.suptitle(
        "Box Counting on the Koch Snowflake",
        fontsize=14
    )

    plt.tight_layout()

    plt.savefig(
        "koch_box_counting_diagram.png",
        dpi=200,
        bbox_inches="tight"
    )


    # Estimate dimension
    x = np.log(1 / np.array(grid_sizes))
    y = np.log(np.array(box_counts))

    dimension, intercept = np.polyfit(x, y, 1)

    theoretical = np.log(4) / np.log(3)

    print("epsilon\tN(epsilon)")
    for size, count in zip(grid_sizes, box_counts):
        print(f"{size:.5f}\t{count}")

    print()
    print(f"Estimated dimension: {dimension:.4f}")
    print(f"Theoretical dimension: {theoretical:.4f}")


if __name__ == "__main__":
    main()
