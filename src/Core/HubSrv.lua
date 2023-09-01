local skynet = require "skynet"
local socket = require "skynet.socket"
local hub = {}
local AuthSrv
local ipConf = {
    ip = "0.0.0.0",
    port = "5678",
}

-- todo: zf 换成 snax

-- 参考 https://blog.codingnow.com/2016/06/skynet_sample.html

local function newClient(fd, addr)
    skynet.error("hub new cliend, fd =", fd, "addr =", table.dump(addr))
    skynet.send(AuthSrv, "lua", "ConnectFromHub", fd, addr)
end

function hub.open()
    local ip = ipConf.ip
    local port = ipConf.port
    skynet.error(string.format("hub listen ip:%s, oprt:%s", ip, port))
    local fd = socket.listen(ip, port)
    socket.start(fd, newClient)
end

skynet.start(function() 
    AuthSrv = skynet.newservice("AuthSrv")

    skynet.dispatch("lua", function (_,_, cmd, ...)
        local f = hub[cmd]
        if f then
            skynet.ret(skynet.pack(f(...)))
        else
            log("Unknown command : [%s]", cmd)
            skynet.response()(false)
        end
    end)
end)