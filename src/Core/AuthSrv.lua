local skynet = require "skynet"
local AuthSrv = {}
local handler = {}
local RPC = require "Common.RPC"
local ProxySocket = require "Common.ProxySocket"
local socketdriver = require "skynet.socketdriver"

function AuthSrv.ConnectFromHub(fd, addr)
    skynet.error("fd", fd, "addr", addr)
    socketdriver.start(fd)
    socketdriver.nodelay(fd)
end

function handler.disconnect(fd)
    print("客户端断开连接11111111", fd)
    socketdriver.close(fd)
end

function handler.error(fd)
    print("连接异常11111111111", fd)
    socketdriver.close(fd)
end

skynet.start(function() 
    ProxySocket.Init(handler)
    
    skynet.dispatch("lua", function(_, _, cmd, ...)
        skynet.error("dispatchevent lua", cmd)
        local f = AuthSrv[cmd]
        if f then
            skynet.ret(skynet.pack(f(...)))
        else
            log("Unknown command : [%s]", cmd)
            skynet.response()(false)
        end
    end)
end)

-- 密钥验证
RPC.Init()