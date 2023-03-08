# Code bellow allows to compare multiple souporcell runs and combine souporcell cluster into donors
# it is very experimental, and should be refactored for each particular project
# Pasha Mazin, email:pm19@sanger.ac.uk

library(visutils)
readComp = function(f){
  r = read.table(f,skip = 5,header = T)
  l = as.numeric(sapply(strsplit(readLines(f)[2:3],' '),'[',3))
  r$ncells1=l[1]
  r$ncells2=l[2]
  r
}

comp2socs = function(f1,f2){
  r1 = read.table(f1,row.names = 1,header = TRUE)
  r2 = read.table(f2,row.names = 1,header = TRUE)[rownames(r1),]
  f = r1$status=='singlet' & r2$status=='singlet'
  ts = table(r1$status,r2$status)
  #tsn = sweep(sweep(ts,1,rowSums(ts),'/'),2,colSums(ts),'/')
  #imageWithText(ts)
  t = table(r1$assignment[f],r2$assignment[f])
  t = t[,order(apply(t,2,which.max))]
  #imageWithText(t)
  list(cl1=r1,cl2=r2,tstatus=ts,tassignment=t)
}

# load expected donor to sample distribution
s2d = read.table('actions/sample2donor.txt',sep='\t')
rownames(s2d) = sub('HCA_A_','',rownames(s2d))
s2d
#                   AS4 AS6 AS8 A60 A61 A63 PBMC1 PBMC2 PBMC3
# HCA_A_LNG12874136   x   x   x                 x     x     x
# HCA_A_LNG12874137   x   x   x                 x     x     x
# HCA_A_LNG12874138       x                     x     x     x
# HCA_A_LNG12874139       x                     x     x     x
# HCA_A_LNG12930421               x   x   x     x     x     x
# HCA_A_LNG12930422               x   x   x     x     x     x
# HCA_A_LNG12930423               x   x   x     x     x     x
# HCA_A_LNG12930424               x   x         x     x     x
# HCA_A_LNG12930425               x             x     x     x


# two columns: sample_id and number of donors
samples = read.table('actions/samples_k.txt')
ds = list.files('data/',pattern = '')
samples$dataset = ds[sapply(samples$V1,grep,ds)]



#dir.create('figures/soc')
# comp different runs #####
# compare multiple runs of soc (gex and atac for instance)
f1 = 'data/HCA_A_LNG12874136_and_44931_HCA_A_LNG12865768/soc2/clusters.tsv'
f2 = 'data/HCA_A_LNG12874136_and_44931_HCA_A_LNG12865768/soc2_atac/clusters.tsv'


comp = list()
comp[['gex_v1-2-gex_v2']] = lapply(samples$dataset,function(s)comp2socs(paste0('data/',s,'/soc/clusters.tsv'),
                                                     paste0('data/',s,'/soc2/clusters.tsv')))

comp[['gex_v1-2-atac_v2']] = lapply(samples$dataset,function(s)comp2socs(paste0('data/',s,'/soc/clusters.tsv'),
                                                     paste0('data/',s,'/soc2_atac/clusters.tsv')))

comp[['gex_v2-2-atac_v2']] = lapply(samples$dataset,function(s)comp2socs(paste0('data/',s,'/soc2/clusters.tsv'),
                                                      paste0('data/',s,'/soc2_atac/clusters.tsv')))
dir.create('figures/soc',recursive = T)
pdf('figures/soc/status.tables.pdf',w=3*8,h=3*3)
par(mfcol=c(3,nrow(samples)),mar=c(6,6,2,1),mgp=c(5,0.5,0))
for(i in 1:nrow(samples)){
  for(n in names(comp)){
    x = comp[[n]][[i]]
    labs = strsplit(n,'-2-',fixed = T)[[1]]
    imageWithText(x$tstatus,xlab=labs[1],ylab=labs[2],main=samples$V1[i])
  }
}
dev.off()

pdf('figures/soc/singlet.assignment.tables.pdf',w=3*8,h=3*3)
par(mfcol=c(3,nrow(samples)),mar=c(3,3,2,1),mgp=c(1.5,0.5,0))
for(i in 1:nrow(samples)){
  for(n in names(comp)){
    x = comp[[n]][[i]]
    labs = strsplit(n,'2',fixed = T)[[1]]
    imageWithText(x$tassignment,xlab=labs[1],ylab=labs[2],main=samples$V1[i])
  }
}
dev.off()

