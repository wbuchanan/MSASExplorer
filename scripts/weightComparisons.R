weightComparisons <- function(data = allgrades, grad = NULL, hist = NULL, 
                                sci = NULL) {

        browser()
        
        dataSet <- subset(allgrades, allgrades$schgrtyp == "Has 12th Grade")

        # Unweight the history and science components by multiplying them by 2
        # and dividing the school graduation rate component by 2
        dataSet$unwgthist <- dataSet$schprosci * 2
        dataSet$unwgtsci <- dataSet$schprosci * 2
        dataSet$unwgtgrad <- dataSet$schgrad / 2
    
        # Create new component scores based on the user supplied weights
        dataSet$ngradrate <- dataSet$graduate * grad
        dataSet$nhistory <- dataSet$unwgthist * hist
        dataSet$nscience <- dataSet$unwgtsci * hist
    
        # Create a new total score variable
        dataSet$npoints <-  dataSet$schprorla + dataSet$schpromth + #
                            dataSet$schgrorla + dataSet$schgromth + #
                            dataSet$schgrolrla + dataSet$schgrolmth + #
                            dataSet$ngradrate + dataSet$nhistory + #
                            dataSet$nscience        
    
        # Initial Grade attempt
        dataSet$ngrade <-   ifelse(dataSet$npoints %in% c(0:421), 5,
                            ifelse(dataSet$npoints %in% c(422:539), 4,
                            ifelse(dataSet$npoints %in% c(540:622), 3,
                            ifelse(dataSet$npoints %in% c(623:694), 2,
                            ifelse(dataSet$npoints >= 695, 1, NA)))))

        # Adjust grade for participation rate violation
        dataSet$ngrade <-  ifelse(dataSet$sdropgrade == "< 95% Tested" & #
        dataSet$ngrade < 5, dataSet$ngrade + 1, dataSet$ngrade)
    
}