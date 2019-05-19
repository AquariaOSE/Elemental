-- ================================================================================================
-- P U R P L E S P O O T E R
-- ================================================================================================

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/inc_timerqueue.lua"))


local STATE_JUMP				= 1000
local STATE_TRANSITION		= 1001

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.jumpDelay = 0
v.moveTimer = 0
v.rotateOffset = 0
v.updateMulti = 1
v.myWeight = 300

v.happytex = ""
v.happy = false
v.onwall = false
v.keepdir = false
v.stop = false
v.checkJumpT = 0
v.autojump = true
v.warp = 0
v.oldx = 0
v.oldy = 0
v.stillT = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function v.makeHappy(me)
    v.happy = true
    entity_setTexture(me, v.happytex)
    entity_setNaijaReaction(me, "smile")
end

function v.commonInit(me, texId, noclamp)
    local tex = "purplespooter" .. texId
    setupBasicEntity(
    me,
    tex,						-- texture
    9,							-- health
    2,							-- manaballamount
    2,							-- exp
    10,							-- money
    40,							-- collideRadius (for hitting entities + spells)
    STATE_IDLE,						-- initState
    128,							-- sprite width
    128,							-- sprite height
    1,							-- particle "explosion" type, 0 = none
    0,							-- 0/1 hit other entities off/on (uses collideRadius)
    4000							-- updateCull -1: disabled, default: 4000
    )

    v.happytex = tex .. "happy"
    
    if isFlag(MINEOCTOBOSS_DONE, 1) then
        v.makeHappy(me)
    end

    if not noclamp then
        entity_clampToSurface(me)
        v.onwall = true
    end
    
    entity_setWeight(me, v.myWeight)

    --entity_setDeathParticleEffect(me, "PurpleExplode")
    entity_setDeathSound(me, "") -- not killable anyway

    entity_setSegs(me, 2, 16, 0.4, 0.4, -0.05, 0, 6, 1)

    esetv(me, EV_WALLOUT, 24)
end

function postInit(me)
    v.oldx, v.oldy = entity_getPosition(me)
end

function v.commonUpdate(me, dt)

    v.updateTQ(dt)

    local xdt = dt * v.updateMulti
    
    if v.warp ~= 0 and node_isEntityIn(v.warp, me) and isMapName("labyrinth_pearlmine") then
        entity_clearVel(me)
        v.stop = true
        v.warp = 0
        entity_setState(me, STATE_DEAD)
        
        --[[
        entity_alpha(me, 0, 0.5)
        v.pushTQ(0.5, function()
            entity_setHairHeadPosition(me, 0, 0)
            entity_updateHair(me, 1)
            entity_delete(me)
            entity_setState(me, STATE_DEAD)
        end)
        ]]
    end
    
    -- HACK: grrr no idea why they get stuck on rocks sometimes
   
    local x, y = entity_getPosition(me)
    if not v.stop then
        if x == v.oldx and y == v.oldy then
            v.stillT = v.stillT + dt
            if v.stillT >= 0.5 then
                v.stillT = 0
                debugLog("purplespooter unstuck")
                entity_setState(me, STATE_JUMP)
            end
        else
            v.stillT = 0
        end
    end
    v.oldx = x
    v.oldy = y

    if entity_getState(me)==STATE_IDLE then
    
        if v.stop then
            entity_updateMovement(me, dt) -- just gravity
        else
            if v.checkJumpT >= 0 then
                v.checkJumpT = v.checkJumpT - dt
                if v.checkJumpT <= 0 then
                    v.checkJumpT = 0.2
                    local j = entity_getNearestNode(me, "kuirlinjump")
                    if j ~= 0 and node_isEntityIn(j, me) then
                        debugLog("purplespooter in jump node")
                        entity_setState(me, STATE_JUMP)
                    end
                    v.warp = getNearestNodeByType(entity_x(me), entity_y(me), PATH_WARP)
                end
            end

            if v.onwall then
                entity_rotateToSurfaceNormal(me, 0.1)
                entity_moveAlongSurface(me, xdt, 100, 6)
                
                if not v.keepdir then
                    v.moveTimer = v.moveTimer + dt
                    if v.moveTimer > 30 then
                        entity_switchSurfaceDirection(me)
                        v.moveTimer = 0
                    end
                end
            end

            if not v.happy then
                if not(entity_hasTarget(me)) then
                    entity_findTarget(me, 1200)
                else
                    if entity_isTargetInRange(me, 600) and v.autojump then
                        v.jumpDelay = v.jumpDelay - dt
                        if v.jumpDelay < 0 then
                            v.jumpDelay = 3
                            debugLog("purplespooter jump timer expired")
                            entity_setState(me, STATE_JUMP)
                        end
                    end
                end
            end
        end
        
    elseif entity_getState(me)==STATE_JUMP then
        v.rotateOffset = v.rotateOffset + dt * 400
        if v.rotateOffset > 180 then
            v.rotateOffset = 180
        end
        entity_rotateToVel(me, 0.1, v.rotateOffset)
        entity_updateMovement(me, dt)
        
    elseif not(entity_isState(me, STATE_TRANSITION)) then
        entity_updateMovement(me, dt)
    end

    if not v.happy then
        entity_touchAvatarDamage(me, 64, 1, 400)
    end
    
    entity_handleShotCollisions(me)
