(function(){

    function initializeSparkline(){
        var sparklines=document.getElementsByClassName('mod-sparkline');
        for(var spi=0;spi<sparklines.length;spi++){
            /** @const*/
            var sparklineElement=sparklines[spi];
            /** @const*/
            var containerWidth=sparklineElement.parentNode.offsetWidth;
            /** @const*/
            var containerHeight=sparklineElement.parentNode.offsetHeight;
            /** @const*/
            var padding=10;
            /** @type {Array.<number>}
             * @const*/
            var sparkline = JSON.parse(sparklineElement.getAttribute('data-sparkline'));

            //Transform the sparkline to a graph, eg. an array with x and y coordinates
            /** @const*/
            var lineData=(function(){
                var result=[];
                for(var j=0;j<sparkline.length;j++){
                    result.push({x:j,y:sparkline[j]});
                }
                return result;
            })();

            /** The position of the center element
             * @const*/
            var center = sparklineElement.getAttribute('data-center')?parseFloat(sparklineElement.getAttribute('data-center')):sparkline.length / 2;

            /** @const*/
            var eventpredictedstart = sparklineElement.getAttribute('data-predictedstart')?parseFloat(sparklineElement.getAttribute('data-predictedstart')):null;
            /** @const*/
            var eventpredictedend = sparklineElement.getAttribute('data-predictedstart')?parseFloat(sparklineElement.getAttribute('data-predictedend')):null;

            /** The SVG element
             * @const*/
            var vis = d3.select(sparklineElement);

            //Scales
            /** @const*/
            var xRange = d3.scale.linear().range([padding, containerWidth - padding]).domain([d3.min(lineData, function (d) {
                    return d.x;
                }),
                    d3.max(lineData, function (d) {
                        return d.x;
                    })
                ]);

            /** @const*/
            var yRange = d3.scale.linear().range([containerHeight - padding, padding]).domain([d3.min(lineData, function (d) {
                return d.y;
            }),
                d3.max(lineData, function (d) {
                    return d.y;
                })
            ]);

            /** The sparkline
             * @const*/
            var lineFunc = d3.svg.line()
                .x(function (d) {
                    return xRange(d.x);
                })
                .y(function (d) {
                    return yRange(d.y);
                })
                .interpolate('cardinal');

            vis.append("svg:path")
                .attr("d", lineFunc(lineData));

            //The circles. The center circle is skipped
            vis.selectAll("circle")
                .data(lineData.filter(function(d,i){
                    return typeof eventpredictedstart !== "number" || i !== center;
                }))
                .enter().append("circle")
                .attr("r", 3)
                .attr("cx", function(d){return xRange(d.x);})
                .attr("cy", function(d){return yRange(d.y);});

            //If there is event
            if (typeof eventpredictedstart === "number") {
                //The center circle
                vis.append('circle')
                    .attr('cx',xRange(lineData[center].x))
                    .attr('cy',yRange(lineData[center].y))
                    .attr('r',3)
                    .attr('class','event');

                vis.append('rect')
                    .attr('x',xRange(center-0.5))
                    .attr('y',yRange(eventpredictedend))
                    .attr('width',xRange(center+0.5)-xRange(center-0.5))
                    .attr('height',yRange(eventpredictedstart)-yRange(eventpredictedend))
                    .attr('fill','lightGrey');

                vis.append('line')
                    .attr('x1',xRange(center-0.5))
                    .attr('y1',0)
                    .attr('x2',xRange(center-0.5))
                    .attr('y2',containerHeight);

                vis.append('line')
                    .attr('x1',xRange(center+0.5))
                    .attr('y1',0)
                    .attr('x2',xRange(center+0.5))
                    .attr('y2',containerHeight);
            }
        }
    }

    window.onload = (function(pre){
        return function(){
            pre && pre.apply(this,arguments);
            initializeSparkline();
        };
    })(window.onload);

})();