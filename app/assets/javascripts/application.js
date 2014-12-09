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