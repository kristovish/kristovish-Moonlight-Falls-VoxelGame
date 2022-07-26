loot_crates = {}

loot_crates.ent = {}

-- Inventory --

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "loot_crates:loot_crate_common" then
        local name = player:get_player_name()
        local ent = loot_crates.ent[name]
        if ent 
        and ent:get_luaentity() then
            ent = ent:get_luaentity()
            local inv = minetest.get_inventory({type = "detached", name = "loot_crate_common"})
            local table = {}
            local inv_size = inv:get_size("loot_crate_common_inv")
            if inv_size > 0 then
                for i = 1, inv_size do
                    table[i] = inv:get_stack("loot_crate_common_inv", i):to_table()
                end
                ent.loot_table = mobkit.remember(ent, "loot_table", table)
            end
        end
        return true
	elseif formname == "loot_crates:loot_crate_uncommon" then
        local name = player:get_player_name()
        local ent = loot_crates.ent[name]
        if ent 
        and ent:get_luaentity() then
            ent = ent:get_luaentity()
            local inv = minetest.get_inventory({type = "detached", name = "loot_crate_uncommon"})
            local table = {}
            local inv_size = inv:get_size("loot_crate_uncommon_inv")
            if inv_size > 0 then
                for i = 1, inv_size do
                    table[i] = inv:get_stack("loot_crate_uncommon_inv", i):to_table()
                end
                ent.loot_table = mobkit.remember(ent, "loot_table", table)
            end
        end
        return true
	elseif formname == "loot_crates:loot_crate_rare" then
        local name = player:get_player_name()
        local ent = loot_crates.ent[name]
        if ent 
        and ent:get_luaentity() then
            ent = ent:get_luaentity()
            local inv = minetest.get_inventory({type = "detached", name = "loot_crate_rare"})
            local table = {}
            local inv_size = inv:get_size("loot_crate_rare_inv")
            if inv_size > 0 then
                for i = 1, inv_size do
                    table[i] = inv:get_stack("loot_crate_rare_inv", i):to_table()
                end
                ent.loot_table = mobkit.remember(ent, "loot_table", table)
            end
        end
        return true
	else
        return false
    end
end)

local function create_detached_inv(name)
	local inv = minetest.create_detached_inventory(name, {
		allow_move = function(inv, from_list, from_index, _, _, _, player)
			local stack = inv:get_stack(from_list, from_index)
			return 0
		end,
		allow_put = function(_, _, _, stack)
			return 0
		end,
		allow_take = function(_, _, _, stack)
			return stack:get_count()
		end,
	})
	inv:set_size(name .. "_inv", 3)
	inv:set_width(name .. "_inv", 3)
end

create_detached_inv("loot_crate_common")
create_detached_inv("loot_crate_uncommon")
create_detached_inv("loot_crate_rare")

-- Loot registration --

loot_crates.common_loot = {}
loot_crates.uncommon_loot = {}
loot_crates.rare_loot = {}

local function is_valid_rarity(str)
    local valid = {
        "common",
        "uncommon",
        "rare"
    }
    for i = 1, 3 do
        if str == valid[i] then
            return true
        end
    end
    return false
end

function loot_crates.register_loot(rarity, loot)
    if not is_valid_rarity(rarity) then
        return
    end
    if loot.name
    and type(loot.name) == "string"
    and loot.max_count
    and type(loot.max_count) == "number" then
        table.insert(loot_crates[rarity .. "_loot"], {name = loot.name, max_count = loot.max_count})
    end
end

