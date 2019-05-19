
-- partly controlled by node_atethem.lua

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))

local STATE_CHASE = 1000
local STATE_WEIRD = 1001

v.rotvel = false
v.weirdT = 0
v.gaspT = 0
v.off = false
v.active = false
v.wakeupT = -1
v.collisionSegs = 40
v.q = 0
v.q2 = 0

function init(me)
    setupEntity(me, "kuirlinghost")
    entity_setCollideRadius(me, 80) -- seems ok
    local sc = math.random(80, 120) / 100
    entity_scale(me, sc, sc)
    entity_setAllDamageTargets(me, false)
    
    entity_setMaxSpeed(me, 450)
    entity_setState(me, STATE_IDLE)
    entity_setSegs(me, 2, 30, 0.5, 0.3, -0.018, 0.01, 3, 1)
    
    entity_alpha(me, 0)
    entity_setHealth(me, 3)
    entity_setDeathScene(me, true)

    v.q = createQuad("kuirlinghost", 13)
    sc = sc * 1.1
    quad_scale(v.q, sc, sc)
    quad_setBlendType(v.q, BLEND_ADD)
    quad_alpha(v.q, 0)

    v.q2 = createQuad("softglow-add", 13)
    quad_scale(v.q2, 2.5, 2.5)
    quad_setBlendType(v.q2, BLEND_ADD)
    quad_alpha(v.q2, 0)
    quad_color(v.q2, 0.5, 1, 0.5)
end

function postInit(me)
    v.n = getNaija()
    entity_setTarget(me, v.n)
    
    --entity_alpha(me, 0.4, 3, -1, 1)
end

function update(me, dt)
    
    if v.off then return end
    
    if v.wakeupT >= 0 then
        v.wakeupT = v.wakeupT - dt
        if v.wakeupT <= 0 then
            v.active = true
        end
    end
    
    if not v.active then return end
    
    
    local nx, ny = entity_getVectorToEntity(me, v.n)
    
    if entity_isState(me, STATE_IDLE) then
        if vector_getLength(nx, ny) < 650 then
            --entity_setState(me, STATE_CHASE)
            entity_setState(me, STATE_WEIRD)
        end
    else
        local m = dt * 3
        entity_addVel(me, nx * m, ny * m)
    end
    
    --[[if entity_isState(me, STATE_WEIRD) then
        if v.weirdT < dt then
            entity_setState(me, STATE_CHASE) -- FIXME: go idle at some point?
        else
            v.weirdT = v.weirdT - dt
        end
    end]]
    
    if v.gaspT > 0 then
        v.gaspT = v.gaspT - dt
    end
    
    if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1) then
        entity_setState(me, STATE_WEIRD)
        -- pale blue?
        entity_color(v.n, 0.3, 0.3, 1)
        entity_color(v.n, 1, 1, 1, 10)
        
        -- FIXME: this might still be gasp spam if too many of those are near
        if v.gaspT <= 0 then
            entity_playSfx(v.n, "naijagasp")
            v.gaspT = 5
        end
    end
    

    
    
    entity_updateMovement(me, dt)
    entity_doCollisionAvoidance(me, dt, 5, 1)
    --entity_handleShotCollisions(me) -- should shoot through ghost? probably.
    
    entity_doEntityAvoidance(me, dt * 2.5, 42, 1.5) -- prevent stacking
    
    
    
    if v.rotvel then
        entity_rotateToVel(me)
    end
    
    quad_rotate(v.q, entity_getRotation(me))
    local x, y = entity_getPosition(me)
    quad_setPosition(v.q, x, y)
    quad_setPosition(v.q2, x, y)
end

function enterState(me)
    if entity_isState(me, STATE_CHASE) then
        v.rotvel = true
        v.weirdT = 0
        --entity_enableMotionBlur(me)
    elseif entity_isState(me, STATE_WEIRD) then
        entity_rotate(me, 0, 2)
        v.weirdT = math.random(5, 15)
        v.rotvel = false
        entity_setMaxSpeedLerp(me, 3)
        entity_setMaxSpeedLerp(me, 1, v.weirdT)
    elseif entity_isState(me, STATE_IDLE) then
        --entity_disableMotionBlur(me)
    end
end

function msg(me, s, x)
    if s == "bg" then
        entity_switchLayer(me, -4)
        v.off = true
        local sx, sy = entity_getScale(me)
        entity_scale(me, sx * 0.5, sy * 0.5)
    elseif s == "wakeup" then
        v.wakeupT = 3
        entity_alpha(me, 0.4, 3)
        quad_alpha(v.q, 1, 2)
        quad_alpha(v.q2, 0.6, 3)
    end

end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
    return me == attacker
end

function hitSurface(me)
end

function lightFlare(me)
    if not v.off and entity_isEntityInRange(me, v.n, 800) then -- FIXME: finetune distance
        entity_damage(me, me, 1)
        local vx, vy = entity_getVectorToEntity(v.n, me)
        vx, vy = vector_normalize(vx, vy)
        
        entity_setMaxSpeedLerp(me, 3)
        entity_setMaxSpeedLerp(me, 1, 0.7)
        
        entity_addVel(me, vx * 2000, vy * 2000)
    end

end