#  group clusters ######
# it reads outputs of twosubmit.sh, links top n pairs where n is expected number of common donors for given pair of samples
# then cluster resulting graph. Just linked components should be enaugh if everythings works well.
# read outputs of twosubmit.sh
fls = list.files('work_souporcell/twoout2_atac/',pattern = 'out*')
d = lapply(fls,function(f){
  r = cbind(fname=f,readComp(paste0('work_souporcell/twoout2_atac/',f)))
  sids = strsplit(f,'_')
  r$sid1 = s1 = sapply(sids,'[',3)
  r$sid2 = s2 = sapply(sids,'[',10)
  nexp = sum((s2d[s1,]=='x') & (s2d[s2,]=='x'))
  r = r[order(r$loss),]
  # according to expected number of common donors for given sample pair
  r$topn = (1:nrow(r)) <= nexp
  r
  })
d = do.call(rbind,d)
d

# make sance for gex where it predicted very small cluster (~4 cells)
# as results all losses with this sampls were weird
# there is some weirdly low loss in some of files
# dl = split(log(d$loss+1e-10) , d$sid1)
##dl = dl[order(sapply(dl, mean))]
# sims it depends on first sample
# sapply(dl, mean)
# boxplot(dl)
# bdsam = names(dl)[1] # LNG12874136
## loss is very small if this sample is first..
#s2d[bdsam,]
# # there are pairs of samples were it was first only because this sample has 6 donnors
# # so, I'll remove only pairs that were considered in the opposite direction
# u = unique(d$sid1[d$sid2==bdsam])
# d = d[!(d$sid1==bdsam & d$sid2 %in% u),]

hist(d$loss,100000,xlim=c(0,2000))
hist(d$loss,10000)
range(d$ncells1)
dim(d)

d$d1 = paste0(d$sid1,'_',d$experiment1_cluster)
d$d2 = paste0(d$sid2,'_',d$experiment2_cluster)
u = sort(unique(c(d$d1,d$d2)))

# lets make matrix of pairwise identity between clusters. Top n (where n is expected number of common donors) pairs are considered as identicall for each pair
mtx = matrix(FALSE,ncol=length(u),nrow=length(u),dimnames = list(u,u))
for(i in 1:nrow(d)){
  #mtx[d$d1[i],d$d2[i]] = mtx[d$d2[i],d$d1[i]] = min(d$loss[i],mtx[d$d2[i],d$d1[i]],na.rm = TRUE)
  mtx[d$d1[i],d$d2[i]] = mtx[d$d2[i],d$d1[i]] = d$topn[i] | mtx[d$d1[i],d$d2[i]] | mtx[d$d2[i],d$d1[i]]
}

diag(mtx) = TRUE

hcl = hclust(as.dist(1-mtx),method='av')
membs = cutree(hcl,k = 9)
mcols=RColorBrewer::brewer.pal(9,'Set1')
heatmap(1-mtx,symm = T,distfun = function(x)as.dist(x),hclustfun = function(d)hclust(d,method='av'),margins = c(7,7),
        ColSideColors = mcols[membs],RowSideColors = mcols[membs])

plot(hcl)
# there are 9 donors expected

library(igraph)
comp = components(graph_from_adjacency_matrix(mtx+0))$membership
t = table(comp,membs)
imageWithText(t>0,t) # exactly rhe same

membership = as.data.frame(do.call(rbind,strsplit(names(membs),'_')))
rownames(membership) = names(membs)
colnames(membership) = c('sid','soccl')
membership$group = membs
membership$multiome_id = samples$dataset[match(membership$sid,sub('HCA_A_','',samples$V1))]


