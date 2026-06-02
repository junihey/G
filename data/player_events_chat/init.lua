-- Hilfsfunktion für farbige Chat-Nachrichten
local function log_event(msg)
    minetest.chat_send_all(minetest.colorize("#FFFF00", "[Event] ") .. msg)
end

-- 1. Spieler joint (mit 2 Sekunden Verzögerung, damit man die Nachricht auch sieht!)
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    -- Verzögert das Senden um 2 Sekunden
    minetest.after(2.0, function()
        log_event(name .. " ist aufgewacht/beigetreten.")
    end)
end)

-- 2. Spieler stirbt
minetest.register_on_dieplayer(function(player, reason)
    if player then
        local name = player:get_player_name()
        log_event(name .. " ist gestorben.")
    end
end)

-- 3. Spieler craftet etwas
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
    if player and itemstack then
        local name = player:get_player_name()
        local item_name = itemstack:get_name()
        local count = itemstack:get_count()
        log_event(name .. " hat " .. count .. "x " .. item_name .. " hergestellt.")
    end
end)

-- 4. Spieler baut ab (Absturzsicher)
minetest.register_on_dignode(function(pos, oldnode, digger)
    -- Prüfen, ob überhaupt ein Spieler gräbt
    if digger and digger:is_player() then
        local name = digger:get_player_name()
        -- tostring() verhindert Fehler, falls oldnode.name aus irgendeinem Grund leer ist
        local block_name = tostring(oldnode.name) 
        
        log_event(name .. " hat " .. block_name .. " abgebaut.")
    end
end)

-- 5. Spieler platziert (Absturzsicher)
minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)
    -- Prüfen, ob überhaupt ein Spieler platziert
    if placer and placer:is_player() then
        local name = placer:get_player_name()
        local block_name = tostring(newnode.name)
        
        log_event(name .. " hat " .. block_name .. " platziert.")
    end
end)