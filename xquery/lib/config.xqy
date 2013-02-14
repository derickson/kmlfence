xquery version "1.0-ml" ;

(:  config.xqy
    This library module holds configuration variables for the application
:)

module  namespace cfg = "http://framework/lib/config";


(: controlled collections :)
declare variable $SETS_OFF_TRAPS as xs:string := "sets-off-traps";