z = as.data.frame(reshape::cast(membership,sid ~ group,fun.aggregate = length,value = 'soccl'))
z
rownames(z) = z$sid
z$sid = NULL
z = z[,order(apply(z,2,sum))]
visutils::imageWithText(t(as.matrix(z)[rev(rownames(s2d)),]))
#clord=c('6','1','3','7','8','9','2','4','5')
clord=c('3','2','6','9','7','8','1','4','5')
par(mfrow=c(1,2),mar=c(7,10,1,1))
visutils::imageWithText(t(as.matrix(z)[rev(rownames(s2d)),clord]),main='Observed',xlab='group')
visutils::imageWithText(t(as.matrix(s2d=='x')[rev(rownames(s2d)),]),main='Expected')
o = order(match(membs,clord))
par(mfrow=c(1,1),mar=c(10,10,1,1),las=2)
visutils::dotPlot(mtx[rev(o),o],plot.legend = F,colColours = mcols[membs[o]],rowColours = rev(mcols[membs[o]]))

# for gex
# membership[membership$group==6,]
# membership[membership$sid=='LNG12874136',]
# #LNG12874136_1 is not used, it should be donor 6
# d[d$sid1=='LNG12874137' & d$sid2=='LNG12874136',]
# 
# group2donor=c('6'='AS4/8','1'='AS6','3'='AS4/8',
#               '7'='A60','8'='A61','9'='A63',
#               '2'='PBMC','4'='PBMC','5'='PBMC')
# set it manually
group2donor=c('3'='AS4/8_x1','2'='AS6','6'='AS4/8_x2',
              '9'='A60','7'='A61','8'='A63',
              '1'='PBMC_x1','4'='PBMC_x2','5'='PBMC_x3')

membership$supposed_donor = group2donor[as.character(membership$group)]

zz = as.data.frame(reshape::cast(membership,sid ~ supposed_donor,fun.aggregate = length,value = 'soccl'))
rownames(zz) = zz$sid
zz = zz[,group2donor]

pdf('figures/soc/soc_cluster2donors.pdf',w=8,h=12)
layout(matrix(c(1,1,2,1,1,3),ncol=2))
par(mar=c(13,13,1,1),bty='n',las=2)
o = order(match(membership[rownames(mtx),'supposed_donor'],group2donor))
mtx_ = mtx[rev(o),o]
mcols = char2col(group2donor,palette = TRUE)
visutils::dotPlot(mtx_,plot.legend = F,
                  colColours = mcols[membership[colnames(mtx_),'supposed_donor']],
                  rowColours = mcols[membership[rownames(mtx_),'supposed_donor']],main='Matched soc clusters',max.cex = 2,ylab.cex = 0.7,xlab.cex = 0.7)
visutils::dotPlot(as.matrix(zz),main='Observed',xlab='group',plot.legend = F,colColours = mcols[colnames(zz)],max.cex = 2)
visutils::dotPlot(as.matrix(s2d=='x')+0,main='Expected',xlab='group',plot.legend = F,max.cex = 2)
dev.off()


# make cell assignment #####
cellassignment = lapply(samples$dataset,function(f)cbind(multiome_id=f,read.table(paste0('data/',f,'/soc2_atac/clusters.tsv'),header = TRUE)[,1:3]))
cellassignment[[1]][1:2,]
cellassignment = do.call(rbind,cellassignment)
cellassignment[1:2,]
table(cellassignment$assignment)
cellassignment$assignment_donor = NA
for(m in unique(membership$multiome_id)){
  f = cellassignment$multiome_id==m
  c2d = membership[membership$multiome_id==m,]
  c2d = setNames(c2d$supposed_donor,c2d$soccl)
  cellassignment$assignment_donor[f] = sapply(strsplit(cellassignment$assignment[f],'/',fixed = TRUE),function(x)paste(c2d[x],collapse = '/'))
}

table(cellassignment$assignment_donor)

t = table(cellassignment$assignment[f],cellassignment$assignment_donor[f])
image(t[,order(apply(t,2,which.max))]>0)

t = table(cellassignment$assignment,cellassignment$assignment_donor)
image(t[,order(apply(t,2,which.max))]>0)


write.csv(membership,'membership.v02.csv')
write.csv(cellassignment,'cellassignment.v02.csv')


######  
install.packages('vcfR')
library(vcfR)
v1 = read.vcfR('/lustre/scratch126/cellgen/cellgeni/tickets/tic-1887/data/HCA_A_LNG12874138_and_44931_HCA_A_LNG12865770/soc/cluster_genotypes.vcf')


