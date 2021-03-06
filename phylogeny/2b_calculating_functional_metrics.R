#Calculating functional metrics (that are comparable to phylo metrics)


#Load in needed stuff
source("start_here.R")
#get taxonomy table
dbDisconnect(con)
rm(con, alltaxa,noNIDseedlings,propertaxa,cover.thin,subturf.thin,turfs)
library(ape)
library(PhyloMeasures)
library(picante)
source("phylogeny/r_functions/comm_phy_fxs.R")
#library(devtools)
#install_github("NGSwenson/lefse_0.5")
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Prepare community data as needed for phylo stuff

tree_names<-read.csv(file = "phylogeny/tree_names_to_code_lookup.csv")#Contains standardized names used in phylogenies and names used in cover.thin

#Convert cover (species x turf matrix) to match names on phylogeny, probably smarter way to do this, but meh....
cover_names<-as.data.frame(colnames(cover))
colnames(cover_names)<-"covernames"
cover_names<-merge(x = cover_names,y = tree_names,by.x = "covernames", by.y = "species",all.x = T)
colnames(cover)<-cover_names$speciesName
cover<-cover[which(!is.na(cover_names$speciesName))]
rm(cover_names)
colnames(cover)<-gsub(pattern = " ",replacement = "_",x = colnames(cover))
tree_1<-read.tree("phylogeny/phylogenies/gbotb_base_rep_1.tre")
colnames(cover)[which(!colnames(cover)%in%tree_1$tip.label)]#need to drop a few species from the cover set
cover<-cover[which(colnames(cover)%in%tree_1$tip.label)]
cover_binary<-cover
class(cover_binary)
cover_binary<-as.matrix(cover_binary)
cover_binary[which(is.na(cover_binary))]<-0
cover_binary[which(cover_binary>0)]<-1
rm(tree_1,tree_names)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#Import trait data

#Note: this code can probably be improved at some point, but it works for now
library(funrar)
source("Traits/Cleaning.R")
rm(CN,dict_CN,dict_Site,LA,systematics_species,traits)

traitdata$Species<-gsub(traitdata$Species,pattern = "_",replacement = ".",fixed = T)
unitraits<-unique(traitdata[c("Species","SLA_mean_global","Height_mean_global","LDMC_mean_global","CN_ratio_mean_global")])
unitraits<-na.omit(unitraits)
tree_names<-read.csv(file = "phylogeny/tree_names_to_code_lookup.csv")#Contains standardized names used in phylogenies and names used in cover.thin

#Append species names to cover.thin, drop species that aren't in phylogeny
unitraits<-merge(x = unitraits,y = tree_names,by.x = "Species",by.y = "species")
rownames(unitraits)<-unitraits$speciesName
rownames(unitraits)<-gsub(pattern = " ",replacement = "_",x = rownames(unitraits))
unitraits<-unitraits[c("SLA_mean_global","Height_mean_global","LDMC_mean_global","CN_ratio_mean_global")]
trait_distance<-funrar::compute_dist_matrix(traits_table = unitraits,metric = "euclidean",center = T,scale = T)
cover.meta<-readRDS("phylogeny/cover_phylo.rds")


###############################################################

traitdata2<-read.csv("Traits/data/traitdata_NO.csv")
tree_names<-read.csv(file = "phylogeny/tree_names_to_code_lookup.csv")#Contains standardized names used in phylogenies and names used in cover.thin
unique(traitdata2$Taxon[which(!traitdata2$Taxon %in% tree_names$speciesName)])
traitdata2$Taxon<-gsub(pattern = "Agrostis capilaris", replacement = "Agrostis capillaris",x = traitdata2$Taxon)
traitdata2$Taxon<-gsub(pattern = "Luzula pilosella", replacement = "Luzula pilosa",x = traitdata2$Taxon)
traitdata2$Taxon<-gsub(pattern = "Viola palustris ", replacement = "Viola palustris",x = traitdata2$Taxon)
traitdata2$Taxon<-gsub(pattern = "Potentilla  crantzii", replacement = "Potentilla crantzii",x = traitdata2$Taxon)

#traitdata2<-traitdata2[which(traitdata2$Taxon%in%tree_names$speciesName),]

