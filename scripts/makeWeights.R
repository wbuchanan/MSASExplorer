# Function to generate scaled weights for scatterplots
makeWeights <- function(x, y, base = 125){
    
    weightVars <- list(schtotpts = "schpartden", schtotpts_rank = "schpartden", 
                       schprorla = "pdenrlas", schprorla_rank = "pdenrlas", 
                       schpromth = "pdenmths", schpromth_rank = "pdenmths", 
                       schprosci = "pdenscis", schprosci_rank = "pdenscis", 
                       schprohis = "pdenhiss", schprohis_rank = "pdenhiss", 
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