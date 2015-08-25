library("shiny"); library("ggvis"); library("plyr");
library("dplyr"); library("ggplot2"); library("foreign");
library("magrittr")

if (file.exists("data/allgrades.RData") == TRUE) {
    # If the allgrades file has been created load it
    load("data/allgrades.RData", envir = .GlobalEnv)
} else {
    buildAllGrades()
}

# Load data sources for graphs and axis labels
load("data/menuMin.RData", envir = .GlobalEnv)

component_weighting <- list("output_wgtTable_hidden",
                            "output_userSchWgt_hidden",
                            "output_sciencewgt_hidden",
                            "output_historywgt_hidden",
                            "output_currentSchWgt_hidden",
                            "output_currGradeTable_hidden")




#con <- socketConnection(host = "127.0.0.1", port = 6983,
#                        server = FALSE, open = "a+r")
#sink(file = con, append = TRUE, type = "output")
#uiclean <- function(strdata, p, r) {
#    gsub(pattern = p, replacement = r, x = strdata)
#}
#reptype <- function(listui) {
#    lapply(as.list(listui[grepl("^(output)", names(listui)) == TRUE]),
#               FUN = function(x) {
#            if (x == FALSE) x
#    }) %>% unlist() %>% names()
#}

# Define server logic for random distribution application
shinyServer(function(input, output, session) {

#    uid <- reactiveValues(userData = session$clientData)
#    uiinputs <- reactiveValues(uiin = session$input)

#    uidata <- observe({

#        user <- list(userID = toString(runif(1, 1000000, 9999999)))
#        uiList <- list(userID = user, timestamp = toString(Sys.time()))
#        uiList <- append(uiList, reactiveValuesToList(uid$userData))
#        uiList <- append(uiList, reactiveValuesToList(uiinputs$uiin))
#        uiList <- append(uiList, list("report" = reptype(uiList)))
#        uiList <- jsonlite::toJSON(uiList, pretty = FALSE,
#                             POSIXt = "ISO8601", factor = "integer",
#                             complex = "string", null = "null",
#                             na = "null", digits = 5, force = TRUE) %>%
#            uiclean('true', 1) %>% uiclean('false', 0)
#        cat(uiList, file = con)
#        print(uiList)
#    })

	source("R/amoTable.R", local = .GlobalEnv)
	source("R/buildAllGrades.R", local = .GlobalEnv)
    source("R/graduationTable.R", local = .GlobalEnv)
	source("R/growLow25Table.R", local = .GlobalEnv)
	source("R/growthTable.R", local = .GlobalEnv)
	source("R/l25growgap.R", local = .GlobalEnv)
	source("R/makeTable.R", local = .GlobalEnv)
	source("R/axlabels.R", local = .GlobalEnv)
	source("R/barvalues.R", local = .GlobalEnv)
	source("R/colorFilters.R", local = .GlobalEnv)
	source("R/graphData.R", local = .GlobalEnv)
	source("R/makeDataTable.R", local = .GlobalEnv)
	source("R/makeWeights.R", local = .GlobalEnv)
	source("R/msasbar.R", local = .GlobalEnv)
	source("R/scatterColors.R", local = .GlobalEnv)
	source("R/scattervalues.R", local = .GlobalEnv)
	source("R/schCompGraph.R", local = .GlobalEnv)
	source("R/weightComparisons.R", local = .GlobalEnv)

	# Build a list of named elements for school IDs
	schnames <- split(setNames(na.omit(allgrades$schid), na.omit(allgrades$schnm)),
	                  na.omit(allgrades$distnm))

	# Create a named list of district IDs
	distnames <- setNames(na.omit(distgrades$distid), na.omit(distgrades$distnm))

	# Load the codebook into memory
	codebook <- readLines("data/fullCodebook.txt")

	# List of options for scatterplots
	xvariables <- c("Total Points" = "schtotpts",
	                "Total Points Rank" = "schtotpts_rank",
	                "RLA Proficiency Points" = "schprorla",
	                "RLA Proficiency Rank" = "schprorla_rank",
	                "Math Proficiency Points" = "schpromth",
	                "Math Proficiency Rank" = "schpromth_rank",
	                "Science Proficiency Points" = "schprosci",
	                "Science Proficiency Rank" = "schprosci_rank",
	                "US History Proficiency Points" = "schprohis",
	                "US History Proficiency Rank" = "schprohis_rank",
	                "RLA Growth Points" = "schgrorla",
	                "RLA Growth Rank" = "schgrorla_rank",
	                "Math Growth Points" = "schgromth",
	                "Math Growth Rank" = "schgromth_rank",
	                "RLA Low 25% Points" = "schgrolrla",
	                "RLA Low 25% Rank" = "schgrolrla_rank",
	                "Math Low 25% Points" = "schgrolmth",
	                "Math Low 25% Rank" = "schgrolmth_rank",
	                "Grad Rate Points" = "schgrad",
	                "Grad Rate Rank" = "schgrad_rank")

	linkedcutpts <- readxl::read_excel("data/linkedTotalPoints600Scale.xlsx", sheet = 1)

	totalPoints <- c(paste(linkedcutpts[1, 2], linkedcutpts[1, 3], sep = "-"), #
	                   paste(linkedcutpts[2, 2], linkedcutpts[2, 3], sep = "-"), #
	                   paste(linkedcutpts[3, 2], linkedcutpts[3, 3], sep = "-"), #
	                   paste(linkedcutpts[4, 2], linkedcutpts[4, 3], sep = "-"), #
	                   paste(linkedcutpts[5, 2], linkedcutpts[5, 3], sep = "-"))

	pctilePoints <- c(paste(linkedcutpts[1, 4], linkedcutpts[1, 5], sep = "-"), #
	                   paste(linkedcutpts[2, 4], linkedcutpts[2, 5], sep = "-"), #
	                   paste(linkedcutpts[3, 4], linkedcutpts[3, 5], sep = "-"), #
	                   paste(linkedcutpts[4, 4], linkedcutpts[4, 5], sep = "-"), #
	                   paste(linkedcutpts[5, 4], linkedcutpts[5, 5], sep = "-"))
	linkgrades <- c("A", "B", "C", "D", "F")
	linkedcutpts <- as.data.frame(cbind(linkgrades, totalPoints, pctilePoints),
	                              stringsAsFactors = FALSE)
	names(linkedcutpts) <- c("Grade", "Total Points", "Percentiles")

	# Create static graph showing the current distribution of letter grades for
	# schools with a 12th grade

	currSchWgt <- subset(allgrades, allgrades$schgrtyp == "Has 12th Grade" & allgrades$schid != "2502-004")
    output$currGradeTable <- renderTable(table(currSchWgt$schgrade, currSchWgt$distsch))
	currSchWgtGraph <-  ggplot(currSchWgt, aes(x = schwaivedgrade, fill = schwaivedgrade)) +   #
	    geom_bar() + facet_wrap(~distsch, nrow = 1) +          #
	    labs(x = "Performance Classifiers",
	         y = "# of Schools/Districts",
	         title = "Approved Component Weights") +            #
	    scale_fill_manual(values = c("#0000FF", "#00FF00",
	                                 "#FFFF00", "#FFA500", "#FF0000"),
	                      breaks = c("A", "B", "C", "D", "F"),
	                      name = "Accountability \nGrades") +                #
	    theme(panel.background = element_rect(fill = "white"),
	          strip.text = element_text(size = 16),
	          legend.title = element_text(size = 16),
	          legend.text = element_text(size = 16),
	          plot.title = element_text(size = 24),
	          axis.text.x = element_text(size = 12, color = "black"),
	          axis.text.y = element_text(size = 12, color = "black"),
	          axis.title.x = element_text(size = 20, color = "black"),
	          axis.title.y = element_text(size = 20, color = "black"))

	# Build a list of named elements for school IDs
	growth$schnm[growth$sch == "001"] <- growth$distnm[growth$sch == "001"]

	# Order the data by the unique school ID (districts have sch == 001)
	growth <- growth[order(growth$schid), ]

	# Create a named list of school ids
	growthunits <- setNames(growth$schid, growth$schnm)

	# Select only the unique school/districts from that list
	growthunits <- growthunits[unique(names(growthunits))]

	# Build a list of named elements for school IDs
	graduation$schnm[graduation$sch == "001"] <- graduation$distnm[graduation$sch == "001"]

	# Order the data by the unique school ID (districts have sch == 001)
	graduation <- graduation[order(graduation$schid), ]

	# Create a named list of school ids
	gradunits <- setNames(graduation$schid, graduation$schnm)

	# Select only the unique school/districts from that list
	gradunits <- gradunits[unique(names(gradunits))]

	# Build a list of named elements for school IDs
	growLow25$schnm[growLow25$sch == "001"] <- growLow25$distnm[growLow25$sch == "001"]

	# Order the data by the unique school ID (districts have sch == 001)
	growLow25 <- growLow25[order(growLow25$schid), ]

	# Create a named list of school ids
	low25units <- setNames(growLow25$schid, growLow25$schnm)

	# Select only the unique school/districts from that list
	low25units <- low25units[unique(names(low25units))]

	# Assign district names to school name for districts
	amos$schnm[amos$sch == "001"] <- amos$distnm[amos$sch == "001"]

	# Order the data by the unique school ID (districts have sch == 001)
	amos <- amos[order(amos$schid), ]

	# Create a named list of school ids
	amounits <- setNames(amos$schid, amos$schnm)

	# Select only the unique school/districts from that list
	amounits <- amounits[unique(names(amounits))]

	# Build a list of named elements for school IDs
	gradgroups <- setNames(unique(graduation$group), unique(graduation$group))
	gradgroups <- gradgroups[order(gradgroups)]

	# Build a list of named elements for school IDs
	low25amogroup <- setNames(unique(growLow25$group), unique(growLow25$group))
	low25amogroup <- low25amogroup[order(low25amogroup)]
	low25indicator <- list("In the Lowest 25%" = "In the Lowest 25%",
	                       "Not in the Lowest 25%" = "Not in the Lowest 25%")

	# Build a list of named elements for school IDs
	growthgroups <- setNames(unique(growth$group), unique(growth$group))
	growthgroups <- growthgroups[order(growthgroups)]

	# Build a list of named elements for school IDs
	amogroups <- setNames(unique(as.character(amos$group)),
	                      unique(as.character(amos$group)))
	amogroups <- amogroups[order(amogroups)]

	# Build a list of named elements for school IDs
	gradOutcomes <- list("All" = "All", "Graduates" = "graduate",
						 "Dropouts" = "dropout",
	                     "Still Enrolled Students" = "stillenr",
	                     "Other HS Completers" = "completer")

	# Build a list of named elements for school IDs
	growthOutcomes <- list("All" = "All", "Reading/Language Arts" = "schgrorla",
	                       "Math" = "schgromth")

	# Build a list of named elements for school IDs
	low25Outcomes <- list("All" = "All", "Reading/Language Arts" = "schgrolrla",
	                      "Math" = "schgrolmth")
    observe({

        # Capture what was selected for the x variable for scatter plots
        xselect <- variables$x()

        # Remove that element from the list of x variables
        yvariables <- xvariables[xvariables != xselect]

        if (is.null(input$yvar)) {
            # Update the choices available for yvariables
            updateSelectInput(session, "yvar", choices = yvariables,
                          selected = yvariables[[runif(1, min=1, max=19)]])
        }

    })

    output$schdistbars <- renderUI({

        if (input$schbar == TRUE) {

            nDist <- distnames[unique(trunc(runif(1, 1, length(distgrades$schid))))]

            selectInput("schdistbars",
                "Select a District to see how those Schools Rank",
                choices = distnames, selected = nDist, multiple = FALSE,
                selectize = TRUE)

        } else{

            nDists <- distnames[unique(trunc(runif(25, 1, #
                length(distgrades$schid))))]

            selectInput("schdistbars",
                "Select a District to see how those Schools Rank",
                choices = distnames, selected = nDists,
                multiple = TRUE, selectize = TRUE)

        }
    })

    observe({


	    # School/District Selector for graduation rate gap analysis
	    output$gradGapUnit <- renderUI({

	        selectInput("gradGapUnit",
	                    "Select a School/District to filter or view all",
	                    choices = gradunits, selected = NULL, multiple = TRUE,
	                    selectize = TRUE)

	    })

	    # School/District Selector for growth of the low 25% gap analysis
	    output$low25GapUnit <- renderUI({

	        selectInput("low25GapUnit",
	                    "Select a School/District to filter or view all",
	                    choices = low25units, selected = NULL, multiple = TRUE,
	                    selectize = TRUE)

	    })

	    # School/District Selector for all students growth gap analysis
	    output$growthGapUnit <- renderUI({

	        selectInput("growthGapUnit",
	                    "Select a School/District to filter or view all",
	                    choices = growthunits, selected = NULL, multiple = TRUE,
	                    selectize = TRUE)

	    })

	    # School/District Selector for amo gap analysis
	    output$amoGapUnit <- renderUI({

	        selectInput("amoGapUnit",
	                    "Select a School/District to filter or view all",
	                    choices = amounits, selected = NULL, multiple = TRUE,
	                    selectize = TRUE)

	    })


	    # Subgroup Selector for graduation rate gap analysis
	    output$gradGroup <- renderUI({

	        selectInput("gradGroup",
	                    "Select a Student Group for Your Gap Analysis : ",
	                    choices = gradgroups, selected = NULL, multiple = FALSE,
	                    selectize = TRUE)

	    })

	    # Subgroup Selector for growth of the low 25% gap analysis
	    output$low25Group <- renderUI({

	        selectInput("low25Group",
	                    "Select a Student Group for Your Gap Analysis : ",
	                    choices = low25amogroup, selected = NULL, multiple = FALSE,
	                    selectize = TRUE)

	    })

	    # Subgroup Selector for growth of the low 25% gap analysis
	    output$low25indicator <- renderUI({

	        selectInput("low25Indicator",
	                    "Select either Low 25% Subgroup or Not Low 25% Subgroup : ",
	                    choices = list("Are Not Low 25% Students" = "Not in the Lowest 25%",
	                                   "Are Low 25% Students" = "In the Lowest 25%"),
	                    selected = "In the Lowest 25%", multiple = FALSE,
	                    selectize = TRUE)

	    })

	    # Subgroup Selector for all students growth gap analysis
	    output$growthGroup <- renderUI({

	        selectInput("growthGroup",
	                    "Select a Student Group for Your Gap Analysis : ",
	                    choices = growthgroups, selected = NULL, multiple = FALSE,
	                    selectize = TRUE)

	    })

	    # Subgroup Selector for amo gap analysis
	    output$amoGroup <- renderUI({

	        selectInput("amoGroup",
	                    "Select a Student Group for Your Gap Analysis : ",
	                    choices = amogroups, selected = NULL, multiple = FALSE,
	                    selectize = TRUE)

	    })

    })

    variables <- reactiveValues()

    variables$x <- reactive({
        return(input$xvar)
    })

    variables$y <- reactive({
        return(input$yvar)
    })

    variables$scatterdata <- reactive({

        scatterdata <- switch(input$scatterdata,
                                "allgrades" = allgrades,
                                "distgrades" = distgrades,
                                "schgrades" = schgrades)

        return(scatterdata)
    })

    variables$distshape <- reactive({
        return(input$distschpts)
    })
    variables$checkSmooth <- reactive({
        return(input$smoother)
    })

    variables$cfilter <- reactive({
        return(input$coloring)
    })

    variables$district <- reactive({
        dists <- ldply(input$dist, paste, sep = ", ")
        dists <- paste(dists, sep = "")
    })

    variables$school <- reactive({
        schs <- ldply(input$sch, paste, sep = ", ")
        schs <- paste(schs, sep = "")
    })

    variables$alpha <- reactive({
        return(input$transparency)
    })

    variables$color <- reactive({
        return(input$filter)
    })

    variables$weight <- reactive ({
        return(input$scaleweights)
    })

    variables$condensed <- reactive({
        return(input$smallDataView)
    })

    variables$dltype <- reactive({
        return(input$datatype)
    })

    variables$linkgraph <- reactive({
        return(input$linkgraph)
    })

    variables$bardistsch <- reactive({
        return(input$schdistbars)
    })

    variables$schbar <- reactive({
        return(input$schbar)
    })

    variables$barvars <- reactive({
        return(input$barinput)
    })

    variables$barcols <- reactive({
        return(input$barfill)
    })

    variables$binwide <- reactive({
        return(input$binwide)
    })

    variables$barsort <- reactive({
        return(input$sorted)
    })


    reactive({

        msasbar(bars = input$barinput, schbar = input$schbar,
                color = variables$barcols(), sorted = variables$barsort(),
                binwide = variables$binwide(), district = variables$bardistsch())

    }) %>% bind_shiny("msasbar")


    reactive({

        source("R/scattervalues.R")
        source("R/makeWeights.R")

        # Create interactive scatterplot
        graphData(data = variables$scatterdata(), x = variables$x(),
                    y = variables$y(), dist = variables$district(),
                    sch = variables$school(), smooth = input$smoother,
                    alpha = variables$alpha(), filter = variables$cfilter(),
                    wgt = input$scaleweights, color = variables$color())
                    #shape = variables$scattershape())

    }) %>% bind_shiny("msasplot")

    # Prepare data table of accountability results for display
    msasview <- reactive({

            msasview <- makeDataTable(input$smallDataView)
            return(msasview)

    })

    # Display accountability system results set
    output$MSASdata <- renderDataTable(msasview(),
                                options = list(pageLength = 10,
                                lengthMenu = list(c(10, 25, 50, 100, -1),
                                c('10', '25', '50', '100', 'All'))))

    # Display a table of cutpoints from the linking process
    output$linkresults <- renderDataTable(linkedcutpts,
                                          options = list(paging = FALSE,
                                                        pageLength = 6,
                                                        searching = FALSE))

    # Download function support for the accountability system data
    output$dlMSASdata <- downloadHandler(

        # Create a file name dynamically including the start/end academic year
        filename = function() {

            # Append Start/End Years to file name for Download
            paste(paste("msas", start, end, sep="-"), input$datatype, sep = "")

        },

        # Allow users to select from multiple output formats
        content = function(file) {

            # Build the content based on the value selected by the user
            if (input$datatype == ".xlsx") {
                xlsx::write.xlsx(msasview, file)
            } else if (input$datatype == ".csv") {
                write.csv(msasview, file)
            }
            else if (input$datatype == ".dta") {
                foreign::write.dta(msasview, file)
            } else {
                save(msasview, file)
            }
        }
    )

    output$codebook <- downloadHandler(
        filename = "msascodebook.txt",
        content = function(file){
            # Copy the r object to a file
            file.copy(codebook, file)
        },
        contentType = "text"
    )

    output$linking  <-  renderImage({
                            return(list(src = input$linkgraph,
                                        contentType = "image/png"))
                            },
                            deleteFile = FALSE
                        )

    output$historywgt <- renderUI({

        # Set and control the value of US History weights
        sliderInput("historywgt",
            "Select the weight of the US History Component",
            min = 0, max = 3 - input$gradwgt,
            value = ((3 - input$gradwgt) * runif(1, .01, .7)),
            step = .01
        )

    })

    variables$sciencewgt <- reactive({
        return(3 - (input$gradwgt + input$historywgt))

    })

    output$sciencewgt <- renderText({
        paste("The science component would be weighted at: ", #
                variables$sciencewgt(), #
                "The graph shows how this would change performance classifiers",
            sep = "  \n\n  ")

    })

    # Build the dataset required for the weight comparisons
    wgtGraphData <- reactive({

        # Call function to calculate new grades w/user input
        weightGraphs <- weightComparisons(  data = allgrades,
                                            grad = input$gradwgt,
                                            sci = variables$sciencewgt(),
                                            hist = input$historywgt)

        # return the data set with the new grades to the wgtGraphData object
        return(weightGraphs)

    })

    wgtTable <- reactive({
        # Call function to calculate new grades w/user input
        weightGraphs <- weightComparisons(  data = allgrades,
                                            grad = input$gradwgt,
                                            sci = variables$sciencewgt(),
                                            hist = input$historywgt)

        weightTable <- table(weightGraphs$ngrade, weightGraphs$distsch)
        return(weightTable)
    })

    output$wgtTable <- renderTable(wgtTable())

    # Builds graphs based on user input
    output$userSchWgt <- renderPlot({

        # Create graph of letter grade distribution from user inputs
        schCompGraph(data = wgtGraphData())

    })

    # Create graph based on current cutpoints and grades
    output$currentSchWgt <- renderPlot({
        print(currSchWgtGraph)
    })

	variables$amoOutcome <- reactive({return(input$amoOutcomeVar)})
	variables$amoGapUnit <- reactive({return(input$amoGapUnit)})
    variables$amoGroup <- reactive({return(input$amoGroup)})

    amoGapTable <- reactive({
    	tempData <- amos %>% select(schid, distnm, schnm, group, rlapctgr,
                        rlagoalgr, rlapartgr, mthpctgr, mthgoalgr, mthpartgr)

    	 amoTable <- amoTable(data = tempData, outcomeVar = variables$amoOutcome(),
    	 				    stdGroup = input$amoGroup, unit = input$amoGapUnit)
    	 return(amoTable)
    })

    output$amogap <- renderDataTable(amoGapTable())


    growthGapTable <- reactive({
        tempData <- growth %>% select(schid, distnm, schnm, group, schgrorla, schgromth)
    	growTable <- growthTable(data = tempData,
    							 outcomeVar = input$growthOutcome,
    						  	 stdGroup = input$growthGroup,
    							 unit = input$growthGapUnit)
    	return(growTable)
    })

    output$growthgap <- renderDataTable(growthGapTable())

    growthLow25GapTable <- reactive({

        tempData <- growLow25 %>% select(schid, distnm, schnm, schlow25,
                                    group, schgrolrla, schgrolmth)

    	growLow25Table <- growLow25Table(data = tempData,
    							 outcomeVar = input$low25Outcome,
    							 lowGroup = input$low25Indicator,
    							 stdGroup = input$low25Group,
    							 unit = input$low25GapUnit)
    	return(growLow25Table)
    })

    output$growthLow25gap <- renderDataTable(growthLow25GapTable())


	graduationGapTable <- reactive({
        gradTemp <- graduation %>% select(schid, distnm, schnm, group, graduate,
                                    dropout, stillenr, completer)
    	gradTable <- graduationTable(data = gradTemp,
    							 outcomeVar = input$gradOutcome,
    							 stdGroup = input$gradGroup,
    							 unit = input$gradGapUnit)
    	return(gradTable)
    })

    output$graduationgap <- renderDataTable(graduationGapTable())





    # Create low 25% growth gap analysis graph
    #output$growthGapPlot <- reactive({
    #
    #    if
    #        l25growgap(data = input$growgapdata, distFilter = input$distFilter,
    #            schFilter = input$schFilter, alphaPt = input$alphaPt,
    #            reg = input$reg, wgt = input$gapweights, subzoom = input$subzoom,
    #            low25district = input$low25district, l25bars = input$gapBars)
    #
    #})

})


