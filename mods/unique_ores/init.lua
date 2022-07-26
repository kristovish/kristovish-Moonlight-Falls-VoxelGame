unique_ores = {}
unique_ores.debug = false
unique_ores.names = {
	{
		{"az","Az","vibrant"},
		{"xor","Xor","grey"},
		{"upsid","Upsid","grey"},
		{"lux","Lux","dark"},
		{"magn","Magn","grey"},
		{"aur","Aur","vibrant"},
		{"noct","Noct","dark"},
		{"byzant","Byzant","dark"},
		{"tyr","Tyr","dark"},
	},
	{
		strong = {
			{"an","red"},
			{"on","red"},
			{"az","silver"},
			{"iz","green"},
			{"ul","blue"},
			{"umin","blue"},
			{"olith","purple"},
		},
		regular = {
			{"in","brown"},
			{"oc","yellow"},
			{"al","green"},
			{"","silver"},
		}
	},
	{
		{"ium",instant_ores.register_metal,"durable"},
		{"ite",instant_ores.register_metal,"fast"},
		{"on",instant_ores.register_crystal,"durable"},
		{"ine",instant_ores.register_crystal,"fast"},
	},
}

unique_ores.colors = {
	vibrant={
		red="#C00:140",
		purple="#A0D:160",
		green="#1C1:140",
		blue="#00C:140",
		silver="#DDD:100",
		brown="#860:140",
		yellow="#DB0:140",
	},
	dark = {
		red="#400:160",
		purple="#404:160",
		green="#040:160",
		blue="#004:160",
		silver="#000:180",
		brown="#401800:160",
		yellow="#440:160",
	},
	grey = {
		red="#623:96",
		purple="#757:96",
		green="#474:96",
		blue="#246:96",
		silver="#CCC:128",
		brown="#764:96",
		yellow="#984:110",
	},
}

unique_ores.magical_noisemaker = PerlinNoise(tonumber(minetest.get_mapgen_setting("seed"))%100000000, 12, 2, 1000)

local worldrand = function(n)
	return math.abs(math.floor(unique_ores.magical_noisemaker:get2d({x=n*200,y=-200})))
end

local strong_prefix = unique_ores.names[1][(worldrand(1) % #(unique_ores.names[1]))+1]
local strong_middle = unique_ores.names[2].strong[(worldrand(2) % #(unique_ores.names[2].strong))+1]
local strong_suffix = unique_ores.names[3][(worldrand(3) % #(unique_ores.names[3]))+1]

local regular_prefix = unique_ores.names[1][(worldrand(4) % #(unique_ores.names[1]))+1]
local regular_middle = unique_ores.names[2].regular[(worldrand(5) % #(unique_ores.names[2].regular))+1]
local regular_suffix = unique_ores.names[3][(worldrand(6) % #(unique_ores.names[3]))+1]

strong_suffix[2]({
	name = "unique_ores:"..strong_prefix[1]..strong_middle[1]..strong_suffix[1],
	description = strong_prefix[2]..strong_middle[1]..strong_suffix[1],
	color = unique_ores.colors[strong_prefix[3] ][strong_middle[2] ],
	power = 3,
	speed = 3 + ((strong_suffix[3] == "fast") and 0.25 or 0),
	depth = 128,
	rarity = 16,
	durability = 250 + ((strong_suffix[3] == "durable") and 300 or 0),
})


regular_suffix[2]({
	name = "unique_ores:"..regular_prefix[1]..regular_middle[1]..regular_suffix[1],
	description = regular_prefix[2]..regular_middle[1]..regular_suffix[1],
	color = unique_ores.colors[regular_prefix[3] ][regular_middle[2] ],
	power = 2,
	speed = 2.25+((regular_suffix[3] == "fast") and 0.5 or 0),
	depth = 32,
	rarity = 13,
	durability = 128 + ((regular_suffix[3] == "durable") and 192 or 0),
})

 -- Keep track of the names, so that other mods can still make an attempt to work with us, 
 -- even though we are literally the most insane and unpredictable mod in all of minetest.
unique_ores.strong_material = "unique_ores:"..strong_prefix[1]..strong_middle[1]..strong_suffix[1]
unique_ores.regular_material = "unique_ores:"..regular_prefix[1]..regular_middle[1]..regular_suffix[1]

if unique_ores.debug then
	minetest.after(10, minetest.chat_send_all, 
		(tonumber(minetest.get_mapgen_setting("seed"))%100000000) .." ".. worldrand(1) .." ".. worldrand(2) .." ".. worldrand(3) .." ".. worldrand(4) .." ".. worldrand(5) .." ".. worldrand(6)
	)
end