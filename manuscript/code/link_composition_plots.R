#############################################################
#  Description: This script creates figures 1, 3, 4, 5, and 6 for the manuscript, "Genetic specificity of a plant-insect food web: Implications for linking genetic variation to food-web complexity"
#  Code author: Matthew A. Barbour
#  Email: barbour@zoology.ubc.ca
#############################################################


#source('~/Documents/Genotype_Networks/Rscripts/network_management_tree_level.R')
tree_level_interaxn_all_plants_traits_size <- read.csv("manuscript/Dryad_data_copy/empirical_data/tree_level_interaxn_all_plants_traits_size.csv")
#source('~/Documents/miscellaneous_R/ggplot_themes.R')
source('~/Documents/ggnet/bipartite_plot_info.R') # need to link to forked version on github
source('~/Documents/ggnet/tripartite_plot_info.R')  # need to link to forked version on github

## load required libraries
library(ggplot2)
#devtools::install_github("hadley/ggplot2")
library(gridExtra)
library(plyr)
library(dplyr)
library(tidyr)
library(vegan)
library(scales)

## for an unknown reason, ggsave needs to be modified for me to save my arrangeGrob object ----
#ggsave <- ggplot2::ggsave; body(ggsave) <- body(ggplot2::ggsave)[-2]

## create theme for figures ----
theme_links <- theme_bw() +
  theme(axis.title.x = element_text(size = 11, vjust = -0.25), # size = 12
        axis.title.y = element_text(size = 11, vjust = 1.25), # size = 12
        axis.text.y = element_text(size = 9),#10
        axis.text.x = element_text(size = 8), #12
        strip.text = element_text(size = 9), #9
        panel.grid = element_blank(),
        legend.position = "none")
point.size.range <- c(1,3) #c(1,5)
point.size.range.ptism <- c(0.25,3)#c(1,3.5)
label.x.pos <- 1.5 #2
label.y.galls <- c(20,16,2.6) #23 # 21
label.y.gallsize <- 14 #13.75
label.y.ptoids <- c(8.1,3.65,2.75) #9.5 #9.75
label.y.ptism <- 1
label.size <- 3 # 3
ABCD.allgalls <- data.frame(x = rep(label.x.pos,4), y = rep(label.y.galls,4), 
                            variable = c("Leaf gall", "Apical-stem gall", 
                                         "Bud gall", "Mid-stem gall"), 
                            labels = c("(A)","(B)","(C)","(D)"))
ABC.domgalls <- data.frame(x = rep(label.x.pos,3), y = label.y.galls,#3), 
                          variable = c("Leaf gall","Bud gall", "Apical-stem gall"), 
                          labels = c("(A)","(B)","(C)"))
D.gallsize <- data.frame(x = label.x.pos, y = label.y.gallsize, labels = "(D)")
ABC.domptoids <- data.frame(x = rep(label.x.pos,3), y = label.y.ptoids, 
                            Parasitoid = c("Platygaster", "Mesopolobus", "Torymus"), 
                            labels = c("(A)","(B)","(C)"))
EFG.domptoids <- data.frame(x = rep(label.x.pos,3), y = rep(label.y.ptoids,3), 
                            Parasitoid = c("Platygaster", "Mesopolobus", "Torymus"), 
                            labels = c("(E)","(F)","(G)"))
D.ptism <- data.frame(x = label.x.pos, y = label.y.ptism, labels = "(D)")
H.ptism <- data.frame(x = label.x.pos, y = label.y.ptism, labels = "(H)")
A.linkabund <- data.frame(x = 0.5, y = 10, labels = "(A)")
B.ptism <- data.frame(x = 4.25, y = label.y.ptism, labels = "(B)")
AB.ptism <- data.frame(x = rep(4.25,2), y = rep(1,2), 
                       labels = c("(A)","(B)"), cut.vLG_abund = c("Low leaf gall abundance (1 - 4 per branch)", "High leaf gall abundance (5 - 22 per branch)"))
#point.size <- 6
line.widths <- 2 # for link plots (3 for full page plots)
## create color-blind friendly palette with grey (taken from http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/)
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

## make integer breaks for facet plotting in ggplot
integer_breaks <- function(n = 5, ...) {
  breaker <- pretty_breaks(n, ...)
  function(x) {
    breaks <- breaker(x)
    breaks[breaks == floor(breaks)]
  }
}

## change Genotype * to C for plotting aesthetics
levels(tree_level_interaxn_all_plants_traits_size$Genotype)[1] <- "C"

## Figure 3: genetic specificity of gall community ----

## tidy up gall composition data
gall.df <- as.data.frame(tree_level_interaxn_all_plants_traits_size) %>%
  select(Genotype, "Leaf gall" = vLG_abund, 
         "Bud gall" = rG_abund, 
         "Apical-stem gall" = aSG_abund, 
         "Mid-stem gall" = SG_abund) %>%
  gather(Genotype)
