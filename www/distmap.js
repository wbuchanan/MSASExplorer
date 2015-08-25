var margins = {top: 20, right: 20, bottom: 20, left: 20}, 
	width = 500,
    height = 650,
    active = d3.select(null);

var projection = d3.geo.albers();

var zoom = d3.behavior.zoom()
    .translate([0, 0])
    .scale(1)
    .scaleExtent([1, 8])
    .on("zoom", zoomed);
    
var path = d3.geo.path()
    .projection(projection);

var svg = d3.select("body").append("svg")
    .attr("width", width)
    .attr("height", height)
    .on("click", stopped, true);

svg.append("rect")
    .attr("class", "background")
    .attr("width", width)
    .attr("height", height)
    .on("click", reset);

var g = svg.append("g");

svg
    .call(zoom) // delete this line to disable free zooming
    .call(zoom.event);

d3.json("distgeo.json", function(error, districts) {
  var distgeo = topojson.feature(districts, districts.objects.distgeo);
  projection
      .scale(7176.509806548226)
      .translate([-451.1837806114247, -419.77615822543294]);

g.selectAll("path")
      .data(distgeo.features.filter(function(d) { return (d.id / 10000 | 0) % 100 !== 99; }))
    .enter().append("path")
      .attr("class", "distgeo")
      .attr("d", path)
      .attr("class", "feature")
      .on("click", clicked);
      
g.append("path")
      .datum(topojson.mesh(districts, districts.objects.distgeo, function(a, b) { return a !== b; }))
      .attr("class", "mesh")
      .attr("d", path);

});

d3.select(self.frameElement).style("height", height + "px");

function clicked(d) {
  if (active.node() === this) return reset();
  active.classed("active", false);
  active = d3.select(this).classed("active", true);

  var bounds = path.bounds(d),
      dx = bounds[1][0] - bounds[0][0],
      dy = bounds[1][1] - bounds[0][1],
      x = (bounds[0][0] + bounds[1][0]) / 2,
      y = (bounds[0][1] + bounds[1][1]) / 2,
      scale = .9 / Math.max(dx / width, dy / height),
      translate = [width / 2 - scale * x, height / 2 - scale * y];

  svg.transition()
      .duration(750)
      .call(zoom.translate(translate).scale(scale).event);
}

function reset() {
  active.classed("active", false);
  active = d3.select(null);

  svg.transition()
      .duration(750)
      .call(zoom.translate([0, 0]).scale(1).event);
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
