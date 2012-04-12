dat <-read.table("genematrix_table.tab",header=T,sep="\t")
row.names(dat) = dat$GENE
dat  = dat[,2:5] # this does require us to know how many strains are in the file - fix this when we know the column count
gene_matrix <- data.matrix(dat)

# choose some nice blue colors
palette <- colorRampPalette(c('#f0f3ff','#0033BB'))(256)
hc.rows <- hclust(dist(gene_matrix))
hc.cols <- hclust(dist(t(gene_matrix)))
pdf("genematrix_heatmap.pdf")

gene_heatmap <- heatmap(gene_matrix, Rowv=as.dendrogram(hc.rows), Colv=as.dendrogram(hc.cols),
col = palette, scale="none",margins=c(5,10))
