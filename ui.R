library(shiny); load("data/menuMin.RData"); source("R/colorFilters.R")
amoSubGroups = list("All Students" = "1",
    "Asian" = "2",
    "Black or African American" = "3",
    "Hispanic or Latino" = "4",
    "Two or More Races" = "5",
    "American Indian or Alaskan Native" = "6",
    "Native Hawaiian or Pacific Islander" = "7",
    "White" = "8",
    "Female" = "9",
    "Male" = "10",
    "Economically Disadvantaged" = "11",
    "Limited English Proficiency" = "12",
    "Students w/Disabilities" = "13")

# Material to include in reports
reportOpts <- list("Tables" = list("All Data Tables" = "alltables",
    "MSAS Component Scores" = "scoretable",
    "MSAS Component Rankings" = "ranktable",
    "Reading AMOs" = "amorlatable",
    "Math AMOs" = "amomathtable",
    "Other Academic Indicators" = "amoothtable",
    "Proficiency Gaps" = "progaptable",
    "Growth Gaps" = "growthgaptable",
    "Graduation Rate Gaps" = "gradgaptable"),
    "Graphs" = list("Bar RLA Proficiency" = "rlaprobar",
        "Bar Math Proficiency" = "mthprobar",
        "Bar Science Proficiency" = "sciprobar",
        "Bar History Proficiency" = "hisprobar",
        "Bar Graduation Rates" = "gradbar",
        "Scatter Proficiency Scores" = "scatprofscores",
        "Scatter Growth Scores" = "scatgrowscore")
)

