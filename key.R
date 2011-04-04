library(colorspace)

keyData <- data.frame()
for (b in 10 : -10) {
  for (a in -10 : 10) {
    keyData <- rbind(keyData, c(70, a * 10, b * 10))
  }
}

keyColor <- LAB(data.matrix(keyData))
keyColor <- as(keyColor, "RGB")

write(t(coords(keyColor)), file = "key_colors.tsv", sep = "\t", ncolumns = 3)
