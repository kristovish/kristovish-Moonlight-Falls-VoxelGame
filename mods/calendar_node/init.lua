local S
-- Compability translator code to support MT 0.4, which doesn't support
-- translations for mods.
if not minetest.translate then
	-- No translation system available, use dummy functions
	local function translate(textdomain, str, ...)
		local arg = {n=select('#', ...), ...}
		return str:gsub("@(.)", function(matched)
			local c = string.byte(matched)
			if string.byte("1") <= c and c <= string.byte("9") then
				return arg[c - string.byte("0")]
			else
				return matched
			end
		end)
	end

	S = function(str, ...)
		return translate("calendar_node", str, ...)
	end
else
	S = minetest.get_translator("calendar_node")
end

local on_rightclick
if minetest.get_modpath("calendar") then
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
		if not clicker:is_player() then
			return itemstack
		end
		calendar.show_calendar(clicker:get_player_name())
		return itemstack
	end
	-- If the calendar mod was not found, the calendar node is basically
	-- just a decorative node.
end

minetest.register_node("calendar_node:calendar", {
	drawtype = "signlike",
	description = S("Calendar"),
	tiles = { "calendar_node_calendar.png" },
	inventory_image = "calendar_node_calendar.png",
	wield_image = "calendar_node_calendar.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	is_ground_content = false,
	walkable = false,
	groups = { dig_immediate = 3, attached_node = 1, },
	selection_box = {
		type = "wallmounted",
	},
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("infotext", S("Calendar"))
	end,
	on_rightclick = on_rightclick,
})

if minetest.get_modpath("default") and minetest.get_modpath("dye") then
	minetest.register_craft({
		output = "calendar_node:calendar",
		recipe = {
			{ "default:paper","default:paper","default:paper" },
			{ "default:paper","dye:black","default:paper" },
			{ "default:paper","default:paper","default:paper" },


		},
	})
end
