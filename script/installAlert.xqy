xquery version "1.0-ml";
import module namespace alert = "http://marklogic.com/xdmp/alert" 
		  at "/MarkLogic/alert.xqy";
		
let $config := alert:make-config(
      "/alert/config/kmlalert.xml",
      "KMLBasedAlerting",
      "Alerting config for KML Alert",
        <alert:options/> )
return
	alert:config-insert($config);
	
xquery version "1.0-ml";
import module namespace alert = "http://marklogic.com/xdmp/alert" 
		  at "/MarkLogic/alert.xqy";

let $action := alert:make-action(
    "kml-alert", 
    "Fire off the kml alert",
    xdmp:modules-database(),
    xdmp:modules-root(), 
    "/actions/kml-alert.xqy",
    <alert:options/> )
return
alert:action-insert("/alert/config/kmlalert.xml", $action);

xquery version "1.0-ml";
import module namespace alert = "http://marklogic.com/xdmp/alert" 
	at "/MarkLogic/alert.xqy";
import module namespace trgr="http://marklogic.com/xdmp/triggers"
	at "/MarkLogic/triggers.xqy";

 let $uri := "/alert/config/kmlalert.xml"
 let $trigger-ids :=
   alert:create-triggers (
       $uri,
       trgr:trigger-data-event(
           trgr:directory-scope("/storage/pings/", "infinity"),
           trgr:document-content(("create", "modify")),
           trgr:post-commit()))
 let $config := alert:config-get($uri)
 let $new-config := alert:config-set-trigger-ids($config, $trigger-ids)
 return alert:config-insert($new-config)