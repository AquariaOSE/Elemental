if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/inc_util.lua"))

v.t = 1

function init(me)
end

local function checkAndRemove(e, me)
    if entity_getName(e):startsWith("purplespooter") and node_isEntityIn(me, e) then
        entity_delete(e, 0.5)
    end
end

function update(me, dt)
    if v.t >= 0 then
        v.t = v.t - dt
        if v.t <= 0 then
            v.t = 1
            v.forAllEntities(checkAndRemove, me)
        end
    end
end

function song() end
function songNote() end
function songNoteDone() end
