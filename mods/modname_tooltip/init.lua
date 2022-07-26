modname_tooltip = {
	mods_titles = {},
}

modname_tooltip.color = "#b0d0FF"

local gamename = false
local function getgameid ()
	local gamesettings = Settings(minetest.get_worldpath().."/world.mt")
	gamename = gamesettings:get("gameid")
	gamename = gamename:gsub("_", " ")
	gamename = gamename:gsub("%f[%a].", string.upper) --Word Case
end
pcall(getgameid) --"try" if mod.conf can't be read

for _,modname in ipairs(minetest.get_modnames()) do

	local modpath = minetest.get_modpath(modname)
	
	local function getmodtitle ()
		modsettings = Settings(modpath.."/mod.conf")
		modtitle = modsettings:get("title")
	end
	pcall(getmodtitle) --in case mod.conf can't be read

	if modtitle == nil then --if title wasn't read
		modtitle = modname:gsub("_", " ")
		modtitle = modtitle:gsub("%f[%a].", string.upper) --Word Case
		if gamename ~= false and modpath:match("/games/") then
			modtitle = gamename .. " - " .. modtitle
		end
	end
	
	modname_tooltip.mods_titles[modname] = modtitle
end

function modname_tooltip.set_mod_title(modname, title)
	modname_tooltip.mods_titles[modname] = title
end

function modname_tooltip.get_mod_title(modname)
	return modname_tooltip.mods_titles[modname]
end

minetest.get_modnames()

tt.register_snippet(
	function(itemstring)
		return modname_tooltip.get_mod_title(itemstring:match("(.-):.*")), modname_tooltip.color
	end
)
