--[[
Goals:
Make this as physically involved as possible, holding to "magic" mindset, random, unknown outcomes

-use cauldron from the old enchantments mod
-make player have to throw in lapiz from the lapiz mod to activate cauldron
-have the cauldron bubble when activated
-have the cauldron "explode", do a huge thing of particles and explode sound when
player throws in item
-have cauldron enchant single item, throw item at player
-then go back to being deactivated

-make cauldrons bubble
-bubble particles on idle along with a lot of bubble particles when active

Enchantments:
##/ = hardcoded for now, until items are modifyable
##(metadata)
##/luck        = more items per mine
##/furnace     = instant cook items if possible
##/delicate    = get source node if drop is differant than source

(hard defined)
###quickmine   = mine faster
dueler      = faster tool recover time
hard hitter = do more damage to players/entities

]]--

local MOD_NAME = minetest.get_current_modname()
local MOD_PREFIX = MOD_NAME .. ":"


--max level for enchants, things like quickmine use time/level to calc how much performance increase
--the item has, don't get too crazy with it because it adds (enchant_level_max*item number) more items per item that
--get enchanted
local enchant_level_max = 3


--do enchantments

--do this to stop items defs from acting strange
local tool_list = minetest.registered_tools
local tool_list_clone = {}
for item in pairs(tool_list) do
	table.insert(tool_list_clone, item)
end

--defs
for _,item in pairs(tool_list_clone) do

	local shovel = string.match(item, "shovel")

	local axe    = string.match(item, "axe")

	local pick   = string.match(item, "pick")

	local enchantment = string.match(item, "enchantment")

	--do a seperate thing of enchantments for this
	local sword = string.match(item, "sword")

	--if enchantable then create every variation of it that can be made
	if pick or shovel or axe then
		local description = minetest.registered_tools[item].description


		local wield_image = minetest.registered_tools[item].wield_image
		local inventory_image = minetest.registered_tools[item].inventory_image
		local full_punch_interval = minetest.registered_tools[item].tool_capabilities.full_punch_interval
		local max_drop_level = minetest.registered_tools[item].tool_capabilities.max_drop_level

		for quickmine = 0,enchant_level_max do
		for furnace   = 0,1 do
		for luck      = 0,1 do
		for delicate  = 0,1 do -- on or off
		if quickmine+furnace+luck+delicate > 0 then -- stop from duplicating items
		local temp_description = description
		local groupcaps = {}

		local groups = {flammable = 2}

		--quickmine enchant
		if quickmine >= 0 then
			if quickmine > 0 then
				temp_description = temp_description.."\nQuick Mine "..quickmine
			end
			for g in pairs(minetest.registered_tools[item].tool_capabilities.groupcaps) do
				groupcaps[g] = {}
				--avoid overwriting
				local timer = minetest.registered_tools[item].tool_capabilities.groupcaps[g].times
				local times = {}
				for t,n in pairs(timer) do
					times[t] = n/(quickmine+1)
				end

				--other vars, maybe code these into the game as enchantments?
				groupcaps[g].times = times

				groupcaps[g].uses = minetest.registered_tools[item].tool_capabilities.groupcaps[g].uses
				groupcaps[g].maxlevel = minetest.registered_tools[item].tool_capabilities.groupcaps[g].maxlevel
			end
		else
			groupcaps = minetest.registered_tools[item].tool_capabilities.groupcaps
		end

		--these three will be done on dignode
		--furnace enchant
		if furnace > 0 then
			groups["furnace"] = furnace
			temp_description = temp_description.."\nFurnace"
		end

		--luck enchant
		if luck > 0 then
			groups["luck"] = luck
			temp_description = temp_description.."\nLuck"
		end

		--delicate enchant
		if delicate > 0 then
			groups["delicate"] = delicate
			temp_description = temp_description.."\nDelicate"
		end

		groups["enchanted_tool"] = 1

		--define the item - thanks to kaeza
		minetest.register_tool(MOD_PREFIX..item:match("^.-:(.*)").."_"..quickmine..furnace..luck..delicate, {
			description = temp_description,
			inventory_image = inventory_image.."^[colorize:#551A8B:120",
			wield_image = wield_image,
			tool_capabilities = {
				full_punch_interval = full_punch_interval,
				max_drop_level=max_drop_level,
				groupcaps=groupcaps,
				damage_groups = {fleshy=2},
			},
			groups = groups,
			sound = {breaks = "default_tool_breaks"},
		})

		end
		end
		end
		end
		end
	end

