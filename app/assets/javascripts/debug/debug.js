"use strict";

(function(){
    var lineData=JSON.parse(document.getElementById('sparkline').value).map(function(obs){
        return {
            x:new Date(obs.index),
            y:Number(obs.value)
        }
    }).sort(function(a,b){
        return a.x.getTime()-b.x.getTime();
    });

    var observations_points=JSON.parse(document.getElementById('observations').value).map(function(obs){
        return {
            x:new Date(obs.index),
            y:Number(obs.value)
        }
    }).sort(function(a,b){
        return a.x.getTime()-b.x.getTime();
    });

    var bands_lower=JSON.parse(document.getElementById('bands').value).map(function(obs){
        return {
            x:new Date(obs.date),
            y:Number(obs.low)
        }
    });

    var bands_upper=JSON.parse(document.getElementById('bands').value).map(function(obs){
        return {
            x:new Date(obs.date),
            y:Number(obs.high)
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
        .on('mouseout',hidePopup);


    vis.append('svg:path')
        .attr('d', lineFunc(bands_lower))
        .attr('stroke', 'orange')
        .attr('stroke-width', 2)
        .attr('fill', 'none');

    vis.append('svg:path')
        .attr('d', lineFunc(bands_upper))
        .attr('stroke', 'orange')
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

    var selection_locked=false;
    var selection_mode=null;

    function scrollToSelectedElementOnObservationsTable(){
        var container=$('.data-table .observations-table .table');
        var firstSelected=container.find('.observation-selected,.sparkline-selected')[0];
        if(!(container.scrollTop() <= firstSelected.offsetTop && container.scrollTop()+container.height()>=firstSelected.offsetTop)) {
            container.scrollTop(firstSelected.offsetTop);
        }
    }

    function scrollToSelectedElementOnSparklineTable(){
        var container=$('.data-table .sparkline-table .table');
        var firstSelected=container.find('.observation-selected,.sparkline-selected')[0];
        if(!(container.scrollTop() <= firstSelected.offsetTop && container.scrollTop()+container.height()>=firstSelected.offsetTop)) {
            container.scrollTop(firstSelected.offsetTop);
        }
    }

    function getAffectingObservationsForSparklinePoint(time){
        time=parseInt(time);
        var beginning_of_day=new Date(new Date(time).setUTCHours(0,0,0,0));
        var end_of_day=new Date(new Date(time).setUTCHours(24,0,0,0));
        var first=$.grep(observations_points,function(observation){
            return observation.x.getTime()<=beginning_of_day;
        }).sort(function(obs_a,obs_b){
            return obs_a.x-obs_b.x;
        }).reverse()[0];
        var last=$.grep(observations_points,function(observation){
            return observation.x.getTime()>=end_of_day;
        }).sort(function(obs_a,obs_b){
            return obs_a.x-obs_b.x;
        })[0];
        return $.map($.grep(observations_points,function(observation){
            return observation.x.getTime()>=first.x.getTime() && observation.x.getTime()<=last.x.getTime();
        }),function(observation){
            return observation.x.getTime();
        });
    }

    function getAffectingSparklineForObservation(time){
        time=parseInt(time);
        var result=[];
        var lowerSparklines=$.grep(lineData,function(sparkline){
            return sparkline.x.getTime()<=time;
        }).sort(function(spr_a,spr_b){
            return spr_a.x.getTime()-spr_b.x.getTime();
        }).reverse();
        for(var i=0;i<lowerSparklines.length;i++){
            if($.grep(getAffectingObservationsForSparklinePoint(lowerSparklines[i].x.getTime()),function(observation){
                return observation==time;
            }).length==0){
                break;
            }
            result.push(lowerSparklines[i].x.getTime());
        }

        var upperSparklines=$.grep(lineData,function(sparkline){
            return sparkline.x.getTime()>time;
        }).sort(function(spr_a,spr_b){
            return spr_a.x.getTime()-spr_b.x.getTime();
        });
        for(var i=0;i<upperSparklines.length;i++){
            if($.grep(getAffectingObservationsForSparklinePoint(upperSparklines[i].x.getTime()),function(observation){
                return observation==time;
            }).length==0){
                break;
            }
            result.push(upperSparklines[i].x.getTime());
        }

        return result;
    }

    (function(){
        for(var i in observations_points) {
            (function (observation) {
                vis.append('circle')
                    .attr('r', 3)
                    .attr("cx", xRange(observation.x))
                    .attr("cy", yRange(observation.y))
                    .attr('data-time', observation.x.getTime())
                    .on('mouseover', function () {
                        mouseOverOnObservation(observation.x.getTime());
                    })
                    .on('mouseout', function () {
                        mouseOutOnObservation(observation.x.getTime());
                    })
                    .on('click', function () {
                        clickedOnObservation(observation.x.getTime());
                    });
            })(observations_points[i])
        }

        var observations_table=$('.data-table .observations-table table tbody');
        $.each(observations_points,function(idx,observation_pont){
            observations_table.append('<tr data-time="'+observation_pont.x.getTime()+'"><td>'+$('.data-table .observations-table .table tbody tr').length+'</td><td>'+observation_pont.x+'</td><td>'+observation_pont.y+'</td></tr>');
        });

        function selectFromObservationsTable(time){
            selection_mode='observation';
            $('.data-table .observations-table tr[data-time='+time+']').addClass('observation-selected');
            $('#debug-chart circle:not(.sparkline-point)[data-time='+time+']')[0].classList.add('observation-selected');
            scrollToSelectedElementOnObservationsTable();

            $.each(getAffectingSparklineForObservation(time),function(idx,time){
                $('.data-table .sparkline-table tr[data-time='+time+']').addClass('observation-selected');
                $('#debug-chart circle.sparkline-point[data-time='+time+']')[0].classList.add('observation-selected');
            });

            scrollToSelectedElementOnSparklineTable();
        }

        function clickedOnObservation(time){
            var selected=$('.data-table .observations-table .observation-selected').attr('data-time')==time;
            $('.sparkline-selected, .observation-selected').each(function(idx,e){
                e.classList.remove('sparkline-selected');
                e.classList.remove('observation-selected');
            });
            if(selection_locked && selection_mode==='observation' && selected){
                selection_locked=false;
            }else{
                selection_locked=true;
                selectFromObservationsTable(time);
            }
        }

        function mouseOverOnObservation(time){
            if(!selection_locked) {
                selectFromObservationsTable(time);
            }
        }

        function mouseOutOnObservation(time){
            if(!selection_locked) {
                $('.sparkline-selected, .observation-selected').each(function(idx,e){
                    e.classList.remove('sparkline-selected');
                    e.classList.remove('observation-selected');
                });
            }
        }

        observations_table.on('click','tr',function(){
            clickedOnObservation($(this).attr('data-time'));
        });
        observations_table.on('mouseover','tr',function(){
            mouseOverOnObservation($(this).attr('data-time'));
        });
        observations_table.on('mouseout','tr',function(){
            mouseOutOnObservation($(this).attr('data-time'));
        });
    })();

    (function() {
        for (var i in lineData) {
            (function (sparkline) {
                vis.append('circle')
                    .attr('r', 3)
                    .attr("cx", xRange(sparkline.x))
                    .attr("cy", yRange(sparkline.y))
                    .attr('class', 'sparkline-point')
                    .attr('data-time', sparkline.x.getTime())
                    .on('mouseover', function () {
                        mouseOverOnSparkline(sparkline.x.getTime());
                    })
                    .on('mouseout', function () {
                        mouseOutOnSparkline(sparkline.x.getTime());
                    })
                    .on('click', function () {
                        clickedOnSparkline(sparkline.x.getTime());
                    });
            })(lineData[i])
        }

        var sparkline_table = $('.data-table .sparkline-table table tbody');
        $.each(lineData, function (idx, sparkline_point) {
            var upper;
            var lower;

            var closestUpperBand = bands_upper.filter(function (d) {
                return d.x.getTime() === sparkline_point.x.getTime()
            });
            if (closestUpperBand.length) {
                upper = closestUpperBand[0].y;
            }
            var closestLowerBand = bands_lower.filter(function (d) {
                return d.x.getTime() === sparkline_point.x.getTime()
            });
            if (closestLowerBand.length) {
                lower = closestLowerBand[0].y;
            }
            var anomaly=false;
            if(typeof lower!='undefined' && sparkline_point.y<lower){
                anomaly=true;
            }
            if(typeof upper!='undefined' && sparkline_point.y>upper){
                anomaly=true;
            }
            var event=$.grep(events,function(event){
                return event.x.getTime()==sparkline_point.x.getTime();
            }).length!=0;

            sparkline_table.append('<tr data-time="' + sparkline_point.x.getTime() + '"><td>'+$('.data-table .sparkline-table .table tbody tr').length+'</td><td>' + sparkline_point.x + '</td><td>' + sparkline_point.y + '</td><td>' + (typeof lower!='undefined'?lower:'-') + '</td><td>' + (typeof upper!='undefined'?upper:'-') + '</td><td>'+(anomaly?'Yes':'')+'</td><td>'+(event?'Yes':'')+'</td></tr>');
        });

        function selectFromSparklineTable(time) {
            selection_mode = 'sparkline';
            $('.data-table .sparkline-table tr[data-time=' + time + ']').addClass('sparkline-selected');
            $('#debug-chart circle.sparkline-point[data-time=' + time + ']')[0].classList.add('sparkline-selected');
            scrollToSelectedElementOnSparklineTable();

            $.each(getAffectingObservationsForSparklinePoint(time),function(idx,time){
                $('.data-table .observations-table tr[data-time='+time+']').addClass('sparkline-selected');
                $('#debug-chart circle:not(.sparkline-point)[data-time='+time+']')[0].classList.add('sparkline-selected');
            });

            scrollToSelectedElementOnObservationsTable();
        }

        function clickedOnSparkline(time) {
            var selected = $('.data-table .sparkline-table .sparkline-selected').attr('data-time') == time;
            $('.sparkline-selected, .observation-selected').each(function (idx, e) {
                e.classList.remove('sparkline-selected');
                e.classList.remove('observation-selected');
            });
            if (selection_locked && selection_mode === 'sparkline' && selected) {
                selection_locked = false;
            } else {
                selection_locked = true;
                selectFromSparklineTable(time);
            }
        }

        function mouseOverOnSparkline(time) {
            if (!selection_locked) {
                selectFromSparklineTable(time);
            }
        }

        function mouseOutOnSparkline(time) {
            if (!selection_locked) {
                $('.sparkline-selected, .observation-selected').each(function(idx,e){
                    e.classList.remove('sparkline-selected');
                    e.classList.remove('observation-selected');
                });
            }
        }

        sparkline_table.on('click', 'tr', function () {
            clickedOnSparkline($(this).attr('data-time'));
        });
        sparkline_table.on('mouseover', 'tr', function () {
            mouseOverOnSparkline($(this).attr('data-time'));
        });
        sparkline_table.on('mouseout', 'tr', function () {
            mouseOutOnSparkline($(this).attr('data-time'));
        });
    })();
})();