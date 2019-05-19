
if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Elemental/scripts/inc_util.lua"))

v.parent = 0
v.n = 0
v.damageT = 0
v.bounceT = 0

function init(me)
    setupEntity(me)
    entity_setEntityType(me, ET_NEUTRAL)

    entity_setTexture(me, "bigcellboss/mito")
    entity_scale(me, 0.25, 0.25)
    entity_setHealth(me, math.random(3,5))

    esetv(me, EV_LOOKAT, false)

    entity_setAllDamageTargets(me, false)
    entity_setUpdateCull(me, -1)

    entity_setCollideRadius(me, 50)

    entity_setCanLeaveWater(me, false)
    
    entity_setMaxSpeed(me, 200)
    --entity_setDeathScene(me, false)
    
    entity_setDeathParticleEffect(me, "tinyredexplode")
    
    entity_alpha(me, 0.4)
end


function postInit(me)
    v.n = getNaija()
    v.parent = entity_getNearestEntity(me, "bigcellboss")
    if v.parent == 0 then
        entity_delete(me)
        return
    end
    if chance(50) then
        entity_rotateOffset(me, 360, math.random(25,40), -1)
    else
        entity_rotateOffset(me, 360)
        entity_rotateOffset(me, 0, math.random(25,40), -1)
    end
    entity_addVel(me, math.random(-100, 100), math.random(-100, 100))
end

function update(me, dt)
    
    if v.parent == 0 then
        --[[if v.damageT >= 0 then
            v.damageT = v.damageT - dt
            if v.damageT <= 0 then
                v.damageT = 1
                entity_damage(me, me, 1)
            end
        end]]
    else

        -- try to be near cell center
        --[[local vx, vy = entity_getVectorToEntity(me, v.parent)
        local s = 20 * dt
        entity_addVel(me, vx * s, vy * s)]]
        
        if not entity_isEntityInRange(me, v.parent, 270) then -- HACK: hardcoding sucks! (but necessary here because boss has no collide radius externally)
            local vx, vy = entity_getVectorToEntity(me, v.parent)
            vx, vy = v.vector_rotateDeg(vx, vy, math.random(-100, 100))
            local s = 20 * dt
            entity_addVel(me, vx * s, vy * s)
        end
        
        if entity_isState(v.parent, STATE_DEATHSCENE) then
            v.parent = 0
        end
            
    end
        
    
    if v.bounceT >= 0 then
        v.bounceT = v.bounceT - dt
        if v.bounceT <= 0 then
            local vx, vy = v.vector_fromDeg(math.random(7000) / 100, 32)
            entity_addVel(me, vx * 0.5, vy * 0.5)
            v.bounceT = math.random(1500, 5000) / 10000
        end
    end
    
    entity_doEntityAvoidance(me, dt, 65, 1)
    entity_doFriction(me, dt, 80)
    entity_updateMovement(me, dt)
    entity_handleShotCollisions(me)
    
end

function enterState(me)
end

function exitState(me)
end

function msg(me, s, x)
end

function damage(me, attacker, bone, damageType, dmg)
	return attacker == me
end

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

