#!/usr/bin/tclsh
source "wapp.tcl"
proc wapp-default {} {
  wapp-subst {<h1>Hello, World!</h1>\n}
}
wapp-start $argv
