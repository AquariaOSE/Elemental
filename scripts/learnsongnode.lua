if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.song = false
v.needinit = true

function v.commonInit(me, song)
    v.song = song or false
end

function update(me, dt)
    if v.needinit then
        v.needinit = false
        if not v.song then
            centerText("Oops! learnsongnode.lua - no song!")
            return
        end
        if not hasSong(v.song) then
            local e = createEntity("learnsong", "", node_getPosition(me))
            entity_msg(e, "setsong", v.song)
        end
    end
end

function song() end
function songNoteDone() end
function songNote() end
