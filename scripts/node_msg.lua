
if not v then v = {} end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/inc_util.lua"))

v.needinit = true
v.m = ""
v.x = 0

function init(me)

    local seting = node_getNearestNode(me, "seting")
    v.m = node_getContent(seting)
    v.x = node_getAmount(seting)
end

local function filterInside(e, me)
    return node_isEntityIn(me, e)
end

local function sendMsg(e)
    entity_msg(e, v.m, v.x)
end

function update(me, dt)
    if v.needinit then
        v.needinit = false
        v.forAllEntities(sendMsg, nil, filterInside, me)
    end
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
