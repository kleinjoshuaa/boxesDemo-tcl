# boxesDemo-tcl

The boxes demo re-implemented in Tcl, using the [Split Evaluator](https://help.split.io/hc/en-us/articles/360020037072-Split-Evaluator) to make calls to track and getTreatment as there is no Split SDK for Tcl. 

Make sure to set your URL and Auth Keys in the [evaluator.tcl](evaluator.tcl) file for this to correctly call out to your split evaluator

Requires tcl 8.6 and the tcllib package on most Linux package managers

Uses the [wapp](https://wapp.tcl.tk/home/doc/trunk/README.md) Tcl web application framework. 

run with `wapp main.tcl`

