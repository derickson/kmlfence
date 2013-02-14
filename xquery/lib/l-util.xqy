xquery version "1.0-ml";

module namespace lu = "http://framework/lib/util";

import module namespace cfg = "http://framework/lib/config" at "/lib/config.xqy";

declare function lu:guid($objectType as xs:string) as xs:string {
	if($objectType) then
		let $rand := xdmp:random()
		let $time := fn:current-dateTime()
		let $text := fn:string-join((fn:string($rand), $objectType, fn:string($time))," ")
		return
			fn:concat($objectType,"-",xdmp:hash64($text))
	else
		fn:error(xs:QName("ER-BAD-INPUT"),"lu:guid $objectType requires non blank string")
};