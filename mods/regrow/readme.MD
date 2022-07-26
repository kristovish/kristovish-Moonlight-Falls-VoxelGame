REGROW
------

This mod helps to regrow tree fruits instead of the need for replanting
saplings each time.


USAGE
-----

The regrow.add_fruit() function is used to override each fruits after_dig_node
function so that an invisible node is placed once it is taken, then a timer is
started that will regrow the fruit on completion (unless tree is chopped down).

Example: regrow.add_fruit("default:apple", "default:leaves")

So far default apples and ethereal banana, orange and coconuts are supported.


Changelog
---------

 - 0.1 - Initial upload.
 - 0.2 - Add checks for player placed fruit and tree's nearby.
 - 0.3 - Make add_fruit a global function for other mods to use.
 - 0.4 - Add check for fruit tree leaf type before re-growing.
 - 0.5 - Ethereal Lemons and Olives can now regrow.
