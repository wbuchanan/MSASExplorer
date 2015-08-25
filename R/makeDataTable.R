# Define a function that will build a condensed view of the results
makeDataTable <- function(x){

    # Create Data Table for release/display
    msasdata <- subset(allgrades, !is.na(allgrades$schtotpts) &
                           !is.na(allgrades$schwaivedgrade))

	# If the user selects the condensed view they get components only.
	# Otherwise they get the full file.
	if (x != FALSE){
	    dataview <- msasdata[, c(2:6, 52, 7:17)]
	    names(dataview) <- #
	        c("District", "School", "Official Grade",
	          "Past Grade", "w/o Waiver Grade", "DA Label", "Total Points",
	          "RLA Prof", "Math Prof", "Sci. Prof", "Hist. Prof",
	          "Gr. All RLA", "Gr. All Math", "Gr. L25 RLA",
	          "Gr. L25 Math", "Grad Rate", "Part.")
	} else {
		dataview <- msasdata
	}
	return(dataview)
}
