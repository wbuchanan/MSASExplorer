growLow25Table <- function(data, outcomeVar = "All", stdGroup = "All Students",
						   lowGroup = "In the Lowest 25%", unit = NULL) {

	if (outcomeVar == "All") {
		tempData <- data

		dataTable <- tempData %>% rename("School ID" = schid,
										 "District Name" = distnm,
										 "School Name" = schnm,
										 "AMO Student SubGroup" = group,
										 "Low 25 Percent" = schlow25,
										 "Reading Growth" = schgrolrla,
										 "Math Growth" = schgrolmth)
		return(as.data.frame(dataTable))

	} else {

	tempData <- data
	tblNames <- names(tempData)
	names(tempData)[names(tempData) == outcomeVar] <- "Outcome"
	tableIDS <- c("distnm", "schnm", "schid", "schlow25", "group", outcomeVar)
	pos <- match(tableIDS, tblNames)
	groupNames <- c("dist", "sch", "SchoolID", "schlow25", "subgr", "GapGroup")
	nonGroupNames <- c("District", "School", "SchoolID", "Low25Group", "AMOGroups", "Outcome")
	if (is.null(unit)) {
		if (stdGroup == "All Students" || is.null(stdGroup)) {
				dataTable <- select(tempData, pos)
				names(dataTable) <- nonGroupNames
				dataTable <- dataTable %>% #
					arrange(SchoolID, AMOGroups) %>% #
					select(District, School, Low25Group, AMOGroups, Outcome)
		} else {
			dataTable <- tempData %>% #
				filter(group == stdGroup, schlow25 == lowGroup) %>% #
					select(pos)
			othTable <- tempData %>% #
				filter(group != stdGroup, schlow25 != lowGroup) %>% #
					select(pos)
			names(dataTable) <- groupNames; names(othTable) <- nonGroupNames;
			dataTable <- othTable %>% inner_join(dataTable, by = "SchoolID") %>% #
				mutate(GAP = GapGroup - Outcome) %>% #
				arrange(SchoolID, AMOGroups) %>% #
				select(District, School, AMOGroups, Low25Group, Outcome, GapGroup, GAP)
		}
	} else {
		if (stdGroup == "All Students" || is.null(stdGroup)) {
			dataTable <- tbl_df(subset(tempData, schid %in% unit, select = pos))
			names(dataTable) <- nonGroupNames
			dataTable <- dataTable %>% #
				arrange(SchoolID, AMOGroups) %>% #
				select(District, School, AMOGroups, Low25Group, Outcome)
		} else {
			dataTable <- tempData %>% #
				filter(group == stdGroup, schid %in% unit, #
					   schlow25 == lowGroup) %>% select(pos)
			othTable <- tempData %>% #
				filter(group != stdGroup, schid %in% c(unit), #
					   schlow25 != lowGroup) %>% select(pos)
			names(dataTable) <- groupNames; names(othTable) <- nonGroupNames;
			dataTable <- othTable %>% #
				inner_join(dataTable, by = "SchoolID") %>% #
				mutate(GAP = GapGroup - Outcome) %>% #
				arrange(SchoolID, AMOGroups) %>% #
				select(District, School, AMOGroups, Low25Group, Outcome, GapGroup, GAP)
		}
	}
	dataTable <- dataTable %>% filter(!is.na(School))
	return(as.data.frame(dataTable))
	}
}

