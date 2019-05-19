
if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Elemental/scripts/inc_util.lua"))

local STATE_N_TRAPPED = 800

v.parent = 0
v.n = 0
v.bounceT = 1
v.lock = 0 -- locked entity
v.poisonT = 0
v.animT = 0
v.lastrot = 0

v.vacpoint = 0

function init(me)
    setupEntity(me)
    entity_setEntityType(me, ET_NEUTRAL)

    entity_setTexture(me, "bigcellboss/vacuole")
    entity_scale(me, 0.35, 0.35)
    entity_setDeathParticleEffect(me, "tinyredexplode")

    esetv(me, EV_LOOKAT, 1)
    
    entity_setHealth(me, 4)

    entity_setUpdateCull(me, -1)

    entity_setCollideRadius(me, 90)

    entity_setCanLeaveWater(me, false)
    
    entity_setMaxSpeed(me, 100)
    
    entity_alpha(me, 0.42)
    
    --entity_setAllDamageTargets(me, false)
    entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
    
    entity_setDeathScene(me, true)
    
    entity_setEntityLayer(me, 1)
    
    entity_initEmitter(me, 0, "vacpoison")
    
end

function postInit(me)
    v.n = getNaija()
    v.parent = entity_getNearestEntity(me, "bigcellboss")
    if v.parent == 0 then
        entity_delete(me)
        return
    end
    
    v.vacpoint = entity_getBoneByIdx(v.parent, 4)
    
    entity_startEmitter(me, 0)
    
    v.lock = 0
end

function update(me, dt)

    if v.lock == v.n then
        if v.animT >= 0 then
            v.animT = v.animT - dt
            if v.animT <= 0 then
                v.animT = 2
                local an = entity_getAnimationName(v.n)
                if an ~= "swim" and an ~= "trapped" then
                    entity_setState(v.n, STATE_N_TRAPPED) -- have to set non-idle state, otherwise the game will reset the animation to "idle" in every tick
                    entity_animate(v.n, "trapped", -1)
                end
            end
        end
    end

    -- try to be near cell center
    if v.parent ~= 0 then
        --local vx, vy = entity_getVectorToEntity(me, v.parent)
        local vx, vy = v.makeVector(entity_x(me), entity_y(me), bone_getWorldPosition(v.vacpoint))
        entity_addVel(me, vx * 0.6, vy * 0.6)
    
        if entity_isState(v.parent, STATE_DEATHSCENE) then
            v.parent = 0
        end
    end
    
    -- apply random force
    --[[if v.bounceT >= 0 then
        v.bounceT = v.bounceT - dt
        if v.bounceT <= 0 then
            vx, vy = v.vector_fromDeg(math.random(36000) / 100, 20)
            entity_addVel(me, vx, vy)
            v.bounceT = 0.2
        end
    end]]
    
    entity_doEntityAvoidance(me, dt, 380, 1.7)
    entity_doFriction(me, dt, 80)
    entity_updateMovement(me, dt)
    entity_handleShotCollisions(me)
    
    if v.poisonT >= 0 then
        v.poisonT = v.poisonT - dt
    end
    
    if v.lock ~= 0 then
    
        local x, y = entity_getPosition(me)
        entity_setPosition(v.lock, x, y)
        
        if not entity_isRotating(v.lock) then
            local rd = entity_getRotation(me) - v.lastrot
            entity_rotate(v.lock, (entity_getRotation(v.lock) + rd) % 360)
        end
        
        --debugLog("vac lock anim: " .. entity_getAnimationName(v.lock))
        
        -- apply poison
        if v.lock == v.n then
            if v.poisonT <= 0 then
                setPoison(2, 4)
                v.poisonT = 4.1
                --debugLog("vac poison v.n")
            end
        else
            if v.poisonT <= 0 then
                entity_damage(v.lock, me, 0.4)
                v.poisonT = 0.5
                --debugLog("vac poison " .. entity_getName(v.lock))
            end
        end
        
        if v.lock ~= v.n and (entity_isState(v.lock, STATE_DEATHSCENE) or entity_isState(v.lock, STATE_DEAD)) then
            --debugLog(string.format("vac lock dead: %s", entity_getName(v.lock)))
            entity_setState(me, STATE_DEATHSCENE, 1.3)
            entity_alpha(me, 0, 1.3)
            entity_setHealth(v.lock, -999)
            v.lock = 0
        end
    end

    v.lastrot = entity_getRotation(me)
end

function enterState(me)
    if entity_isState(me, STATE_DEATHSCENE) then
        entity_setStateTime(me, 0.5)
        entity_setState(v.n, STATE_IDLE)
    end
end

function exitState(me)
end

function msg(me, s, x)
    if s == "lock" then
        entity_setDeathScene(x, true)
        v.lock = x
    end
end

function damage(me, attacker, bone, damageType, dmg)
    --debugLog(string.format("vac dmg: %s %d %f", entity_getName(attacker), damageType, dmg))
    if attacker == v.n and damageType == DT_AVATAR_ENERGYBLAST and dmg < 0.5 and avatar_isBursting() then -- urchin only
        return true
    end
    return false
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


--[[
if isMapName("dbg") then
    dofile(appendUserDataPath("_mods/Labyrinth/scripts/_debugHooks.lua"))
    installDebugHooks("vac")
end
]]