colnames(gall.df)[2] <- c("variable")

gall.summary <- gall.df %>% group_by(Genotype, variable) %>% summarise_each(funs(mean)) %>% arrange(variable)
max(filter(gall.summary, variable == "Leaf gall")$value) # 10
max(filter(gall.summary, variable == "Bud gall")$value) # 8
max(filter(gall.summary, variable == "Apical-stem gall")$value) # 1.4

## order genotypes by mean leaf gall abundance for all plots with genotype on X axis. 
vLG.df.sum <- gall.df %>%
  filter(variable == "Leaf gall") %>%
  group_by(Genotype) %>%
  summarise(mean_abundance = mean(value)) %>%
  arrange(mean_abundance)
gall.df$Genotype <- factor(gall.df$Genotype, levels = vLG.df.sum$Genotype)

## create gall composition plot with the leaf and bud galls. The two species that are driving the differences in gall community composition.
gall.dominants.plot <- ggplot(filter(gall.df, variable %in% c("Leaf gall", "Bud gall", "Apical-stem gall")), 
       aes(x = Genotype, y = value, fill = variable)) +
  geom_boxplot() + 
  facet_wrap( ~ variable, ncol = 1, scales = "free_y") + 
  ylab("No. of galls per branch") + xlab("") +
  geom_text(data = ABC.domgalls, aes(x = x, y = y, label = labels), size = label.size) +
  scale_fill_manual(values = cbPalette[c(7,3,1)]) +
  #scale_y_continuous(limits = c(0,25), # 0,14
   #                  breaks = seq(0,20,10)) +
  theme_links + theme(axis.text.x = element_blank(),
                      plot.margin = unit(c(0.5,0.5,-0.2,0.5),"cm")) # 1,1,0,0.5

anova(MASS::glm.nb(vLG_abund ~ Genotype, data = tree_level_interaxn_all_plants_traits_size),
      MASS::glm.nb(vLG_abund ~ 1, data = tree_level_interaxn_all_plants_traits_size))

anova(MASS::glm.nb(rG_abund ~ Genotype, data = tree_level_interaxn_all_plants_traits_size),
      MASS::glm.nb(rG_abund ~ 1, data = tree_level_interaxn_all_plants_traits_size))

anova(MASS::glm.nb(aSG_abund ~ Genotype, data = tree_level_interaxn_all_plants_traits_size),
      MASS::glm.nb(aSG_abund ~ 1, data = tree_level_interaxn_all_plants_traits_size))

## tidy up leaf gall size data 
vLG.size.df <- tree_level_interaxn_all_plants_traits_size %>%
  select(Genotype, vLG.height.mean, vLG.gall.count) %>%
  mutate(type = "mean")

lm.vLG.size <- lm(vLG.height.mean ~ Genotype, data = vLG.size.df, weights = vLG.gall.count)
summary(lm.vLG.size)
anova(lm.vLG.size)

## calculate weighted mean for leaf gall size based on the number of galls found on each replicate willow
vLG.size.df.2 <- vLG.size.df %>%
  group_by(Genotype) %>%
  summarise(vLG.height.mean = weighted.mean(vLG.height.mean, vLG.gall.count, 
                                              na.rm = TRUE),
            vLG.gall.count = 7) %>% # point size for weighted mean
  mutate(type = "weighted.mean")

## combine the original leaf gall size data with the weighted mean estimates.
vLG.size.df.3 <- rbind.data.frame(vLG.size.df.2,
                                  vLG.size.df)

## order leaf gall size data by median leaf gall abundance. This enables me to visually see whether there is a correlation between leaf gall abundance and size among genotypes.
vLG.size.df.3$Genotype <- factor(vLG.size.df.3$Genotype, levels = vLG.df.sum$Genotype)

## plot leaf gall size data. Size of points correspond to weights used to calculated the weighted mean of gall size for each genotype.
leaf.gall.size <- ggplot(vLG.size.df.3, 
       aes(x = Genotype, y = vLG.height.mean, size = vLG.gall.count, 
           fill = type, color = type, shape = type)) +
  geom_point() +
  scale_shape_manual(values = c(1, 23)) + 
  scale_color_manual(values = c("#666666", "black")) +
  scale_size(range = point.size.range) +
  scale_fill_manual(values = cbPalette[c(1,7)]) +
  geom_text(data = D.gallsize, aes(x = x, y = y, label = labels), inherit.aes = FALSE, size = label.size) +
  scale_y_continuous(limits = c(0,15), # 0,14
                     breaks = seq(0,15,5)) + # seq(0,14,2)
  ylab("Gall diameter (mm)") + # Leaf gall diameter (mm)
  xlab("Willow genotype") +
  theme_links + theme(plot.margin = unit(c(-0.2,0.5,0.5,0.5),"cm")) # 0,1,0.5,0.5