if minetest.get_modpath("default") then
    loot_crates.register_loot("common", {name = "default:stick", max_count = 14})
    loot_crates.register_loot("common", {name = "default:torch", max_count = 99})
    loot_crates.register_loot("common", {name = "default:cobble", max_count = 48})
    loot_crates.register_loot("uncommon", {name = "default:steel_ingot", max_count = 12})
    loot_crates.register_loot("uncommon", {name = "default:gold_ingot", max_count = 8})
    loot_crates.register_loot("uncommon", {name = "default:copper_ingot", max_count = 8})
    loot_crates.register_loot("uncommon", {name = "binoculars:binoculars", max_count = 1})
    loot_crates.register_loot("rare", {name = "default:diamond", max_count = 4})
    loot_crates.register_loot("rare", {name = "default:mese_crystal", max_count = 4})
end

local function update_emission(self, texture, overlay)
    local pos = self.object:get_pos()
    local level = minetest.get_node_light(pos, minetest.get_timeofday())
    if not level then return end
    local color = math.ceil(level / minetest.LIGHT_MAX * 255)
    if color > 255 then
        color = 255
    end
    local modifier = ("^[multiply:#%02X%02X%02X"):format(color, color, color)
    self.object:set_properties({
        textures = {"(" .. texture .. modifier .. ")^" .. overlay}
    })
end

