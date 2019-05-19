
if not v then v = {} end


v.needinit = false
v.id = 0

function v.commonInit(me, id)
    v.id = id
    
    if isFlag(FLAG_FOUND_DRIFTPEARL0 + v.id, 1) then
        v.needinit = true
    end
end


function v.commonUpdate(me, dt)
    if v.needinit then
        v.needinit = false
        debugLog("driftpearl init " .. v.id)
        local e = createEntity("driftpearl")
        entity_setPosition(e, node_getPosition(me))
        entity_msg(e, "color", v.id)
    end
end

function song() end
function songNoteDone() end
function songNote() end
