xquery version "1.0-ml";

module namespace mp = "http://derickson/kmlalert/model/m-ping";

import module namespace cfg = "http://framework/lib/config" at "/lib/config.xqy";
import module namespace lu = "http://framework/lib/util" at "/lib/l-util.xqy";

declare namespace fg = "http://framework/geo";


declare variable $OBJECT_TYPE as xs:string := "pings";
declare variable $STORAGE_PREFIX as xs:string := fn:concat("/storage/",$OBJECT_TYPE,"/");


declare function mp:gen-ping($point as cts:point) as element(mp:ping) {
	let $guid := lu:guid($OBJECT_TYPE)

	return
		element mp:ping{
			element mp:guid { $guid },
			element mp:time { fn:current-dateTime() },
			element fg:location { $point }
		}
};


declare function mp:get-by-id($id as xs:string) as element(mp:ping)? {
	/mp:ping[mp:guid eq $id]
};

declare function mp:store($item as element(mp:ping)) as empty-sequence() {
	let $uri := fn:concat($STORAGE_PREFIX, $item/mp:guid/fn:string(), ".xml")
	return (
		xdmp:document-insert($uri, $item, (), ($OBJECT_TYPE, $cfg:SETS_OFF_TRAPS))
	)

		
};

declare function mp:delete($item as element(mp:ping)) as empty-sequence() {
	xdmp:document-delete(xdmp:node-uri($item))
};