end

-- to be overridden if necessary
function update(me, dt)
    return v.commonUpdate(me, dt)
end

function hitSurface(me)
    v.onwall = true
    entity_setWeight(me, 0)
    entity_clearVel(me)
    if entity_getState(me)==STATE_JUMP then
        local t = egetvf(me, EV_CLAMPTRANSF)
        if entity_checkSurface(me, 6, STATE_TRANSITION, t) then
            entity_rotateToSurfaceNormal(me, 0)
            entity_scale(me, 1, 0.5)
            entity_scale(me, 1, 1, t)
            entity_setInternalOffset(me, 0, 64)
            entity_setInternalOffset(me, 0, 0, t)
        else
            --local nx,ny = getWallNormal(entity_getPosition(me))
            --nx,ny = vector_setLength(nx, ny, 40)
            --entity_addVel(me, nx, ny)
        end
    elseif entity_isState(me, STATE_IDLE) then
        -- prevents the one dropping in the pearlmine from falling through the walls sometimes for unknown reason
        debugLog("purplespooter backup bounce")
        local nx,ny = getWallNormal(entity_getPosition(me))
        nx,ny = vector_setLength(nx, ny, 25)
        entity_addVel(me, nx, ny)
    end
end

function v.commonEnterState(me)
    if entity_getState(me)==STATE_IDLE then
        entity_setMaxSpeed(me, 800)
        --entity_setWeight(me, v.myWeight)
    elseif entity_getState(me)==STATE_JUMP then
        debugLog("purplespooter jump")
        v.rotateOffset = 0
        v.onwall = false
        entity_clearVel(me) -- HACK: this hopefully prevents them from going through walls when jumping when inside a nature form vine
        entity_applySurfaceNormalForce(me, 800)
        entity_adjustPositionBySurfaceNormal(me, 10)
        entity_setWeight(me, v.myWeight)
    end
end

-- to be overridden if necessary
function enterState(me)
    return v.commonEnterState(me)
end

function exitState(me)
    if entity_getState(me)==STATE_TRANSITION then
        entity_setState(me, STATE_IDLE)
    end
end

function damage(me, attacker, bone, damageType, dmg)
    if damageType ~= DT_AVATAR_BITE and damageType ~= DT_AVATAR_VINE then
        if entity_isState(me, STATE_IDLE) then
            debugLog("purplespooter damage")
            entity_setState(me, STATE_JUMP)
        end
    end
    return false
end

function msg(me, s, x)
    debugLog("purplespooter msg: " .. s)
    if s == "happy" then
        v.makeHappy(me)
    elseif s == "jump" then
        entity_setState(me, STATE_JUMP)
    elseif s == "keepdir" then
        v.keepdir = true
    elseif s == "go" then
        v.stop = false
        v.stillT = 0
    elseif s == "speed" then
        v.updateMulti = x / 1000
    elseif s == "switchdir" then
        entity_switchSurfaceDirection(me)
    elseif s == "minetimer" then -- HACK
        v.pushTQ(70, function()
            entity_alpha(me, 0, 5)
            v.pushTQ(5, function()
                entity_delete(me, 0.1)
            end)
        end)
    end
end
