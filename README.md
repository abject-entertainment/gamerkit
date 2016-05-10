# Gamers' Toolkit #

Gamers' Toolkit is now open source.  If you have questions about this project or how to make use of this code in your own projects, or if you want to help get a new version out the door, feel free to contact us on the [Facebook page](https://www.facebook.com/Gamers-Toolkit-227816083921466/).

## Current Status ##
This project represents the latest published version of Gamers' Toolkit for iOS, with the following changes:

1. Code has been updated to support iOS 9.
1. The use of XSLT in rendering character sheets has been removed (no longer allowed by Apple), and replaced with [Mustache](https://www.npmjs.com/package/mustache) for JavaScript.
1. Character sheet functionality is now implemented using [Knockout.js](http://knockoutjs.com/).
1. Support for separate character sheets for display/play, editing and printing has been added.
1. The 4th Edition D&D character sheet has been mostly updated to these changes.
1. The package server has been rewritten for [Node.JS](https://nodejs.org).

Here is what still needs to be done to have a finished app again:

* Finish updating the 4th Edition D&D sheets.
* Update the character sheets for D&D 3.5, Hollow Earth Expedition and Savage Worlds.
* Get the Maps functionality working again.
* Finish the package server rewrite to include a database of what a user (by device or by other id) already owns, as well as support for promotion code redemption.
* General UI cleanup and polish, as well as bug fixing.