## Create a two-panel figure of dominant drivers of gall composition and variation in leaf gall size. 
gall.dom <- ggplot_gtable(ggplot_build(gall.dominants.plot))
gall.size <- ggplot_gtable(ggplot_build(leaf.gall.size))

maxWidth = unit.pmax(gall.dom$widths[2:3], gall.size$widths[2:3])

gall.dom$widths[2:3] <- maxWidth
gall.size$widths[2:3] <- maxWidth

gall_specificity <- arrangeGrob(gall.dominants.plot, leaf.gall.size, 
                                 ncol = 1, heights = c(7/10, 3/10))

#ggsave("manuscript/figures/fig_3/fig_3_gall_specificity_PNAS.png", gall_specificity, width = 3.42, height = 5, units = "in")

## Figure 4: genetic specificity of gall-parasitoid interactions ----

## tidy up data for visualizing differences in link composition among genotypes. 
link.df <- as.data.frame(tree_level_interaxn_all_plants_traits_size) %>%
  select(Genotype, 
         vLG_Platy, vLG_Mesopol, vLG_Tory, vLG_Eulo, vLG_Mymarid, 
         rG_Tory, rG_Eulo, rG_Platy, rG_Mesopol, rG_Lestodip, rG_Mesopol,
         aSG_Tory, SG_Platy) %>%
  gather(Genotype)
colnames(link.df)[2] <- c("variable")

link.df <- link.df %>%
  separate(variable, into = c("Gall", "Parasitoid"), sep = "_")

## revalue link composition data from species codes to common/species names
link.df$Gall <- factor(revalue(factor(link.df$Gall), c("vLG" = "Leaf gall", 
                                               "rG" = "Bud gall",
                                               "aSG" = "Apical-stem gall",
                                               "SG" = "Mid-stem gall")))
link.df$Gall <- factor(link.df$Gall, levels = c("Leaf gall", "Bud gall", "Apical-stem gall", "Mid-stem gall"))
link.df$Parasitoid <- factor(revalue(link.df$Parasitoid, c("Platy" = "Platygaster",
                                                           "Mesopol" = "Mesopolobus",
                                                           "Tory" = "Torymus",
                                                           "Eulo" = "Eulophid",
                                                           "Lestodip" = "Lestodiplosis",
                                                           "Mymarid" = "Mymarid")))
link.df$Parasitoid <- factor(link.df$Parasitoid, levels = c("Platygaster",
                                                            "Mesopolobus",
                                                            "Torymus",
                                                            "Eulophid",
                                                            "Lestodiplosis",
                                                            "Mymarid"))
## order genotypes by mean leaf gall abundance
link.df$Genotype <- factor(link.df$Genotype, levels = vLG.df.sum$Genotype)

## link summary 
link.summary <- link.df %>% group_by(Genotype, Gall, Parasitoid) %>% summarise_each(funs(mean)) %>% arrange(Gall)
max(filter(link.summary, Gall == "Leaf gall", Parasitoid == "Platygaster")$value) # 3.7
max(filter(link.summary,  Gall == "Leaf gall", Parasitoid == "Mesopolobus")$value) # 8
max(filter(link.summary,  Gall == "Leaf gall", Parasitoid == "Torymus")$value) # 1.4

## link composition plot for Platygaster, Mesopolobous, and Torymus attacking leaf galls. These are the links that were the dominant drivers of variation in link composition among genotypes.
link.dominants.plot <- ggplot(filter(link.df, Gall == "Leaf gall", 
                           Parasitoid %in% c("Platygaster", "Mesopolobus", "Torymus")), 
                    aes(x = Genotype, y = value, fill = Parasitoid)) +
  facet_grid(Parasitoid ~ Gall, scales = "free_y") + 
  geom_boxplot() +
  geom_text(data = ABC.domptoids, aes(x = x, y = y, label = labels), 
            size = label.size) +
  scale_fill_manual(values = cbPalette[c(6,4,2)]) +
  scale_y_continuous(breaks = integer_breaks()) +
  #scale_y_continuous(limits = c(0,10), breaks = seq(0,10,5)) +
  ylab("No. of interactions per branch\n") + 
  xlab("") +
  theme_links + 
  theme(axis.text.x = element_blank(),
        plot.margin = unit(c(0.5,0.3,-0.2,0.5),"cm"),
        axis.title.y = element_text(size = 11),#, 
                                    #margin = margin(unit(1, "cm"))),
        panel.margin.y = unit(0.5, "lines"))#,
                      #strip.text = element_text(size = 9))

## analyses reported in legend
anova(MASS::glm.nb(vLG_Platy ~ Genotype, data = tree_level_interaxn_all_plants_traits_size),
      MASS::glm.nb(vLG_Platy ~ 1, data = tree_level_interaxn_all_plants_traits_size))

anova(MASS::glm.nb(vLG_Mesopol ~ Genotype, data = tree_level_interaxn_all_plants_traits_size),
      MASS::glm.nb(vLG_Mesopol ~ 1, data = tree_level_interaxn_all_plants_traits_size))

