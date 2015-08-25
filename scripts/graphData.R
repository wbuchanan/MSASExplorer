graphData <- function(data = NULL, x = NULL, y = NULL, dist = "", 
                      sch = NULL, smooth = FALSE, alpha = .85, filter = FALSE, 
                      wgt = FALSE, color = ""){
        
    # Clone the data frame & make copies of x and y parameters
    theData <- data; xcopy <- x; ycopy <- y;
    
    # Define the function values which is used to build out the tool tip
    values <- function(x){
        if (is.null(x)) return(NULL)
        labs <- theData[theData$id == x$id, ]
        tip <- paste( #
            "District : ", labs[, 2], "<br />",
            "School : ", labs[, 3], "<br />",
            "<table>",
            "<tr>", 
            "<td>", " ", "</td>", 
            "<td>", "Grade : ", "</td>", 
            "<td>", labs[, 5], "</td>", 
            "<td>", "Total Points : ", "</td>", 
            "<td>", labs[, 6], "</td>", 
            "</tr>",  
            "<tr>", 
            "<td>"," ", "</td>", 
            "<td>", "Reading", "</td>", 
            "<td>", "Math", "</td>", 
            "<td>", "Science", "</td>", 
            "<td>", "US History", "</td>", 
            "</tr>",
            "<tr>", 
            "<td>", "Proficiency", "</td>", 
            "<td>", labs[, 7], "</td>", 
            "<td>", labs[, 8], "</td>", 
            "<td>", labs[, 9], "</td>",
            "<td>", labs[, 10], "</td>", 
            "</tr>",  
            "<tr>",
            "<td>", "Growth All", "</td>",  
            "<td>", labs[, 11], "</td>",  
            "<td>", labs[, 12], "</td>",  
            "<td>", "Graduation Rate", "</td>",  
            "<td>", "Participation Rate", "</td>", 
            "</tr>", 
            "<tr>",
            "<td>", "Growth Low 25%", "</td>",  
            "<td>", labs[, 13], "</td>",  
            "<td>", labs[, 14], "</td>",              
            "<td>", labs[, 15], "</td>",  
            "<td>", labs[, 16], "</td>", 
            "</tr>",
            "</table>")
    }
    
    # Function to generate scaled weights for scatterplots
    makeWeights <- function(x, y, base = 125){
        
        weightVars <- list(schtotpts = "schpartden", schtotpts_rank = "schpartden", 
                           schprorla = "schprorladen", schprorla_rank = "schprorladen", 
                           schpromth = "schpromthden", schpromth_rank = "schpromthden", 
                           schprosci = "schprosciden", schprosci_rank = "schprosciden", 
                           schprohis = "schprohisden", schprohis_rank = "schprohisden", 
                           schgrorla = "metrladens", schgrorla_rank = "metrladens", 
                           schgromth = "metmthdens", schgromth_rank = "metmthdens", 
                           schgrolrla = "metrladensl25", 
                           schgrolrla_rank = "metrladensl25", 
                           schgrolmth = "metmthdensl25", 
                           schgrolmth_rank = "metmthdensl25", 
                           schgrad = "denominator", schgrad_rank = "denominator")
        
        # Get x and y weight variable
        names(theData)[names(theData) == weightVars[[x]]] <<- "xwgt"
        names(theData)[names(theData) == weightVars[[y]]] <<- "ywgt"
        
        # Scale the two variables and multiply by the base
        wgt <- scale(as.matrix(theData$xwgt, theData$ywgt), center = FALSE) 
        
        # Add weight variable back to data frame
        theData$wgt <<- wgt * base
        
    }
    
    # Create color scales
    colscales <- list(list("#000000"), 
                      list(c("#377eb8", "#ff7f00")),
                      list(c("#1b9e77", "#d95f02", "#7570b3")),
                      list(c("#e41a1c", "#377eb8", "#4daf4a", "#984ea3")),
                      list(c("#e41a1c", "#377eb8", "#4daf4a", 
                                      "#984ea3", "#ff7f00")), 
                      list(c("#1b9e77", "#d95f02", "#7570b3", "#e7298a", 
                             "#66a61e", "#e6ab02")), 
                      list(c("#1b9e77", "#d95f02", "#7570b3", "#e7298a", 
                             "#66a61e", "#e6ab02", "#a6761d")), 
                      list(c("#1b9e77", "#d95f02", "#7570b3", "#e7298a", 
                             "#66a61e", "#e6ab02", "#a6761d", "#666666")), 
                      list(c("#1b9e77", "#d95f02", "#7570b3", "#e7298a", 
                             "#66a61e", "#e6ab02", "#a6761d", "#666666")))
    
    # Create size weights for points
    if (wgt == TRUE) {
        makeWeights(x = xcopy, y = ycopy)
    } else {
        theData$wgt <- 60
    }
    
    # Get legend title
    legendTitle <- axlabels[[color]]
    
    # Get X-axis & Y-axis labels
    xlabel <- axlabels[[x]]; ylabel <- axlabels[[y]]
    
    
    # If the x and y variable are the same clone the x variable to create y
    if (x != y) {
        
        # Rename the variables that will be graphed
        names(theData)[names(theData) == x] <- "x"
        names(theData)[names(theData) == y] <- "y"
        
    } else {
         
        # Rename the variables that will be graphed
        names(theData)[names(theData) == x] <- "x"
        
        # Clone the x variable in y
        theData[, "y"] <- theData[,"x"]
        
    }  
    
    
    if (filter == TRUE & (((!is.null(color) | !is.na(color)) & color != ""))) {
                
        # Rename the filtering variable
        names(theData)[names(theData) == color] <- "color"        
        
        # Remove cases from the data where the x and/or y axes are missing
        theData <- subset(theData, !is.na(theData$x) & !is.na(theData$y) & 
                              !is.na(theData$color))
        
        # Set a variable to identify the correct corresponding color scale
        colorScale <- colscales[[length(unique(theData$color))]]
        
    } else {
        
        # Remove cases from the data where the x and/or y axes are missing
        theData <- subset(theData, !is.na(theData$x) & !is.na(theData$y)) 
        theData$color <- ""
        colorScale <- colscales[[1]]
                              
    }    
    
    theData$color <- factor(theData$color)
    
    # Create an ID variable that will be used to identify points for the tool tip
    theData$id <- theData$schid
    
     
    if (smooth == TRUE) {
        theGraph <-   theData %>% #
            ggvis(x = ~x, y = ~y) %>% #
            layer_model_predictions(model = "lm", se = TRUE, fill := "bisque4", 
            fillOpacity := .65, strokeWidth := 2.5, stroke := "chartreuse") %>% #
            layer_points(key := ~id, fill = ~color, opacity := alpha, 
                         size := ~wgt, shape = ~distsch) %>% #
            add_tooltip(values, "hover") %>% #
            add_axis("x", title = xlabel, title_offset = 50, 
                     layer = "back", grid = FALSE, 
                     properties = axis_props(
                         labels = list(fontSize = 12, fill = "black"),
                         title = list(fontSize = 16))) %>% #
            add_legend("fill", title = legendTitle, 
                        properties = legend_props(
                            labels = list(fontSize = 14),
                            title = list(fontSize = 12),
                            symbols = list(size = 25))) %>% #
            add_axis("y", title = ylabel, title_offset = 50, 
                     layer = "back", grid = FALSE, 
                     properties = axis_props(
                         labels = list(fontSize = 12, fill = "black"),
                         title = list(fontSize = 16)))
        
    } else {
        theGraph <- theData %>% #
            ggvis(x = ~x, y = ~y) %>% #
            layer_points(key := ~id, fill = ~color, shape = ~distsch,
                         opacity := alpha, size := ~wgt) %>% #
            add_tooltip(values, "hover") %>% #
            add_axis("x", title = xlabel, title_offset = 50, 
                     layer = "back", grid = FALSE, 
                     properties = axis_props(
                         labels = list(fontSize = 12, fill = "black"),
                         title = list(fontSize = 16))) %>% #
            add_legend("fill", title = legendTitle, 
                       properties = legend_props(
                           labels = list(fontSize = 14),
                           title = list(fontSize = 12),
                           symbols = list(size = 25)))  %>%
            add_axis("y", title = ylabel, title_offset = 50, 
                     layer = "back", grid = FALSE, 
                     properties = axis_props(
                         labels = list(fontSize = 12, fill = "black"),
                         title = list(fontSize = 16)))
    } 
    
}
