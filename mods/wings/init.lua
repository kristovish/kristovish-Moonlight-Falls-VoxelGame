--local minetest.colorize saves time
Colorize = minetest.colorize

--Making the priv
minetest.register_privilege("wings_god", {
	description = "Can change the wings settings of players",
	give_to_singleplayer = true
}) 

--Command to add fly privs player!
minetest.register_chatcommand("wings_effect", {
    description = "/wings_effect playername on / off (off = wings have an effect to you, on = they do not (This is good for keeping fly privs)",
	privs = {wings_god=true},
    func = function(name, param)
        local pname = param:split(' ')[1]
        local peffect = param:split(' ')[2]
        local player = minetest.get_player_by_name(pname)
        if player == nil then 
            minetest.chat_send_player(name, Colorize("#ff0000", "Error Player has to be online!"))
            return
        end
        if peffect == "on" then
            minetest.chat_send_player(name, Colorize("#ff8800", "Successfully changed wings settings from player "..pname.." to on"))
            minetest.chat_send_player(name, Colorize("#ff8800", "Your wings settings got changed to on"))
            player:set_attribute("No_wing_effect", "True")
        elseif peffect == "off" then
            --Simple but works
            minetest.chat_send_player(name, Colorize("#ff8800", "Successfully changed wings settings from player "..pname.." to off"))
            minetest.chat_send_player(name, Colorize("#ff8800", "Your wings settings got changed to off"))
            player:set_attribute("No_wing_effect", "False")
        else
            minetest.chat_send_player(name, Colorize("#ff0000", "Error you can only set it to on or off"))
        end
    end
}) 

--let admins / mods not effect by the wings but anyone else who glitchs
minetest.register_on_joinplayer(function(player)
	--check player privs 
    local name = player and player:get_player_name()
    if player:get_attribute("No_wing_effect") == nil then
        player:set_attribute("No_wing_effect", "False")
    end
    if player:get_attribute("No_wing_effect") == "True" then 
        return 
    end
    if player:get_attribute("No_wing_effect") == "False" then
        local privs = minetest.get_player_privs(name)
        --indeed important check else server would crash do NEVER REMOVE THIS CODE PART
        if not minetest.check_player_privs(name, { fly=true }) then
            return 
        end
        --------------------------------------------------------------
                
        priv_to_get_revoked = "fly" 
        for priviliges, _ in pairs(privs) do
            privs[priv_to_get_revoked] = nil
        end 
		minetest.set_player_privs(name, privs)
        
    end
end)

 
--the actual wings code
minetest.register_craftitem("wings:wings", {
	description = Colorize("#f3e15c", "Wings (hold it in your hands to fly)"),
	inventory_image = "wings.png",
})
 
local timer = 0
minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer >= 0.3 then
        for _, player in ipairs(minetest.get_connected_players()) do
            local name = player and player:get_player_name()
            --simple check nothing spezial to see here
            if name == nil then 
                return  
            end
            local wielditem = player:get_wielded_item()
            if wielditem:get_name() == "wings:wings" then
                if player:get_attribute("No_wing_effect") == "True" then
                    --minetest.chat_send_all("Worked")
                    timer = 0
                    return
                end
                local privs = minetest.get_player_privs(name)
			    local name = player:get_player_name()

			    privs.fly = true
			    minetest.set_player_privs(name, privs)
 
                timer = 0    
            else 
                if player:get_attribute("No_wing_effect") == "True" then
                    --minetest.chat_send_all("Worked")
                    timer = 0
                    return
                end
                local privs = minetest.get_player_privs(name)
			    local name = player:get_player_name()

                --indeed important check else server would crash do NEVER REMOVE THIS CODE PART
                if not minetest.check_player_privs(name, { fly=true }) then
                    timer = 0
                    return 
                end
                --------------------------------------------------------------
                
                priv_to_get_revoked = "fly" 
                for priviliges, _ in pairs(privs) do
                    privs[priv_to_get_revoked] = nil
                end 
			    minetest.set_player_privs(name, privs)
                timer = 0 
            end  
        end
    end 
end)  