anova(MASS::glm.nb(vLG_Tory ~ Genotype, data = tree_level_interaxn_all_plants_traits_size),
      MASS::glm.nb(vLG_Tory ~ 1, data = tree_level_interaxn_all_plants_traits_size))

anova(glm(vLG_Tory ~ 1, data = tree_level_interaxn_all_plants_traits_size, family = poisson), glm(vLG_Tory ~ Genotype, data = tree_level_interaxn_all_plants_traits_size, family = poisson), test = "LR")

## tidy up the data for visualizing the differences in leaf gall parasitism among willow genotypes. 
vLG_ptized.df <- as.data.frame(tree_level_interaxn_all_plants_traits_size) %>%
  mutate(vLG_ptized = vLG_Platy + vLG_Tory + vLG_Mesopol + vLG_Eulo + vLG_Mymarid) %>%
  mutate(vLG_prop.ptized = vLG_ptized/vLG_abund, type = "mean") %>%
  select(Genotype, vLG_prop.ptized, vLG_abund, type)

glm.vLG_ptized <- glm(vLG_prop.ptized ~ Genotype, data = vLG_ptized.df, weights = vLG_abund, family = "binomial")
summary(glm.vLG_ptized)
anova(glm.vLG_ptized, test = "LR")

## calculated the weighted mean of leaf gall parasitism on each genotype. I used the number of galls sampled on each replicate willow as the weight, because these will have a more reliable estimate of mean gall size for that willow.
vLG_ptized.df.2 <- vLG_ptized.df %>%
  group_by(Genotype) %>%
  summarise(vLG_prop.ptized = weighted.mean(vLG_prop.ptized, vLG_abund, 
                                            na.rm = TRUE),
            vLG_abund = 12) %>% # point size to use for plotting
  mutate(type = "weighted.mean")

## bind the original and summarized data together, then order the genotypes according to median leaf gall abundance
vLG_ptized.df.3 <- rbind.data.frame(vLG_ptized.df.2, vLG_ptized.df)
vLG_ptized.df.3$Genotype <- factor(vLG_ptized.df.3$Genotype, levels = vLG.df.sum$Genotype)

## plot leaf gall parasitism among willow genotypes. Size of points correspond to weights used to calculated the weighted mean of leaf gall parasitism for each genotype. 
vLG_ptized.plot <- ggplot(vLG_ptized.df.3, aes(x = Genotype, y = vLG_prop.ptized, 
                            size = vLG_abund, fill = type, color = type, shape = type)) +
  geom_point() +
  scale_shape_manual(values = c(1, 23)) + 
  scale_color_manual(values = c(cbPalette[1], "black")) +
  scale_size(range = point.size.range.ptism) +
  scale_fill_manual(values = cbPalette[c(1,7)]) +
  scale_y_continuous(limits = c(-0.1, 1.1), breaks = seq(0,1.0,0.5)) +
  geom_text(data = D.ptism, aes(x = x, y = y, label = labels), 
            inherit.aes = FALSE, size = label.size) + 
  ylab("Prop. of galls parasitized\n") + xlab("Willow genotype") +
  theme_links + 
  theme(plot.margin = unit(c(-0.2,0.95,0.5,0.36),"cm"),
        axis.title.y = element_text(margin = unit(c(10,1,10,3), "pt"),
                                    vjust = 1))#unit(c(-0.2,0.85,0.5,0.5),"cm"))#,
                     # axis.title.y = element_text(size = 11, vjust = 1.25))

# create multipanel figure
link.dom <- ggplot_gtable(ggplot_build(link.dominants.plot))
vLG.ptized <- ggplot_gtable(ggplot_build(vLG_ptized.plot))

maxWidth = unit.pmax(link.dom$widths[2:3], vLG.ptized$widths[2:3])

link.dom$widths[2:3] <- maxWidth
vLG.ptized$widths[2:3] <- maxWidth

# used same plotting dimensions as for gall specificity figure
parasitism_specificity <- arrangeGrob(link.dominants.plot, vLG_ptized.plot, #
                                      ncol = 1, heights = c(7/10, 3/10))
#ggsave("manuscript/figures/fig_4/fig_4_parasitism_specificity_PNAS.png", parasitism_specificity, width = 3.42, height = 5, units = "in")

## Figure 5 ----

## create a focused dataset of how the probability of parasitoid attack of the leaf gall depends on gall size.
attack.df <- as.data.frame(tree_level_interaxn_all_plants_traits_size) %>% 
  filter(vLG.height.mean > 0) %>%
  select(vLG.height.mean, vLG_abund, vLG_Platy, vLG_Mesopol, vLG_Tory) %>%
  gather(vLG.height.mean, vLG_abund)
colnames(attack.df)[3:4] <- c("variable","value")

