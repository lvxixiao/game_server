local skynet = require "skynet"
local ProxySocket = require "Common.ProxySocket"
local socketdriver = require "skynet.socketdriver"
local hub = {}
local handler = {}
local AuthSrv
local ipConf = {
    ip = "0.0.0.0",
    port = "5678",
}

-- todo: zf 换成 snax

function handler.connect(fd, addr)
    skynet.sleep(200)
    skynet.send(AuthSrv, "lua", "ConnectFromHub", fd, addr)
    print("客户端连接", fd, addr)
end

function handler.disconnect(fd)
    print("客户端断开连接", fd)
    socketdriver.close(fd)
end

function handler.error(fd)
    print("连接异常", fd)
    socketdriver.close(fd)
end

-- 参考 https://blog.codingnow.com/2016/06/skynet_sample.html

function hub.open()
    ProxySocket.Open(ipConf)
end

skynet.start(function() 
    ProxySocket.Init(handler)
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