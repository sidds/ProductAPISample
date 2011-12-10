/***
 *** Javascript doesn't have true classes or inheritance. It is a loosely and dynamically typed language. 
 *** So the implementation models namespaces, interfaces, and classes via existing Javascript mechanisms.
 *** The Util "namespace" provides some helpers to dynamically check for conformance to the desired OO constraints.
 *** Eventually replace with something like JSONSchema .....
***/

var UTIL = {};

UTIL.checkInterface = function(theObject, theInterface) {
    // alert("Checking interface " + theInterface);
    for (var member in theInterface) {
	// alert ("Checking for interface member: " + member);
        if ( (typeof theObject[member] != typeof theInterface[member]) ) {
            alert("dev error: object failed to implement interface member " + member);
            return false;
        }
    }
    //if we get here, it passed the test, so return true
    return true;
};
