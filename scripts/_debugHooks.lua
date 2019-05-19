
-- quick hack to debug Lua-related crashes
-- no longer used

local function forcestring(x)

    local t = type(x)

    -- try to convert to string (respects metatables)
    local ok, s = pcall(tostring, x)
    if ok then
        --return "[type: " .. t .. "]: " .. s
        return s
    end
    
    -- if that didn't work, check the type
    if t == "nil" then
        return "<Nil>"
    elseif t == "function" then
        return "(function)"
    elseif t == "userdata" then
        return "(userdata)"
    elseif t == "table" then
        return "(table)"
    elseif x == true then
        return "true"
    elseif x == false then
        return "false"
    elseif t == "thread" then
        return "(thread)"
    elseif t == "number" or t == "string" then
        return tostring(x)
    end
    return t
end

local depth = 0

local ignored = {
    debugLog = true,
    type = true,
    pairs = true,
    ipairs = true,
    pcall = true,
    xpcall = true,
    tostring = true,
    error = true,
    unpack = true,
    dofile = true,
    next = true,
    tonumber = true,
    rawget = true,
    rawset = true,
}

local function installDebugHooks(name)
    if AQUARIA_VERSION then
        return
    end
    
    local tins = table.insert
    
    for i, x in pairs(_G) do
        if type(x) == "function" and not ignored[i] then
            --debugLog("[" .. name .. "] --- hooking " .. i)
            local override = function(...)
                local str = { "[", depth, ":", name, "] - ", string.rep("  ", depth), i , " ( "}
                local first = true
                for _, p in pairs({...}) do
                    if first then
                        first = false
                    else
                        tins(str, ", ")
                    end
                    if type(p) == "string" then
                        tins(str, '"')
                        tins(str, p)
                        tins(str, '"')
                    else
                        tins(str, forcestring(p))
                    end
                end
                tins(str, " )")
                debugLog(table.concat(str))
                depth = depth + 1
                local result = {pcall(x, ...)}
                depth = depth - 1
                local good = table.remove(result, 1)
                if not good then
                    debugLog("ERROR in function: " .. i .. ": " .. result[1])
                    error(result[1])
                end
                if depth < 0 then
                    depth = 0
                end
                return unpack(result)
            end
            rawset(_G, i, override)
        end
    end

end

rawset(_G, "installDebugHooks", installDebugHooks)