minetest.register_entity("loot_crates:common", {
    hp_max = 1,
    physical = true,
    collisionbox = {-0.25, 0, -0.25, 0.25, 0.5, 0.25},
    visual = "mesh",
    visual_size = {x = 6.5, y = 6.5},
    mesh = "loot_crates_mesh.b3d",
    textures = {"loot_crates_bg.png"},
    glow = 16,
    makes_footstep_sound = false,
    get_staticdata = mobkit.statfunc,
    logic = function(self)
        if mobkit.timer(self, 1) then
            minetest.add_particle({
                pos = self.object:get_pos(),
                velocity = {x = 0, y = 10, z = 0},
                acceleration = {x = 0, y = 20, z = 0},
                expirationtime = 6,
                size = 6,
                collisiondetection = false,
                vertical = false,
                glow = 16,
                texture = "loot_crates_green_beacon.png"
            })
        end
    end,
    physics = function(self) end,
    on_step = function(self, dtime, moveresult)
        mobkit.stepfunc(self, dtime, moveresult)
        update_emission(self, "loot_crates_bg.png", "loot_crates_green.png")
        local remove = true
        if #self.loot_table < 1 then
            minetest.add_particlespawner({
                amount = math.random(4, 6),
                time = 0.25,
                minpos = self.object:get_pos(),
                maxpos = self.object:get_pos(),
                minvel = vector.new(-1, 1, -1),
                maxvel = vector.new(1, 2, 1),
                minacc = vector.new(0, -9.81, 0),
                maxacc = vector.new(0, -9.81, 0),
                minsize = 1,
                maxsize = 1.5,
                collisiondetection = true,
                glow = 16,
                texture = "loot_crates_green_beacon.png"
            })
            self.object:remove()
        end
    end,
    on_activate = function(self, dtime, staticdata)
        mobkit.actfunc(self, dtime, staticdata)
        self.object:set_animation({x = 0, y = 60}, 10, 0, true)
        self.loot_table = mobkit.recall(self, "loot_table") or {}
        self.loot_init = mobkit.recall(self, "loot_init") or false
        if not self.loot_init then
            for i = 1, 3 do
                local random = math.random(#loot_crates.common_loot)
                local loot = loot_crates.common_loot[random]
                self.loot_table[i] = {name = loot.name, count = math.random(loot.max_count), wear=0, metadata=""}
            end
            self.loot_table = mobkit.remember(self, "loot_table", self.loot_table)
            self.loot_init = mobkit.remember(self, "loot_init", true)
        end
    end,
    on_rightclick = function(self, clicker)
        loot_crates.ent[clicker:get_player_name()] = self.object
        local inv = minetest.get_inventory({type = "detached", name = "loot_crate_common"})
        inv:set_list("loot_crate_common_inv", {})
        for k, v in pairs(self.loot_table) do
             inv:set_stack("loot_crate_common_inv", k, v)
        end
        local formspec = {
            "size[8, 8;]",
            "label[3,0;Common Loot Crate]",
            "list[detached:loot_crate_common;loot_crate_common_inv;2.5,1;3,2;]",
            "list[current_player;main;0,4;8,4;]"
        }
        minetest.show_formspec(clicker:get_player_name(), "loot_crates:loot_crate_common", table.concat(formspec))
    end
})

minetest.register_entity("loot_crates:uncommon", {
    hp_max = 1,
    physical = true,
    collisionbox = {-0.25, 0, -0.25, 0.25, 0.5, 0.25},
    visual = "mesh",
    visual_size = {x = 6.5, y = 6.5},
    mesh = "loot_crates_mesh.b3d",
    textures = {"loot_crates_bg.png"},
    glow = 16,
    makes_footstep_sound = false,
    get_staticdata = mobkit.statfunc,
    logic = function(self) end,
    physics = function(self) end,
    on_step = function(self, dtime, moveresult)
        mobkit.stepfunc(self, dtime, moveresult)
        update_emission(self, "loot_crates_bg.png", "loot_crates_blue.png")
        if mobkit.timer(self, 3) then
            minetest.add_particle({
                pos = self.object:get_pos(),
                velocity = {x = 0, y = 10, z = 0},
                acceleration = {x = 0, y = 20, z = 0},
                expirationtime = 6,
                size = 4,
                collisiondetection = false,
                vertical = false,
                glow = 16,
                texture = "loot_crates_blue_beacon.png"
            })
        end
        local remove = true
        if #self.loot_table < 1 then
            minetest.add_particlespawner({
                amount = math.random(4, 6),
                time = 0.25,
                minpos = self.object:get_pos(),
                maxpos = self.object:get_pos(),
                minvel = vector.new(-1, 1, -1),
                maxvel = vector.new(1, 2, 1),
                minacc = vector.new(0, -9.81, 0),
                maxacc = vector.new(0, -9.81, 0),
                minsize = 1,
                maxsize = 1.5,
                collisiondetection = true,
                glow = 16,
                texture = "loot_crates_blue_beacon.png"
            })
            self.object:remove()
        end
    end,
    on_activate = function(self, dtime, staticdata)
        mobkit.actfunc(self, dtime, staticdata)
        self.object:set_animation({x = 1, y = 59}, 10, 0, true)
        self.loot_table = mobkit.recall(self, "loot_table") or {}
        self.loot_init = mobkit.recall(self, "loot_init") or false
        if not self.loot_init then
            for i = 1, 3 do
                local random = math.random(#loot_crates.uncommon_loot)
                local loot = loot_crates.uncommon_loot[random]
                self.loot_table[i] = {name = loot.name, count = math.random(loot.max_count), wear=0, metadata=""}
            end
            self.loot_table = mobkit.remember(self, "loot_table", self.loot_table)
            self.loot_init = mobkit.remember(self, "loot_init", true)
        end
    end,
    on_rightclick = function(self, clicker)
        loot_crates.ent[clicker:get_player_name()] = self.object
        local inv = minetest.get_inventory({type = "detached", name = "loot_crate_uncommon"})
        inv:set_list("loot_crate_uncommon_inv", {})
        for k, v in pairs(self.loot_table) do
             inv:set_stack("loot_crate_uncommon_inv", k, v)
        end
        local formspec = {
            "size[8, 8;]",
            "label[3,0;Uncommon Loot Crate]",
            "list[detached:loot_crate_uncommon;loot_crate_uncommon_inv;2.5,1;3,2;]",
            "list[current_player;main;0,4;8,4;]"
        }
        minetest.show_formspec(clicker:get_player_name(), "loot_crates:loot_crate_uncommon", table.concat(formspec))
    end
})

minetest.register_entity("loot_crates:rare", {
    hp_max = 1,
    physical = true,
    collisionbox = {-0.25, 0, -0.25, 0.25, 0.5, 0.25},
    visual = "mesh",
    visual_size = {x = 6.5, y = 6.5},
    mesh = "loot_crates_mesh.b3d",
    textures = {"loot_crates_bg.png"},
    glow = 16,
    makes_footstep_sound = false,
    get_staticdata = mobkit.statfunc,
    logic = function(self) end,
    physics = function(self) end,
    on_step = function(self, dtime, moveresult)
        mobkit.stepfunc(self, dtime, moveresult)
        update_emission(self, "loot_crates_bg.png", "loot_crates_red.png")
        if mobkit.timer(self, 6) then
            minetest.add_particle({
                pos = self.object:get_pos(),
                velocity = {x = 0, y = 10, z = 0},
                acceleration = {x = 0, y = 20, z = 0},
                expirationtime = 6,
                size = 2,
                collisiondetection = false,
                vertical = false,
                glow = 16,
                texture = "loot_crates_red_beacon.png"
            })
        end
        local remove = true
        if #self.loot_table < 1 then
            minetest.add_particlespawner({
                amount = math.random(4, 6),
                time = 0.25,
                minpos = self.object:get_pos(),
                maxpos = self.object:get_pos(),
                minvel = vector.new(-1, 1, -1),
                maxvel = vector.new(1, 2, 1),
                minacc = vector.new(0, -9.81, 0),
                maxacc = vector.new(0, -9.81, 0),
                minsize = 1,
                maxsize = 1.5,
                collisiondetection = true,
                glow = 16,
                texture = "loot_crates_red_beacon.png"
            })
            self.object:remove()
        end
    end,
    on_activate = function(self, dtime, staticdata)
        mobkit.actfunc(self, dtime, staticdata)
        self.object:set_animation({x = 1, y = 59}, 10, 0, true)
        self.loot_table = mobkit.recall(self, "loot_table") or {}
        self.loot_init = mobkit.recall(self, "loot_init") or false
        if not self.loot_init then
            for i = 1, 3 do
                local random = math.random(#loot_crates.rare_loot)
                local loot = loot_crates.rare_loot[random]
                self.loot_table[i] = {name = loot.name, count = math.random(loot.max_count), wear=0, metadata=""}
            end
            self.loot_table = mobkit.remember(self, "loot_table", self.loot_table)
            self.loot_init = mobkit.remember(self, "loot_init", true)
        end
    end,
    on_rightclick = function(self, clicker)
        loot_crates.ent[clicker:get_player_name()] = self.object
        local inv = minetest.get_inventory({type = "detached", name = "loot_crate_rare"})
        inv:set_list("loot_crate_rare_inv", {})
        for k, v in pairs(self.loot_table) do
             inv:set_stack("loot_crate_rare_inv", k, v)
        end
        local formspec = {
            "size[8, 8;]",
            "label[3,0;Rare Loot Crate]",
            "list[detached:loot_crate_rare;loot_crate_rare_inv;2.5,1;3,2;]",
            "list[current_player;main;0,4;8,4;]"
        }
        minetest.show_formspec(clicker:get_player_name(), "loot_crates:loot_crate_rare", table.concat(formspec))
    end
})

mob_core.register_spawn({
	name = "loot_crates:common",
	nodes = {},
	min_light = 0,
	max_light = 15,
	min_height = 1,
	max_height = 1024,
	min_rad = 24,
	max_rad = 256,
	group = 0,
}, 300, 1)

mob_core.register_spawn({
	name = "loot_crates:uncommon",
	nodes = {},
	min_light = 0,
	max_light = 15,
	min_height = -1024,
	max_height = 1,
	min_rad = 24,
	max_rad = 256,
	group = 0,
}, 300, 5)

mob_core.register_spawn({
	name = "loot_crates:rare",
	nodes = {},
	min_light = 0,
	max_light = 15,
	min_height = -31000,
	max_height = -1024,
	min_rad = 24,
	max_rad = 256,
	group = 0,
}, 300, 10)