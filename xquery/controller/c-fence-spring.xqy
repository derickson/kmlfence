xquery version "1.0-ml";

module namespace cfs = "http://derickson/kmlfence/controller/fence-spring";

import module namespace cfg = "http://framework/lib/config" at "/lib/config.xqy";
import module namespace lu = "http://framework/lib/util" at "/lib/l-util.xqy";
import module namespace lh = "http://derickson/lib/l-mlhue" at "/lib/l-mlhue.xqy";

import module namespace mkf = "http://derickson/kmlalert/model/m-kf" at "/model/m-kmlfence.xqy";
(: import module namespace ms = "http://dinotrap.com/model/survivor" at "/model/m-survivor.xqy"; :)

declare variable $LOG-LEVEL := "debug";

declare function cfs:spring-fence(
	$fence-id as xs:string, 
	$triggering-doc as node()) as empty-sequence() {
	
	xdmp:log(text{
		"Alert for fance:",$fence-id,
		"on object:",$triggering-doc//*:guid/fn:string()
	}, $LOG-LEVEL),
	
(:	let $surv := ms:get-by-id($survivor-id) :)
	let $fence := mkf:get-by-id($fence-id)
(:	let $dino := md:get-by-id($triggering-doc//*:guid/fn:string()) :)
	
	return (
		
	(:	mkf:delete($fence), :)
	
	let $color := $fence//mkf:color/fn:string()
		
		return (
			xdmp:log(text{"Color:",$color}),
			cfs:change-lights($color)
		)
	)
	
	
};

declare function cfs:change-lights($color as xs:string) {
	let $R := xs:float(xdmp:hex-to-integer(fn:substring($color, 7, 2)) div 255)
	let $G := xs:float(xdmp:hex-to-integer(fn:substring($color, 5, 2)) div 255)
	let $B := xs:float(xdmp:hex-to-integer(fn:substring($color, 3, 2)) div 255)
	
	let $M := xs:float(fn:max(($R,$G,$B)))
	let $m := xs:float(fn:min(($R,$G,$B)))
	
	let $delta := xs:float( $M - $m )
	let $r := xs:float(($M - $R) div ($delta))
	let $g := xs:float(($M - $G) div ($delta))
	let $b := xs:float(($M - $B) div ($delta) )

	let $V := $M
	
	let $S := xs:float(
		if($delta eq 0) 
		then 0
		else ($delta) div $M  
	)

	let $H := xs:float(
		if($M eq 0) then 0
		else if($R eq $M) then 60 * ( (($G - $B) div $delta) mod 6 )
		else if($G eq $M) then 60 * ( (($B - $R) div $delta) + 2 )
		else if($B eq $M) then 60 * ( (($R - $G) div $delta) + 4 )
		else 0
	)

	let $H := xs:float(
		if($H ge 360) then $H - 360
		else if($H le 0) then $H + 360
		else $H )

	let $light := lh:hsb(
		fn:ceiling($H) cast as xs:int, 
		fn:ceiling($S * 100) cast as xs:int,
		fn:ceiling($V * 100) cast as xs:int
	)

	return (
		(: xdmp:log(xdmp:describe($light)) :)
		
		lh:put-all-state( $light )
		
	)
};

