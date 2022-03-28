# /usr/bin/env Rscript
# To run it


# test if there is at least one argument: if not, return an error
args = commandArgs(trailingOnly=TRUE)

if (length(args)==0) {
  stop("Please check your input file", call.=FALSE)
}


df = read.table(args[1], header=TRUE,sep="")
outputdir=args[2]
plot_name="plot.png"
output=paste0(outputdir,'/',plot_name)

header=colnames(df)
frequencies=c(0,0,0)
#names(frequencies)=c("Imputed (0)","Measured and genotyped (1)"," Not genotyped (2)")
names(frequencies)=c(0,1,2)
legend_names=c("Imputed (0)","Measured and genotyped (1)","Not genotyped (2)")
frequencies[1] <- length(which(df$type==0))
frequencies[2] <- length(which(df$type==1))
frequencies[3] <- length(which(df$type==2))

ggbg2 <- function() {
  points(0,0,pch=16, cex=1e6, col="lightgray")
  grid(col="white", lty=1)
}

png(output)
#barplot (frequencies, ylab="SNPs count", panel.first=ggbg2(), col="darkblue")
#barplot (frequencies, ylab="SNPs count", panel.first=ggbg2(), col="darkblue", las=2)
par(oma = c(0,0,0,2), mar = c(5,5,1,10), xpd=TRUE)
barplot(frequencies, col=c("#ff80ff", "darkgreen", "darkblue"), ylab="SNPs count", panel.first=ggbg2())
legend(x = "topright", inset = c(-0.6, 0), legend = legend_names, fill = c("#ff80ff", "darkgreen", "darkblue"), bty = "n")
dev.off()
