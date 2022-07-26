local colors = {
    ["0"] = "#ff0000", -- red
    ["1"] = "#ff5500", -- orange
    ["2"] = "#0000ff", -- blue
    ["3"] = "#00ff00", -- green
    ["4"] = "#ffff00", -- yellow 
}
-- you can change the color in "minetest.chat_send_all" command

local function get_escape(color)
  return minetest.get_color_escape_sequence(colors[string.upper(color)] or "#FFFFFF")
end

local function colorize(text)
  return string.gsub(text,"#([01234])",get_escape)
end

-- end of color

minetest.register_privilege("serversay", {
description ="The privilege to use the Command ",
give_to_singleplayer = false,
})

--end of register privilege "servertext"


minetest.register_chatcommand("ssay", {
	params = "<message>",
	description = "Send text to chat",
	privs = {serversay = true},
  func = function( _ , message)
    minetest.chat_send_all(colorize("#0[SERVER] #1")..message)
	end,
})
-- end of register chatcommand server


