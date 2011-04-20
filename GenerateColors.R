library(colorspace)

args <- commandArgs(TRUE)

FILE.SCORE <- args[1]
FILE.COLOR <- args[2]
FILE.ORDER <- args[3]

scaleScore <- function(filename) {
  rawData  <- read.table(filename)
  nCols    <- max(rawData[, 1])
  nRows    <- max(rawData[, 2], rawData[, 3])
  scaled   <- data.frame()

  for (col in 1 : nCols) {
    colData  <- rawData[rawData[, 1] == col, ]
    if (length(colData[, 1]) == 0) next
    colData[, 4] <- 1 - colData[, 4]
    points   <- sort(unique(c(colData[, 2], colData[, 3])))
    nPoints  <- length(points)

    distMat  <- matrix(0, nPoints, nPoints)
    dimnames(distMat) <- list(points, points)
    distInd  <- rbind(cbind(match(colData[[2]], points), match(colData[[3]], points)), 
                      cbind(match(colData[[3]], points), match(colData[[2]], points))) 
    distMat[distInd]  <- rep(colData[[4]], 2) 

    colScaled <- cmdscale(distMat, min(nrow(distMat) - 1, 2))
    colScaled <- cbind(col, points, colScaled, if (ncol(colScaled) < 2) 0)
    if (ncol(colScaled) < 4) colScaled <- cbind(colScaled, 0)
    colScaled[is.nan(colScaled[, 4]), 4] <- 0
    scaled    <- rbind(scaled, colScaled)
  }
  scaled
}

createLch    <- function(scaled) {
  lightness  <- 70
  multiplier <- 100
  labData    <- cbind(lightness, scaled[, 3:4] * multiplier)
  labColor   <- LAB(data.matrix(labData))
  lchColor   <- as(labColor, "polarLAB")
  lchColor
}

adjustColor <- function(lchColor) {
  lchData   <- coords(lchColor)
  chroma    <- lchData[, 2]
  #chroma    <- (chroma / max(chroma)) * 80 + 0
  lightness <- (chroma / max(chroma)) * 0 + 70
  lchData   <- cbind(lightness, chroma, lchData[, 3])
  lchColor  <- polarLAB(lchData)
  lchColor
}

colorToData <- function(color) {
  cbind(scaled[, 1:2], coords(color))
}

angleDiff <- function(angleA, angleB) {
  (angleA - angleB + 180) %% 360 - 180
}

angleAvg <- function(angles) {
  sumSin <- sum(sin(angles / 180 * pi))
  sumCos <- sum(cos(angles / 180 * pi))
  if (sumSin * sumCos == 0) 0 else (atan2(sumSin, sumCos) / pi * 180)
}

angleVar  <- function(angles) {
  if (length(angles) == 0) return(0)
  average <- angleAvg(angles)
  sum(((average - angles + 180) %% 360 - 180) ^ 2) / length(angles)
}

angleAdd  <- function(angleA, angleB) {
  (angleA + angleB) %% 360
}

doRotation <- function(lchData, rotation) {
  flip     <- rotation < 0
  flpData  <- lchData
  flpData[, 5] <- ifelse(flip[flpData[, 1]], (- flpData[, 5]) %% 360, flpData[, 5])
  rotation <- abs(rotation)
  rotData  <- flpData
  rotData[, 5] <- angleAdd(rotData[, 5], rotation[rotData[, 1]])
  rotData
}

penalty    <- function(rotation) {
  rotData  <- doRotation(lchData, rotation)
  nRows    <- max(lchData[, 2])
  sumVar   <- 0
  for (row in 1 : nRows) {
    rowVar <- angleVar(rotData[rotData[, 2] == row, 5])
    sumVar <- sumVar + rowVar
  }
  sumVar
}

initRot    <- function(lchData) {
  nCols    <- max(lchData[, 1])
  rotation <- rep(0, nCols)
  rotation
}

bfgsOptim  <- function(lchData, rotation) {
  nCols    <- length(rotation)
  optimRot <- optim(rotation, penalty, NULL, method = "L-BFGS-B", lower = rep(-360, nCols), upper = rep(360, nCols))
  optimRot$par
}

rotSeqOrd  <- function(seqOrder) {
  seqHues  <- seqOrder[, 2]
  nextHues <- c(seqHues[-1], seqHues[1])
  diffHues <- abs(angleDiff(nextHues, seqHues))
  maxGap   <- which(diffHues == max(diffHues))[1]
  newOrder <- seqOrder[1 : maxGap, ]
  if (maxGap < nrow(seqOrder)) {
    newOrder <- rbind(seqOrder[(maxGap + 1) : nrow(seqOrder), ], newOrder)
  }
  newOrder
}

sortSeq    <- function(rotData) {
  nRows    <- max(rotData[, 2])
  sortData <- data.frame()
  for (row in 1 : nRows) {
    rowData  <- rotData[rotData[, 2] == row, ]
    rowAvg   <- angleAvg(rowData[, 5]) %% 360
    avgColor <- colorAvg(rowData)
    sortData <- rbind(sortData, c(row, rowAvg, avgColor))
  }
  seqOrder <- sortData[order(sortData[, 2]), ]
  seqOrder <- rotSeqOrd(seqOrder)
  seqOrder
}

colorAvg   <- function(lchData) { # need to be refactored
  lchColor <- polarLAB(data.matrix(lchData[, 3:5]))
  rgbColor <- as(lchColor, "RGB")
  rgbData  <- coords(rgbColor)
  labColor <- as(rgbColor, "LAB")
  labData  <- coords(labColor)
  c(mean(data.frame(rgbData)), mean(data.frame(labData)))
}

outputData <- function(rotData, seqOrder) {
  lchColor <- polarLAB(data.matrix(rotData[, 3:5]))
  rgbColor <- as(lchColor, "RGB")
  rgbData  <- cbind(rotData[, 1:2], coords(rgbColor))
  write(t(rgbData),  file = FILE.COLOR, sep = "\t", ncolumns = 5)
  write(t(seqOrder), file = FILE.ORDER, sep = "\t", ncolumns = 8)
}

scaled   <- scaleScore(FILE.SCORE)
lchColor <- createLch(scaled)
lchColor <- adjustColor(lchColor)
lchData  <- colorToData(lchColor)

rotation <- initRot(lchData)
rotation <- bfgsOptim(lchData, rotation)

rotData  <- doRotation(lchData, rotation)
seqOrder <- sortSeq(rotData)

outputData(rotData, seqOrder)
