source wapp.tcl 
source wapp-routes.tcl 
source evaluator.tcl

package require http
package require json

set root [file dirname [file normalize [info script]]]
set root "${root}/public"

# key to authenticate against a locally running split evaluator (or one behind some kind of shared firewall)
set authKey "123456" 


#load all of the files to variables :(

set fp [open "${root}/html/footer.html" r]
set footer [read $fp]
close $fp

set fp [open "${root}/html/demo.html" r]
set demo [read $fp]
close $fp

set fp [open "${root}/html/header.html" r]
set header [read $fp]
close $fp

set fp [open "${root}/html/login.html" r]
set login [read $fp]
close $fp

set fp [open "${root}/js/script.js" r]
set js [read $fp]
close $fp

set fp [open "${root}/css/styles.css" r]
set css [read $fp]
close $fp

proc createTableData {} {
    set alphabet [split "abcdefghijklmnopqrstuvwxyz" {}];
    set account {
    {"Nike"  "Nike"  "Nike"  "Apple"  "Apple"  "Apple"  "LinkedIn"  "Best Buy"  "Best Buy"  "Best Buy"} 
    {"Nike"  "Nike"  "Nike"  "Apple"  "Apple"  "Apple"  "LinkedIn"  "Best Buy"  "Best Buy"  "Best Buy"} 
    {"Nike"  "Nike"  "Nike"  "Apple"  "Apple"  "Apple"  "LinkedIn"  "Best Buy"  "Best Buy"  "Best Buy"} 
    {"Google"  "Google"  "Google"  "Microsoft"  "Microsoft"  "Microsoft"  "Microsoft"  "Best Buy"  "Best Buy"  "Best Buy"} 
    {"Google"  "Google"  "Google"  "Microsoft"  "Microsoft"  "Microsoft"  "Microsoft"  "Pintrest"  "Pintrest"  "Pintrest"} 
    {"Google"  "Google" "Google"  "Microsoft"  "Microsoft"  "Microsoft"  "Microsoft"  "Pintrest"  "Pintrest"  "Pintrest"} 
    {"Dell"  "Dell"  "Dell"  "Microsoft"  "Microsoft"  "Microsoft"  "Microsoft"  "Pintrest"  "Pintrest"  "Pintrest"} 
    {"Zoom"  "Zoom"  "Zoom"  "Slack"  "Slack"  "Slack"  "Samsung"  "Disney"  "Disney"  "Disney"} 
    {"Zoom"  "Zoom"  "Zoom"  "Slack"  "Slack"  "Slack"  "Samsung"  "Disney"  "Disney"  "Disney"} 
    {"Zoom"  "Zoom"  "Zoom"  "Slack"  "Slack"  "Slack"  "Samsung"  "Disney"  "Disney"  "Disney"}
    }; # theoretically you could expand this table if you wanted. It would be a non-trivial exercise to get realistic clusters like this though
    set table [];
    for {set i 0} {$i < 10} {incr i} {
        for {set j 0} {$j < 10} {incr j} {
            lset table $i $j [dict create user "[lindex $alphabet $i]${j}"  account [lindex $account $i $j]]
        }
    }
    return $table;
}


set table [createTableData]

proc buildTable {table splitName eventName} {
  global authKey
    set htmlString "<table id=\'myTable\'>"
    for {set rowIdx 0} {$rowIdx < [llength $table]} {incr rowIdx} {
        set htmlString "${htmlString}<tr>"
        set row [lindex $table $rowIdx];
        for {set colIdx 0} {$colIdx < [llength $row]} {incr colIdx} {
            set rowElem [lindex $row $colIdx]
            set attributes [dict create row "\"[lindex [split [dict get $rowElem user] {}] 0]\"" col "\"[lindex [split [dict get $rowElem user] {}] 1]\"" userid "\"[dict get $rowElem user]\"" account "\"[dict get $rowElem account]\""]

            set splitResult [getTreatmentWithConfig $splitName [dict get $rowElem user] $authKey $attributes]
            after 5 #being kind to the server here as not to flood it
            set configs  [dict create popup_value "" popup_message "coming soon" font_size "medium"]

            
            if {[dict exists $splitResult config] && [dict get $splitResult config] ne "null"} {
                set configs [::json::json2dict [dict get $splitResult config]]; #overide with configs from treatment
            }
            set treatmentColor "red;"
            switch [dict get $splitResult treatment] {
                 "standard" {
                  set treatmentColor "rgb(255, 70, 82);"
                 }
                 "premium" {
                  set  treatmentColor "rgb(0, 124, 156);"
                 }
                 "current" {
                  set  treatmentColor "rgb(173, 193, 116);"
                 }
                default {
                  set  treatmentColor "red;"
                }
            }
            append htmlString "<td style=\"font-size:[dict get $configs font_size]; color:white; width:40px; height:40px; text-align:center; background-color:${treatmentColor}\""
            append htmlString " onclick= \"createPopup({user:'[dict get $rowElem user]', message:'[dict get $configs popup_message]', eventName:'${eventName}', treatment:'[dict get $splitResult treatment]', value:'[dict get $configs popup_value]' })\">[dict get $rowElem user]</td>";
        }
        append htmlString "</tr>"    
    }
    
    append htmlString "</table>"

    return $htmlString
}



