//Event list

(function() {
    function hideEventsAfter(num) {
        var allEventsPage = document.getElementsByClassName('all-events');
        if(allEventsPage.length){
            var events = allEventsPage[0].getElementsByClassName('event');

            for (var j = 0; j < events.length; j++) {
                if(j<num){
                    // show grandparent with all its content
                    events[j].parentNode.parentNode.style.display = 'block';
                }
                if(j==num-1 && events[j].className.indexOf('lastevent')==-1){
                    events[j].className+=' lastevent';
                }
                // if reached max elements to show
                if (j >= num) {
                    events[j].style.display = 'none';
                    events[j].style.opacity=0;
                }
            }

            var seeMoreButton=document.getElementById('see-all');

            function hideSeeMore(){
                seeMoreButton.style.display='none';
                for(var j=0;j<events.length;j++){
                    if(events[j].className.indexOf('lastevent')!=-1){
                        events[j].className = (events[j].className.replace(/\blastevent\b/,''));
                    }
                }
            }

            if(events.length<=num){
                hideSeeMore();
            }

            seeMoreButton.addEventListener('click',function(){
                var events = allEventsPage[0].getElementsByClassName('event');
                for (var j = num; j < events.length; j++) {
                    setTimeout(function(event){
                        return function(){
                            event.parentNode.parentNode.style.display = 'block';
                            event.style.display = 'block';
                            setTimeout(function(){
                                event.style.opacity=1;
                            },0);
                        }
                    }(events[j]),(j-num)*100);
                }
                hideSeeMore();
            });
        }
    }

    window.onload = (function(pre) {
        return function() {
            pre && pre.apply(this, arguments);
            hideEventsAfter(5);
        };
    })(window.onload);

})();

//Sparkline

uphex=window.uphex || {};

/**
 * @typedef {Object}
 * @property {number} x
 * @property {number} y
 */
uphex.Point;

/**
 * @typedef {Array.<uphex.Point>}
 * */
uphex.QuadraticSegment;

/**
 * @typedef {Object}
 * @property {number} minX
 * @property {number} minY
 * @property {number} width
 * @property {number} height
 */
uphex.ViewBox;

/**
 * @typedef {Object}
 * @property {number} min
 * @property {number} max
 */
uphex.MinMax;

