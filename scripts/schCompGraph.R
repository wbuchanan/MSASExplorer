schCompGraph <- function(data = wgtGraphData(), userWgt = TRUE) {
    
  browser()
  
    if (userWgt == TRUE) {
        
        compgraph <-                                                           #
                    ggplot(data, aes(x = ngrade, fill = ngrade)) +             #
                    geom_bar() + facet_wrap(~distsch, nrow = 1) +              #
                        labs(x = "Performance Classifiers", 
                            y = "# of Schools/Districts", 
                            title = "User-Selected Component Weights") +       #
                    scale_fill_manual(values = c("#0000FF", "#00FF00", 
                        "#FFFF00", "#FFA500", "#FF0000"), 
                        breaks = c("A", "B", "C", "D", "F"), 
                        name = "Accountability \nGrades") +                    #
                    theme(panel.background = element_rect(fill = "white"),                 
                        strip.text = element_text(size = 16), 
                        legend.title = element_text(size = 16), 
                        legend.text = element_text(size = 16),
                        plot.title = element_text(size = 24),
                        axis.text.x = element_text(size = 12, color = "black"),
                        axis.text.y = element_text(size = 12, color = "black"), 
                        axis.title.x = element_text(size = 20, color = "black"),
                        axis.title.y = element_text(size = 20, color = "black"))
    } else {
        
        compgraph <-                                                           #
                    ggplot(data, aes(x = schwaivedgrade, fill = schwaivedgrade)) +         #
                    geom_bar() + facet_wrap(~distsch, nrow = 1) +              #
                    labs(x = "Performance Classifiers", 
                        y = "# of Schools/Districts", 
                        title = "Approved Component Weights") +                #
                    scale_fill_manual(values = c("#0000FF", "#00FF00", 
                        "#FFFF00", "#FFA500", "#FF0000"), 
                        breaks = c("A", "B", "C", "D", "F"), 
                        name = "Accountability \nGrades") +                    #
                    theme(panel.background = element_rect(fill = "white"),                 
                        strip.text = element_text(size = 16), 
                        legend.title = element_text(size = 16), 
                        legend.text = element_text(size = 16),
                        plot.title = element_text(size = 24),
                        axis.text.x = element_text(size = 12, color = "black"),
                        axis.text.y = element_text(size = 12, color = "black"), 
                        axis.title.x = element_text(size = 20, color = "black"),
                        axis.title.y = element_text(size = 20, color = "black"))
    }
    
    return(compgraph)
}