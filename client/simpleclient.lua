local PATH,IP,PORT = ...

IP = IP or "127.0.0.1"
PORT = PORT or 5678

package.path = string.format("%s/client/?.lua;%s/lib/skynet/lualib/?.lua;", PATH, PATH) .. package.path 
package.cpath = string.format("%s/lib/skynet/luaclib/?.so;%s/lib/lsocket/?.so;", PATH, PATH) .. package.cpath

local socket = require "simplesocket"
local message = require "simplemessage"

message.register(string.format("%s/Sproto/", PATH))

message.peer(IP, PORT)
message.connect()

local event = {}

message.bind({}, event)

function event:__error(what, err, req, session)
	print("error", what, err)
end

function event:ping()
	print("ping")
end

function event:signin(req, resp)
	print("signin", req.userid, resp.ok)
	if resp.ok then
		message.request "ping"	-- should error before login
		message.request "login"
	else
		-- signin failed, signup
		message.request("signup", { userid = "alice" })
	end
end

function event:signup(req, resp)
	print("signup", resp.ok)
	if resp.ok then
		message.request("signin", { userid = req.userid })
	else
		error "Can't signup"
	end
end

function event:login(_, resp)
	print("login", resp.ok)
	if resp.ok then
		message.request "ping"
	else
		error "Can't login"
	end
end

function event:push(args)
	print("server push", args.text)
end

-- message.request("signin", { userid = "alice" })

message.close()
print("关闭连接")