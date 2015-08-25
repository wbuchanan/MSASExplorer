buildAllGrades <- function() {
    # Build the R version of the allgrades file
    allgrades <- as.data.frame(read.dta("data/msasexplorer.dta"))

    # Sort the data by district name and then school ID
    allgrades <<- allgrades[order(allgrades$distnm, allgrades$schid), ]

    distgrades <<- subset(allgrades, allgrades$sch == "001")

    # Sort the district Data by district name
    distgrades <<- distgrades[order(distgrades$distnm), ]

    schgrades <<- subset(allgrades, allgrades$sch != "001")

    # Load the growth disaggregations for gap analysis
    growth <<- as.data.frame(read.dta("data/msasgrowth.dta"))

    # Load the low25 % growth disaggregations for gap analysis
    growLow25 <<- as.data.frame(read.dta("data/msasgrowthlow25.dta"))

    # Load the graduation rate disaggregations for gap analysis
    graduation <<- as.data.frame(read.dta("data/completeGradRates.dta"))

    # Load AMO data for gap analysis
    amos <<- as.data.frame(read.dta("data/msasexplorer-amos.dta"))

    # Save all the objects to an R data file so they can be loaded simultaneously next time
    save(allgrades, distgrades, schgrades, growth, growLow25,
         graduation, amos, file = "data/allgrades.RData")

}
