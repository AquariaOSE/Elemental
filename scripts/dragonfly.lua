
-- original script by Yogoda. (magic mod)
-- adapted for use in the Labyrinth mod

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end


local MAXSPEED = 800


v.n = 0
--v.lx, v.ly = 100, 100
--v.l = 0
v.horz = true
v.horzT = 0
v.dartT = 0
 
function init(me)
 
    setupEntity(me)

    -- set entity graphic
    --entity_setTexture(me,"missingImage")

    entity_initSkeletal(me, "dragonfly")
    entity_scale(me, 0.4, 0.4)

    entity_setEntityType(me, ET_NEUTRAL)
    entity_setHealth(me, 3)
    entity_setCollideRadius(me, 64)
    entity_setUpdateCull(me, 2000)
    entity_setDeathParticleEffect(me, "TinyBlueExplode")
    entity_setMaxSpeed(me, MAXSPEED)

    -- make the wings move
    --[[local wingfront1 = entity_getBoneByName(me, "wingfront1")
    local wingfront2 = entity_getBoneByName(me, "wingfront2")
    local wingback1 = entity_getBoneByName(me, "wingback1")
    local wingback2 = entity_getBoneByName(me, "wingback2")

    bone_alpha(wingfront1, 1)
    bone_alpha(wingfront1, 0, 0.05, -1, 1, 1)
    bone_alpha(wingfront2, 0)
    bone_alpha(wingfront2, 1, 0.05, -1, 1, 1)
    bone_alpha(wingback1, 1)
    bone_alpha(wingback1, 0, 0.05, -1, 1, 1)
    bone_alpha(wingback2, 0)
    bone_alpha(wingback2, 1, 0.05, -1, 1, 1)]]

    entity_setState(me, STATE_IDLE)
    entity_setCanLeaveWater(me, true)

    entity_setDeathScene(me, true)

    entity_setBounceType(me, BOUNCE_REAL)
    entity_setBounce(me, 1)
    
    v.horz = chance(50)

end
 
function postInit(me)
    v.n = getNaija()
    entity_setTarget(me, v.n)
end
 
function update(me, dt)

 
    local x, y = entity_getPosition(me)

    --[[v.l = (v.l + vector_getLength(v.lx - x, v.ly - y)) / 2.0

    if v.l < 0.01 then
        entity_clearVel(me)
        entity_addVel(me, 0, -200)
    end]]

    entity_handleShotCollisions(me)

    --entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 0)
    entity_doFriction(me, dt, 70)

    entity_doCollisionAvoidance(me, dt, 5, 1.0)
    entity_doEntityAvoidance(me, dt, 64, 1)

    entity_flipToVel(me)

    if v.horz then
        if v.dartT >= 0 then
            v.dartT = v.dartT - dt
            if v.dartT <= 0 then
                v.dartT = math.random(40, 170) / 100
                local vel = math.random(-600, 600)
                entity_addVel(me, vel, 0)
            end
        end
    else
        entity_moveTowardsTarget(me, dt, 400)
    end
    
    if v.horzT >= 0 then
        v.horzT = v.horzT - dt
        if v.horzT <= 0 then
            v.horzT = math.random(200, 1500) / 100
            v.horz = not v.horz
        end
    end

    --if entity_velx(me) < 10 then
        -- setControlHint('stuck', 0, 0, 0, 1)
    --end

    --v.lx = x
    --v.ly = y

    if y + 20 > getWaterLevel() then
        entity_addVel(me, 0, -500)
    end

    entity_updateMovement(me, dt)

end

function damage(me, attacker, bone, damageType, dmg)
    return true
end
 
function dieNormal(me)
end
 
function enterState(me)
    if entity_isState(me, STATE_IDLE) then
        entity_animate(me, "idle", -1)
    end
end
 
function exitState(me)

end
 
 
function hitSurface(me)
    entity_setMaxSpeedLerp(me, 2)
    entity_setMaxSpeedLerp(me, 1, 2)
    
    --entity_doCollisionAvoidance(me, 1, 5, 2) -- messes up for some reason
    
    -- alternative:
    local nx, ny = getWallNormal(entity_x(me), entity_y(me), 10)
    nx, ny = vector_setLength(nx, ny, 500)
    entity_addVel(me, nx, ny - 100)
end
 
function songNote(me, note)
end
 
function songNoteDone(me, note)
end
 
function song(me, song)
end
 
function activate(me)
end