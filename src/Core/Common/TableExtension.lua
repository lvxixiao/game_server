--- 将表dump成字符串(便于人类阅读的格式,支持环状引用)
--@param[type=table] t 表
--@return[type=string] dump成的字符串
function table.dump(t,iterDepth)
    if type(t) ~= "table" then
        return tostring(t)
    end
    local name = ""
    local cache = { [t] = "."}
    local function _dump(t,space,name, depth)
		if iterDepth and depth > iterDepth then
			return space .. tostring(t) .. "(max depth)."
		end

        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            if type(k) == "number" then
                key = "[".. k .."]"
            end
            if cache[v] then
                table.insert(temp, space .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
				if table.next(v) then
                	table.insert(temp, space .. key .. " = {\n" .. _dump(v,space ..  string.rep(" ", 4) ,new_key, depth + 1) .. "\n" .. space .. "},")
				else
					table.insert(temp, space .. key .. " = {},")
				end
            else
                if type(v) == "string" then
                    v = "\"" .. v .."\""
                end
                table.insert(temp, space .. key .. " = " .. tostring(v) ..",")
            end
        end
        return table.concat(temp,"\n")
    end
    return "{\n" .._dump(t,"  ",name, 1) .. "\n}"
end