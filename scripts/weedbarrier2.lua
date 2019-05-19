if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end



function init(me)
    setupEntity(me, "barrier", 1)
    entity_setHealth(me, 2)
    entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
    entity_setCollideRadius(me, 150)
end

function postInit(me)   
    n = getNaija()
    if entity_isFlag(me, 1) then
        entity_delete(me)
    end
end

function update(me, dt)
    entity_handleShotCollisions(me)

end

function enterState(me)
    if entity_isState(me, STATE_DEAD) then
        entity_setFlag(me, 1)
    end
end

function damage(me, attacker, bone, damageType, dmg)
    return true
end


