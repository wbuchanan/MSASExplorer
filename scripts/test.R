# Create the combined School Names/ID numbers
schnames <- split(allgrades$schcombo, allgrades$distnm)

# Create the district names
distnames <- unique(allgrades$distnm)

# Create the names of all the quantile variables
colorFilters <- c(grep("(^sch.*q)|(schgrtyp)|(schoverall.*)|(schmetallamos)", 
                       names(allgrades), value = TRUE), "schwaivedgrade", 
                  "schpriorgrade", "schdalabel", "title1", "targetedtitle1")

# Find the column indices that match the variable names
x <- match(colorFilters, names(allgrades))

# Get the variable labels for each of the filter variables
x <- lapply(x, function(x){
    attributes(allgrades)$var.labels[[x]]
})

colorFilters <- list("NA" = NA,
"Statewide Quintiles Total Points" = "schtotpts_q",                    
"Statewide Proficiency Quintiles - RLA" = "schprorla_q",    
"Statewide Proficiency Quintiles - Math" = "schpromth_q",                
"Statewide Proficiency Quintiles - Science" = "schprosci_q", 
"Statewide Proficiency Quintiles - US History" = "schprohis_q",     
"Statewide Growth Quintiles - Reading All Students" = "schgrorla_q",     
"Statewide Growth Quintiles - Math All Students" = "schgromth_q",      
"Statewide Growth Quintiles - Low 25% Students Reading" = "schgrolrla_q",    
"Statewide Growth Quintiles - Low 25% Students Math" = "schgrolmth_q",   
"Statewide Graduation Rate Quintiles" = "schgrad_q",
"School Grade Configuration" = "schgrtyp",         
"AMO Status for Reading" = "schoverallrla",      
"AMO Status for Math" = "schoverallmth",                   
"AMO Status for Other Academic Indicators" = "schoveralloth",                   
"Met All AMO Goals Indicator" = "schmetallamos",                                
"Current Year's Grade" = "schwaivedgrade",
"Prior Year's Grade" = "schpriorgrade", 
"Current Year's DA Label" = "schdalabel",                      
"Title I Status" = "title1",                           
"Targeted Title I Status" = "targetedtitle1")





# Create x variable choices
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


