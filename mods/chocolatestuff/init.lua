local scale=2.5
if minetest.get_modpath("farming") ~= nil and farming.mod == "redo" then
	minetest.register_alias_force( -- Dark chocolate sortof looks like an ingot. This is why this mod is even a thing.
		"chocolatestuff:chocolate_ingot",
		"farming:chocolate_dark"
	)
	minetest.register_alias_force(
		"chocolatestuff:chocolateblock",
		"farming:chocolate_block"
	)

else
	minetest.log("info","chocolatestuff: could not find source for chocolate. Chocolate armor will not be obtainable in survival.")
end
instant_ores.register_metal({ -- cuz eating your armor is so metal
	name = "chocolatestuff:chocolate",
	description = "Chocolate",
	artificial = true,  -- We don't need ores.
	power = .5, -- So weak as to crumble after but a few real uses.
	color = "#653302",  -- Color sampled from the chocolate color in the farming redo mod
})
ediblestuff.make_tools_edible("chocolatestuff","chocolate",scale)
if minetest.get_modpath("3d_armor") == nil then return end
local armor_types=ediblestuff.make_armor_edible_while_wearing("chocolatestuff","chocolate",scale)
-- Ok, so apparently this idea for chocolate armor wasn't super original. May as well play nice.
local made_aliases = false
for _,armormod in ipairs{"moarmour","armor_addon"} do
	if minetest.get_modpath(armormod) then
		ediblestuff.make_armor_edible_while_wearing(armormod,"chocolate",scale)
		if made_aliases then break end
		made_aliases = true
		for typ,_ in pairs(armor_types) do
			minetest.register_alias_force("chocolatestuff:"..typ.."_chocolate",    armormod..":"..typ.."_chocolate")
		end
	end
end
-- If neither of the other mods are present...
if not made_aliases then
	for typ,_ in pairs(armor_types) do
		minetest.register_alias_force("moarmour:"..typ.."_chocolate",       "chocolatestuff:"..typ.."_chocolate")
		minetest.register_alias_force("armor_addon:"..typ.."_chocolate",    "chocolatestuff:"..typ.."_chocolate")
	end
end
