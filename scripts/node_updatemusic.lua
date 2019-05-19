if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.n = 0
v.t = 0

function init(me)
    v.n = getNaija()
end

function update(me, dt)
    if v.t > 0 then
        v.t = v.t - dt
    end
    if v.t <= 0 and node_isEntityIn(me, v.n) then
        updateMusic()
        v.t = 1
    end
end
