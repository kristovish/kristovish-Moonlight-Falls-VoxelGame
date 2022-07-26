-- Tests for the getname Minetest mod. This file also creates shims for
-- the minetest dependencies log() and get_modpath().
--
-- License: GNU GPLv3 (https://www.gnu.org/licenses/gpl-3.0.txt)
-- Copyright 2020 Kevin Sangeelee (kevin@susa.net)

minetest = {
	log = function(p1, p2)
		if(p2 == nil) then
			print('Log:' .. p1)
		else
			print('[' .. p1 .. ']:' .. p2)
		end
	end,
	get_modpath = function() return '.' end,
	register_chatcommand = function() end,
	register_tool = function() end,
	register_on_player_receive_fields = function() end,
}

dofile( "init.lua" )

print("A forename: " .. getname.forename())
print("A surname: " .. getname.surname())

print("A genderlessName: " .. getname.genderlessName())
print("A feminineName: " .. getname.feminineName())
print("A masculineName: " .. getname.masculineName())

print("A dogName: " .. getname.dogName())
print("A dogNameFemale: " .. getname.dogNameFemale())
print("A dogNameMale: " .. getname.dogNameMale())

print("A catName: " .. getname.catName())
print("A catNameFemale: " .. getname.catNameFemale())
print("A catNameMale: " .. getname.catNameMale())

print("\nRunning getnameCall() for each getname function\n----")

for k,_ in pairs(getname) do
	print("getnameCall('" .. k .. "'): " .. getnameCall(k))
end

print("\nRunning getnameCall() for non-existent getname function\n----")
print("getnameCall('thisFunctionDoesNotExist'): " .. (getnameCall('thisFunctionDoesNotExist') or 'nil'))

print("\nRunning getnameCall() for a generators function\n----")

for _,v in ipairs({'hamlet', 'street', 'coastal', 'wetland', 'mountain', 'hill', 'island', 'village'}) do
	print("getnameCall('place_" .. v .. "'): " .. (getnameCall('place_'..v) or 'nil'))
end

