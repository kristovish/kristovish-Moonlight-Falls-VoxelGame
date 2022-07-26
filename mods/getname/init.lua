-- getname Minetest mod. This mod is intended as a utility for other mods
-- that need to generate random names.
--
-- License: GNU GPLv3 (https://www.gnu.org/licenses/gpl-3.0.txt)
-- Copyright 2020 Kevin Sangeelee (kevin@susa.net)

local stamper = dofile(minetest.get_modpath("getname") .. '/stamper.lua')

local BLOCK_SIZE = 128
math.randomseed( os.time() )
local modpath = minetest.get_modpath('getname')
local listsPath = modpath .. '/lists/'

-- returns a function that will choose a line from the given file. The file
-- should contain at least 10 or 20 names (specifically, at least BLOCK_SIZE *
-- 1.5 bytes)
local function getNameGenerator(filename)

    local file = io.open(listsPath .. filename)

    if(not file) then
        minetest.log("error", "getname cannot open file " .. filename)
        return false
    end

    local size = file:seek("end")
    local BLOCKS = math.floor(size / BLOCK_SIZE)

    if BLOCKS < 1 then
        BLOCKS = 1 
    end 

    return function()
        local block = math.random(BLOCKS)
        local offset = math.random(0, BLOCK_SIZE / 2)
        -- Seek block from zero to one less than last block.
        -- Our random offset allows names on block boundaries
        -- to be included.
        file:seek("set", BLOCK_SIZE * (block - 1) + offset)
        file:read("*line") -- skip possible partial line
        local names={}
        for i=0, 20 do
            local name = file:read("*line")
            if(name == nil) then
                break
            end 
            table.insert(names, name)
        end 

        return names[math.random(1, #names)]
    end 
end

-- Define a table of generator functions for the underlying list files.
local generators = {
    feminine = getNameGenerator('feminine.txt'),
    masculine = getNameGenerator('masculine.txt'),
    genderless = getNameGenerator('genderless.txt'),
    surname = getNameGenerator('surnames.txt'),
    dog_female = getNameGenerator('dogs-female.txt'),
    dog_male = getNameGenerator('dogs-male.txt'),
    cat_female = getNameGenerator('cats-female.txt'),
    cat_male = getNameGenerator('cats-male.txt'),
    place_street = getNameGenerator('place-streets.txt'),
    place_hamlet = getNameGenerator('place-hamlets.txt'),
    place_coastal = getNameGenerator('place-coastal.txt'),
    place_wetland = getNameGenerator('place-wetlands.txt'),
    place_mountain = getNameGenerator('place-mountains.txt'),
    place_hill = getNameGenerator('place-hills.txt'),
    place_island = getNameGenerator('place-islands.txt'),
    place_village = getNameGenerator('place-villages.txt'),
}

local function eitherof(f1, f2)
    if(math.random(1,2) == 1) then
        return f1()
    else
        return f2()
    end
end

-- The getname table defines the global APIs.
getname = {

    -- forename() - return a forename, non gender-specific
    forename = function() return eitherof(generators.feminine, generators.masculine) end,

    -- surname() - return a surname
    surname = function() return generators.surname() end,

    -- genderlessName() - a genderless forename
    genderlessName = function() return generators.genderless() end,

    -- feminineName() - a femine forename
    feminineName = function() return generators.feminine() end,

    -- masculineName() - a masculine forename
    masculineName = function() return generators.masculine() end,

    -- dogName() - a dog name, non-gender-specific
    dogName = function() return eitherof(generators.dog_female, generators.dog_male) end,

    -- dogNameFemale() - a dog name (female)
    dogNameFemale = function() return generators.dog_female() end,

    -- dogNameMale() - a dog name (male)
    dogNameMale = function() return generators.dog_male() end,

    -- catName() - a cat name, non-gender-specific
    catName = function() return eitherof(generators.cat_female, generators.cat_male) end,

    -- catNameFemale() - a cat name (female)
    catNameFemale = function() return generators.cat_female() end,

    -- catNameMale() - a cat name (male)
    catNameMale = function() return generators.cat_male() end,

    -- Names for people, full names including surname.
    fullName = function() return getname.genderlessName() .. ' ' .. getname.surname() end,
    fullNameMale = function() return getname.masculineName() .. ' ' .. getname.surname() end,
    fullNameFemale = function() return getname.feminineName() .. ' ' .. getname.surname() end,
}

getnameCall = function(fname)
    if(getname[fname]) then
        return getname[fname]()
    elseif(generators[fname]) then
        return generators[fname]()
    end
end

-- Generate a string of parameter options for the chat command. This is just a
-- list of the getname API functions, followed by a list of underlying
-- generator functions.

local chat_params = ''
for k,_ in pairs(getname) do
    if chat_params ~= '' then chat_params =  chat_params .. ' | ' end
    chat_params = chat_params .. '<' .. k .. '>'
end

for k,_ in pairs(generators) do
    chat_params = chat_params .. ' | <' .. k .. '>'
end

minetest.register_chatcommand("getname", {
    params = chat_params,
    description = "Generate and show a suggested name.",
    func = function(name, type)
        local f = getname[type] or generators[type]
        if(f) then
            minetest.chat_send_player(name, "Suggested name '" .. f() .. "'")
        end
    end,
})

-- Register the stamper tool and tool chooser form field handler.
minetest.register_tool("getname:stamper", stamper.toolDefinition)
minetest.register_craft(stamper.toolRecipe)
minetest.register_on_player_receive_fields(stamper.playerReceiveFields)

minetest.log("[MOD] getname has loaded. Functions: " .. chat_params)
