local skynet = require "skynet"
local AuthSrv = {}

function AuthSrv.ConnectFromHub(fd, addr)
    skynet.error("fd", fd, "addr", addr)
end

skynet.start(function() 
    skynet.dispatch("lua", function(_, _, cmd, ...)
        local f = AuthSrv[cmd]
        if f then
            skynet.ret(skynet.pack(f(...)))
        else
            log("Unknown command : [%s]", cmd)
            skynet.response()(false)
        end
    end)
end)


return AuthSrv