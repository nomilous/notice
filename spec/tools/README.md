[`../notice`](../notice)

Tools API
=========

* New. 
* Undocumented. 
* Design incomplete.
* `grep -B2 -A20 -r '##undecided' src/* spec/*`
* Illustrated: [`../walkthrough`](../walkthrough)/tools.
* The idea `has!` juice! (imho)



Todo
----

* consider a second bus, for errors, warnings and cancellations
    * initial thought was to push errors down the main bus
    * but what if the error traversal errors (runnaway chain reaction)
* middleware registers separately, access to same tools / cache
* additionally enable access to error history
* enables middleware modules that can implement all error maintenance goodness via this tools api
    * eg.. error scrolling, flaggin, flushing, marking resolve, etc. et. e. ra.
