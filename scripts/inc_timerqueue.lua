
-- FG:
-- ~Sept 2011 : initial version
-- 28. Mar 2012 : bugfix (watch() in timed function would cause re-entering the function)
-- 17. Mar 2013 : bugfix (error in compacting)

if not v then v = {} end


v._tq = 0 -- array of tables
v._tq_lock = 0

local function ensureTQ()
    if v._tq == 0 then
        v._tq = {}
    end
end

-- callback function, delay, additional param for callback function
-- order is arbitrary, as long as delay comes before param in case both are numbers
function v.pushTQ(p1, p2, p3)
    ensureTQ()
    
    local func, delay, param
    
    if type(p1) == "function" then
        func = p1
    elseif type(p1) == "number" then
        delay = p1
    else
        param = p1
    end
    
    if not func and type(p2) == "function" then
        func = p2
    elseif not delay and type(p2) == "number" then
        delay = p2
    elseif not param then
        param = p2
    end
    
    if not func and type(p3) == "function" then
        func = p3
    elseif not delay and type(p3) == "number" then
        delay = p3
    elseif not param then
        param = p3
    end
    
    --debugLog("pushTQ: func:" .. type(func) .. " delay:" .. delay .. " param:" .. type(param) .. " level:" .. v._tq_lock)
    
    local targ = v._tq[v._tq_lock]
    if not targ then
        --debugLog("TQ create level " .. v._tq_lock)
        targ = {}
        v._tq[v._tq_lock] = targ
    end
    table.insert(targ, {f = func, t = delay, param = param} )
end

-- compact v._tq[1...X] into v._tq[0]
local function compactIfPossible()
    if v._tq_lock == 0 then
        local alltq = v._tq
        if #alltq > 1 then
            local targ = v._tq[0] -- must exist
            for qi, tq in pairs(alltq) do
                if qi > 0 then -- skip v._tq[0]
                    for _,e in pairs(tq) do
                        table.insert(targ, e)
                    end
                    alltq[qi] = nil
                end
            end
            debugLog("TQ compact done")
        end
    end
end

-- re-entrant update function
-- that means calling wait()/watch() in a TQ callback is allowed,
-- and calling pushTQ() from a callback is no problem either.
-- (taking care of not adding entries to any table that is currently iterated over)
-- Lua docs say removing elems while iterating is okay.
function v.updateTQ(dt)
    if v._tq == 0 then return end
    
    v._tq_lock = v._tq_lock + 1
    --debugLog("TQ update push level " .. v._tq_lock)
    
    for qi,tq in pairs(v._tq) do
        if tq then
            --debugLog("TQ update level " .. qi .. ": " .. #tq .. " queued")
            for i,e in pairs(tq) do
                if e.t < dt then
                    --debugLog("running TQ callback in level " .. v._tq_lock)
                    tq[i] = nil
                    e.f(e.param)
                else
                    e.t = e.t - dt
                end
            end
        end
    end 
    v._tq_lock = v._tq_lock - 1
    
    compactIfPossible()
end

function v.isEmptyTQ()
    return v._tq == 0 or next(v._tq) == nil
end
