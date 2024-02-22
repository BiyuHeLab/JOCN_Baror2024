library(tidyverse)
library(readxl)
library(glue)
library(ggtext)
library(ggplot2)
install.packages("RColorBrewer")     
library(RColorBrewer)
display.brewer.all(colorblindFriendly = TRUE)
install.packages("viridis")  # Install
library("viridis")
install.packages("wesanderson")
library(wesanderson)
names(wes_palettes)


# Figure 1C
ggplot(Fig1C_behavior_Fixed, aes(x=ImageCondition, y=ViewingDuration, fill=Category))+ 
  geom_boxplot(width=0.5,draw_quantiles = c(0.25, 0.5, 0.75), outlier.shape=NA)+
  geom_jitter(width = .05, aes(fill = Category), shape = 21)+
  facet_grid(.~Category)+
  scale_fill_manual(values = c("royalblue", "chartreuse2"))+
  scale_color_manual(values = c("royalblue", "chartreuse2"))+
  coord_cartesian(ylim = c(0, 10000)) +
  labs(title='Fixed Dataset')+
  theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+
  theme(text = element_text(size = 20))+
  theme(axis.text.x = element_text(size = 8))


ggplot(Fig1C_behavior_Random, aes(x=ImageCondition, y=ViewingDuration, fill=Category))+ 
  geom_boxplot(width=0.5,draw_quantiles = c(0.25, 0.5, 0.75), outlier.shape=NA)+
  geom_jitter(width = .05, aes(fill = Category), shape = 21)+
  facet_grid(.~Category)+
  scale_fill_manual(values = c("royalblue", "chartreuse2"))+
  scale_color_manual(values = c("royalblue", "chartreuse2"))+
  coord_cartesian(ylim = c(0, 10000)) +
  labs(title='Random Dataset')+
  theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+
  theme(text = element_text(size = 20))+
  theme(axis.text.x = element_text(size = 8))


# Figure 1D
ggplot(Fig1D_orderPrecentiles, aes(x = Order_inPrecentiles, y = ViewingDuration, colour= Dataset, fill=Dataset)) +
  geom_line(colour = "black") +
  geom_ribbon(aes(ymin = ViewingDuration - sem,
                  ymax = ViewingDuration + sem), alpha = 0.7)+
  coord_cartesian(ylim = c(0, 6000)) +
  scale_fill_manual(values=c("#999999", "#E69F00"))+
  scale_colour_manual(values=c("#999999", "#E69F00"))+
  theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+
  theme(text = element_text(size = 20))

ggplot(Fig1D_corWorder, aes(x=Dataset, y=SpearmanRho, fill=Dataset))+ 
  geom_boxplot(width=0.5,draw_quantiles = c(0.25, 0.5, 0.75), outlier.shape=NA)+
  geom_jitter(width = .1, aes(fill = Dataset), shape = 21)+
  geom_hline(yintercept=0, show.legend = FALSE)+
  coord_cartesian(ylim = c(-1, 1)) +
  scale_fill_manual(values=c("#999999", "#E69F00"))+
  scale_color_manual(values=c("#999999", "#E69F00"))+
  theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+
  theme(text = element_text(size = 20))+   
  theme(axis.text.x = element_text(size = 18))

# Figure 1E
ggplot(Fig1E_viewDurByFixed, aes(x = ViewingDuration_FixedDataset , y = ViewingDuration, fill=Dataset)) +
  facet_grid(.~category)+
  coord_cartesian(ylim = c(0, 6000)) +
  geom_line(colour = "black") +
  geom_ribbon(aes(ymin = ViewingDuration - sem,
                  ymax = ViewingDuration + sem), alpha = 0.7, show.legend = FALSE)+
  scale_fill_manual(values=c("#999999", "#E69F00"))+
  theme_bw() + theme(panel.border =  element_blank(), panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+
  theme(text = element_text(size = 20))


## Figure 4 B top    
ggplot(Fig4B_r_tfResults, aes(x=range, y=RHO, fill=condition))+ 
  geom_boxplot(aes(col = condition),outlier.shape=NA, width=0.5)+
  geom_jitter(width = .1, aes(fill = condition), shape = 21)+
  #geom_jitter(aes(col = condition,fill=condition), alpha = 0.7, width = 0.05)+
  #geom_point(position=position_jitterdodge())+
  coord_cartesian(ylim = c(-0.5, 0.5)) +
  geom_hline(yintercept=0)+
  scale_fill_manual(values = c("turquoise", "steelblue4"))+
  scale_color_manual(values = c("turquoise4", "midnightblue"))+
  #scale_fill_manual(values = c("Plum", "orchid4"))+
  #scale_color_manual(values = c("Plum4", "gray29"))+
  theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                     panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+
  theme(text = element_text(size = 14))


## Figure 5 B bottom
    ggplot(Fig5B_r_pupilSizeResults, aes(x=timePoint, y=R, fill=condition))+ 
      geom_boxplot(aes(col = condition),outlier.shape=NA, width=0.5)+
      geom_jitter(width = .1, aes(fill = condition), shape = 21)+
      #geom_jitter(aes(col = condition,fill=condition), alpha = 0.7, width = 0.05)+
      #geom_point(position=position_jitterdodge())+
      coord_cartesian(ylim = c(-0.8, 0.8)) +
      geom_hline(yintercept=0)+
      scale_fill_manual(values = c("Plum", "orchid4"))+
      scale_color_manual(values = c("Plum4", "gray29"))+
      
      theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                         panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+
        theme(text = element_text(size = 14))
    

#Figure 5c
    #Residuals
    ggplot(Fig5C_partialCorrelationsForR, aes(x=Residuals, y=Pearson)) + 
      geom_bar(stat="identity", color="black",width = 0.4, 
               position=position_dodge(0.7)) +
      scale_fill_manual(values = brewer.pal(n = 3, name = "PuRd"))+
      coord_cartesian(ylim = c(-0.4, 0.4)) +
      geom_hline(yintercept=0)+
      geom_errorbar(aes(ymin=Pearson-semPearson, ymax=Pearson+semPearson), width=.1,
                    position=position_dodge(.7))+ 
      theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                         panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+
      theme(text = element_text(size = 10)) 
    
    #SerialOrder
    ggplot(Fig5C_partialCorrelationsForR, aes(x=SerialOrder, y=Spearman)) + 
      geom_bar(stat="identity", color="black",width = 0.4, 
               position=position_dodge(0.7)) +
      scale_fill_manual(values = brewer.pal(n = 3, name = "PuRd"))+
      coord_cartesian(ylim = c(-0.4, 0.4)) +
      geom_hline(yintercept=0)+
      geom_errorbar(aes(ymin=Spearman-semSpearman, ymax=Spearman+semSpearman), width=.1,
                    position=position_dodge(.7))+ 
      theme_bw() + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                         panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))+
      theme(text = element_text(size = 10)) 
    
