## Fractal dimension of the coastline of China
## Adapted from: https://rspatial.org/cases/2-coastline.html


library(terra)
library(geodata)

## 1. Get a coastline polygon for China from GADM
w   <- world(path = ".", resolution = 3)
chn <- w[w$GID_0 == "CHN", ]
plot(chn)

as.data.frame(chn)

## project to Albers Equal Area Conic projection. this is the standard
prj <- "+proj=aea +lat_1=25 +lat_2=47 +lat_0=36 +lon_0=105 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs"
gchn <- project(chn, prj)

## 3. Split into individual polygons (mainland + all islands) and
##    keep the largest one (mainland China)
dchn <- disagg(gchn)
a <- expanse(dchn)
i <- which.max(a)
a[i] / 1000000   # area in km2

b <- dchn[i, ]
par(mai = rep(0, 4))
plot(b)

## 4. Ruler (yardstick / divider) function -- unchanged from original
measure_with_ruler <- function(pols, stick_length, lonlat = FALSE) {
  stopifnot(inherits(pols, "SpatVector"))
  stopifnot(length(pols) == 1)
  g <- geom(pols)[, c('x', 'y')]
  nr <- nrow(g)
  pts <- 1
  newpt <- 1
  while (TRUE) {
    p <- newpt
    j <- p:(p + nr - 1)
    j[j > nr] <- j[j > nr] - nr
    gg <- g[j, ]
    pd <- distance(gg[1, , drop = FALSE], gg, lonlat)
    pd <- as.vector(pd)
    i <- which(pd > stick_length)[1]
    if (is.na(i)) {
      stop('Ruler is longer than the maximum distance found')
    }
    newpt <- i + p
    if (newpt >= nr) break
    pts <- c(pts, newpt)
  }
  pts <- c(pts, 1)
  g[pts, ]
}

## 5. Walk the coast with rulers of different lengths
##    CHANGE: China's coastline is much longer than Britain's (roughly
##    14,500 km of mainline coast, more if you count all the islands),
##    so we use a set of larger ruler lengths to keep the number of
##    segments (and runtime) reasonable. Adjust as needed -- smaller
##    rulers give a more accurate fractal dimension but take much
##    longer to run.
rulers <- c(50, 100, 200, 400, 600, 800, 1000)  # km
y <- list()
for (i in 1:length(rulers)) {
  y[[i]] <- measure_with_ruler(b, rulers[i] * 1000)
}

## 6. Plot the coastline as traced by each ruler
par(mfrow = c(3, 3), mai = rep(0, 4))
for (i in 1:length(y)) {
  plot(b, col = 'lightgray', lwd = 2)
  p <- y[[i]]
  lines(p, col = 'red', lwd = 2)
  points(p, pch = 20, col = 'blue', cex = 1)
  text(par("usr")[1] + 0.15 * diff(par("usr")[1:2]),
       par("usr")[4] - 0.08 * diff(par("usr")[3:4]),
       paste0(rulers[i], ' km (', nrow(p), ')'), cex = 1.1)
}

## 7. Fractal (log-log) plot
n <- sapply(y, nrow)   # number of ruler steps for each ruler length

par(mfrow = c(1, 1))
plot(log(rulers), log(n), pch = 20, cex = 2, col = 'red',
     xlab = 'Ruler length (km, log scale)',
     ylab = 'Number of segments (log scale)', axes = FALSE)
tics <- c(1, 10, 25, 50, 100, 200, 400, 800, 1600)
axis(1, at = log(tics), labels = tics)
axis(2, at = log(tics), labels = tics, las = 2)

m <- lm(log(n) ~ log(rulers))
abline(m, lwd = 3, col = 'lightblue')
points(log(rulers), log(n), pch = 20, cex = 2, col = 'red')

## 8. Fractal dimension D = absolute value of the slope
summary(m)
D <- -1 * m$coefficients[2]
D