# double-check analyses
platy <- glm(value/vLG_abund ~ vLG_abund*vLG.height.mean, data = filter(attack.df, variable == "vLG_Platy"), family = 'binomial', weights = vLG_abund)
summary(platy)
anova(platy, test = "Chi")

mesopol <- glm(value/vLG_abund ~ vLG_abund*vLG.height.mean, data = filter(attack.df, variable == "vLG_Mesopol"), family = 'binomial', weights = vLG_abund)
summary(mesopol)
anova(mesopol, test = "Chi")

tory <- glm(value/vLG_abund ~ vLG_abund + vLG.height.mean, data = filter(attack.df, variable == "vLG_Tory"), family = 'binomial', weights = vLG_abund)
summary(tory)
anova(tory, test = "Chi") # be careful with order of main effect

## create a plot showing how both leaf gall abundance and attack rate determine attack rates from individual parasitoid species
attack.df$cut.vLG_abund <- cut(attack.df$vLG_abund, breaks = c(1, 4, 22), include.lowest = TRUE, labels = c("Low leaf gall abundance (1 - 4 per branch)", "High leaf gall abundance (5 - 22 per branch)"))
table(attack.df$cut.vLG_abund, attack.df$variable)

vLG_parasitism_mech <- ggplot(attack.df, aes(x = vLG.height.mean, y = value/vLG_abund, 
                      color = variable, shape = variable, linetype = variable)) + 
  geom_jitter(alpha = 0.25, size = 2, 
              position = position_jitter(height = 0.01, width = 0)) +
  facet_wrap(~ cut.vLG_abund, ncol = 1) +
  geom_smooth(method = "glm", family = binomial, 
              aes(weight = vLG_abund), se = FALSE, size = line.widths) + 
  geom_text(data = AB.ptism, aes(x = x, y = y, label = labels), 
            inherit.aes = FALSE, size = label.size) +
  xlab("Leaf gall diameter (mm)") + ylab("Prop. of galls parasitized") +
  scale_color_manual(values = cbPalette[c(6,4,2)]) + 
  theme_links + theme(axis.text.x = element_text(size = 9))

#ggsave("manuscript/figures/fig_5/fig_5_parasitism_mechanisms_PNAS.png", vLG_parasitism_mech, width = 3.42, height = 5, units = "in") # 6.48

## Figure 6: ordination inset ----

## tidy up full link composition data for ordination of entire food web
full.links.df <- as.data.frame(tree_level_interaxn_all_plants_traits_size) %>%
  select(Genotype, 
         vLG_abund, aSG_abund, rG_abund, SG_abund, # willow-gall links
         vLG_Platy, vLG_Tory, vLG_Mesopol, vLG_Eulo, vLG_Mymarid, # vLG-ptoid links
         rG_Platy, rG_Tory, rG_Mesopol, rG_Eulo, rG_Lestodip, # rG-ptoid links
         SG_Platy, aSG_Tory) # other gall-ptoid links
all.links <- names(full.links.df)[-1]
trees.with.links <- which(rowSums(full.links.df[ ,all.links]) > 0)
table(full.links.df$Genotype[trees.with.links]) # J, N, and U have 2 or less replicates with any links.

full.links.df.sub <- filter(full.links.df[trees.with.links, ], 
                            Genotype != "J",
                            Genotype != "N",
                            Genotype != "U")

## analysis of dissimilarity
adonis(full.links.df.sub[ ,all.links] ~ Genotype, data = full.links.df.sub, distance = "bray")
anova(betadisper(vegdist(full.links.df.sub[ ,all.links], "bray"), full.links.df.sub$Genotype)) # no difference in betadiversity
full.links.meandist <- meandist(vegdist(full.links.df.sub[ ,all.links], "bray"), full.links.df.sub$Genotype)
summary(full.links.meandist) 
mean(full.links.meandist[lower.tri(full.links.meandist, diag = TRUE)]) # eseentially matches summary, may be slightly different due to weightings.
max(full.links.meandist[lower.tri(full.links.meandist, diag = TRUE)])
min(full.links.meandist[lower.tri(full.links.meandist, diag = TRUE)])

## perform RDA analyses and extract centroid scores for plotting.
cap.geno <- capscale(full.links.df.sub[ ,all.links] ~ Genotype, 
                     data = full.links.df.sub,
                     distance = "bray")
summary(cap.geno)
centroids.cap.geno <- data.frame(scores(cap.geno, choices = c(1,2), display = "cn"))
rownames(centroids.cap.geno) <- levels(full.links.df$Genotype)[-c(10,14,21)] # remove Genotypes J, N, and U
centroids.cap.geno$Genotype <- rownames(centroids.cap.geno)

sites.cap.geno <- data.frame(scores(cap.geno, choices = c(1,2), display = "sites"), droplevels(full.links.df.sub$Genotype))
colnames(sites.cap.geno)[3] <- "Genotype"

