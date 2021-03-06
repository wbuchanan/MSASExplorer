var d3OutputBinding = new Shiny.OutputBinding();
    $.extend(d3OutputBinding, {
    find: function(scope) {
        return $(scope).find('.msasMap');
    }});

		// Define the color scale for the district grades/polygons
		var distGradeColor = d3.scale.ordinal().domain(["N/A", "A", "B", "C", "D", "F"])
								.range(["rgb(245,245,245)","rgb(141,211,199)", "rgb(255,255,179)", "rgb(190,186,218)", "rgb(251,128,114)", "rgb(128,177,211)"]);

		// Define a separate color scale for school grades/points that uses
		// colors with greater saturation to make them stand out
		var schGradeColor = d3.scale.ordinal().domain(["N/A", "A", "B", "C", "D", "F"])
								.range(["rgb(240,249,232)", "rgb(228,26,28)", "rgb(55,126,184)", "rgb(77,175,74)", "rgb(152,78,163)", "rgb(255,127,0)"]);

		// This sets the margins, height, and width of the map
		var margins = {top: 25, right: 25, bottom: 25, left: 25}, 
						width = 600,
						height = 900,
						active = d3.select(null);

		// Set the projection algorithm to map the geo coordinates onto a 2D plane
		var projection = d3.geo.albersUsa();

		// Define the parameters used for the zoom function        
		var zoom = d3.behavior.zoom().translate([0, 0]).scale(1)
					.scaleExtent([1, 8]).on("zoom", zoomed);

		// Create a variable with the path generator to draw the maps
		var path = d3.geo.path().projection(projection);

		// Create an svg element on the page (this is where the map will be displayed)
		// Also defines the height & width of the svg image as well as the zoom to district on click behavior
		var svg = d3.select("#distmap").append("svg").attr("width", width)
					.attr("height", height).on("click", stopped, true);

		// This adds a background rectange to help distinguish the map from the rest of the page
		// The reset behavior is what makes the map zoom back out to the state
		svg.append("rect").attr("class", "background")
		.attr("width", width).attr("height", height).on("click", reset);

		// Now we create a variable that will attach things to the svg element
		var g = svg.append("g");

		// zoom enables free zooming.  It can distort some of the visuals, but isn't harmful
		// zoom.event is used for zooming to an individual district
		svg.call(zoom).call(zoom.event);

		// Function that loads and draws the district level data to the svg element
		d3.json("distgrades.json", function(error, districts) {
			
				// Store the district data in a variable called distgrades
				var distgrades = topojson.feature(districts, districts.objects.distgrades);

				// The next four lines are used to determine the best scale and transform parameters
				// to fit the map in this size canvas
				projection.scale(1).translate([0, 0]);
				var b = path.bounds(distgrades),
				s = .95 / Math.max((b[1][0] - b[0][0]) / width, (b[1][1] - b[0][1]) / height),
				t = [(width - s * (b[1][0] + b[0][0])) / 2, (height - s * (b[1][1] + b[0][1])) / 2];

				// Now that the calculation is done, we can use those values to project the district
				// geographies to the HTML document and draw the map
				projection.scale(s).translate(t); 

d3.helper = {};
d3.helper.tooltip = function(accessor){
    return function(selection){
        var tooltipDiv;
        var bodyNode = d3.select('body').node();
        selection.on("mouseover", function(d, i){
            // Clean up lost tooltips
            d3.select('body').selectAll('body').remove();
            // Append tooltip
            tooltipDiv = d3.select('body').append('div').attr('class', 'tooltip');
            var absoluteMousePos = d3.mouse(bodyNode);
            tooltipDiv.style('left', (absoluteMousePos[0])+'px')
                .style('top', (absoluteMousePos[1])+'px')
                .style('position', 'absolute') 
                .style('opacity', '1')
                .style('z-index', 1001);
            // Add text using the accessor function
            var tooltipText = accessor(d, i) || '';
           
        })
        .on('mousemove', function(d, i) {
            // Move tooltip
            var absoluteMousePos = d3.mouse(bodyNode);
            tooltipDiv.style('left', (absoluteMousePos[0])+'px')
                .style('top', (absoluteMousePos[1])+'px');
            var tooltipText = accessor(d, i) || '';
            tooltipDiv.html(tooltipText);
        })
        .on("mouseout", function(d, i){
            // Remove tooltip
            tooltipDiv.remove();
        });

    };
} ;



				// Select all of the paths that we are going to draw based on the id property in the data
				// On entering, add the path to the svg element, give this a class called distgrades
				// Set the d attribute to the data, define the on-click function caller
				// And get the colors from the color palatte for districts defined above
				g.selectAll("path")
					.data(distgrades.features.filter(function(d) { return (d.id / 10000 | 0) % 100 !== 99; }))
					.enter().append("path")
					.attr("class", "distgrades")
					.attr("d", path)
					.on("click", clicked)
					.style("fill", function(d) {
						var thisDistrictColor = d.properties.grade;
							if (thisDistrictColor) {
								return distGradeColor(thisDistrictColor);
							} else {
								return "#FFFFFF"
							}
						}
					)
					.style("opacity", 0.75)
					.call(d3.helper.tooltip(function(d, i){
							if (d.properties.distnm === undefined) {
								return null
							} else {
								return "District : " + d.properties.distnm + "<br />" +
								"<table>" + "<tr>" + "<td>" + " " + "</td>" +
								"<td>" + "Grade : " + "</td>" + "<td>" + d.properties.grade + "</td>" +
								"<td>" + "Total Points : " + "</td>" + "<td>" + d.properties.totpts + "</td>" +
								"</tr>" + "<tr>" + "<td>" +" " + "</td>" + "<td>" + "Reading" + "</td>" +
								"<td>" + "Math" + "</td>" + "<td>" + "Science" + "</td>" + "<td>" + "US History" + "</td>" +
								"</tr>" + "<tr>" + "<td>" + "Proficiency" + "</td>" +
								"<td>" + d.properties.prorla + "</td>" +
								"<td>" + d.properties.promth + "</td>" +
								"<td>" + d.properties.prosci + "</td>" +
								"<td>" + d.properties.prohis + "</td>" + "</tr>" + "<tr>" +
								"<td>" + "Growth All" + "</td>" + "<td>" + d.properties.grorla + "</td>" +
								"<td>" + d.properties.gromth + "</td>" + "<td>" + "Graduation" + "</td>" +
								"<td>" + "Participation" + "</td>" + "</tr>" + "<tr>" +
								"<td>" + "Growth Low 25%" + "</td>" + "<td>" + d.properties.grolrla + "</td>" +
								"<td>" + d.properties.grolmth + "</td>" +
								"<td>" + d.properties.grad + "</td>" + "<td>" + d.properties.partic + "</td>" + "</tr>" + "</table>" + "<br />" + 
								"<table>" + "<tr>" + "<td style='width: 125px'><strong>District Legend</strong></td>" +
								"<td style='background-color: rgb(245,245,245); width: 50px'><strong>N/A</strong></td>" +
								"<td style='background-color:rgb(141,211,199); width: 50px'><strong>A</strong></td>" +
								"<td style='background-color:rgb(255,255,179); width: 50px'><strong>B</strong></td>" +
								"<td style='background-color:rgb(190,186,218); width: 50px'><strong>C</strong></td>" +
								"<td style='background-color:rgb(251,128,114); width: 50px'><strong>D</strong></td>" +
								"<td style='background-color:rgb(128,177,211); width: 50px'><strong>F</strong></td>" + "</tr>" + "</table>";
							}                 
						}
					)
				);

				// Add the path element to the mesh that will show and outline all of the polygons
				g.append("path")
				.datum(topojson.mesh(districts, districts.objects.distgrades, function(a, b) { return a !== b; }))
				.attr("class", "mesh").attr("d", path);
			}
		);

		// Select the frame (where the map lives)
		d3.select(self.frameElement).style("height", height + "px");

		// Define the function to control the zooming to the district shapes
		function clicked(d) {
		if (active.node() === this) return reset();
		active.classed("active", false);
		active = d3.select(this).classed("active", true);
		var bounds = path.bounds(d),
		dx = bounds[1][0] - bounds[0][0],
		dy = bounds[1][1] - bounds[0][1],
		x = (bounds[0][0] + bounds[1][0]) / 2,
		y = (bounds[0][1] + bounds[1][1]) / 2,
		scale = .95 / Math.max(dx / width, dy / height),
		translate = [width / 2 - scale * x, height / 2 - scale * y];
		var district = d.id;

d3.helper = {};
d3.helper.tooltip = function(accessor){
    return function(selection){
        var tooltipDiv;
        var bodyNode = d3.select('body').node();
        selection.on("mouseover", function(d, i){
            // Clean up lost tooltips
            d3.select('body').selectAll('body').remove();
            // Append tooltip
            tooltipDiv = d3.select('body').append('div').attr('class', 'tooltip');
            var absoluteMousePos = d3.mouse(bodyNode);
            tooltipDiv.style('left', (absoluteMousePos[0])+'px')
                .style('top', (absoluteMousePos[1])+'px')
                .style('position', 'absolute') 
                .style('opacity', '1')
                .style('z-index', 1001);
            // Add text using the accessor function
            var tooltipText = accessor(d, i) || '';
           
        })
        .on('mousemove', function(d, i) {
            // Move tooltip
            var absoluteMousePos = d3.mouse(bodyNode);
            tooltipDiv.style('left', (absoluteMousePos[0])+'px')
                .style('top', (absoluteMousePos[1])+'px');
            var tooltipText = accessor(d, i) || '';
            tooltipDiv.html(tooltipText);
        })
        .on("mouseout", function(d, i){
            // Remove tooltip
            tooltipDiv.remove();
        });

    };
} ;

		// Create a transition to the district shape;
		// At the end of the transition display the school points and define
		// the tooltip for the school points
		svg.transition().call(zoom.translate(translate).scale(scale).event)
		.each("end", function(d) {
			
				// After transitioning load the school data
			 	d3.json("schoolgrades.json", function(error, schools) {
			 		
			 		// Store the school data for the district in an object called district
			 		dist = schools.objects.schools.geometries ;

					var theSchool = svg.selectAll("circle")
						.data(dist.filter(function(d) { return d.properties.distid == district ;}))
						.enter().append("circle")
						.attr("cx", function(d) {
							return projection([d.properties.lon, d.properties.lat])[0] * scale + translate[0];
						})
						.attr("cy", function(d) {
							return projection([d.properties.lon, d.properties.lat])[1] * scale + translate[1];
						})                     
						.attr("r", 3.5)
						.attr("class", "schPoints")
						.style("fill", function(schgrade) {
								var thisSchoolColor = schgrade.properties.grade;
								if (thisSchoolColor) {
									return schGradeColor(thisSchoolColor)
								} else {
									return none
								}
							}
						)
						.style("opacity", 0.75)
						.style("stroke", "black")
						.style("stroke-width", "0.25")
						.call(d3.helper.tooltip(
							function(d, i){
									if (!d.properties.grade) {
										var grade = 'N/A';
									} else {
										var grade = d.properties.grade;
									}
									if (d.properties.dalabel === undefined) {
										var dalabel = 'N/A';
									} else {
										var dalabel = d.properties.dalabel;
									}
									if (d.properties.prohis === undefined) {
										var prohis = 'N/A';
									} else {
										var prohis = d.properties.prohis;
									}
									if (!d.properties.prosci | d.properties.sci == 0) {
										var prosci = 'N/A';
									} else {
										var prosci = d3.round(d.properties.prosci, 1);
										if (prosci == 0) {
										    prosci = 'N/A';
										} 
									}
									if (d.properties.partic === undefined || d.properties.partic == 0) {
										var partic = 'N/A';
									} else {
										var partic = d3.round(d.properties.partic, 1);
									}
									if (!d.properties.grad) {
										return "District : " + d.properties.distnm + "<br />" + "School : " + d.properties.schnm + "<br />" +
										"Differentiated Accountability Label : " + dalabel + "<br />" +
										"<table>" + "<tr>" + "<td>" + "Grade : " + "</td>" + "<td>" + grade + "</td>" +
										"<td>" + "Total Points : " + "</td>" + "<td>" + d.properties.totpts + "</td>" +
										"</tr>" + "<tr>" + "<td>" +" " + "</td>" + "<td>" + "Reading" + "</td>" +
										 "<td>" + "Math" + "</td>" + "<td>" + "Science" + "</td>" + "</tr>" + 
										"<tr>" + "<td>" + "Proficiency" + "</td>" + "<td>" + d.properties.prorla + "</td>" +
										 "<td>" + d.properties.promth + "</td>" + "<td>" + prosci + "</td>" +
										"</tr>" + "<tr>" + "<td>" + "Growth All" + "</td>" + "<td>" + d.properties.grorla + "</td>" +
										"<td>" + d.properties.gromth + "</td>" + "<td>" + "Participation" + "</td>" + "</tr>" + 
										"<tr>" + "<td>" + "Growth Low 25%" + "</td>" + "<td>" + d.properties.grolrla + "</td>" +
										"<td>" + d.properties.grolmth + "</td>" + "<td>" + partic + "</td>" + "</tr>" + "</table>" + "<br />" +
										 "<table>" + "<tr>" + "<td style='width: 125px'><strong>School Legend</strong></td>" +
										"<td style='background-color:rgb(240,249,232); width: 50px'><strong>N/A</strong></td>" +
										"<td style='background-color:rgb(228,26,28); width: 50px'><strong>A</strong></td>" +
										"<td style='background-color:rgb(55,126,184); width: 50px'><strong>B</strong></td>" +
										"<td style='background-color:rgb(77,175,74); width: 50px'><strong>C</strong></td>" +
										"<td style='background-color:rgb(152,78,163); width: 50px'><strong>D</strong></td>" +
										"<td style='background-color:rgb(255,127,0); width: 50px'><strong>F</strong></td>" + "</tr>" + "</table>" ;
									} else {
										var grad = d3.round(d.properties.grad, 1);
										return 	 "District : " + d.properties.distnm + "<br />" + "School : " + d.properties.schnm + "<br />" +
										"Differentiated Accountability Label : " + dalabel + "<br />" + "<table>" + "<tr>" + "<td>" + " " + "</td>" +
										"<td>" + "Grade : " + "</td>" + "<td>" + grade + "</td>" + "<td>" + "Total Points : " + "</td>" + 
										"<td>" + d.properties.totpts + "</td>" + "</tr>" + "<tr>" + "<td>" +" " + "</td>" + "<td>" + "Reading" + "</td>" +
										"<td>" + "Math" + "</td>" + "<td>" + "Science" + "</td>" + "<td>" + "US History" + "</td>" + "</tr>" + "<tr>" + 
										"<td>" + "Proficiency" + "</td>" + "<td>" + d.properties.prorla + "</td>" + "<td>" + d.properties.promth + "</td>" +
										"<td>" + prosci + "</td>" + "<td>" + prohis + "</td>" + "</tr>" + "<tr>" + "<td>" + "Growth All" + "</td>" + 
										"<td>" + d.properties.grorla + "</td>" + "<td>" + d.properties.gromth + "</td>" + "<td>" + "Graduation" + "</td>" +
										"<td>" + "Participation" + "</td>" + "</tr>" + "<tr>" + "<td>" + "Growth Low 25%" + "</td>" + 
										"<td>" + d.properties.grolrla + "</td>" + "<td>" + d.properties.grolmth + "</td>" + "<td>" + grad + "</td>" + 
										"<td>" + partic + "</td>" + "</tr>" + "</table>" + "<br />" + "<table>" + "<tr>" + 
										"<td style='width: 125px'><strong>School Legend</strong></td>" +
										"<td style='background-color:rgb(240,249,232); width: 50px'><strong>N/A</strong></td>" +
										"<td style='background-color:rgb(228,26,28); width: 50px'><strong>A</strong></td>" +
										"<td style='background-color:rgb(55,126,184); width: 50px'><strong>B</strong></td>" +
										"<td style='background-color:rgb(77,175,74); width: 50px'><strong>C</strong></td>" +
										"<td style='background-color:rgb(152,78,163); width: 50px'><strong>D</strong></td>" +
										"<td style='background-color:rgb(255,127,0); width: 50px'><strong>F</strong></td>" + "</tr>" + "</table>";	
									}                    
								}
							)
						);
					}
				)
			}
		);
	}

	function reset() {
		active.classed("active", false);
		active = d3.select(null);
		svg.transition().duration(750)
			.call(zoom.translate([0, 0]).scale(1).event);
		svg.selectAll(".schPoints").remove();
		d3.select(".tooltip").classed("hidden", true);
	}

	function zoomed() {
		g.style("stroke-width", 1.5 / d3.event.scale + "px");
		g.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
	}
	
	// If the drag behavior prevents the default click,
	// also stop propagation so we don’t click-to-zoom.
	function stopped() {
		if (d3.event.defaultPrevented) d3.event.stopPropagation();
	}



Shiny.outputBindings.register(d3OutputBinding,"example.d3OutputBinding");
