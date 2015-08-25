msasplot <- function(data, x = NULL, y = NULL, dist = NULL, 
                     sch = NULL, smooth = NULL, alpha = 1){
    
    # Remove cases from the data where the x and/or y axes are missing
    grdata <- subset(data, !is.na(x) & !is.na(y))
    
    # Create a key variable used by the values function to build the tool tips
    grdata$id <- 1:nrow(grdata)
    
    # Create Highlighter variable
    grdata$highlight <- ifelse(is.null(dist) & is.null(sch), 0,
                        ifelse(!is.null(dist) & is.null(sch) & 
                                  grdata[, distnm %in% dist], 1, 
                        ifelse(!is.null(dist) & !is.null(sch) & 
                                   grdata[, distnm %in% dist & schnm %in% !sch], 1,  
                        ifelse(!is.null(dist) & !is.null(sch) & 
                                   grdata[, distnm %in% dist & schnm %in% sch], 2, 
                        ifelse(is.null(dist) & !is.null(sch) &
                                   grdata[, schnm %in% sch], 2, NA)))))
    
    # Define the function values which is used to build out the tool tip
    values <- function(x){
        if (is.null(x)) return(NULL)
        labs <- grdata[grdata$id == x$id, ]
        tip <- paste("District : ", labs[, 39], "<br />",
                     "School : ", labs[, 2], "<br />", 
                     "<table>",
                        "<tr>", 
                            "<td>", " ", "</td>", 
                            "<td>", "Grade : ", "</td>", 
                            "<td>", labs[, 3], "</td>", 
                            "<td>", "Total Points : ", "</td>", 
                            "<td>", labs[, 4], "</td>", 
                        "</tr>",  
                        "<tr>", 
                            "<td>"," ", "</td>", 
                            "<td>", "Reading", "</td>", 
                            "<td>", "Math", "</td>", 
                            "<td>", "Science", "</td>", 
                            "<td>", "US History", "</td>", 
                        "</tr>",
                        "<tr>", 
                            "<td>", "Proficiency", "</td>", 
                            "<td>", labs[, 10], "</td>", 
                            "<td>", labs[, 11], "</td>", 
                            "<td>", labs[, 12], "</td>",
                            "<td>", labs[, 13], "</td>", 
                        "</tr>",  
                        "<tr>",
                            "<td>", "Growth All", "</td>",  
                            "<td>", labs[, 5], "</td>",  
                            "<td>", labs[, 6], "</td>",  
                            "<td>", "Graduation Rate", "</td>",  
                            "<td>", "Participation Rate", "</td>", 
                        "</tr>", 
                        "<tr>",
                            "<td>", "Growth Low 25%", "</td>",  
                            "<td>", labs[, 7], "</td>",  
                            "<td>", labs[, 8], "</td>",  
                            "<td>", labs[, 9], "</td>",  
                            "<td>", labs[, 14], "</td>", 
                        "</tr>",
                     "</table>")
    }
    
    grdata %>% ggvis(eval(paste0("~", quote(x))), eval(paste0("~", quote(y))), 
        key := ~id, opacity = alpha) %>% layer_points() %>% add_tooltip(values, "hover")
    
    bind_shiny("ggvis", "ggvis_ui")
    
}