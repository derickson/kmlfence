xquery version "1.0-ml";

import module namespace mp = "http://derickson/kmlalert/model/m-ping" at "/model/m-ping.xqy";


declare variable $lat as xs:double := xdmp:get-request-field("lat") cast as xs:double;
declare variable $lon as xs:double := xdmp:get-request-field("lon") cast as xs:double;



mp:store( mp:gen-ping( cts:point($lat, $lon) ) )
