local skynet = require "skynet"
local netpack = require "skynet.netpack"
local socketdriver = require "skynet.socketdriver"

local ProxySocket = {}
local socket
local queue
local CMD = setmetatable({}, { __gc = function() netpack.clear(queue) end })

local connection = {}
local listen_context = {}

function ProxySocket.Open(conf)
    assert(not socket)
    local address = conf.address or "0.0.0.0"
    local port = assert(conf.port)
    skynet.error(string.format("Listen on %s:%d", address, port))
    socket = socketdriver.listen(address, port)
    listen_context.co = coroutine.running()
    listen_context.fd = socket
    skynet.wait(listen_context.co)
    conf.address = listen_context.addr
    conf.port = listen_context.port
    listen_context = nil
    socketdriver.start(socket)
end

function ProxySocket.close()
    assert(socket)
    socketdriver.close(socket)
end

function ProxySocket.Init(handler)
    local MSG = {}

    local function dispatch_msg(fd, msg, sz)
        skynet.error(string.format("dispatch msg"))
        local isConnect = connection[fd]
		if not isConnect then
			-- todo: zf
			skynet.error("dispatch_msg", "lose fd", fd)
		end

		-- local todo: zf entitymap
    end

    MSG.data = dispatch_msg

    local function dispatch_queue()
		local fd, msg, sz = netpack.pop(queue)
		if fd then
			-- may dispatch even the handler.message blocked
			-- If the handler.message never block, the queue should be empty, so only fork once and then exit.
			skynet.fork(dispatch_queue)
			dispatch_msg(fd, msg, sz)

			for fd, msg, sz in netpack.pop, queue do
				dispatch_msg(fd, msg, sz)
			end
		end
	end

    MSG.more = dispatch_queue

    function MSG.open(fd, addr)
		connection[fd] = true
		handler.connect(fd, addr)
	end

    function MSG.close(fd)
        if fd ~= socket then
            if connection[fd] then
                connection[fd] = false
            end
            if handler.disconnect then
                handler.disconnect(fd)
            end
        else
            socket = nil
        end
    end

    function MSG.error(fd, msg)
		if fd == socket then
			skynet.error("gateserver accept error:",msg)
		else
			socketdriver.shutdown(fd)
			if handler.error then
				handler.error(fd, msg)
			end
		end
	end

    function MSG.warning(fd, size)
		if handler.warning then
			handler.warning(fd, size)
		end
	end

    function MSG.init(id, addr, port)
		if listen_context then
			local co = listen_context.co
			if co then
				assert(id == listen_context.fd)
				listen_context.addr = addr
				listen_context.port = port
				skynet.wakeup(co)
				listen_context.co = nil
			end
		end
	end

    skynet.register_protocol {
		name = "socket",
		id = skynet.PTYPE_SOCKET,	-- PTYPE_SOCKET = 6
		unpack = function ( msg, sz )
			return netpack.filter( queue, msg, sz)
		end,
		dispatch = function (_, _, q, type, ...)
			queue = q
			print("socket type", skynet.self(), type)
			if type then
				MSG[type](...)
			end
		end
	}
end

return ProxySocket