end


--luck,furnace enchantment
local old_handle_node_drops = minetest.handle_node_drops
minetest.handle_node_drops = function(pos, drops, digger)
	local wielded_item = digger:get_wielded_item()

	-- if the wielded item isn't enchanted return
	if minetest.get_item_group(wielded_item:get_name(), "enchanted_tool") == 0 then
		return old_handle_node_drops(pos, drops, digger)
	end

	local description = minetest.registered_tools[wielded_item:get_name()].description

	-- convert the drops to the `ItemStack` format so some usefull functions can be called on them
	for k, item in pairs(drops) do
		drops[k] = ItemStack(item)
	end

	-- for all items in the drop list cook if cookable
	-- this may or may not work correctly for stacks of more than on item
	-- depending on the get_craft_result implementation
	if string.match(description, "Furnace") then
		for k, item in pairs(drops) do
			local output = minetest.get_craft_result({ method = "cooking", width = 1, items = {item}}).item
			if not output:is_empty() then
				drops[k] = output
			end
		end
	end

	-- for all items in the drop list incrase thier count
	-- but only if the item isn't a node to reduce abuse potential
	if string.match(description, "Luck") then
		for k, item in pairs(drops) do
			if not minetest.registered_nodes[item:get_name()] then
				local count = item:get_count()
				count = count + math.random(3) - 1
				item:set_count(count)
			end
		end
	end

	return old_handle_node_drops(pos, drops, digger)
end

-- delicate enchantment
local old_get_node_drops = minetest.get_node_drops
minetest.get_node_drops = function(node, toolname)
    if minetest.get_item_group(toolname, "delicate") > 0 then
        return {node}
    end
	return old_get_node_drops(node, toolname)
end


--generate items when enchanting by doing math.random(0,maxlevel)..math.random(0,maxlevel)......
local enchant_top = {
	name = "default_water_source_animated.png^[colorize:red:120^enchant_table_top.png",
	animation = {
		type = "vertical_frames",
		aspect_w = 16,
		aspect_h = 16,
		length = 2.0,
	},
}
minetest.register_node(MOD_PREFIX .. "crucible", {
	description = "Crucible",

	--Thanks to Gambit and kilbith for this
	tiles = {enchant_top,"enchant_table_bottom.png","enchant_table_side.png","enchant_table_side.png","enchant_table_side.png","enchant_table_side.png",},
	paramtype2 = "facedir",
	is_ground_content = true,
	groups = {snappy=1,choppy=3,flammable=2},
	paramtype = "light",
	drawtype = "nodebox",
	selection_box = {type="regular"},
	node_box = {
			type = "fixed",
			fixed = {
			--jukebox core - divide by 16 because 16 pixels
			{-8/16, -8/16, -8/16, 8/16, 7/16, 8/16},
			--top
			{-8/16, 6/16, -8/16, 8/16, 7/16, 8/16},
			--top trim
			{6/16, 7/16, -8/16, 8/16, 8/16, 8/16},
			{-8/16, 7/16, 6/16, 8/16, 8/16, 8/16},
			{-8/16, 7/16, -8/16, -6/16, 8/16, 8/16},
			{-8/16, 7/16, -8/16, 8/16, 8/16, -6/16},
			},
		},
	--on_place = minetest.rotate_node,
	on_construct = function(pos)
		enchantment.set_particlespawner(pos)
	end,
	on_destruct = function(pos)
		enchantment.remove_particlespawner(pos)
	end,
})

minetest.register_craft({
	output = MOD_PREFIX .. "crucible",
	recipe = {
		{"default:obsidian","basic_materials:energy_crystal_simple","default:obsidian"},
		{"default:obsidian","bucket:bucket_water","default:obsidian"},
		{"default:diamondblock","default:mese","default:diamondblock"},
	}
})


minetest.register_lbm({
	name = MOD_PREFIX .. "add_bubbles",
	nodenames = {MOD_PREFIX .. "crucible"},
	run_at_every_load = true,
	action = function(pos, node)
		enchantment.set_particlespawner(pos)
	end,
})
enchantment = {}

