library(ggplot2)
library(easyGgplot2)
suppressMessages(library('ape'))
library(vegan)

input <- 'tmp_ko_PA.txt'
output <- 'tmp_ko_PA.pdf'

data <- read.table(input,header=T,row.names = 1)
distance.euc <- vegdist(t(data),method="euclidean", binary=FALSE, diag=TRUE, upper=TRUE)
distance.bray <- vegdist(t(data),method="bray", binary=FALSE, diag=TRUE, upper=TRUE)
distance.jaccard <- vegdist(t(data),method="jaccard", binary=FALSE, diag=TRUE, upper=TRUE)
distance.raup <- vegdist(t(data),method="raup", binary=FALSE, diag=TRUE, upper=TRUE)

mds5 = pcoa(distance.euc)		
mds.data <- data.frame(Sample=rownames(mds5$vectors),
  X=mds5$vectors[,1],
  Y=mds5$vectors[,2])
mds.data		

p1 <- ggplot(data=mds.data, aes(x=X, y=Y, label=Sample)) +
		geom_point(color = "red") +
		geom_text() +
		theme_bw() +
		xlab(paste("MDS1 - ", round(mds5$values[1,2]*100,1), "%", sep="")) +
		ylab(paste("MDS2 - ", round(mds5$values[2,2]*100,1), "%", sep="")) +
		ggtitle("MDS plot using Euclidean distance")

mds5 = pcoa(distance.bray)		
mds.data <- data.frame(Sample=rownames(mds5$vectors),
  X=mds5$vectors[,1],
  Y=mds5$vectors[,2])
mds.data		

p2 <- ggplot(data=mds.data, aes(x=X, y=Y, label=Sample)) +
		geom_point(color = "red") +
		geom_text() +
		theme_bw() +
		xlab(paste("MDS1 - ", round(mds5$values[1,2]*100,1), "%", sep="")) +
		ylab(paste("MDS2 - ", round(mds5$values[2,2]*100,1), "%", sep="")) +
		ggtitle("MDS plot using Bray–Curtis distance")

mds5 = pcoa(distance.jaccard)		
mds.data <- data.frame(Sample=rownames(mds5$vectors),
  X=mds5$vectors[,1],
  Y=mds5$vectors[,2])
mds.data		

p3 <- ggplot(data=mds.data, aes(x=X, y=Y, label=Sample)) +
		geom_point(color = "red") +
		geom_text() +
		theme_bw() +
		xlab(paste("MDS1 - ", round(mds5$values[1,2]*100,1), "%", sep="")) +
		ylab(paste("MDS2 - ", round(mds5$values[2,2]*100,1), "%", sep="")) +
		ggtitle("MDS plot using jaccard distance")

mds5 = pcoa(distance.raup)		
mds.data <- data.frame(Sample=rownames(mds5$vectors),
  X=mds5$vectors[,1],
  Y=mds5$vectors[,2])
mds.data		

p4 <- ggplot(data=mds.data, aes(x=X, y=Y, label=Sample)) +
		geom_point(color = "red") +
		geom_text() +
		theme_bw() +
		xlab(paste("MDS1 - ", round(mds5$values[1,2]*100,1), "%", sep="")) +
		ylab(paste("MDS2 - ", round(mds5$values[2,2]*100,1), "%", sep="")) +
		ggtitle("MDS plot using Raup–Crick distance (scaled)")	

pdf(file=output,useDingbats=FALSE)		
ggplot2.multiplot(p1,p2,p3,p4, cols=2)
dev.off()


