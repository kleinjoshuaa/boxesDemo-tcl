package require http
package require json
package require json::write
source urlencode.tcl

# key for evaluator
set authKey "123456"

proc getAuthDict {evaluatorKey} {
    set auth [dict create Authorization $evaluatorKey]
    return $auth
}

#key for auth
proc getUrl {} {
    return "http://localhost:7548/client/get-treatment-with-config?"
}

proc getTrackUrl {} {
    return "http://localhost:7548/client/track?"
}

proc generateQuery {attrs} {
    return [::http::formatQuery {*}[dict get $attrs]];
}

#supposed to be a dict
proc formAttributes {attrs} {
    ::json::write indented false
    return [::json::write object {*}[dict get $attrs]]
}

proc httpGet {url authKey query} {

    http::config -useragent moop  -urlencoding {}  ;
    set tok [::http::geturl "${url}${query}" -headers $authKey ]   ;
    try {
        upvar 1 $tok state
        if {[set status [::http::status $tok]] ne "ok"} {
            error $status
        }
        set headers [dict map {key val} [::http::meta $tok] {
            set key [string tolower $key]
            set val
        }]
        return [::http::data $tok]
    } finally {
        ::http::cleanup $tok
    }
}

proc getTreatmentWithConfig {splitName splitKey apiKey attributes} {
    global authKey

    if {$attributes ne ""} {
    set queryString [generateQuery [dict create key $splitKey split-name $splitName attributes [formAttributes $attributes]]]
    } else {
    set queryString [generateQuery [dict create key $splitKey split-name $splitName]]
    }
    set url [getUrl]    
    
    set auth [getAuthDict $authKey]

    set result [::json::json2dict [httpGet $url [dict create Authorization $authKey] $queryString]]
    return $result
}



#puts [getTreatmentWithConfig "josh_boxes_demo" "b1" "123456" [dict create "row" "\"b\""]]

#puts [getTreatmentWithConfig "java_Demo_flag" "user1" "123456" ""]

proc track {eventName splitKey value apiKey attributes} {
    global authKey

    if {$attributes ne ""} {
    set queryString [generateQuery [dict create key $splitKey event-type $eventName traffic-type user value $value attributes [formAttributes $attributes]]]
    } else {
    set queryString [generateQuery [dict create key $splitKey event-type $eventName traffic-type user value $value]]
    }
    set url [getTrackUrl]    
    
    set auth [getAuthDict $authKey]
puts $queryString
puts $url
    set result [httpGet $url [dict create Authorization $authKey] $queryString]
    return $result
}

#puts [track "clicks" "j1" 7 "123456" [dict create "treatment" "super_control"]]