function getUrlVars() {
    var vars = {};
    var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
        vars[key] = value;
    });
    return vars;
}

const proxyurl = "https://cors-anywhere.herokuapp.com/";
$(document).ready(function(){
    var lat = getUrlVars()["lat"];
    var lon = getUrlVars()["lon"];
    if (typeof lat === 'undefined' || typeof lon === "undefined") window.location.replace("index.html");
    const url = proxyurl + "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + lat + "," + lon + "&radius=200&sensor=true&key=AIzaSyBU291kkcLu7fPWwATXzOtfkgJGFZN5128";
    $.getJSON(url, function(response, status, jqXHR){
        processJSON(jqXHR.responseText);
    });
});

function processJSON(jsonText) {
//var json = this.responseText;
var data = JSON.parse(jsonText);
// and do something with obj here
//processing code
var tId,cnt=0;
pjs = Processing.getInstanceById("artography");
console.log(cnt+':'+pjs);
if (!pjs) tId=setInterval(function() {
pjs = Processing.getInstanceById("artography");
console.log(cnt+':'+pjs);
if (pjs) {
clearInterval(tId);
//var pjs = Processing.getInstanceById('artography');
   console.log("pjs is "+pjs+ " and parsing"+data);
   if(data) {
        for(p=0, end=data.results.length; p<end; p++) {
            var place = data.results[p];
            if(validPlace(place)) {
                var location = data.results[p].geometry.location;
                var viewport = data.results[p].geometry.viewport;
                pjs.addLocation(location.lat, location.lng, width(viewport), height(viewport), place.name);
                //document.write((location.lat+ " " +location.lng+ " " +width(viewport)+ " " +height(viewport)+ " " + place.name));
            }
        }
        pjs.initializeAll();
   }

}
},500); 
}
    

function validPlace(place) {
    var types = place.types;
    for (i = 0; i < types.length; i++) {
        if (types[i]=="locality") return false;
        if (types[i]=="political") return false;
    }
    return true;
}
function width(viewport) {
    var northeast = viewport.northeast.lng;
    var southwest = viewport.southwest.lng;
    return ((northeast - southwest) * 13000);
}
function height(viewport) {
    var northeast = viewport.northeast.lat;
    var southwest = viewport.southwest.lat;
    return ((northeast - southwest) * 13000);
}
