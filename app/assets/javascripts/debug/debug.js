var lineData=JSON.parse(document.getElementById('sparkline').value).map(function(obs){
    return {
        x:new Date(obs.index),
        y:obs.value
    }
});

var observations_points=JSON.parse(document.getElementById('observations').value).map(function(obs){
    return {
        x:new Date(obs.index),
        y:obs.value
    }
});

var bands_lower=JSON.parse(document.getElementById('bands').value).map(function(obs){
    return {
        x:new Date(obs.date),
        y:obs.low
    }
});

var bands_upper=JSON.parse(document.getElementById('bands').value).map(function(obs){
    return {
        x:new Date(obs.date),
        y:obs.high
    }
});

var events=JSON.parse(document.getElementById('events').value).map(function(obs){
    var date=new Date(obs.date);
    for(var i in lineData){
        if(lineData[i].x.getTime()===date.getTime()){
            return{
                x:date,
                y:lineData[i].y
            }
        }
    }
});

var datas=[lineData,observations_points,bands_lower,bands_upper];
var min_data_y=d3.min(datas.map(function(data){
    return d3.min(data,function(d){return d.y});
}));

var max_data_y=d3.max(datas.map(function(data){
    return d3.max(data,function(d){return d.y});
}));

var chart_x_min=Math.min(d3.min(lineData, function(d) {
    return d.x;
}),d3.min(observations_points, function(d) {
    return d.x;
}));

var chart_x_max=Math.max(d3.max(lineData, function(d) {
    return d.x;
}),d3.max(observations_points, function(d) {
    return d.x;
}));

var chart_y_min=min_data_y;

var chart_y_max=max_data_y;

var vis = d3.select('#debug-chart'),
    WIDTH = d3.select('#debug-chart')[0][0].offsetWidth,
    HEIGHT = d3.select('#debug-chart')[0][0].offsetHeight,
    MARGINS = {
        top: 20,
        right: 20,
        bottom: 20,
        left: 50
    },
    xRange = d3.time.scale().range([MARGINS.left, WIDTH - MARGINS.right]).domain([chart_x_min, chart_x_max]),
    yRange = d3.scale.linear().range([HEIGHT - MARGINS.top, MARGINS.bottom]).domain([chart_y_min, chart_y_max]),
    xAxis = d3.svg.axis()
        .scale(xRange)
        .tickSize(5)
        .tickSubdivide(true),
    yAxis = d3.svg.axis()
        .scale(yRange)
        .tickSize(5)
        .orient('left')
        .tickSubdivide(true);

vis.append('svg:g')
    .attr('class', 'x axis')
    .attr('transform', 'translate(0,' + (HEIGHT - MARGINS.bottom) + ')')
    .call(xAxis);

vis.append('svg:g')
    .attr('class', 'y axis')
    .attr('transform', 'translate(' + (MARGINS.left) + ',0)')
    .call(yAxis);

function displayPopup(position,text){
    var popup=document.getElementById('debug-popup');
    if(!popup){
        popup=document.createElement('div');
        popup.setAttribute('id','debug-popup');
        document.body.appendChild(popup)
    }
    popup.setAttribute('style','top:'+(position[1]+document.getElementById('debug-chart').offsetTop)+'px;left:'+(position[0]+document.getElementById('debug-chart').offsetLeft+20)+'px;');
    popup.innerHTML=text;
}

function hidePopup(){
    var popup=document.getElementById('debug-popup');
    if(popup){
        popup.setAttribute('style','display:none;');
    }
}

var lineFunc = d3.svg.line()
    .x(function(d) {
        return xRange(d.x);
    })
    .y(function(d) {
        return yRange(d.y);
    })
    .interpolate('linear');

vis.append('svg:path')
    .attr('d', lineFunc(lineData))
    .attr('stroke', 'blue')
    .attr('stroke-width', 2)
    .attr('fill', 'none')
    .on('mouseover',function(){
        xpos=xRange.invert(d3.mouse(this)[0]);
        var closestDate=lineData.sort(function(a,b){return Math.abs(xpos.getTime()- a.x.getTime())-Math.abs(xpos.getTime()- b.x.getTime())})[0].x;
        var text='Date:'+closestDate+"<br/>";
        var closestLineData=lineData.filter(function(d){return d.x===closestDate});
        if(closestLineData.length){
            text+='<b>Sparkline</b><br/>Value:'+closestLineData[0].y+'<br/>'
        }
        var closestUpperBand=bands_upper.filter(function(d){return d.x.getTime()===closestDate.getTime()});
        if(closestUpperBand.length){
            text+='<b>Upper band</b><br/>Value:'+closestUpperBand[0].y+'<br/>'
        }
        var closestLowerBand=bands_lower.filter(function(d){return d.x.getTime()===closestDate.getTime()});
        if(closestLowerBand.length){
            text+='<b>Lower band</b><br/>Value:'+closestLowerBand[0].y+'<br/>'
        }
        displayPopup(d3.mouse(this),text);
    })
    .on('mouseout',hidePopup);

for(var i in observations_points){
    (function(observation){
        vis.append('circle')
            .attr('r', 3)
            .attr("cx", xRange(observation.x))
            .attr("cy", yRange(observation.y))
            .on('mouseover',function(){
                displayPopup(d3.mouse(this),'<b>Observation</b><br/>Date:'+observation.x+'<br/>Value:'+observation.y);
            })
            .on('mouseout',hidePopup);
    })(observations_points[i])
}


vis.append('svg:path')
    .attr('d', lineFunc(bands_lower))
    .attr('stroke', 'red')
    .attr('stroke-width', 2)
    .attr('fill', 'none');

vis.append('svg:path')
    .attr('d', lineFunc(bands_upper))
    .attr('stroke', 'red')
    .attr('stroke-width', 2)
    .attr('fill', 'none');

for(var i in events){
    (function(event){
        vis.append('circle')
            .attr('r', 5)
            .attr("cx", xRange(event.x))
            .attr("cy", yRange(event.y))
            .attr('style','fill:red;')
            .on('mouseover',function(){
                displayPopup(d3.mouse(this),'<b>Event</b><br/>Date:'+event.x+'<br/>');
            })
            .on('mouseout',hidePopup);
    })(events[i]);
}