#plot.new() # need to call this for ordiellipse function to work
#ellip <- ordiellipse(cap.geno, groups = full.links.df.sub$Genotype, 
 #           kind = "se", draw = "polygon", #Note that by specificying the kind of ellipse in ordiellipse will make sure the type of ellipse you want is drawn (e.g. standard error or 95% CI)
  #          col= "gray50", #"gainsboro", 
   #         border = NA, label = T)


## ggplot2 ordination plot ----
# function for ellipses: taken from the excellent stackoverflow Q+A: http://stackoverflow.com/questions/13794419/plotting-ordiellipse-function-from-vegan-package-onto-nmds-plot-created-in-ggplot2. Another useful reference was https://oliviarata.wordpress.com/2014/04/17/ordinations-in-ggplot2/
veganCovEllipse <- function (cov, center = c(0, 0), scale = 1, npoints = 100) 
{
  theta <- (0:npoints) * 2 * pi/npoints
  Circle <- cbind(cos(theta), sin(theta))
  t(center + scale * t(Circle %*% chol(cov)))
}

# data for ellipse. 
df_ell.cap.geno <- data.frame() #sets up a data frame before running the function.
for(g in levels(sites.cap.geno$Genotype)){
  df_ell.cap.geno <- rbind(df_ell.cap.geno, 
                           cbind(as.data.frame(
                             with(sites.cap.geno[sites.cap.geno$Genotype == g, ], 
                                  veganCovEllipse(ellip[[g]]$cov, ellip[[g]]$center, ellip[[g]]$scale))), Genotype = g))
}

#B.compliment <- data.frame(x = -2.925, y = 2.4, labels = "(B)") # plot label

compliment <- ggplot(data = df_ell.cap.geno, aes(x = CAP1, y = CAP2, group = Genotype)) +
  coord_fixed(ratio = 1) + #, xlim= c(-3.3,3.3)) + #xlim = c(-3,3.2)
  geom_polygon(color = NA, fill = "gray50", alpha = 0.5) + # didn't use stat_ellipse because I wanted to plot standard errors instead of 95% confidence intervals
  geom_text(data = centroids.cap.geno, 
            aes(x = CAP1, y = CAP2, label = Genotype), size = 2) +
  #scale_x_continuous(limits = c(-3,2)) +
  #geom_text(data = B.compliment, aes(x = x, y = y, label = labels), 
  #          inherit.aes = FALSE, size = 4) +
  theme_bw() + 
  theme(axis.text.y = element_text(size = 6),#10
        axis.text.x = element_text(size = 6),#10
        axis.title.x = element_text(size = 8, vjust = 0.75),#vjust = 0.1, 
        axis.title.y = element_text(size = 8, vjust = 0.25),#vjust = 0.5, 
        panel.grid = element_blank(),
        plot.margin = unit(c(0,0,0,0), "in"))
# adjust plot.margin

vp <- viewport(width = 0.35, height = 0.35, x = 0.75, y = 0.32) #viewport(width = 0.4, height = 0.4, x = 0.7, y = 0.35)

tiff("manuscript/figures/fig_6/fig_6_complexity_complimentarity.tiff", width = 3.42, height = 4, units = "in", res = 600)
print(total) # need to run simulation plot first.
print(compliment, vp = vp)
dev.off() # turn off device

# create multipanel figure ----
complexity <- ggplotGrob(total)#ggplot_gtable(ggplot_build(total))
complimentarity <- ggplotGrob(compliment)#ggplot_gtable(ggplot_build(compliment))

maxWidth = unit.pmax(complexity$widths[2:3], complimentarity$widths[2:3])

complexity$widths[2:3] <- maxWidth
complimentarity$widths[2:3] <- maxWidth

# used same plotting dimensions as for gall specificity figure
grid.arrange(complexity,complimentarity, ncol = 1)

complex_compliment <- arrangeGrob(complexity, complimentarity, ncol = 1)

ggsave("manuscript/figures/fig_6/fig_6_complexity_complimentarity_PNAS.png", complex_compliment, width = 3.42, height = 5, units = "in")
#dev.off() # turn off png device

## Fig. 1: skeletons ----

## Create metaweb
gall.ptoid <- as.data.frame(tree_level_interaxn_all_plants_traits_size) %>%
  dplyr::select(aSG_Tory:rG_Platy, rG_Tory, SG_Platy, vLG_Eulo:vLG_Tory) %>%
  summarise_each(funs(sum)) %>%
  gather(variable) %>%
  separate(col = variable, into = c("lower","upper"), sep = "_")

willow.gall <- as.data.frame(tree_level_interaxn_all_plants_traits_size) %>%
  dplyr::select(aSG_abund:SG_abund) %>%
  summarise_each(funs(sum)) %>%
  gather(variable) %>%
  separate(col = variable, into = c("upper","lower"), sep = "_") %>%
  mutate(lower = "willow") %>%
  dplyr::select(lower, upper, value)

metaweb <- rbind(willow.gall, gall.ptoid) 

