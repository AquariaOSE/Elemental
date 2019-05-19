if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.needinit = false

function init(me)
    v.needinit = isFlag(MINEOCTOBOSS_DONE, 1)
end

function update(me, dt)
    if v.needinit then
        createEntity("purplespooter" .. math.random(2, 8), "", node_getPosition(me))
        v.needinit = false
    end
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end

function song(me, s)
end
