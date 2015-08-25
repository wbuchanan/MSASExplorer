# Function to generate bar graphs
msasbar <- function(bars = NULL, schbar = FALSE, binwide = .2,
                    color = NULL, sorted = FALSE, district = NULL) {


    # Load the axlabels script
    source("R/barvalues.R", local = TRUE)

    # Load the allgrades file
    load("data/allgrades.RData")

    # Get variable label to use for x-axis title
    xlabel <- axlabels[[bars]]

    # Test whether the user wants district or school within district bar graphs
    if (schbar == TRUE) {

        # Subset the all grades file to pull out only the selected district
        barData <- subset(allgrades, allgrades$distid == district)

    } else {

        # Clone the allgrades data
        barData <- subset(allgrades, allgrades$distid %in% district & sch == "001")

        # For district level file, push the district names into school names
        barData$schnm <- barData$distnm

    }

    # Rename the variable that will be graphed
    names(barData)[names(barData) == bars] <- "grbar"

    # Create the ID key variable
    barData$id <- barData$schid

    # Check if the user specified any colors for the bars
    if (is.na(color)) {

        # Build the bar graph; use the schnm variable on the y axis to get
        # the name of the unit across school and district level graphs.
        barData %>% ggvis(y = ~schnm, x = ~grbar) %>% #
            layer_rects(x2 = 0, height = band(), key = ~id,
                fill.update := "steelblue", fill.hover := "white") %>% #
            add_tooltip(barvalues, "hover") %>% #
            add_axis("y", title = "", grid = FALSE,
                properties = axis_props(
                    labels = list(fontSize = 12, fill = "black"))) %>% #
            scale_nominal("y", reverse = FALSE, sort = sorted,
                padding = binwide) %>% hide_legend("fill") %>% #
            add_axis("x", title = xlabel, title_offset = 50, layer = "back",
                grid = TRUE, properties = axis_props(
                    labels = list(fontSize = 12, fill = "black"),
                    title = list(fontSize = 16)))

    } else {

        # Get variable label for the variable used as the color
        legendTitle <- axlabels[[color]]

        # Otherwise rename the variable defining the color of the bars
        names(barData)[names(barData) == color] <- "barcolor"

        # Remove missing value cases from graphed and coloring variables
        barData <- subset(barData, !is.na(barData$grbar) & !is.na(barData$barcolor))

        # Make sure that variable is considered a factor
        barData$barcolor <- as.factor(barData$barcolor)

        # Build the bar graph; use the schnm variable on the y axis to get the name of the unit
        # across school and district level graphs.
        barData %>% ggvis(y = ~schnm, x = ~grbar) %>% #
            layer_rects(x2 = 0, height = band(), fill.update = ~barcolor,
                fill.hover := "white") %>% #
            #add_tooltip(barvalues(barData$id, barData$grbar), "hover") %>% #
            add_axis("y", title = "", grid = FALSE, properties = axis_props(
                    labels = list(fontSize = 12, fill = "black"))) %>% #
            scale_nominal("y", reverse = FALSE, sort = sorted,
                padding = binwide) %>%
            add_legend("fill", title = legendTitle,
                        properties = legend_props(
                        labels = list(fontSize = 14),
                        title = list(fontSize = 16),
                        symbols = list(size = 75))) %>% #
            add_axis("x", title = xlabel, title_offset = 50, layer = "back",
                grid = TRUE, properties = axis_props(
                    labels = list(fontSize = 12, fill = "black"),
                    title = list(fontSize = 16)))

    }

}