# turn into graph
metaweb.graph <- graph.edgelist(as.matrix(metaweb)[,1:2])
E(metaweb.graph)$weight <- metaweb$value

metaweb.adj <- get.adjacency(metaweb.graph, sparse = F, attr = "weight")

metaweb.info <- tripartite_plot_info(metaweb.graph)

interaction.df <- metaweb.info[[1]] %>%
  mutate(x = as.numeric(x), y = as.numeric(y)) %>%
  filter(Sequence == 500 | Sequence == 1) %>%
  reshape(idvar = "Group", timevar = "Sequence", direction = "wide") %>%
  mutate(weight.trans = Weight.1) # unscaled weights

max.interaction.strength <- max(interaction.df$weight.trans)

nodeinfo.df <- metaweb.info[[2]]

## create theme for food web graphs
new_theme_empty <- theme_bw()
new_theme_empty$line <- element_blank()
new_theme_empty$rect <- element_blank()
new_theme_empty$strip.text <- element_blank()
new_theme_empty$axis.text <- element_blank()
new_theme_empty$plot.title <- element_blank()
new_theme_empty$axis.title <- element_blank()
new_theme_empty$plot.margin <- structure(c(2, 2, 2, 2), unit = "lines", 
                                         valid.unit = 3L, class = "unit")


metaweb.plot <- ggplot(interaction.df) + 
  geom_segment(data = interaction.df, aes(x = x.1, xend = x.500, y = y.1, yend = y.500),
               color = "grey",
               size = interaction.df$weight.trans/max.interaction.strength*25,
               alpha = 0.75)  +
  new_theme_empty + 
  geom_point(data = nodeinfo.df, aes(x = x, y = y, fill = vertex.names),
             color = "black",
             size = 1, show_guide = FALSE) 

#Code to override clipping
metaweb.plot
gt <- ggplot_gtable(ggplot_build(metaweb.plot))
gt$layout$clip[gt$layout$name == "panel"] <- "off"
grid.draw(gt)

## Genotype subweb plots
max.genotype.sub.web <- 60

## Create web for Genotype Q
gall.ptoid.Q <- as.data.frame(tree_level_interaxn_all_plants_traits_size) %>%
  filter(Genotype == "Q") %>%
  dplyr::select(aSG_Tory:rG_Platy, rG_Tory, SG_Platy, vLG_Eulo:vLG_Tory) %>%
  summarise_each(funs(sum)) %>%
  gather(variable) %>%
  separate(col = variable, into = c("lower","upper"), sep = "_")

willow.gall.Q <- as.data.frame(tree_level_interaxn_all_plants_traits_size) %>%
  filter(Genotype == "Q") %>%
  dplyr::select(aSG_abund:SG_abund) %>%
  summarise_each(funs(sum)) %>%
  gather(variable) %>%
  separate(col = variable, into = c("upper","lower"), sep = "_") %>%
  mutate(lower = "willow") %>%
  dplyr::select(lower, upper, value)

metaweb.Q <- rbind(willow.gall.Q, gall.ptoid.Q) %>%
  filter(value > 0)

# turn into graph
metaweb.graph.Q <- graph.edgelist(as.matrix(metaweb.Q)[,1:2])
E(metaweb.graph.Q)$weight <- metaweb.Q$value

metaweb.adj.Q <- get.adjacency(metaweb.graph.Q, sparse = F, attr = "weight")

metaweb.info.Q <- tripartite_plot_info(metaweb.graph.Q)

interaction.df.Q <- metaweb.info.Q[[1]] %>%
  mutate(x = as.numeric(x), y = as.numeric(y)) %>%
  filter(Sequence == 500 | Sequence == 1) %>%
  reshape(idvar = "Group", timevar = "Sequence", direction = "wide") %>%
  mutate(weight.trans = Weight.1) # unscaled weights

nodeinfo.df.Q <- metaweb.info.Q[[2]]

metaweb.plot.Q <- ggplot(interaction.df.Q) + 
  geom_segment(data = interaction.df.Q, aes(x = x.1, xend = x.500, y = y.1, yend = y.500),
               color = "grey",
               size = interaction.df.Q$weight.trans/max.genotype.sub.web*25,
               alpha = 0.75)  +
  new_theme_empty + 
  geom_point(data = nodeinfo.df.Q, aes(x = x, y = y, fill = vertex.names),
             color = "black",
             size = 1, show_guide = FALSE) 

#Code to override clipping
metaweb.plot.Q
gt.Q <- ggplot_gtable(ggplot_build(metaweb.plot.Q))
gt.Q$layout$clip[gt.Q$layout$name == "panel"] <- "off"
grid.draw(gt.Q)


## Create web for Genotype K
gall.ptoid.K <- as.data.frame(tree_level_interaxn_all_plants_traits_size) %>%
  filter(Genotype == "K") %>%
  dplyr::select(aSG_Tory:rG_Platy, rG_Tory, SG_Platy, vLG_Eulo:vLG_Tory) %>%
  summarise_each(funs(sum)) %>%
  gather(variable) %>%
  separate(col = variable, into = c("lower","upper"), sep = "_")