proc wapp-default {} {

  set mname [wapp-param PATH_HEAD]
  if { $mname eq "" } {
      wapp-redirect index
  }
}
proc wapp-page-index {} {
  
  global login
  global header
  global footer
  wapp-trim {
    %unsafe($header)
    %unsafe($login)
    %unsafe($footer)
  }
}

proc wapp-page-login {} {
  #this is not ideal, but currently just a demo
   wapp-content-security-policy {off} 
  
  global login
  global header
  global footer
  global demo
  global table
  set params [dict create {*}[string map {= " " & " "} [wapp-param CONTENT]]]
 
  if {[dict exists $params eventName]} {
    set htmlTable [buildTable $table [dict get $params splitName] [dict get $params eventName]]
  } else {
    set htmlTable [buildTable $table [dict get $params splitName] ""]
  }
 
  wapp-trim {
    %unsafe($header)
    %unsafe($demo)
    %unsafe($htmlTable)
    %unsafe($footer)
  }
}

proc wapp-page-track {} {

set params [dict create {*}[string map {= " " & " "} [wapp-param CONTENT]]]
global authKey
puts [track [dict get $params eventName] [dict get $params user] [dict get $params value] $authKey [dict create "treatment" [dict get $params treatment]]]

}


proc wapp-page-script.js {} {
  wapp-mimetype application/javascript
  wapp-cache-control max-age=3600
  global js
  wapp-unsafe $js
}

proc wapp-page-styles.css {} {
  wapp-mimetype text/css
  wapp-cache-control max-age=3600
  global css
  wapp-unsafe $css
}

proc wapp-page-splitfavico.png {} {
  wapp-mimetype image/png
  wapp-cache-control max-age=3600
  wapp-unsafe [binary decode base64 {
    iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAEYUlEQVRYw72Wa0ybZRiGW5jMEeMhi/GIRvq1jMGQQtTMX8aFzRhjUBcPc0txMJlO62GyThN/QFvasWyKVLcfmhkNZn+MSxSBMcZhTHSslDLGxmBAv3aHiCCUHiiU7/F+u68EawuWlr3JlTZp+t7X854lkjg15Zf2JLAJVIMUyc1qOV/ZExCYDirBCBgGDy97MEIYD4ASMAAEQDdFAAG3AxXoAH4xmJZdQJznPFADPCHByyegxDxnm+xZ6yrtXytN9tEIwUH6wYPxnOcUUAqBIUUFL6zZz1PWF2GDZ0AbeAncEo/wO0Eh6GTzDAFS7LNRqt5GnMFG6Qd4erQqEMwWXx/YDe7JgXSswSvF/VwLvMEK5wsEyTjooLzqEeumoyPrcw85pDHuZ4cUQUpwBIyFDvF8AYWRp6eOjFBho4dKzH6fxjLbCJ4Hq2KpfJVYtRBucTGBtAqeHj90nbbWumj3WT8hcD4T4DvwGEhcikAyaI2wspnUxWePjp5+7/dpX0hwKA5QAWR7LYI0HgLXgQHIUfVqdFwEusHsAhLst16gBqs/tlL0AtkmntYdvERrDD1mhb5ng6K8L7C1NF2zUnT6CNCBK4uMBhutZvAiSP6fAtjnn1+mdEM3ycvMxJV1Eac9/6dM118p0w+lycr5wLCyeRbn+xswvoiIE/wA1qOAFWEFsqtsyVmVg61r950nBYLlpR0Q6ITAOZJpL5JMd1nADugDH8nKbfdyRptEFLkVPAPqwNQiIteAHtz2H4G1Fb0r0nQWNYLtQJCXnkW4FdX3Irwf228ouP9nQHtque01iMx1hE7vAgXAAvwLSAyD8HdFmq4zEdUrEX5YXmYZ47Q9qL6PUnWD/zqARNzgGCQ2cAY+if1/b5fA1sdD4FPAAyEqgWDD0K/ktN15nPZCjUw34E3VD4cTCPIXRuMwRDI4I59wY6EKiXs6Z3M/7Jipx0EVvUCwcfpLd8j0gyqEmIF/AQm2PgaABqNx35stnpTtJ92lqgaXDZ+kbvcRhKIXYA2dSlBdCuscDIphkUT86fvtHdsb3dYdzR5/QaOLttY7aUutk97A9/f/mKY90QrMTYvRlgCRTISYwGgkiYwDDio86aHiVi8VNrlJ1TBJW+qc9PIv4wEgcu6d33z3L/nOwDmQhDl/mi1A4AkngOrp7bYp2tHiCVS+7fgkvfrrxOTmn/+uzv9p7MkXjo0lSmJpGpzx2+rdmfk/jp/JNV0jjMycQCYEilu8hCpp5ykvFTW5p1UnXM2v1znzX6mZSI75oSLu92JgZftd3T5NEKGsz67cEMAb4a1TU4RLS9h1euoCFqQaC/HuggZXzMEJYCM4HnriYWEh1Ecbq0cpp+oqht939YMzM8Z3233yXW0+qSQejV0m4sMj4lGLPe/E1Hxf1OR9osQc4cyPUaB1gVvvBHhu0VsvzgLs3u8BO9m9/0k3SZathRFgL58y9vLRRPPyiYMAe/t9C3KX9PaLUaAKbI7nPP8DMqo29RBNp3kAAAAASUVORK5CYII=
  }]
}



wapp-start $argv
