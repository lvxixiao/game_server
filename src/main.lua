local skynet = require "skynet"

skynet.start(function()
    skynet.newservice("debug_console",8000)

    local hub = skynet.uniqueservice "HubSrv"
	skynet.call(hub, "lua", "open", "0.0.0.0", 5678)
	skynet.exit()
end)