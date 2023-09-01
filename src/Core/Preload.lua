require "Common.TableExtension"
local __declared = {}
local mt = getmetatable(_G)
local checkRewriteT = {}
if mt == nil then
	mt = {
		__newindex = function ( t,n,v )	
			if not __declared[n] then
				local w = debug.getinfo(2,"S").what
				error("attempt to write global undeclared variable "..n..","..w, 2)
				-- __declared[n] = true
			end
			rawset(t,n,v)
		end,
		__index = function ( _,n )
			if checkRewriteT[n] then
				return checkRewriteT[n]
			end
			if not __declared[n] then
				error("attempt to read global undeclared variable "..n)
			else
				return nil
			end
		end
	}
	setmetatable(_G,mt)
end