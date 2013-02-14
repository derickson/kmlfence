xquery version "1.0-ml";

module namespace lk = "http://derickson/kmlalert/lib/kml";


declare namespace kml ="http://www.opengis.net/kml/2.2" ;
declare namespace gx ="http://www.google.com/kml/ext/2.2";


declare function lk:fix-ns($nodes as node()*, $ns as xs:string) as item()*{
	for $n in $nodes
	return
		typeswitch($n)
		case text() return $n
		case element() return
			element {fn:QName($ns, fn:local-name($n))} {
				if(fn:local-name($n) ne "kml") then $n/@* else (),
				lk:fix-ns($n/node(), $ns)
			} 
		default return
			xdmp:log(text{"Unrecognized:",xdmp:quote($n)})
};

declare function lk:poly-from-coordinates( $coords as element(kml:coordinates)* )  as cts:polygon* {
	for $coord in $coords
	let $str := fn:normalize-space( $coord/fn:string() )
	return
	cts:polygon(
		for $c in fn:tokenize($str, "(\s)+")
		let $parts := fn:tokenize($c, ",")
		let $len := fn:count($parts)
		return
			cts:point(xs:double($parts[2]),xs:double($parts[1]))
	)
		
};

declare function lk:get-google-map($link as xs:string) as element(kml:kml) {
	
	lk:fix-ns( xdmp:gunzip(xdmp:http-get(fn:concat($link,"&amp;output=kml"))[2],
	  <options xmlns="xdmp:zip-get">
	    <format>xml</format>
	  </options>)/element() , "http://www.opengis.net/kml/2.2")
	
	
	(: 
		/element()) :)
};