enchantment.set_particlespawner = function(pos)
	local ps = minetest.add_particlespawner({
		amount = 5,
		time = 0,
		minpos = {x=pos.x-0.35, y=pos.y+0.5, z=pos.z-0.35},
		maxpos = {x=pos.x+0.35, y=pos.y+0.5, z=pos.z+0.35},
		minvel = {x=0, y=0, z=0},
		maxvel = {x=0, y=0, z=0},
		minacc = {x=0, y=0.5, z=0},
		maxacc = {x=0, y=1.5, z=0},
		minexptime = 1,
		maxexptime = 1,
		minsize = 1,
		maxsize = 1,
		collisiondetection = false,
		vertical = false,
		texture = "bubble.png^[colorize:#551A8B:100",
	})
	local meta = minetest.get_meta(pos)
	meta:set_string("spawner", ps)
end

enchantment.remove_particlespawner = function(pos)
	local meta = minetest.get_meta(pos)
	local ps = meta:get_string("spawner")

	if ps then
		minetest.delete_particlespawner(ps)
	end
end

enchantment.check_for_items = function(pos)
	--item drop code
	for _,object in pairs(minetest.get_objects_inside_radius(pos, 1)) do
		if not object:is_player() and object:get_luaentity() and object:get_luaentity().name == "__builtin:item" then
			if string.match(object:get_luaentity().itemstring, "enchantment") or (not string.match(object:get_luaentity().itemstring, "axe") and not string.match(object:get_luaentity().itemstring, "pick") and not string.match(object:get_luaentity().itemstring, "shovel")) then
				break
			end
			local pos2 = object:getpos()
			local vec = {x=pos.x - pos2.x, y=pos.y - pos2.y, z=pos.z - pos2.z}

			--if item's in the goo do the little animation
			if math.abs(vec.x) < 0.5 and math.abs(vec.z) < 0.5 and vec.y < 0.5 then
				local itemer = object:get_luaentity().itemstring
				object:remove()
				local object2 = minetest.add_entity(pos2, MOD_PREFIX .. "item_ent")
				object2:get_luaentity().nodename = itemer
				minetest.sound_play("drama", {
					gain = 2.0,
					pos = pos,
				})
			end
		end
	end
end

minetest.register_abm{
	nodenames = {MOD_PREFIX .. "crucible"},
	interval = 1,
	chance = 1,
	action = function(pos)
		enchantment.check_for_items(pos)
	end,
}

--item entity
minetest.register_entity(MOD_PREFIX .. "item_ent", {
    hp_max = 1,
    physical = false,
    collisionbox = {0,0,0,0,0,0},
    visual = "wielditem",
    visual_size = {x = 0.25, y = 0.25},
    textures={"air"},
    makes_footstep_sound = false,
    timer = 0,
    old_nodename = nil,

    set_node = function(self,dtime)
		self.texture = ItemStack(self.nodename):get_name()
		self.old_nodename = self.nodename
		self.object:set_properties({textures={self.texture}})
    end,

    on_activate = function(self,dtime)
		self.set_node(self,dtime)
		self.object:setvelocity({x=0,y=0.3,z=0})
    end,


    on_step = function(self,dtime)
		self.timer = self.timer + dtime
		if self.old_nodename ~= self.nodename then
			self.set_node(self,dtime)
		end
		if self.timer > 3 then
			local pos = self.object:getpos()
			minetest.add_particlespawner({
				amount = 50,
				time = 0.1,
				minpos = {x=pos.x, y=pos.y, z=pos.z},
				maxpos = {x=pos.x, y=pos.y, z=pos.z},
				minvel = {x=-5, y=-5, z=-5},
				maxvel = {x=5, y=5, z=5},
				minacc = {x=0, y=0, z=0},
				maxacc = {x=0, y=0, z=0},
				minexptime = 1,
				maxexptime = 1,
				minsize = 1,
				maxsize = 1,
				collisiondetection = false,
				vertical = false,
				texture = "bubble.png^[colorize:#551A8B:100",
			})
			enchantment.enchant(pos,self.nodename)
			self.object:remove()

		end
    end,
})
--enchanting
enchantment.enchant = function(pos,item)
	if item == nil then
		return
	end
	local quickmine = math.random(0,enchant_level_max)
	local furnace   = math.random(0,1)
	local luck      = math.random(0,1)
	local delicate  = math.random(0,1)
	if quickmine+furnace+luck+delicate == 0 then
		local test = minetest.add_item(pos,item)
		if test then
			minetest.sound_play("fart", {
				gain = 2.0,
				pos = pos,
			})
		end

	else
		local test = minetest.add_item(pos, MOD_PREFIX..item:match("^.-:(.*)").."_"..quickmine..furnace..luck..delicate)
		if test then
			minetest.sound_play("enchant", {
				gain = 2.0,
				pos = pos,
			})
		end
	end
end
