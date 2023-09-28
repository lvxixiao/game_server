local skynet = require "skynet"
local crypt = require "compat10.crypt"

local function cryptDemo()
    -- 1. Server->Client : base64(8bytes random challenge)
	-- 2. Client->Server : base64(8bytes handshake client key)
	-- 3. Server: Gen a 8bytes handshake server key
	-- 4. Server->Client : base64(DH-Exchange(server key))
	-- 5. Server/Client secret := DH-Secret(client key/server key)
	-- 6. Client->Server : base64(HMAC(challenge, secret))
	-- 7. Client->Server : DES(secret, base64(token))
	-- 8. Server : call auth_handler(token) -> server, uid (A user defined method)
	-- 9. Server : call login_handler(server, uid, secret) ->subid (A user defined method)
	-- 10. Server->Client : 200 base64(subid)

    local challenge = crypt.randomkey()
    -- challenge 给客户端

    local clientkey = crypt.randomkey()
    print("clientkey",clientkey)
    local eckey = crypt.base64encode(crypt.dhexchange(clientkey))
    print("cckey", eckey)

    -- eckey 给服务端
    local ckey = crypt.base64decode(eckey)
    local serverkey = crypt.randomkey()
    local eskey = crypt.base64encode(crypt.dhexchange(serverkey))

    -- eskey 给客户端
    local skey = crypt.base64decode(eskey)
    local secret2 = crypt.dhsecret(skey, clientkey)
    local hmac2 = crypt.hmac64(challenge, secret2)

    -- 服务端
    local secret = crypt.dhsecret(ckey, serverkey)
    local hmac = crypt.hmac64(challenge, secret2)

    print("密钥交换成功", hmac == hmac2)
end

skynet.start(function()
    skynet.newservice("debug_console",8000)

    local hub = skynet.uniqueservice "HubSrv"
	skynet.call(hub, "lua", "open", "0.0.0.0", 5678)

    cryptDemo()

	skynet.exit()
end)