
-- activates node_warpspot.lua

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.n = 0
v.target = 0

function init(me)
    v.n = getNaija()
    
    
    local data = getNearestNodeByType(node_x(me), node_y(me), PATH_SETING)
    debugLog("warpon 1: " .. node_getName(data))
    local targetname = node_getContent(data)
    debugLog("warpon 2: " .. targetname)
    local target = node_getNearestNode(me, targetname)
    debugLog("warpon 3: " .. node_getName(target))
    v.target = node_getNearestNode(target, "warpspot")
    if v.target == 0 then
        centerText("Oops! node_warpon.lua - no target")
        return
    end
    debugLog("warpon 4: " .. node_getName(v.target))
end

function update(me, dt)
    if v.target ~= 0 and node_isEntityIn(me, v.n) then
        local t = v.target
        v.target = 0
        node_activate(t)
    end
    
end

function activate(me) end
function song() end
function songNote() end
function songNoteDone() end

