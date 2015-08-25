graduationTable <- function(data, outcomeVar = "All", stdGroup = "All Students", unit = NULL) {

	if (outcomeVar == "All") {
		tempData <- data

		dataTable <- tempData %>% arrange(distnm, schnm, group) %>% #
									rename("School ID" = schid,
										"District Name" = distnm,
										"School Name" = schnm,
										"AMO Student SubGroup" = group,
										"Graduate Rate" = graduate,
										"Dropout Rate" = dropout,
										"Still Enrolled" = stillenr,
										"Other Completers" = completer)


		return(as.data.frame(dataTable))

	} else {

		tempData <- data
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
					filter(group == stdGroup, schid %in% unit) %>% select(pos)
				othTable <- tempData %>% #
					filter(group != stdGroup, schid %in% c(unit)) %>% select(pos)
				names(dataTable) <- groupNames; names(othTable) <- nonGroupNames;
				dataTable <- othTable %>% #
					inner_join(dataTable, by = "SchoolID") %>% #
					mutate(GAP = GapGroup - Outcome) %>% #
					arrange(SchoolID, AMOGroups) %>% #
					select(District, School, AMOGroups, Outcome, GapGroup, GAP)
			}
		}
		dataTable <- dataTable %>% filter(!is.na(School))
		return(as.data.frame(dataTable))

	}

}
