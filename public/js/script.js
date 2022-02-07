!function(){var analytics=window.analytics=window.analytics||[];if(!analytics.initialize)if(analytics.invoked)window.console&&console.error&&console.error("Segment snippet included twice.");else{analytics.invoked=!0;analytics.methods=["trackSubmit","trackClick","trackLink","trackForm","pageview","identify","reset","group","track","ready","alias","debug","page","once","off","on","addSourceMiddleware","addIntegrationMiddleware","setAnonymousId","addDestinationMiddleware"];analytics.factory=function(e){return function(){var t=Array.prototype.slice.call(arguments);t.unshift(e);analytics.push(t);return analytics}};for(var e=0;e<analytics.methods.length;e++){var key=analytics.methods[e];analytics[key]=analytics.factory(key)}analytics.load=function(key,e){var t=document.createElement("script");t.type="text/javascript";t.async=!0;t.src="https://cdn.segment.com/analytics.js/v1/" + key + "/analytics.min.js";var n=document.getElementsByTagName("script")[0];n.parentNode.insertBefore(t,n);analytics._loadOptions=e};analytics._writeKey="Gwi7nLJzBJrOCEIUKjfNnUQus4JrarIM";;analytics.SNIPPET_VERSION="4.15.3";
analytics.load("Gwi7nLJzBJrOCEIUKjfNnUQus4JrarIM");
analytics.page();
}}();


function postEvent(data) {
    fetch("/track", {
      method: "POST", // or 'PUT'
      headers: {
        "Content-type": "application/x-www-form-urlencoded; charset=UTF-8"
      },
      body: `user=${data.user}&eventName=${data.eventName}&value=${data.value}&treatment=${data.treatment}`,
    }).then( (data) => {
      console.log('Event tracked!')
    })
      .catch((error) => {
        console.error("Error:", error);
      });
  }
  
  function createPopup(parms) {
      let message = parms.message;
      let eventName = parms.eventName;
      let treatment = parms.treatment;
      let value = parms.value;
  
      if (message != null) {
        alert(message + " " + value);
      }
      if (value != null && eventName != "") {
        analytics.identify(parms.user, {
          row: parms.user.substr(0,1),
          col: parms.user.substr(1)
        });
        analytics.track('clicked_from_segment', {parms});
        result = postEvent(parms);
        }
           
    };
  
 

