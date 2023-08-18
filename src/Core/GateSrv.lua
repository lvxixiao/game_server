local skynet = require "skynet"
local RPC = require "Common.RPC"
local gateserver = require "snax.gateserver"
local handler = {}

function handler.connect(fd, ipaddr)
    skynet.error("客户端连接 connect fd = ", fd, ", ipaddr = ",ipaddr)
    gateserver.openclient(fd) --调用这个接口之后这个服务才会开始接受消息
end

function handler.disconnect(fd)
    skynet.error("客户端断开 disconnect fd = ", fd)
end

function handler.message(fd, msg, sz)
    skynet.error("有新的数据, 一个完整包 message, fd = ", fd, "msg=", msg, ", sz = ", sz, "\n")
    skynet.redirect(agent, 0, "client", fd, msg, sz)
end

function handler.error(fd, msg)
    skynet.error("error fd =", fd, msg) 
end

function handler.command(cmd, source, ...)
    -- 其他服务向gate发 lua 消息就会调用这个接口
    skynet.error("cmd = ", cmd, ", source = ", source, ", args = ", table.dump(...))
end

RPC.Init()
gateserver.start(handler)