graphData <- function(data = NULL, x = NULL, y = NULL, dist = "",
                      sch = NULL, smooth = FALSE, alpha = .85, filter = FALSE,
                      wgt = FALSE, color = ""){

    # Clone the data frame & make copies of x and y parameters
    theData <- data; xcopy <- x; ycopy <- y;

    # Set an optional shape parameter
    #if (shape == TRUE) {
    #    theData$shape <- theData$distsch
    #} else {
    #    theData$shape <- "School/District"
    #}

    source("R/makeWeights.R", local = TRUE);
    source("R/scattervalues.R", local = TRUE);
    source("R/scatterColors.R", local = TRUE)

    # Create size weights for points
    if (wgt == TRUE) {
        makeWeights(x = xcopy, y = ycopy)
    } else {
        theData$wgt <- 60
    }

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


    if (filter == TRUE & ((!is.null(color) & (!is.na(color) | color != "")))) {

        # Rename the filtering variable
        names(theData)[names(theData) == color] <- "color"

        # Remove cases from the data where the x and/or y axes are missing
        theData <- subset(theData, !is.na(theData$x) & !is.na(theData$y) &
                              !is.na(theData$color))

        # Set a variable to identify the correct corresponding color scale
        colorScale <- colscales[[length(unique(theData$color))]]

        # Get legend title
        legendTitle <- axlabels[[color]]

    } else {

        # Remove cases from the data where the x and/or y axes are missing
        theData <- subset(theData, !is.na(theData$x) & !is.na(theData$y))
        theData$color <- " "
        colorScale <- colscales[[1]]
        legendTitle <- " "

    }

    theData$color <- factor(theData$color)

    # Get X-axis & Y-axis labels
    xlabel <- axlabels[[x]]; ylabel <- axlabels[[y]]

    # Create an ID variable that will be used to identify points for the tool tip
    theData$id <- theData$schid

    if (smooth == TRUE) {
        theGraph <-   theData %>% #
            ggvis(x = ~x, y = ~y) %>% #
            layer_model_predictions(model = "lm", se = TRUE, fill := "bisque4",
            fillOpacity := .65, strokeWidth := 2.5, stroke := "chartreuse") %>% #
            layer_points(key := ~id, fill = ~color, opacity := alpha,
                         size := ~wgt) %>% #
            add_tooltip(scattervalues, "hover") %>% #
            add_axis("x", title = xlabel, title_offset = 50,
                     layer = "back", grid = FALSE,
                     properties = axis_props(
                         labels = list(fontSize = 12, fill = "black"),
                         title = list(fontSize = 16))) %>% #
            add_legend("fill", title = legendTitle,
                    properties = legend_props(
                    labels = list(fontSize = 16),
                    title = list(fontSize = 18),
                    symbols = list(size = 125))) %>% #
            add_axis("y", title = ylabel, title_offset = 50,
                     layer = "back", grid = FALSE,
                     properties = axis_props(
                         labels = list(fontSize = 12, fill = "black"),
                         title = list(fontSize = 16)))

    } else {
        theGraph <- theData %>% #
            ggvis(x = ~x, y = ~y) %>% #
            layer_points(key := ~id, fill = ~color, opacity := alpha,
                size := ~wgt) %>% add_tooltip(scattervalues, "hover") %>% #
            add_axis("x", title = xlabel, title_offset = 50,
                     layer = "back", grid = FALSE,
                     properties = axis_props(
                         labels = list(fontSize = 12, fill = "black"),
                         title = list(fontSize = 16))) %>% #
            add_legend("fill", title = legendTitle,
                       properties = legend_props(
                           labels = list(fontSize = 16),
                           title = list(fontSize = 18),
                           symbols = list(size = 125)))  %>%
            add_axis("y", title = ylabel, title_offset = 50,
                     layer = "back", grid = FALSE,
                     properties = axis_props(
                         labels = list(fontSize = 12, fill = "black"),
                         title = list(fontSize = 16)))
    }

}