unitraits2<-matrix(nrow = length(unique(traitdata2$Taxon)),ncol = 5)
unitraits2<-as.data.frame(unitraits2)
colnames(unitraits2)<-c("Species","SLA_mean_global","Height_mean_global","LDMC_mean_global","CN_ratio_mean_global")
unitraits2$Species<-unique(traitdata2$Taxon)

for(i in 1:nrow(unitraits2)){
species_i<-unitraits2$Species[i]

unitraits2$SLA_mean_global[i]<-mean( traitdata2$SLA_cm2_g[which(traitdata2$Taxon==unitraits2$Species[i])],na.rm = T )    
unitraits2$Height_mean_global[i]<-mean( log10(traitdata2$Plant_Height_cm[which(traitdata2$Taxon==unitraits2$Species[i])]),na.rm = T )
unitraits2$LDMC_mean_global[i]<-mean( traitdata2$LDMC[which(traitdata2$Taxon==unitraits2$Species[i])] ,na.rm = T)
unitraits2$CN_ratio_mean_global[i]<-mean( traitdata2$CN_ratio[which(traitdata2$Taxon==unitraits2$Species[i])] ,na.rm = T)
  
}
unitraits2<-unitraits2[which(!is.na(x = unitraits2$Species)),]

rownames(unitraits2)<-unitraits2$Species
rownames(unitraits2)<-gsub(pattern = " ",replacement = "_",x = rownames(unitraits2))
unitraits2<-unitraits2[c("SLA_mean_global","Height_mean_global","LDMC_mean_global","CN_ratio_mean_global")]
unitraits2<-na.omit(unitraits2)
rownames(unitraits2)[which(!rownames(unitraits2)%in%gsub(pattern = " ",replacement = "_",x = tree_names$speciesName))]
unitraits<-na.omit(unitraits)
unitraits2 <- unitraits2[which(row.names(unitraits2) %in% gsub(pattern = " ",replacement = "_",x = tree_names$speciesName)),]



#Check one differences
row.names(unitraits)[which(!row.names(unitraits)%in%gsub(pattern = " ",replacement = "_",x = row.names(unitraits2)))]
row.names(unitraits2)[which(!row.names(unitraits2)%in%gsub(pattern = " ",replacement = "_",x = row.names(unitraits)))]




#



trait_distance<-funrar::compute_dist_matrix(traits_table = unitraits,metric = "euclidean",center = T,scale = T)








#########################
#calculations


#Note: NEED to add trait equivalent of PD. Is this just trait diversity?  Hypervolume size? Convex hull?

#richness
#pd_abd_std <- replicated_traitd_abd_std(comm_matrix = cover,phylogeny_directory = "phylogeny/phylogenies/",n_reps_phylo = 100,nreps_null = 100)
#cover.meta$pd_abd_std<-rowMeans(pd_abd_std)

#divergence
mtraitd_abd_std<-replicated_mtraitd_abd_std(comm_matrix = cover,trait_matrix = trait_distance,nreps_traits = 1,nreps_null = 100)
cover.meta$mtraitd_abd_std<-rowMeans(mtraitd_abd_std)

mntraitd_abd_std<-replicated_mntraitd_abd_std(comm_matrix = cover,trait_matrix = trait_distance,nreps_traits = 1,nreps_null = 100)
cover.meta$mntraitd_abd_std<-rowMeans(mntraitd_abd_std)


#variance
vtraitd_abd_std<-replicated_vtraitd_abd_std(comm_matrix = cover,trait_matrix = trait_distance,nreps_traits = 1,nreps_null = 100)
cover.meta$vtraitd_abd_std<-rowMeans(vtraitd_abd_std)

vntraitd_abd_std<-replicated_vntraitd_abd_std(comm_matrix = cover,trait_matrix = trait_distance,nreps_traits = 1,nreps_null = 100)
cover.meta$vntraitd_abd_std<-rowMeans(vntraitd_abd_std)


saveRDS(object = cover.meta,file = "phylogeny/cover_phylo_trait.rds")


##################

#NOTE!

#It would be possible, and perhaps advisable, to account for trait uncertainty, by implementing some sort of bootstrapping procedure.
# For this use-case, it seems best to randomly take one trait (or set of traits to preserce covariance) per species 
# from the available pool (or BIEN where lacking?) per replicate.





