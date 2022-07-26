--[[
	This is a very basic example treasure spawning mod (TSM).
	It needs the mod “treasurer” to work.

	A TSM’s task is to somehow bring treasures (which are ItemStacks) into the world.
	This is also called “spawning treasures”.
	How it does this task is completely free to the programmer of the TSM. 

	This TSM gives one treasure (as returned from Treasurer) a new or respawning
	player.
	The treasure is requested from the treasurer mod.

	However, the treasurer mod comes itself with no treasures whatsoever. You need
	another mod which tells the treasurer what treasures to add. These mods are
	called “treasure registration mods” (TRMs). For this, there is another example mod,
	called “trm_default_example”, which registers a bunch of items of the default
	mod, like default:gold_ingot.

	See also the README file of Treasurer.

	For an advanced example, try tsm_default_example, which spawns treasures
	into chests.
]]

-- This function will later be registered to the corresponding callbacks
function welcome_gift(player)
	--[[ Request one random treasure from Treasurer. Remember that we receive a table
	 which could be empty.]]
	local treasures = treasurer.select_random_treasures(1)
	--[[ (We could have ommited the parameter above, because the function returns
	1 treasure when called without any parameters) ]]

	-- Get the inventory (InvRef) of the player
	local inventory = player:get_inventory()

	-- Check if we got an non-empty table. (If we don’t do this, we risk a crash!)
	if(#treasures >= 1) then
		-- Add the only treasure to the player’s main inventory
		inventory:add_item("main",treasures[1])
		-- That’s it!
	end
	--[[ If the returned table was empty, there’s nothing we can do here.
	The player gets no gifts. The table may be empty because no TRM was activated.
	Mods must be prepared for this.
	]]
end

-- The gift will be given on these events: new player creation, joining server, respawning
-- Therefore, we have to call these functions:
minetest.register_on_newplayer(welcome_gift)
minetest.register_on_joinplayer(welcome_gift)
minetest.register_on_respawnplayer(welcome_gift)

