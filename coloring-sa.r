library("colorspace")
library("seqinr")

args <- commandArgs(TRUE)

FILE.SCORE <- args[1]
FILE.ALIGN <- args[2]
FILE.HTML  <- args[3]

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
  lightness <- (chroma / max(chroma)) * 0 + 70
  chroma    <- (chroma / max(chroma)) * 30 + 70
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

doFlipping <- function(lchData) {
  nCols    <- max(lchData[, 1])
  nRows    <- max(lchData[, 2])
  for (col in 1 : (nCols - 1)) {
    hues   <- matrix(ncol = 2, nrow = 0)
    colOne <- lchData[lchData[, 1] == col, ]
    colTwo <- lchData[lchData[, 1] == col + 1, ]
    for (row in 1 : nRows) {
      hue1 <- colOne[colOne[, 2] == row, 5]
      hue2 <- colTwo[colTwo[, 2] == row, 5]
      if (length(hue1) & length(hue2)) {
        hues <- rbind(hues, c(hue1, hue2))
      }
    }
    if (nrow(hues) < 2) next
    changes <- hues[c(2 : nrow(hues), 1), ] - hues
    changes <- ifelse(abs(angleDiff(changes, 0)) < 15 | abs(angleDiff(changes, 180)) < 15, 0, changes)
    direction <- ifelse(changes > 0, 1, 0)
    direction <- ifelse(changes < 0, -1, direction)
    if (sum(direction[, 1]) * sum(direction[, 2]) < 0) {
      lchData[lchData[, 1] == col + 1, 5] = 360 - lchData[lchData[, 1] == col + 1, 5]
    }
  }
  lchData
}

doRotation <- function(lchData, rotation) {
  rotData  <- lchData
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
  optimRot <- optim(rotation, penalty, NULL, method = "L-BFGS-B", lower = rep(0, nCols), upper = rep(360, nCols))
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
    sortData <- rbind(sortData, c(row, rowAvg))
  }
  seqOrder <- sortData[order(sortData[, 2]), ]
  seqOrder <- rotSeqOrd(seqOrder)
  seqOrder
}

lchToRgb   <- function(rotData) {
  lchColor <- polarLAB(data.matrix(rotData[, 3:5]))
  rgbColor <- as(lchColor, "RGB")
  rgbData  <- cbind(rotData[, 1:2], coords(rgbColor))
  rgbData
}

outputHtml <- function(rgbData, seqOrder) {
  header   <- '
  <!DOCTYPE html>
  <html lang="en">
    <head>
      <meta http-equiv="content-type" content="text/html; charset=UTF-8" />
      <title>Mavis Output</title>
      <style>
        *     { margin: 0; padding: 0; font-family: Verdana; font-size: 8pt; }
        body  { padding: 0 24px; margin-bottom: 40px; }
        #alignment_header   { font-size: 24pt; margin: 18px 0; padding: 0 0 6px 6px; border-bottom: solid 1px #aaa; }
        #alignment_footer   { text-align: right; margin: 18px 0; padding: 6px 12px; border-top: solid 1px #aaa; }
        #alignment_table    { margin: 10px 20px; }
        #alignment_table *  { font-family: Courier, "Courier New"; }
        #alignment_table td.seq_name  { padding: 0 10px; }
      </style>
    </head>
    <body>
      <div id="alignment_container">
        <div id="alignment_header">Mavis Output</div>
        <table id="alignment_table" cellspacing="0">'
  footer    <- '</table></div><div id="alignment_footer"></div></body></html>'
  alignHtml <- ""
  alignData <- read.fasta(FILE.ALIGN)
  for (row in seqOrder[, 1]) {
    sequence  <- alignData[row]
    seqAvgHue <- seqOrder[seqOrder[, 1] == row, 2]
    seqName   <- attr(sequence, "name")
    seqChars  <- unlist(sequence)
    alignHtml <- paste(alignHtml, '<tr><td bgcolor="', hueToColor(seqAvgHue), '">&nbsp;</td>', sep = '')
    alignHtml <- paste(alignHtml, '<td class="seq_name">', seqName, '</td>', sep = '')
    for (col in 1 : length(seqChars)) {
      cellColor <- getColor(rgbData, row, col) 
      alignHtml <- paste(alignHtml, '<td bgcolor="', cellColor, '">', toupper(seqChars[col]), '</td>', sep = '')
    }  
    alignHtml <- paste(alignHtml, "</tr>", sep = '')
  }
  html <- paste(header, alignHtml, footer, sep = '')
  write(html, file = FILE.HTML)
}

hueToColor <- function(hue) {
  "#a37"
}

getColor   <- function(rgbData, row, col) {
  cellData <- rgbData[rgbData[, 1] == col & rgbData[, 2] == row, ]
  colorHex <- '#fff'
  if (nrow(cellData) > 0) {
    red      <- decToHex1(cellData[1, 3])
    green    <- decToHex1(cellData[1, 4])
    blue     <- decToHex1(cellData[1, 5])
    colorHex <- paste('#', red, green, blue, sep = '')
  }
  colorHex
}

decToHex1  <- function(decimal) {
  decimal  <- max(0, min(1, decimal))
  sprintf("%1x", floor(decimal * 15.99))
}

hueToColor <- function(hue) {
	red   <- decToHex1(hueToPrim(hue + 120))
	green <- decToHex1(hueToPrim(hue))
	blue  <- decToHex1(hueToPrim(hue - 120))
	colorHex <- paste('#', red, green, blue, sep = '')
	colorHex
}

hueToPrim  <- function(hue) {
	hue <- hue %% 360
  if      (hue < 60)  prim <- hue / 60
  else if (hue < 180) prim <- 1
  else if (hue < 240) prim <- (240 - hue) / 60
	else                prim <- 0
	prim
}


scaled   <- scaleScore(FILE.SCORE)
lchColor <- createLch(scaled)
lchColor <- adjustColor(lchColor)
lchData  <- colorToData(lchColor)

lchData  <- doFlipping(lchData)

rotation <- initRot(lchData)
rotation <- bfgsOptim(lchData, rotation)
rotData  <- doRotation(lchData, rotation)

seqOrder <- sortSeq(rotData)

rgbData  <- lchToRgb(rotData)
outputHtml(rgbData, seqOrder)

cat(paste("\nWebpage", FILE.HTML, "has been creaated successfully.\n\n"))
