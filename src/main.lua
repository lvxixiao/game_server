local skynet = require "skynet"

skynet.start(function()
    print("hello world")
    local agentSrv = skynet.newservice("AgentSrv")
    local GateSrv = skynet.newservice("GateSrv")
end)