if (smooth == TRUE) {
    theGraph <-   theData %>% #
        ggvis(x = ~x, y = ~y) %>% #
        layer_model_predictions(model = "lm", 
                                se = TRUE, stroke := "black") %>% #
        layer_points(key := ~id, fill = ~color, 
                     opacity := alpha, 
                     size := ~wgt) %>% #
        add_tooltip(values, "hover") %>% #
        scale_nominal("fill", domain = colorScale) %>% #
        add_axis("x", title = xlabel, title_offset = 50,  
                 properties = axis_props(
                     labels = list(fontSize = 14),
                     title = list(fontSize = 18))) %>% #
        add_legend("fill", title = legendTitle, 
                   properties = legend_props(
                       labels = list(fontSize = 14),
                       title = list(fontSize = 12),
                       symbols = list(size = 25))) %>%
        add_axis("y", title = ylabel, title_offset = 50, 
                 properties = axis_props(
                     labels = list(fontSize = 14),
                     title = list(fontSize = 18)))
    
} else {
    theGraph <- theData %>% #
        ggvis(x = ~x, y = ~y) %>% #
        layer_points(key := ~id, fill = ~color,
                     opacity := alpha, size := ~wgt) %>% #
        add_tooltip(values, "hover") %>% #
        scale_nominal("fill", domain = colorScale) %>% #
        add_axis("x", title = xlabel,  title_offset = 50, 
                 properties = axis_props(
                     labels = list(fontSize = 14),
                     title = list(fontSize = 18))) %>% #
        add_legend("fill", title = legendTitle, 
                   properties = legend_props(
                       labels = list(fontSize = 14),
                       title = list(fontSize = 12),
                       symbols = list(size = 25)))  %>%
        add_axis("y", title = ylabel, title_offset = 50, 
                 properties = axis_props(
                     labels = list(fontSize = 14),
                     title = list(fontSize = 18)))  
} 