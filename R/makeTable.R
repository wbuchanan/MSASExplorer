makeTable <- function(data, outcomeVar, stdGroup = "All Students", unit = NULL) {

	if (is.null(outcomeVar)) {
		tempData <- tbl_df(data)
		
		dataTable <- tempData %>% rename(SchoolID = schid, District = distnm, 
										 School = schnm, AMOGroup = group, 
										 ReadingIndex = rlapctgr, 
										 ReadingGoal = rlagoalgr,
										 ReadingParticipation = rlapartgr,
										 MathIndex = mthpctgr, 
										 MathGoal = mthgoalgr,
										 MathParticipation = mthpartgr)
		
		return(as.data.frame(dataTable))
		
	} else {

		tempData <- tbl_df(data)
		tblNames <- names(tempData)
		names(tempData)[names(tempData) == outcomeVar] <- "Outcome"
		tableIDS <- c("distnm", "schnm", "schid", "group", outcomeVar)
		pos <- match(tableIDS, tblNames)
		groupNames <- c("dist", "sch", "SchoolID", "subgr", "GapGroup")
		nonGroupNames <- c("District", "School", "SchoolID", "AMOGroups", "Outcome")
		
		
		if (is.null(unit)) {
			if (stdGroup == "All Students" || is.null(stdGroup)) {
					dataTable <- select(tempData, pos)
					names(dataTable) <- nonGroupNames
					dataTable <- dataTable %>% #
						arrange(SchoolID, AMOGroups) %>% # 
						select(District, School, AMOGroups, Outcome)
			} else {
				dataTable <- tempData %>% filter(group == stdGroup) %>% select(pos)
				othTable <- tempData %>% filter(group != stdGroup)  %>% select(pos)
				names(dataTable) <- groupNames; names(othTable) <- nonGroupNames;
				dataTable <- othTable %>% inner_join(dataTable, by = "SchoolID") %>% #
					mutate(GAP = GapGroup - Outcome) %>% #
					arrange(SchoolID, AMOGroups) %>% #
					select(District, School, AMOGroups, Outcome, GapGroup, GAP)
					
				dataTable$GAP <- round(dataTable$GAP, digits = 2)
			}
		} else {
			if (stdGroup == "All Students" || is.null(stdGroup)) {
				dataTable <- tbl_df(subset(tempData, schid %in% unit, select = pos))
				names(dataTable) <- nonGroupNames
				dataTable <- dataTable %>% #
					arrange(SchoolID, AMOGroups) %>% #
					select(District, School, AMOGroups, Outcome)
					
			} else {
				dataTable <- tempData %>% #
					filter(group == stdGroup, schid %in% c(unit)) %>% select(pos)
				othTable <- tempData %>% #
					filter(group != stdGroup, schid %in% c(unit)) %>% select(pos)
				names(dataTable) <- groupNames; names(othTable) <- nonGroupNames;
				dataTable <- othTable %>% #
					inner_join(dataTable, by = "SchoolID") %>% #
					mutate(GAP = GapGroup - Outcome) %>% #
					arrange(SchoolID, AMOGroups) %>% #
					select(District, School, AMOGroups, Outcome, GapGroup, GAP) %>% #
					
				dataTable$GAP <- round(dataTable$GAP, digits = 2)
			}
		}
		
		return(as.data.frame(dataTable))
		
	}
	
}
