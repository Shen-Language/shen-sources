# TCL event loop

set in {C:/Users/shend/OneDrive/Desktop/Shen/S39/shen-to-tcl.txt}
set out {C:/Users/shend/OneDrive/Desktop/Shen/S39/tcl-to-shen.txt}
set myloop 1

proc eventloop {File} {
  global myloop
    while { $myloop } {
    after 10
    if  { [newcommand? $File] } {
        enact $File }
    update    }} 
        
proc newcommand? {File} {
  set Source [open $File r]
  set Data [read $Source]
  set Verdict [eot? $Data]
  close $Source
  return $Verdict} 

proc eot? {S} {
   return [ string match *eot $S ] 
   }             
     
proc enact {File} {
  set Source [open $File r]
  set Data [read $Source]
  close $Source
  set Command [trim $Data]
  if { [catch $Command result] != 0 } then { 
        err $result} 
  overwrite $File} 

proc overwrite {File} {
  set Sink [open $File w]
  puts -nonewline $Sink ""
  flush $Sink
  close $Sink}
  
proc trim {S} {
  return [string map {"eot" ""} $S]
  } 
  
proc mysend {String} {
  global out
  set Sink [open $out w]
  puts $Sink [concat $String "eot"] 
  close $Sink}
  
proc err {String} {
  set Format [myformat $String]
  mysend [concat "(error \""  $Format "\")"]}
  
proc url {String} {
  set data [url_help $String]
  #set result [format "\"%s\"" $data]
  mysend $data} 

proc url_help {String} {
  package require http
  package require tls
  ::http::register https 443 [list ::tls::socket -request 1 -ssl2 0 -ssl3 0 -tls1 1 -cafile VeriSignClass3SecureServerCA-G3.crt]
  set token [::http::geturl $String]
  upvar #0 $token state
  set result $state(body)
  ::http::cleanup $token
  return $result}
  
proc myformat {String} {
  return [string map {\" ""} $String]} 

overwrite $in
overwrite $out  
eventloop $in  