# List of options for Bar Graphs
barchoices  <-  list("Bar Graph Options" = #
        c("Total Points" = "schtotpts",
            "Total Points %ile" = "schtotpts_rank",
            "Reading Proficiency" = "schprorla",
            "Reading Proficiency %ile" = "schprorla_rank",
            "Math Proficiency" = "schpromth",
            "Math Proficiency %ile" = "schpromth_rank",
            "Science Proficiency" = "schprosci",
            "Science Proficiency %ile" = "schprosci_rank",
            "US History Proficiency" = "schprohis",
            "US History Proficiency %ile" = "schprohis_rank",
            "Reading Growth (All)" = "schgrorla",
            "Reading Growth (All) %ile" = "schgrorla_rank",
            "Math Growth (All)" = "schgromth",
            "Math Growth (All) %ile" = "schgromth_rank",
            "Reading Growth (Low 25%)" = "schgrolrla",
            "Reading Growth (Low 25%) %ile" = "schgrolrla_rank",
            "Math Growth (Low 25%)" = "schgrolmth",
            "Math Growth (Low 25%) %ile" = "schgrolmth_rank",
            "Graduation Rate" = "schgrad",
            "Graduation Rate %ile" = "schgrad_rank"
        )
)

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
yvariables <- c("Total Points" = "schtotpts",
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

# Define UI for random distribution application
shinyUI(
    navbarPage("MS Statewide Accountability Explorer",
               collapsable = TRUE, fluid = TRUE, responsive = TRUE,
        tabPanel("About",
                 tagList(
                   tags$head(
                     tags$link(rel = "stylesheet", type = "text/css", href = "mapstyle.css"),
                     tags$script(src="http://d3js.org/topojson.v1.min.js"),
                     tags$script(src="http://d3js.org/d3.v3.min.js")
                   )
                 ),
            fluidRow(
                column(4,
                    includeMarkdown("apptext/about.Rmd")
                ),
                column(8,
                    tags$div(id = "distmap", class = "msasMap",
                        style = "width: 600; height: 900;",
                    tags$script(src="maptest.js")
                    )
                )
            )
        ),
        navbarMenu("Graphs",
            tabPanel("Bar Graphs",
                fluidRow(

                    # Selector for variable to graph in the bars
                    column(4,
                        selectInput("barinput",
                            "Select the data you would like to display:",
                            choices = barchoices, selected = "totpts",
                            multiple = FALSE, selectize = FALSE
                        ),

                        # Option that will force either schools within districts
                        # or only the district level
                        checkboxInput("schbar",
                            "Check the box to see schools \nin the district of your choice",
                            FALSE
                        ),
                        uiOutput("schdistbars"),
                        # Selector for color coding the bars
                        selectInput("barfill",
                            "Select to color the bars",
                            choices = barColorFilters, selected = "",
                            multiple = FALSE, selectize = FALSE
                        ),
                        # Adjust the width of the bars
                        sliderInput("binwide",
                            "Adjust the width of the bars to your taste",
                            min = 0, max = 1, step = .01, value = 0.20,
                            animate = FALSE
                        ),
                        # Allow end user to determine if they want to sort the bars
                        checkboxInput("sorted",
                            "Check if you would like the bars sorted by name",
                            FALSE
                        )
                    ),

                    # Render the output of the bar graph
                    column(8,
                        ggvis::ggvisOutput("msasbar")
                    )
                )
            ),

            # Page for scatterplots
            tabPanel("Scatterplots",
                fluidRow(

                    # Selector for x-axis variable
                    column(3,
                        selectInput("xvar",
                            "Select the variable for the x-axis",
                            choices = xvariables, multiple = FALSE,
                            selected = "schgrolrla", selectize = FALSE)
                        ),

                    # True/False check box for adding a smoother to the points
                    column(2,
                        checkboxInput("smoother",
                            "Add a trend line to the plot", FALSE)),

                    # True/False checkbox to allow for color coding data
                    column(2,
                        checkboxInput("coloring",
                            "Color Schools Points", FALSE)),

                    # True/False check box for weighted points
                    column(2,
                       checkboxInput("scaleweights",
                                    "Size Points Based on # of Students",
                                    FALSE)),

                    # Selector for y-axis variable
                    column(3,
                       selectInput("yvar",
                                   "Select the variable for the y-axis",
                                   choices = yvariables, multiple = FALSE,
                                   selected = NULL, selectize = FALSE)
                    )
                ),
                fluidRow(
                    column(2,
                        sliderInput("transparency",
                            "Move Slider to Adjust the Transparency of the Points",
                            min = 0, max = 1, step = .01, value = 0.5,
                            animate = FALSE),
                        conditionalPanel(
                            condition = "input.coloring == true",
                            selectInput("filter",
                                "Select a variable to color code the points",
                                choices = colorFilters,
                                multiple = FALSE, selected = NULL,
                                selectize = FALSE
                            )
                        ),
                        selectInput("scatterdata",
                            "Select the data you would like to graph",
                            choices = c("Schools and Districts" = "allgrades",
                                        "Districts Only" = "distgrades",
                                        "Schools Only" = "schgrades"),
                            selected = "allgrades", multiple = FALSE,
                            selectize = TRUE
                        )
                    ),
                    column(8,
                        mainPanel(
                            ggvis::ggvisOutput("msasplot")
                        )
                    )
                ),
                fluidRow(
                    column(6,
                        conditionalPanel(
                            condition = "input.smoother === true",
                            includeMarkdown("apptext/regression.Rmd")
                        )
                    ),
                    column(6,
                        conditionalPanel(
                            condition = "input.scaleweights === true",
                            includeMarkdown("apptext/weights.Rmd")
                        )
                    )
                )
            ),
            tabPanel("Linking Results",
                fluidRow(
                    column(3,
                        selectInput("linkgraph",
                            "Select a graph to view:",
                            choices = list(
                                "Graph of Letter Grades" = "image/linkedhistogram.png",
                                "Total Point Percentiles" = "image/linkedboxpct.png",
                                "Total Points" = "image/linkedboxscore.png"
                            ),
                            selected = "image/linkedboxpct.png",
                            multiple = FALSE, selectize = FALSE)
                    ),
                    column(6,
                        imageOutput("linking", width = "100%", height = "400px")
                    ),
                    column(3,
                        dataTableOutput("linkresults")
                    )
                )
            )
        ),
            navbarMenu("Gap Analysis",
                tabPanel("Annual Measureable Objectives",
                		 fluidRow(
                		 	column(3,
                		 		   uiOutput("amoGapUnit"), br(),
                		 		   uiOutput("amoGroup"), br(),
                		 		   selectInput("amoOutcomeVar",
                		 		       "Select an AMO Outcome : ",
                		 		       choices = list("All" = "All",
                		 		          "Proficiency Index - Reading" = "rlapctgr",
                		 		          "Proficiency Index - Math" = "mthpctgr",
                		 		          "Participation Rates - Reading" = "rlapartgr",
                		 		          "Participation Rates - Math" = "mthpartgr"),
                		 		   selected = "All", multiple = FALSE, selectize = FALSE)
                		 	),
                		 	column(9,
                		 	       dataTableOutput("amogap")
                		 	)
                		 )
                ),
                tabPanel("Graduation Rates",
	                fluidRow(
                		 column(3,
                		 	uiOutput("gradGapUnit"), br(),
                		 	uiOutput("gradGroup"), br(),
                		 	selectInput("gradOutcome",
                		 	            "Select a Graduation Rate Outcome : ",
                		 	            choices = list("All" = "All",
                                                    "Graduates" = "graduate",
                		 	                        "Dropouts" = "dropout",
                		 	                        "Still Enrolled Students" = "stillenr",
                		 	                        "Other HS Completers" = "completer"),
                                        selected = "All", multiple = FALSE,
                		 	            selectize = TRUE)
	                    ),
	                    column(9,
	                           dataTableOutput("graduationgap")
	                    )
	                )
                ),
                tabPanel("Growth (All Students)",
                		 fluidRow(
                		 	column(3,
                		 		   uiOutput("growthGapUnit"), br(),
                		 		   uiOutput("growthGroup"), br(),
                		 		   selectInput("growthOutcome",
        		 		               "Select a Growth Outcome :",
        		 		               choices = list("All" = "All",
	 		                              "Reading/Language Arts" = "schgrorla",
	 		                              "Math" = "schgromth"),
        		 		               selected = "All", multiple = FALSE, selectize = TRUE)
                		 	),
                		 	column(9,
                		 		   dataTableOutput("growthgap")
                		 	)
                		 )
                ),
                tabPanel("Growth (Low 25% Students)",
                		 fluidRow(
                		 	column(3,
                		 		   uiOutput("low25GapUnit"), br(),
                		 		   uiOutput("low25indicator"), br(),
                		 		   uiOutput("low25Group"), br(),
                		 		   selectInput("low25Outcome",
        		 		               "Select a Growth Outcome for the Lowest 25% Students :",
        		 		               choices = list("All" = "All",
        		 		                              "Reading/Language Arts" = "schgrolrla",
        		 		                              "Math" = "schgrolmth"),
        		 		               selected = "All", multiple = FALSE, selectize = TRUE)
                		 	),
                		 	column(9,
                		 	       dataTableOutput("growthLow25gap")
                		 	)
                		 )
                ),
                tabPanel("Low 25% Growth",
                    fluidRow(
                        # Selector for district filter
                        column(3,
                            conditionalPanel(
                                condition = "input.low25district == false",
	                                selectInput("distFilter",
                                        "Select specific districts to focus on",
                                        choices = NULL, multiple = TRUE,
                                        selected = NULL, selectize = FALSE)
                                )
                            ),
                        # True/False check box for adding a smoother to the points
                        column(2,
                            checkboxInput("reg",
                                           "Add group trend lines to the plot", FALSE)),

                        # True/False checkbox to switch to single district view
                        column(2,
                            checkboxInput("low25district",
                                           "Click to focus on a single district", FALSE)),

                        # True/False check box for weighted points
                        column(2,
                            conditionalPanel(
                                condition = "input.low25district == false",
                                	checkboxInput("gapweights",
                                    	"Size Points Based on # of Students", FALSE)
                                    )
                                ),
                                # Selector for school filter
                                column(3,
                                    conditionalPanel(
                                        condition = "input.low25district == false",
                                       		selectInput("schFilter",
                                                "Select specific schools to focus on",
                                                choices = NULL, multiple = TRUE,
                                                selected = NULL, selectize = FALSE
                                       		)
                                     	)
                                  	)
                                ),
                                fluidRow(
                                    br(), br(),
                                    column(2,
                                        conditionalPanel(
                                           	condition = "input.low25district == false",
                                           		sliderInput("alphaPt",
                                                    "Move Slider to Adjust the Transparency of the Points",
                                                    min = 0, max = 1, step = .01, value = 0.5,
                                                    animate = FALSE)
                                        ),
                                        conditionalPanel(
                                            condition = "input.low25district == false",
                                           		selectInput("growgapdata",
                                                    "Select the data you would like to graph",
                                                    choices = c("Schools and Districts" = "all",
                                                                "Districts Only" = "dist",
                                                                "Schools Only" = "sch"),
                                                    selected = "all", multiple = FALSE, selectize = TRUE
                                           		)
                                        ),
                                        selectInput("subzoom",
                                            "Select an AMO SubGroup to view disaggregated results",
                                            choices = NULL, multiple = FALSE,
                                            selectize = TRUE, selected = NULL
                                        ),
                                         conditionalPanel(
                                           condition = "input.low25district == true",
                                           selectInput("gapSingleDistrict",
                                                       "The district you would like to explore further",
                                                       choices = NULL, multiple = FALSE,
                                                       selected = NULL, selectize = TRUE
                                           )
                                         ),
                                         conditionalPanel(
                                           condition = "input.low25district == true",
                                           checkboxInput("gapBars",
                                                         "Check the box below to view the Math results",
                                                         FALSE
                                           )
                                         )
                                  ),
                                  column(8,
                                         mainPanel(
                                           ggvis::ggvisOutput("growthGapPlot")
                                         )
                                  )
                                ),
                                fluidRow(
                                  column(6,
                                         conditionalPanel(
                                           condition = "input.low25district === false",
                                           #includeMarkdown("apptext/scattergap.Rmd")
                                           helpText("Help Text Here")
                                         )
                                  ),
                                  column(6,
                                         conditionalPanel(
                                           condition = "input.low25district === true",
                                           #includeMarkdown("apptext/bargap.Rmd")
                                           helpText("Help Text Here")
                                         )
                                  )
                                )
                       )
            ),
        navbarMenu("Data Downloads",
            tabPanel("Tables",
            fluidRow(
                column(2,
                    selectInput("datatype",
                            "What format would you like to download the data in?",
                            choices = list(
                                "MS Excel" = ".xlsx",
                                "Comma Separated" = ".csv",
                                "Stata" = ".dta",
                                "R" = ".RData"),
                            selected = NULL, multiple = FALSE,
                            selectize = FALSE),
                    checkboxInput("smallDataView",
                            "Would you like the condensed version of the data?",
                            TRUE),
                    downloadButton("datadl"),
                    conditionalPanel(
                        condition = "input.condensedView == true",
                        helpText("District", br(), "School", br(),
                                 "Official Grade", br(),
                                 "Past Grade = 12-13 Grade",  br(),
                                 "w/o Waiver = 13-14 Grade w/o ESEA Waiver",  br(),
                                 "Total Points", br(),
                                 "RLA Prof = Reading Proficiency", br(),
                                 "Math Prof = Math Proficiency",  br(),
                                 "Sci. Prof= Science Proficiency",  br(),
                                 "Hist. Prof = US History Proficiency",  br(),
                                 "Gr. All RLA = Reading Growth All Students",  br(),
                                 "Gr. All Math = Math Growth All Students",  br(),
                                 "Gr. L25 RLA = Reading Growth Low 25% Students",  br(),
                                 "Gr. L25 Math = Math Growth Low 25% Students",  br(),
                                 "Grad = Graduation Rate", br(),
                                 "Part. = Test Participation Rate")
	                    ),
	                    conditionalPanel(
	                        condition = "input.condensedView == false",
	                        helpText("For a codebook containing a description", br(),
	                                 "of all of the variables in the full view", br(),
	                                 "please click the download button below."),
	                        br(),
	                        downloadButton("codebook"),
	                        helpText("Note: This download button is for the", br(),
	                                 "codebook only.  Use the button on the top", br(),
	                                 "to download the data.")
	                    )
	                ),
	                column(10,
                        dataTableOutput("MSASdata")
                	)
            	)
        	)
        ),
        navbarMenu("Reports",
             tabPanel("Districts",
                      fluidRow(
                        column(4,
                               selectInput("distreport",
                                           "Select what you would like to include in your district report",
                                           choices = NULL, selected = NULL,
                                           multiple = TRUE, selectize = TRUE
                               )
                        ),
                        column(8,
                               downloadButton("distrepdl", "Download the District Report"),
                               helpText("Report Preview") #,
                               #out
                        )
                      )
             ),
             tabPanel("Schools",
                  fluidRow(
                    column(4,
                       selectInput("schoolreport",
                                   "Select what you would like to include in your district report",
                                   choices = NULL, selected = NULL,
                                   multiple = TRUE, selectize = TRUE
                       )
                    ),
                    column(8,
                       downloadButton("schrepdl", "Download the District Report"),
                       helpText("Report Preview") #,
                       #out
                    )
                  )
             )
        ),
        tabPanel("Component Weighting",
        		 fluidRow(
        		 	column(3,
        		 		   sliderInput("gradwgt",
        		 		   			"Select the weight of the Graduation Component",
        		 		   			min = 0, max = 3, value = 1, step = .01
        		 		   ) ,
        		 		   uiOutput("historywgt")
        		 	),
        		 	column(6,
        		 		   plotOutput("userSchWgt")
        		 	),
                    column(3,
                        tableOutput("wgtTable")
                    )
        		 ),
        		 fluidRow(
        		 	column(3,
        		 		   textOutput("sciencewgt")
        		 	),
        		 	column(6,
        		 		   plotOutput("currentSchWgt")
        		 	),
                    column(3,
                           tableOutput("currGradeTable")
                    )
        		 )
        )
    )
)

