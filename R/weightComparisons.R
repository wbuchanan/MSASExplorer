weightComparisons <- function(data = allgrades, grad = NULL, hist = NULL,
                                    sci = NULL) {

        # Load the allgrades data into the local environment
        # load("../data/allgrades.RData", local = TRUE)

        dataSet <- subset(data, data$schgrtyp == "Has 12th Grade" & data$schid != "2502-004",
                    select = c(schprorla, schpromth, schgrorla, schgromth,
                               schgrolrla, schgrolmth, schgrad, schprohis,
                               schprosci, distsch, schid, schnm, schwaivedgrade,
                               schtotpts, sdropgrade))

        # Unweight the history and science components by multiplying them by 2
        # and dividing the school graduation rate component by 2
        dataSet$unwgthist <- round((dataSet$schprohis * 2), 1) ;
        dataSet$unwgtsci <- round((dataSet$schprosci * 2), 1) ;
        dataSet$unwgtgrad <- round((dataSet$schgrad / 2), 1) ;

        # Create new component scores based on the user supplied weights
        dataSet$ngradrate <- round((dataSet$unwgtgrad * grad), 1)
        dataSet$nhistory <- round((dataSet$unwgthist * hist), 1)
        dataSet$nscience <- round((dataSet$unwgtsci * hist), 1)

        # Create a new total score variable
        dataSet$npoints <-  round((dataSet$schprorla + dataSet$schpromth + #
                            dataSet$schgrorla + dataSet$schgromth + #
                            dataSet$schgrolrla + dataSet$schgrolmth + #
                            dataSet$ngradrate + dataSet$nhistory + #
                            dataSet$nscience), 0)

        # Initial Grade attempt
        dataSet$ngrade <-   ifelse(dataSet$npoints %in% c(0:421), 5,
                            ifelse(dataSet$npoints %in% c(422:539), 4,
                            ifelse(dataSet$npoints %in% c(540:622), 3,
                            ifelse(dataSet$npoints %in% c(623:694), 2,
                            ifelse(dataSet$npoints >= 695, 1, NA)))))

        # Adjust grade for participation rate violation
        dataSet$ngrade <-  ifelse(dataSet$sdropgrade == "< 95% Tested" & #
        dataSet$ngrade < 5, dataSet$ngrade + 1, dataSet$ngrade)

        # Convert grade into a character vector
        dataSet$ngrade <- as.character(factor(dataSet$ngrade, levels = c(1:5),
                                          labels = c("A", "B", "C", "D", "F")))

        # Return the dataset object
        return(dataSet)

}
