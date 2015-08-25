# Function to generate bar graphs
msasbar <- function(bars = NULL, schbar = NULL, binwide = .2,  
                    color = NULL, sorted = FALSE, district = NULL) {
    
    # Load the axlabels script
    source("scripts/axlabels.R")
    
    # Get variable label to use for x-axis title
    xlabel <- axlabels[[bars]]

    # Test whether the user wants district or school within district bar graphs
    if (district != "") {

        # Subset the all grades file to pull out only the selected district
        schbar <- subset(schbar, schbar$distnm == district)
        
    } else {
        
        # For district level file, push the district names into school names
        schbar$schnm <- schbar$distnm
        
    }

    # Rename the variable that will be graphed
    names(schbar)[names(schbar) == bars] <- "grbar"
    
    # Check if the user specified any colors for the bars
    if (color == "") {

        # Assign a color to a new variable called barcolor
        schbar$barcolor <- ""
        
        # Set a null legend
        legendTitle <- ""
        

    } else {

        # Get variable label for the variable used as the color
        legendTitle <- axlabels[[color]]

        # Otherwise rename the variable defining the color of the bars
        names(schbar)[names(schbar) == color] <- "barcolor"

        # Remove missing value cases from graphed and coloring variables
        schbar <- subset(schbar, !is.na(schbar$grbar) & #
                            !is.na(schbar$barcolor))

        # Make sure that variable is considered a factor
        schbar$barcolor <- as.factor(schbar$barcolor)

    }
    
    # Create the ID key variable
    schbar$id <- schbar$schid
        
    # Build the bar graph; use the schnm variable on the y axis to get the name of the unit
    # across school and district level graphs.  
    schbar %>% ggvis(y = ~schnm, x = ~grbar) %>% #
        layer_rects(x2 = 0, height = band(), 
                    fill.update = ~barcolor, fill.hover := "white") %>% #
        add_axis("y", title = "", grid = FALSE,
                 properties = axis_props(
                         labels = list(fontSize = 12, fill = "black"))) %>% #
        scale_nominal("y", reverse = FALSE, sort = sorted,
                      padding = binwide) %>% #
        add_legend("fill", title = legendTitle,
                       properties = legend_props(
                            labels = list(fontSize = 14),
                            title = list(fontSize = 12),
                            symbols = list(size = 25))) %>% #
        add_axis("x", title = xlabel, title_offset = 50, layer = "back",
                 grid = TRUE, 
                 properties = axis_props(
                     labels = list(fontSize = 12, fill = "black"),
                     title = list(fontSize = 16)))  #%>% #
        #add_tooltip(values, "click")
    
    
     
   
    
}
