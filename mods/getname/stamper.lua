-- The stamper is the tool that can be used to 'stamp' random names onto signs.
-- There is a formspec that allows the player to choose what kind of random
-- name should be written to the sign (e.g. village, street, person's name,
-- etc.)
--
-- It depends on signs_lib to update the sign.

local function stamper(idStr, labelStr)
    return { id = idStr, label = labelStr }
end

local stampers = {
    stamper('place_street', 'Street'),
    stamper('place_village', 'Village'),
    stamper('place_hamlet', 'Hamlet'),
    stamper('place_coastal', 'Coastal'),
    stamper('place_wetland', 'Wetland'),
    stamper('place_island', 'Island'),
    stamper('place_mountain', 'Mountain'),
    stamper('fullName', 'Name'),
    stamper('fullNameFemale', 'Name (F)'),
    stamper('fullNameMale', 'Name (M)'),
    stamper('dogName', 'Dog Name'),
    stamper('catName', 'Cat Name'),
}

-- Returns the id of the rubber-stamp when given a button label. This will
-- ultimately be used to refer to a generator to pick a random string to stamp
-- onto a sign.
local function stampIdFromLabel(label)
    
    for _,v in ipairs(stampers) do
        if v.label == label then
            return v.id
        end
    end

    return nil
end

-- Generate the formspec for the rubber-stamp chooser form. The existing active
-- stamper is used to highlight the currently active setting.
local function getFormspec(active_stamper)
    
    local f = {
    "formspec_version[3]",
    "size[8,5]",
    }

    for i,v in ipairs(stampers) do

        local cols = 5
        local w = 1.4
        local h = 1
        local x = (((i-1) % cols) + 0.35) * w
        local y = (math.floor((i-1) / cols) + 0.35) * h

        local button =
          "button[" .. x .. "," .. y ..
          ";"..w..","..h..";stamp;" .. 
          v.label .. 
          "]"

        table.insert(f, button)

        -- Add highlight if this iteration is the active stamper
        if(v.id == active_stamper) then
            table.insert(f, "box[" .. x .. "," .. y ..  ";"..w..","..h..";#80f08060]")
        end

    end

    table.insert(f, "button_exit[3,3.7;2,1;close;Close]")

    return table.concat(f, "")
end

local toolDefinition = {

    description = "Name Stamp",
    inventory_image = "getname_tool_stamper.png",

    -- A right-click on any non-sign node shows the chooser form.
    --
    on_place = function(itemstack, placer, pointed_thing)

        if(pointed_thing.type == 'node') then
            local node = minetest.get_node(pointed_thing.under)
            local node_def = minetest.registered_nodes[node.name]
            
            -- Show the chooser if we right-click a non-sign node.
            if(node_def.groups and not node_def.groups.sign) then
                local item = placer:get_wielded_item()
                local itemMeta = item:get_meta()
                local generator = itemMeta:get_string('getname_type') or 'place_street'

                formspec = getFormspec(generator)
                minetest.show_formspec(placer:get_player_name(), "getname:chooser", formspec)
            end
        end
    end,

    -- A left-click (punch) on a sign invokes the name generator and updates
    -- the sign.
    --
    on_use = function(itemstack, user, pointed_thing)

        if(pointed_thing.type == 'node') then
            local node = minetest.get_node(pointed_thing.under)
            local node_def = minetest.registered_nodes[node.name]
            
            if(node_def.groups and node_def.groups.sign) then
                local item = user:get_wielded_item()
                local itemMeta = item:get_meta()
                local generator = itemMeta:get_string('getname_type') or 'place_street'

                if(signs_lib) then
                    signs_lib.update_sign( pointed_thing.under, {
                        text = getnameCall(generator)
                    })
                end
            end
        end

    end,
}

-- clay_lump, steel_ingot, stick. Perhaps dye:black beside clay_lump? 
local toolRecipe = {
	output = "getname:stamper",
	recipe = {
		{"", "default:clay_lump", ""},
		{"", "default:steel_ingot", ""},
		{"", "default:stick", ""},
	}
}

local function playerReceiveFields(player, formname, fields)
    
    if(formname ~= 'getname:chooser') then
        return
    end

    local item = player:get_wielded_item()
    local itemMeta = item:get_meta()

    local stampType = stampIdFromLabel(fields.stamp)

    if(stampType and string.len(stampType) > 1) then
        itemMeta:set_string('getname_type', stampType)
        player:set_wielded_item(item)

        local formspec = getFormspec(stampType)
        minetest.show_formspec(player:get_player_name(), "getname:chooser", formspec)
    end

    return true -- inhibit further processing
end

-- Return a table of exported references to reduce pollution of the global
-- space.

return {
    idFromLabel = stampIdFromLabel,
    getFormspec = getFormspec,
    toolDefinition = toolDefinition,
    toolRecipe = toolRecipe,
    playerReceiveFields = playerReceiveFields,
}

