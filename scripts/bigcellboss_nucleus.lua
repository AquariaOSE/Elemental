
if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Elemental/scripts/inc_util.lua"))

v.parent = 0
v.n = 0
v.bounceT = 1
v.outside = false
v.damageT = 0

function init(me)
    setupEntity(me)
    entity_setEntityType(me, ET_NEUTRAL)

    entity_setTexture(me, "bigcellboss/nucleus")
    entity_scale(me, 0.25, 0.25)

    esetv(me, EV_LOOKAT, true)

    entity_setAllDamageTargets(me, false)
    entity_setUpdateCull(me, -1)

    entity_setCollideRadius(me, 0.0001)

    entity_setCanLeaveWater(me, false)
    
    entity_setMaxSpeed(me, 200)
    entity_setDeathScene(me, true)
    
    entity_setDeathParticleEffect(me, "mermanexplode")
    
    --entity_alpha(me, 0.4)
end


function postInit(me)
    v.n = getNaija()
    v.parent = entity_getNearestEntity(me, "bigcellboss")
    if v.parent == 0 then
        entity_delete(me)
        return
    end
end

function update(me, dt)
    
    if v.parent ~= 0 then

        if not v.outside then
            -- try to be near cell center
            local vx, vy = entity_getVectorToEntity(me, v.parent)
            local s = 200 * dt
            entity_addVel(me, vx * s, vy * s)
        end
        
        if v.outside and not entity_isEntityInRange(me, v.parent, 350) then
            if v.damageT >= 0 then
                v.damageT = v.damageT - dt
                if v.damageT <= 0 then
                    v.damageT = 1
                    entity_damage(v.parent, me, 1)
                    local perc = entity_getHealthPerc(v.parent)
                    local gb = 0.4 + (perc * 0.6)
                    entity_setColor(v.parent, 1, gb, gb)
                    entity_msg(v.parent, "flash")
                    debugLog(string.format("bigcell: %.2f perc HP left", perc))
                end
            end
        end
        
        if entity_isState(v.parent, STATE_DEATHSCENE) then
            v.parent = 0
            avatar_setPullTarget(0)
            entity_stopPull(me)
            --entity_setState(me, STATE_DEATHSCENE)
            entity_setHealth(me, -999)
            entity_delete(me, 2)
        end
    end
        
    
    if v.bounceT >= 0 then
        v.bounceT = v.bounceT - dt
        if v.bounceT <= 0 then
            local vx, vy = v.vector_fromDeg(math.random(36000) / 100, 32)
            entity_addVel(me, vx, vy)
            v.bounceT = 0.2
        end
    end
    
    
    entity_doFriction(me, dt, 80)
    entity_updateMovement(me, dt)
    entity_handleShotCollisions(me)
    
end

function enterState(me)
end

function exitState(me)
end

function msg(me, s, x)
    debugLog("nuc msg: " .. s)
    if s == "leftme" then -- naija broke out
        if entity_isBeingPulled(me) then
            v.outside = true
            v.damageT = 0
        else
            entity_setProperty(me, EP_MOVABLE, false)
        end
    elseif s == "enteredme" then -- sucked naija in, make draggable
        entity_setProperty(me, EP_MOVABLE, true)
    elseif s == "gotcha" then -- sucked nuc back in, stop damaging
        entity_setProperty(me, EP_MOVABLE, false)
        v.outside = false
    end
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


--[[
if isMapName("dbg") then
    dofile(appendUserDataPath("_mods/Labyrinth/scripts/_debugHooks.lua"))
    installDebugHooks("nuc")
end
]]
