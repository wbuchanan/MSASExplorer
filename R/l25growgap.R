l25growgap <- function( data, 
                        distFilter = NULL, 
                        schFilter = NULL, 
                        alphaPt = .5, 
                        reg = TRUE, 
                        wgt = NULL, 
                        low25district = FALSE, 
                        l25bars = NULL, 
                        subzoom = NULL) {
    
    # Label the low 25% group indicator
    low25gap$schlow25 <- factor(as.character(low25gap$schlow25), 
        levels = c("0", "1"), 
        labels = c("Not in the Lowest 25%", 
            "In the Lowest 25%"))
    
    if (data == "dist" & low25district == FALSE) {
        
        low25xy <- subset(low25gap, low25gap$sch == "001")
        
    } else if (data == "sch" & low25district == FALSE) {
        
        low25xy <- subset(low25gap, low25gap$sch != "001")
        
    } 

    if (low25district) low25Data <- subset(low25gap, schlow)
    
    if (!is.null(distFilter)) low25xy <- subset(low25xy, low25xy$distid %in% distFilter)
     
    if (!is.null(schFilter)) low25xy <- subset(low25xy, low25xy$schid %in% schFilter)

    if (!is.null(subzoom)) low25xy <- subset(low25xy, low25xy$group == subzoom)
    
    if (!(low25district)) {

    # Create version of the data with all missing values removed for scatter plots
    low25xy <- na.omit(low25xy)
        
    # Generate a key variable
    low25xy$id <- 1:nrow(low25xy)
    
    # Tool tip contents
    #l25schname <- function(x){
    #                if (is.null(x)) return(NULL)
    #                row <- low25xy[low25xy$id == x$id, ]
    #                tip <- paste0("District : ", row[, 11], "<br />",
    #                    "School : ", row[, 12], "<br />",
    #                    "Low 25% ID: ", row[, 10], "<br />")
    #            }
        
    # Method for scatterplots
    low25xy %>% group_by(schlow25, add = TRUE) %>% #
            ggvis(x = ~schgrolrla, y = ~schgrolmth) %>% #
            layer_model_predictions(model = "lm", se = TRUE, fill = ~schlow25, 
                fillOpacity := .5, strokeOpacity := .7, strokeWidth := 1.5, 
                stroke := "black") %>% hide_legend("fill") %>% #
            layer_points(key := ~id, fill = ~schlow25, opacity := alpha, 
                stroke := "black", size = ~wgt, shape = ~schlow25) %>% #
            hide_legend("size") %>% #
            #add_tooltip(l25schname, "hover") %>% #
            add_axis("x", title = "Low 25% Growth in Reading/Language Arts", 
                title_offset = 50, layer = "back", grid = FALSE, 
                properties = axis_props(labels = 
                        list(fontSize = 12, fill = "black"),
                title = list(fontSize = 16))) %>% hide_legend("size") %>% #
            add_legend(c("fill", "shape"), title = "", 
                properties = legend_props(
                    labels = list(fontSize = 14), 
                    title = list(fontSize = 12), 
                    symbols = list(size = 50))) %>% #
            add_axis("y", title = "Low 25% Growth in Math", title_offset = 50, 
                layer = "back", grid = FALSE, 
                properties = axis_props(
                    labels = list(fontSize = 12, fill = "black"),
                    title = list(fontSize = 16)))         
        
    }

    else {
        
        # Need to get the variable label for the x-axis variable as well
        xl25label <- l25labs[[l25bars]]
                
        # Rename the variable that will be graphed
        names(low25Data)[names(low25Data) == l25bars] <- "l25bar"
        
        # Method for bar graphs for schools within a district
        low25Data %>% filter(distid == low25district) %>% #
            group_by(schlow25, add = TRUE) %>% #
            ggvis(y = ~schnm, x = ~l25bar) %>% #
            layer_rects(x2 = 0, height = band(), 
                fill.update = ~schlow25, fill.hover := "white") %>% #
            add_axis("y", title = "", grid = FALSE, 
                properties = axis_props(labels = 
                        list(fontSize = 12, fill = "black"))) %>% #
            scale_nominal("y", reverse = FALSE, sort = TRUE, padding = .15) %>% #
            add_legend("fill", title = "", properties = 
                legend_props(labels = list(fontSize = 14), 
                symbols = list(size = 50))) %>% #
            add_axis("x", title = xl25label, 
                title_offset = 50, layer = "back", grid = TRUE, 
                properties = axis_props(labels = list(fontSize = 12, 
                    fill = "black"), title = list(fontSize = 16)))
        
    }

 }

