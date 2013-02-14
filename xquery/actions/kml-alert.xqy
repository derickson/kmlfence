xquery version "1.0-ml";

import module namespace cfs = "http://derickson/kmlfence/controller/fence-spring" 
	at "/controller/c-fence-spring.xqy";

declare namespace mkf = "http://derickson/kmlalert/model/m-kf";
declare namespace alert = "http://marklogic.com/xdmp/alert";

(: declare variable $alert:config-uri as xs:string external; :)
declare variable $alert:doc as node() external;
declare variable $alert:rule as element(alert:rule) external;
(: declare variable $alert:action as element(alert:action) external; :)

cfs:spring-fence(
	$alert:rule//alert:options/mkf:guid/fn:string(),
	$alert:doc
)

