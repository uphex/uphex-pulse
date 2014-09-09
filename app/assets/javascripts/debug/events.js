function getMetricName(id){
    return JSON.parse(document.querySelector('#metric_names').value).filter(function(metricName){return metricName.id==id})[0].full_name;
}

function findGroupHeading(groupName){
    var allGroups=document.querySelectorAll('#debug-events-table tbody .date');
    for (var i = 0; i < allGroups.length; i++) {
        var item = allGroups.item(i);
        if(item.innerText===groupName){
            return item;
        }
    }
}

function createGroupHeadingTr(datestring){
    var dateHeadingTr=document.createElement('tr');
    var dateHeadingTd=document.createElement('td');
    dateHeadingTd.appendChild(document.createTextNode(datestring));
    dateHeadingTr.appendChild(dateHeadingTd);
    dateHeadingTr.setAttribute('class','date');
    return dateHeadingTr
}

function ensureGroupExist(groupName){
    var allGroups=document.querySelectorAll('#debug-events-table tbody .date');
    for (var i = 0; i < allGroups.length; i++) {
        var item = allGroups.item(i);
        if (item.innerText.localeCompare(groupName) <= 0) {
            if(item.innerText.localeCompare(groupName)==0){
                return;
            }else {
                document.querySelector('#debug-events-table tbody').insertBefore(createGroupHeadingTr(groupName),item);
                return;
            }
        }
    }
    document.querySelector('#debug-events-table tbody').appendChild(createGroupHeadingTr(groupName));
}

function insertRowToGroup(groupName,tr){
    ensureGroupExist(groupName);
    document.querySelector('#debug-events-table tbody').insertBefore(tr,findGroupHeading(groupName).nextElementSibling);
}

function insertRow(date,name,crossing,event,metricId){
    var tr=document.createElement('tr');
    (function(){
        tr.setAttribute('data-date',date.getTime());

        var nameTd=document.createElement('td');
        nameTd.appendChild(document.createTextNode(name));
        tr.appendChild(nameTd);

        var crossingTd=document.createElement('td');
        crossingTd.appendChild(document.createTextNode(crossing));
        tr.appendChild(crossingTd);

        var eventTd=document.createElement('td');
        eventTd.appendChild(document.createTextNode(event));
        tr.appendChild(eventTd);

        var chartTd=document.createElement('td');
        var toChartAnchor=document.createElement('a');
        toChartAnchor.appendChild(document.createTextNode('Chart'));
        toChartAnchor.setAttribute('class','button-standard');
        toChartAnchor.setAttribute('href','/debug?metric='+metricId);
        chartTd.appendChild(toChartAnchor);
        tr.appendChild(chartTd);

        if(crossing!==event){
            tr.setAttribute('class','anomaly');
        }
    })();
    insertRowToGroup(date.getFullYear()+'.'+(date.getMonth()<9?'0':'')+(date.getMonth()+1)+'.'+(date.getDate()<10?'0':'')+date.getDate(),tr);
}

var metrics=JSON.parse(document.querySelector('#metrics').value);
var all=metrics.length;

if(metrics.length){
    (function loadNext(){
        var metric=metrics.pop();
        d3.json('events/'+metric.id,function(error,json){
            document.querySelector('#counter_current').innerText=all-metrics.length;
            json.forEach(function(anomaly){
                insertRow(new Date(anomaly.date),getMetricName(metric.id),anomaly.crossing,anomaly.event,metric.id);

            });
            if(metrics.length) {
                loadNext();
            }else{
                document.querySelector('#loading_counter').style.display = 'none';
            }
        });
    })();
}