willow.gall.K <- as.data.frame(tree_level_interaxn_all_plants_traits_size) %>%
  filter(Genotype == "K") %>%
  dplyr::select(aSG_abund:SG_abund) %>%
  summarise_each(funs(sum)) %>%
  gather(variable) %>%
  separate(col = variable, into = c("upper","lower"), sep = "_") %>%
  mutate(lower = "willow") %>%
  dplyr::select(lower, upper, value)

metaweb.K <- rbind(willow.gall.K, gall.ptoid.K) %>%
  filter(value > 0)

# turn into graph
metaweb.graph.K <- graph.edgelist(as.matrix(metaweb.K)[,1:2])
E(metaweb.graph.K)$weight <- metaweb.K$value

metaweb.adj.K <- get.adjacency(metaweb.graph.K, sparse = F, attr = "weight")

metaweb.info.K <- tripartite_plot_info(metaweb.graph.K)

interaction.df.K <- metaweb.info.K[[1]] %>%
  mutate(x = as.numeric(x), y = as.numeric(y)) %>%
  filter(Sequence == 500 | Sequence == 1) %>%
  reshape(idvar = "Group", timevar = "Sequence", direction = "wide") %>%
  mutate(weight.trans = Weight.1) # unscaled weights

nodeinfo.df.K <- metaweb.info.K[[2]]

metaweb.plot.K <- ggplot(interaction.df.K) + 
  geom_segment(data = interaction.df.K, aes(x = x.1, xend = x.500, y = y.1, yend = y.500),
               color = "grey",
               size = interaction.df.K$weight.trans/max.genotype.sub.web*25,
               alpha = 0.75)  +
  new_theme_empty + 
  geom_point(data = nodeinfo.df.K, aes(x = x, y = y, fill = vertex.names),
             color = "black",
             size = 1, show_guide = FALSE) 

#Code to override clipping
metaweb.plot.K
gt.K <- ggplot_gtable(ggplot_build(metaweb.plot.K))
gt.K$layout$clip[gt.K$layout$name == "panel"] <- "off"
grid.draw(gt.K)


## Create web for Genotype Y
gall.ptoid.Y <- as.data.frame(tree_level_interaxn_all_plants_traits_size) %>%
  filter(Genotype == "Y") %>%
  dplyr::select(aSG_Tory:rG_Platy, rG_Tory, SG_Platy, vLG_Eulo:vLG_Tory) %>%
  summarise_each(funs(sum)) %>%
  gather(variable) %>%
  separate(col = variable, into = c("lower","upper"), sep = "_")

willow.gall.Y <- as.data.frame(tree_level_interaxn_all_plants_traits_size) %>%
  filter(Genotype == "Y") %>%
  dplyr::select(aSG_abund:SG_abund) %>%
  summarise_each(funs(sum)) %>%
  gather(variable) %>%
  separate(col = variable, into = c("upper","lower"), sep = "_") %>%
  mutate(lower = "willow") %>%
  dplyr::select(lower, upper, value)

metaweb.Y <- rbind(willow.gall.Y, gall.ptoid.Y) %>%
  filter(value > 0)

# turn into graph
metaweb.graph.Y <- graph.edgelist(as.matrix(metaweb.Y)[,1:2])
E(metaweb.graph.Y)$weight <- metaweb.Y$value

metaweb.adj.Y <- get.adjacency(metaweb.graph.Y, sparse = F, attr = "weight")

metaweb.info.Y <- tripartite_plot_info(metaweb.graph.Y)


interaction.df.Y <- metaweb.info.Y[[1]] %>%
  mutate(x = as.numeric(x), y = as.numeric(y)) %>%
  filter(Sequence == 500 | Sequence == 1) %>%
  reshape(idvar = "Group", timevar = "Sequence", direction = "wide") %>%
  mutate(weight.trans = Weight.1) # unscaled weights

nodeinfo.df.Y <- metaweb.info.Y[[2]]

metaweb.plot.Y <- ggplot(interaction.df.Y) + 
  geom_segment(data = interaction.df.Y, aes(x = x.1, xend = x.500, y = y.1, yend = y.500),
               color = "grey",
               size = interaction.df.Y$weight.trans/max.genotype.sub.web*25,
               alpha = 0.75)  +
  new_theme_empty + 
  geom_point(data = nodeinfo.df.Y, aes(x = x, y = y, fill = vertex.names),
             color = "black",
             size = 1, show_guide = FALSE) 

#Code to override clipping
metaweb.plot.Y
gt.Y <- ggplot_gtable(ggplot_build(metaweb.plot.Y))
gt.Y$layout$clip[gt.Y$layout$name == "panel"] <- "off"
grid.draw(gt.Y)

