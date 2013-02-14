xquery version "1.0-ml";

module namespace mkf = "http://derickson/kmlalert/model/m-kf";

import module namespace alert = "http://marklogic.com/xdmp/alert" 
		  at "/MarkLogic/alert.xqy";

import module namespace lk = "http://derickson/kmlalert/lib/kml" at "/lib/l-kml.xqy";
import module namespace cfg = "http://framework/lib/config" at "/lib/config.xqy";
import module namespace lu = "http://framework/lib/util" at "/lib/l-util.xqy";

declare namespace kml ="http://www.opengis.net/kml/2.2" ;
declare namespace gx ="http://www.google.com/kml/ext/2.2";
declare namespace fg = "http://framework/geo";


declare variable $OBJECT_TYPE as xs:string := "kmlfence";
declare variable $STORAGE_PREFIX as xs:string := fn:concat("/storage/",$OBJECT_TYPE,"/");

declare function mkf:guid-rule-name($kmlfence as element(mkf:kmlfence)) as xs:string {
	fn:concat("rule-for-",$kmlfence/mkf:guid/fn:string())
};

declare function mkf:gen-kmlfence($alert as map:map) as element(mkf:kmlfence) {
	let $guid := lu:guid($OBJECT_TYPE)
	let $polygons := map:get($alert, "polygon")
	let $name := map:get($alert, "name")
	let $color := map:get($alert, "color")
	let $query := 
		cts:and-query((
			cts:collection-query($cfg:SETS_OFF_TRAPS),
			cts:element-geospatial-query( (xs:QName("fg:location")), $polygons , ("coordinate-system=wgs84"))
		))
	return
		element mkf:kmlfence{
			element mkf:guid { $guid },
			element mkf:name { $name },
			element mkf:color { $color },
			element fg:regions { $polygons },
			element fg:query { $query }
		}
};


declare function mkf:get-by-id($id as xs:string) as element(mkf:kmlfence)? {
	/mkf:kmlfence[mkf:guid eq $id]
};

declare function mkf:store($item as element(mkf:kmlfence)) as empty-sequence() {
	let $uri := fn:concat($STORAGE_PREFIX, $item/mkf:guid/fn:string(), ".xml")
	let $rule := alert:make-rule(
	    mkf:guid-rule-name($item), 
	    "trap rule",
	    0, (: equivalent to xdmp:user(xdmp:get-current-user()) :)

	    cts:query($item//fg:query/node()),
	    "kml-alert",
	    <alert:options>
		{
			$item/mkf:guid
		}
		</alert:options>
	 )
	return (
		xdmp:document-insert($uri, $item, (), ($OBJECT_TYPE)),
		alert:rule-insert("/alert/config/kmlalert.xml", $rule)
	)

		
};

declare function mkf:delete($item as element(mkf:kmlfence)) as empty-sequence() {
	let $rule-name := mkf:guid-rule-name($item)
	let $rule-id := xs:unsignedLong( (/alert:rule[alert:name eq $rule-name])[1]/@id )
	return
		alert:rule-remove("/alert/config/kmlalert.xml", $rule-id),
		
	xdmp:document-delete(xdmp:node-uri($item))
};

declare function mkf:insert-fence($kml as element(kml:kml)) {

	let $styleMap := map:map()

	let $_ :=
		for $style in $kml//kml:Style[kml:PolyStyle]
		let $id := fn:string($style/@id)
		let $color := $style/kml:PolyStyle/kml:color/fn:string()
		return
			map:put($styleMap, $id, $color)
	
	
	return
		for $alert in $kml//kml:Placemark[kml:Polygon]
		return  

		let $m := map:map()
		let $_ := (
			map:put($m, "polygon", 	lk:poly-from-coordinates( $alert/kml:Polygon//kml:coordinates )),
			map:put($m, "color", 	map:get($styleMap, fn:substring-after($alert/kml:styleUrl/fn:string(), "#") )),
			map:put($m, "name", 	$alert/kml:name/fn:string())
		)
		let $fence := mkf:gen-kmlfence($m)
		return
			mkf:store($fence)
			
};