(function(){
    /**
     * @param {Array.<uphex.Point>} points
     * @returns {Array.<uphex.QuadraticSegment>}
     * */
    function catmullRom2bezier(points) {
        var result = [];
        for (var i = 0; i < points.length - 1; i++) {
            var p = [];

            p.push({
                x: points[Math.max(i - 1, 0)].x,
                y: points[Math.max(i - 1, 0)].y
            });
            p.push({
                x: points[i].x,
                y: points[i].y
            });
            p.push({
                x: points[i + 1].x,
                y: points[i + 1].y
            });
            p.push({
                x: points[Math.min(i + 2, points.length - 1)].x,
                y: points[Math.min(i + 2, points.length - 1)].y
            });

            // Catmull-Rom to Cubic Bezier conversion matrix
            //    0       1       0       0
            //  -1/6      1      1/6      0
            //    0      1/6      1     -1/6
            //    0       0       1       0

            var bp = [];
            //bp.push( { x: p[1].x,  y: p[1].y } );
            bp.push({
                x: ((-p[0].x + 6 * p[1].x + p[2].x) / 6),
                y: ((-p[0].y + 6 * p[1].y + p[2].y) / 6)
            });
            bp.push({
                x: ((p[1].x + 6 * p[2].x - p[3].x) / 6),
                y: ((p[1].y + 6 * p[2].y - p[3].y) / 6)
            });
            bp.push({
                x: p[2].x,
                y: p[2].y
            });
            result.push(bp);
        }

        return result;
    }

    /**
     * @param {Array.<number>} sparkline
     * @return {uphex.MinMax}
     * */
    function calculateMinMax(sparkline){
        var min = Number.MAX_VALUE;
        var max = Number.NEGATIVE_INFINITY;
        for (var i = 0; i < sparkline.length; i++) {
            min = Math.min(min, sparkline[i]);
            max = Math.max(max, sparkline[i]);
        }
        return {min:min,max:max}
    }

    /**
     * @param {Array.<number>} sparkline
     * @param {number} center
     * @param {number} left
     * @param {number} right
     * @param {number} bottom
     * @param {number} top
     * @return {Array.<uphex.Point>}
     * */
    function sparkline2Points(sparkline,center,left,right,bottom,top) {
        var result = [];
        var leftmost = Math.floor(center - Math.floor(Math.max(center, sparkline.length - center)));
        var rightmost = Math.ceil(center + Math.floor(Math.max(center, sparkline.length - center)));
        var minmax=calculateMinMax(sparkline);
        for (var i = 0; i < sparkline.length; i++) {
            result.push({
                x: left+(right-left)/(rightmost-leftmost-1)*(i-leftmost),
                y: bottom+(sparkline[i]-minmax.min)/(minmax.max-minmax.min)*(top-bottom)
            });
        }
        return result;
    }

    /**
     * @param {Array.<number>} sparkline
     * @param {number} center
     * @param {number} left
     * @param {number} right
     * @param {number} bottom
     * @param {number} top
     * @return {string}
     * */
    function sparkline2SVG(sparkline,center,left,right,bottom,top) {
        var points=sparkline2Points(sparkline,center,left,right,bottom,top);
        var result = "M"+points[0].x+"," + points[0].y + " ";
        var catmull = catmullRom2bezier(points);
        for (var i = 0; i < catmull.length; i++) {
            result += "C" + catmull[i][0].x + "," + catmull[i][0].y + " " + catmull[i][1].x + "," + catmull[i][1].y + " " + catmull[i][2].x + "," + catmull[i][2].y + " ";
        }
        return result;
    }

    function initializeSparkline(){
        var sparklines=document.getElementsByClassName('mod-sparkline');
        for(var spi=0;spi<sparklines.length;spi++){
            var sparklineElement=sparklines[spi];
            var containerWidth=sparklineElement.parentNode.offsetWidth;
            var containerHeight=sparklineElement.parentNode.offsetHeight;
            /** @const*/
            var padding=3;
            /** @type {Array.<number>}*/
            var sparkline = JSON.parse(sparklineElement.getAttribute('data-sparkline'));

            /** @const*/
            var minmax=calculateMinMax(sparkline);

            var center = null;
            if (sparklineElement.getAttribute('data-center')) {
                center = parseFloat(sparklineElement.getAttribute('data-center'))
            } else {
                center = sparkline.length / 2;
            }

            var groupElement=sparklineElement.getElementsByTagNameNS('*', 'g')[0];
            groupElement.setAttribute("transform","scale(1,-1) translate(0,-"+containerHeight+")");
            groupElement.getElementsByTagNameNS('*','path')[0].setAttribute('d', sparkline2SVG(sparkline,center,padding,containerWidth-2*padding,padding,containerHeight-2*padding));

            var eventpredictedstart = null;
            var eventpredictedend = null;
            if (sparklineElement.getAttribute('data-predictedstart')) {
                eventpredictedstart = parseFloat(sparklineElement.getAttribute('data-predictedstart'));
                eventpredictedend = parseFloat(sparklineElement.getAttribute('data-predictedend'));
            }

            sparklineElement.setAttribute('viewBox', "0 0 "+containerWidth+" "+containerHeight);
            var circles = sparkline2Points(sparkline,center,padding,containerWidth-2*padding,padding,containerHeight-2*padding);
            for (var i = 0; i < circles.length; i++) {
                if (!eventpredictedstart || i !== center) {
                    var c = document.createElementNS("http://www.w3.org/2000/svg", "circle");
                    c.setAttribute("cx", circles[i].x);
                    c.setAttribute("cy", circles[i].y);
                    c.setAttribute("r", "3");
                    groupElement.appendChild(c);
                }
            }

            if (typeof eventpredictedstart === "number") {
                var ec = document.createElementNS("http://www.w3.org/2000/svg", "circle");
                ec.setAttribute("cx", circles[center].x);
                ec.setAttribute("cy", circles[center].y);
                ec.setAttribute("r", "3");
                ec.setAttribute('class', 'event');
                groupElement.appendChild(ec);

                function calculateEventY(y){
                    return padding+(y-minmax.min)/(minmax.max-minmax.min)*(containerHeight-2*padding-padding);
                }

                var rect = document.createElementNS("http://www.w3.org/2000/svg", "rect");
                rect.setAttribute("x", String((circles[center-1].x+circles[center].x)/2));
                rect.setAttribute("y", String(calculateEventY(eventpredictedstart)));
                rect.setAttribute("width", String((circles[center].x+circles[center+1].x)/2-(circles[center-1].x+circles[center].x)/2));
                rect.setAttribute("height", String(calculateEventY(eventpredictedend)-calculateEventY(eventpredictedstart)));
                rect.setAttribute("fill", "lightGrey");
                groupElement.appendChild(rect);

                var l1 = document.createElementNS("http://www.w3.org/2000/svg", "line");
                l1.setAttribute("x1", String((circles[center-1].x+circles[center].x)/2));
                l1.setAttribute("y1", String(0));
                l1.setAttribute("x2", String((circles[center-1].x+circles[center].x)/2));
                l1.setAttribute("y2", String(containerHeight));
                groupElement.appendChild(l1);

                var l2 = document.createElementNS("http://www.w3.org/2000/svg", "line");
                l2.setAttribute("x1", String((circles[center].x+circles[center+1].x)/2));
                l2.setAttribute("y1", String(0));
                l2.setAttribute("x2", String((circles[center].x+circles[center+1].x)/2));
                l2.setAttribute("y2", String(containerHeight));
                groupElement.appendChild(l2);
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

// linked table rows for .mod-clients
(function() {
	function initTableLinks() {
		var clientsTable = document.getElementsByClassName('mod-clients');
		if (clientsTable.length) {
			var rows = clientsTable[0].getElementsByTagName('tr');
			for (var i = 0; i < rows.length; i++) {
				var link = rows[i].getAttribute('data-link');
				rows[i].onclick = (function(link) {
					return function() {
						window.location = link;
					}
				})(link);
			}
		}
	}

	window.onload = (function(pre){
		return function(){
			pre && pre.apply(this,arguments);
			initTableLinks();
		};
	})(window.onload);

})();