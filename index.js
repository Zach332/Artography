var jsonData;
$('#dljson').click(function(){
    console.log("clicked!");
    lat = parseFloat($(latin).val()); // to be replaced with 
    lon = parseFloat($(lonin).val()); // form field info
    if (isNaN(lat) || isNaN(lon)){
        alert("Invalid Input:\n\nPlease enter valid values for latitude and longitude.");
        return;
    }
    //slap into parameters
    window.location.replace("map.html?lat=" + lat + "?lon=" + lon);
});