# Modname Tooltip

To determinate which tooltip title will be shown, this mod use the following methods, sorted by priority:

1. API
Other mods can call a global function (`modname_tooltip.set_mod_title()`) to set a mod's tooltip-name.
This is useful for modpacks which use different mods to split the code in different parts, but still aims to provide an unified gameplay.

2. Title defined in `mod.conf`
The mod will try to find the title of the mod defined in the mod's `mod.conf`.

3. Mod name
The fallback method is to put the modname in the tooltip, with underscores replaced with spaces and each word capitalized. This might not look as good in certain cases.
Mods that are part of the game will have the gameid appended in front (e.g. `default` will turn into `Minetest - Default`).



**Usage by other mods:**

Changing a mod's tooltip-name:
You can override what name a mod will have in the tooltip by using:
```lua
modname_tooltip.set_mod_title("modname_of_my_mod", "Mod name in Tooltip")
```

Getting a mod's current tooltip-name:
You can get what the current tooltip-name for a mod is by using:
```lua
modname_tooltip.get_mod_title("modname_of_my_mod")
```

Color of the tooltip:
The color of the modname in the tooltip will be light blue (#b0d0FF) by default.
You can globally change the color to whatever hexadecimal values you want by using:
```lua
modname_tooltip.color = "#FFFFFF"
```
