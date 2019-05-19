if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/inc_util.lua"))

v.n = 0
v.dest = false
v.t = 0

function v.commonInit(me, dest)
    v.n = getNaija()
    v.dest = dest or false
    spawnParticleEffect("bigsuck", node_getPosition(me))
end

local function checkAndWarp(e, me)  
    if node_isEntityIn(me, e) then
        if e == v.n then
            screenFadeCapture()
        end
        
        local x, y = node_getPosition(v.dest)
        
        entity_setPosition(e, x, y)
        
        if e == v.n then
            playSfx("spirit-return", nil, 1.66)
            spawnParticleEffect("spirit-big", x, y)
            screenFadeGo(0.5)
            cam_snap()
            if chance(40) then
                v.t = 1.3
            end
        elseif entity_isEntityInRange(e, v.n, 2000) then
            entity_playSfx(e, "spirit-return", nil, 0.7)
            spawnParticleEffect("spiritbeacon", x, y)
        end
    end
end

function update(me, dt)

    if v.dest then
        v.forAllEntities(checkAndWarp, me)
    end
    
    if v.t > 0 then
        v.t = v.t - dt
        if v.t <= 0 then
            emote(EMOTE_NAIJASADSIGH)
        end
    end
end



function song() end
function songNote() end
function songNoteDone() end

