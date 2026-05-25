local socket = require("socket")
local udp = socket.udp()

-- Sendet Daten lokal an die Node.js-Bridge auf Port 1234
udp:setpeername("127.0.0.1", 1234)

-- Event: Block abgebaut
minetest.register_on_dignode(function(pos, oldnode, digger)
    if digger and digger:is_player() then
        -- Erstellt eine simple OSC-ähnliche Textnachricht
        local message = "/luanti/dig " .. oldnode.name
        udp:send(message)
    end
end)