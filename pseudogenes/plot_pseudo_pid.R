library(ggplot2)
g<-read.table("frameshift.ggplot.in",header=T,sep="\t")
pdf("rhizobia_ident.pdf")

qplot(GENENUM,IDENT,data=g,color=FRAMESHIFT)+theme_bw()+labs(title="Genes 0-1500")+xlim(0,1500)+ylim(50,100)+facet_grid(STRAIN ~ .)+scale_colour_brewer(palette="Set1")

qplot(GENENUM,IDENT,data=g,color=FRAMESHIFT)+theme_bw()+labs(title="Genes 1500-3000")+xlim(1500,3000)+ylim(50,100)+facet_grid(STRAIN ~ .)+scale_colour_brewer(palette="Set1")

qplot(GENENUM,IDENT,data=g,color=FRAMESHIFT)+theme_bw()+labs(title="Genes 3000-4500")+xlim(3000,4500)+ylim(50,100)+facet_grid(STRAIN ~ .)+scale_colour_brewer(palette="Set1")

qplot(GENENUM,IDENT,data=g,color=FRAMESHIFT)+theme_bw()+labs(title="Genes 4500-6000")+xlim(4500,6000)+ylim(50,100)+facet_grid(STRAIN ~ .)+scale_colour_brewer(palette="Set1")

qplot(GENENUM,IDENT,data=g,color=FRAMESHIFT)+theme_bw()+labs(title="Genes 6000-8000")+xlim(6000,7817)+ylim(50,100)+facet_grid(STRAIN ~ .)+scale_colour_brewer(palette="Set1")


qplot(GENENUM,IDENT,data=g,color=STRAIN,shape=FRAMESHIFT)+annotate("rect",xmin=702,xmax=854,ymin=10,ymax=100,colour="red",alpha=0.2)+theme_bw()+labs(title="Genes 0-2000")+xlim(0,2000)
qplot(GENENUM,IDENT,data=g,color=STRAIN,shape=FRAMESHIFT)+theme_bw()+labs(title="Genes 2000-4000")+xlim(2000,4000)
qplot(GENENUM,IDENT,data=g,color=STRAIN,shape=FRAMESHIFT)+theme_bw()+labs(title="Genes 4000-6000")+xlim(4000,6000)
qplot(GENENUM,IDENT,data=g,color=STRAIN,shape=FRAMESHIFT)+theme_bw()+labs(title="Genes 6000-8000")+xlim(6000,7817)



g_onestrain <- subset(g,g$STRAIN == "str38")
qplot(GENENUM,IDENT,data=g_onestrain,color=FRAMESHIFT)+theme_bw()+labs(title="Strain 38:0-1500")+annotate("rect",xmin=702,xmax=854,ymin=10,ymax=100,colour="black",alpha=0.2)+xlim(0,1500)+scale_colour_brewer(palette="Set1")

qplot(GENENUM,IDENT,data=g_onestrain,color=FRAMESHIFT)+theme_bw()+labs(title="Strain 38:1500-3000")+annotate("rect",xmin=702,xmax=854,ymin=10,ymax=100,colour="black",alpha=0.2)+xlim(1500,3000)+scale_colour_brewer(palette="Set1")

qplot(GENENUM,IDENT,data=g_onestrain,color=FRAMESHIFT)+theme_bw()+labs(title="Strain 38:3000-4500")+annotate("rect",xmin=702,xmax=854,ymin=10,ymax=100,colour="black",alpha=0.2)+xlim(3000,4500)+scale_colour_brewer(palette="Set1")

qplot(GENENUM,IDENT,data=g_onestrain,color=FRAMESHIFT)+theme_bw()+labs(title="Strain 38:4500-6000")+annotate("rect",xmin=702,xmax=854,ymin=10,ymax=100,colour="black",alpha=0.2)+xlim(4500,6000)+scale_colour_brewer(palette="Set1")

qplot(GENENUM,IDENT,data=g_onestrain,color=FRAMESHIFT)+theme_bw()+labs(title="Strain 38:6000-8000")+annotate("rect",xmin=702,xmax=854,ymin=10,ymax=100,colour="black",alpha=0.2)+xlim(6000,7817)+scale_colour_brewer(palette="Set1")

