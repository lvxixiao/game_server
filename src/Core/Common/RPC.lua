local RPC = {}

function RPC.Init()
    local sproto = require "sproto"
    local f = assert(io.open("Sproto/c2s.sproto"))
    local t = f:read "a"
    f:close()
    RPC.host = sproto.parse(t):host "package"
    local f = assert(io.open("Sproto/s2c.sproto"))
    local t = f:read "a"
    f:close()
    RPC.request = RPC.host:attach(sproto.parse(t))
end

return RPC