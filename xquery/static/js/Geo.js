
App.Geo = Ember.Object.create({
	status: "Inactive",
	lat: 0.0,
	lon: 0.0,
	accuracy: 0.0
});



App.wid = null;

App.startGeo = function() {
	
	console.log("startGeo");
	if (navigator.geolocation) {
			
			App.Geo.set('status','Pinging');
		
			App.wid = navigator.geolocation.watchPosition(
				function(position) {
					var lat = position.coords.latitude;
					var lon = position.coords.longitude;
					var acc = position.coords.accuracy;
					
					
					
					if( acc > 200) {
						App.Geo.set('status','Waiting for Accuracy');
					} else {
						//navigator.geolocation.clearWatch( App.wid );
						//App.wid = null;
					    
						//App.Geo.set('status','Stopped');
						//if(App.maphidden) {
						//	$('div#logincontainer').hide();
						//	$('div#loading').hide();
					    //	$('div#game').show();
						//}
						//map ?  App.updatePlayerPositionAcc(lat, lon, acc) : App.startMap(lat, lon, acc);
						App.updatePlayerPositionAcc(lat, lon, acc) 
					}
					
					
				},
				function(msg) {
					var message = 'LocError: '+ msg;
					console.log(message);
					App.Geo.set('status', message);
				},
				
				{
					enableHighAccuracy: true,
					maximumAge: 10000,
					timeout: 5000
				}
				
			);		
	} else {
		console.log('GeoLocation not supported');
		App.Geo.set('status','GeoLocation not supported');
	}
};







App.updatePlayerPosition = function(lat, lon) {
	App.updatePlayerPositionAcc(lat, lon, -1)
};

App.updatePlayerPositionAcc = function(lat, lon, acc) {
	//console.log("updatePlayerPosition");
	App.Geo.set('lat', lat);
	App.Geo.set('lon', lon);
	App.Geo.set('accuracy', acc);
	
	var url = "/ping.xqy?lat="+lat+"&lon="+lon;
	console.log("Updaing position" + url);
	$.ajax({url: url});
	
};

$(document).ready(function() {
	
	
	App.startGeo();
	
});