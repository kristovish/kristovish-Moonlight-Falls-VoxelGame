
regrow = {}

-- hidden node that runs timer and regrows fruit stored in meta
minetest.register_node("regrow:hidden", {
	drawtype = "airlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = true,
	drop = "",
	groups = {not_in_creative_inventory = 1},

	-- once placed start random timer between 20 and 30 minutes
	on_construct = function(pos)

		local time = math.random(60 * 20, 60 * 30)

		minetest.get_node_timer(pos):start(time)
	end,

	-- when timer reached check which fruit to place if tree still exists
	on_timer = function(pos, elapsed)

		local meta = minetest.get_meta(pos)

		if not meta then
			return
		end

		local fruit = meta:get_string("fruit") or ""
		local leaf = meta:get_string("leaf") or ""

		if fruit == "" or leaf == ""
		or not minetest.find_node_near(pos, 1, leaf) then
			fruit = "air"
		end

		minetest.set_node(pos, {name = fruit})
	end
})

-- helper function to register fruit nodes
regrow.add_fruit = function(nodename, leafname)

	-- does node actually exist ?
	if not minetest.registered_nodes[nodename] then
		return
	end

	-- override after_dig_node to start regrowth
	minetest.override_item(nodename, {

		after_dig_node = function(pos, oldnode, oldmetadata, digger)

			-- if node has been placed by player then do not regrow
			if oldnode.param2 > 0 then
				return
			end

			-- replace fruit with regrowth node, set fruit & leaf name
			minetest.set_node(pos, {name = "regrow:hidden"})

			local meta = minetest.get_meta(pos)

			meta:set_string("fruit", nodename)
			meta:set_string("leaf", leafname)
		end,
	})
end

-- wait until mods are loaded to save dependency mess
minetest.after(0.1, function()

	regrow.add_fruit("default:apple", "default:leaves")
	regrow.add_fruit("ethereal:banana", "ethereal:bananaleaves")
	regrow.add_fruit("ethereal:orange", "ethereal:orange_leaves")
	regrow.add_fruit("ethereal:coconut", "ethereal:palmleaves")
	regrow.add_fruit("ethereal:lemon", "ethereal:lemon_leaves")
	regrow.add_fruit("ethereal:olive", "ethereal:olive_leaves")
--	regrow.add_fruit("ethereal:golden_apple", "ethereal:yellowleaves")

end)
