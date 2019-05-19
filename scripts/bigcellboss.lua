-- ================================================================================================
-- B I G C E L L B O S S (based on euglena, with parts of darkjelly)
-- ================================================================================================

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Elemental/scripts/flags.lua"))
dofile(appendUserDataPath("_mods/Elemental/scripts/inc_util.lua"))
dofile(appendUserDataPath("_mods/Elemental/scripts/inc_timerqueue.lua"))

-- ================================================================================================
-- L O C A L   V A R I A B L E S
-- ================================================================================================

local MITO_COUNT = 12

local STATE_SUCK = 1001

local COLLIDE_RADIUS = 340

v.needinit = true
v.me = 0
v.n = 0
v.nuc = 0 -- nucleus
v.deps = 0 -- all internal entities (also nucleus)
v.stitches = 0 -- all stitch bones
v.eugl = 0 -- initial euglena

v.sz = 1.0

v.lastx = 0
v.lasty = 0
v.lastrot = 0

v.suckbone = 0
v.body = 0

v.sucktimer = 0 -- when 0, changes state
v.sucksfx = 0

v.camDone = false

v.nvac = 0 -- vacuole holding naija, if any
v.inside = false
v.clingT = 0 -- when > 0, can't cling to outer hull. set when breaking out to prevent instant clinging.

v.ndied = false -- true when pwn3d
v.seen = false

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

local function doIdleScale(me)
    entity_scale(me, 1*v.sz, 1.05*v.sz)
    entity_scale(me, 1.01*v.sz, 0.95*v.sz, 2, -1, 1, 1)
end

function init(me)
    setupBasicEntity(
    me,
    "",						-- texture
    12,								-- health
    1,								-- manaballamount
    1,								-- exp
    1,								-- money
    COLLIDE_RADIUS,					-- collideRadius (only used if hit entities is on)
    STATE_IDLE,						-- initState
    800,								-- sprite width
    800,								-- sprite height
    1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
    0,								-- 0/1 hit other entities off/on (uses collideRadius)
    -1							-- updateCull -1: disabled, default: 4000
    )

    entity_initSkeletal(me, "bigcellboss")

    entity_setDropChance(me, 100)

    --entity_addVel(me, math.random(1000)-500, math.random(1000)-500)
    --entity_setDeathParticleEffect(me, "cellexplode")


    entity_setMaxSpeed(me, 500)

    entity_setCanLeaveWater(me, false)
    entity_setDeathScene(me, true)

    doIdleScale(me)
    
    entity_setCull(me, false)
    
     
    --entity_alpha(me, 1)
    entity_setEntityLayer(me, 1)
    
    entity_setAllDamageTargets(me, false)
    entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
    
    v.suckbone = entity_getBoneByName(me, "suckpoint")
    v.body = entity_getBoneByIdx(me, 0)
    
    loadSound("suckloop")
    loadSound("bossdiebig")
    loadSound("rotcore-die")
    loadSound("grouper-die")
    
    v.stitches = {}
    for i = 10,16 do
        local b = entity_getBoneByIdx(me, i)
        bone_alpha(b, 0)
        table.insert(v.stitches, b)
    end
end

local function doDeathStuff(me)

    setFlag(BIGCELLBOSS_DONE, 1)
    
    -- get the reward nodes from the top left
    --[[local nf = getNode("learnnatureformsong")
    local pe = node_getNearestNode(nf, "pe") -- must be "pe ..." now
    if pe == 0 then
        -- for < 1.1.3+
        pe = node_getNearestNode(nf, "pe glowlearnsong")
    end
    
    local x, y = entity_getPosition(me)
    node_setPosition(nf, x, y)
    node_setPosition(pe, x, y)]]
    

end

function postInit(me)
    if getFlag(BIGCELLBOSS_DONE) ~= 0 then
        doDeathStuff(me)
        entity_delete(me)
        return
    end

    v.n = getNaija()
    entity_setTarget(me, v.n)
    v.deps = {}
end

local function updateInternalEntities(me)
    local px, py = entity_getPosition(me)
    local rot = entity_getRotation(me)
    local rdiff = v.lastrot - rot
    local dx, dy = v.makeVector(v.lastx, v.lasty, px, py)
    local x, y, rx, ry, newx, newy
    
    for e, _ in pairs(v.deps) do
        if entity_isState(e, STATE_DEATHSCENE) then
            v.deps[e] = nil
        else
            -- relative position & rotation correction
            x, y = entity_getPosition(e)
            rx, ry = entity_getVectorToEntity(e, me)
            newx = x + dx - rx
            newy = y + dy - ry
            rx, ry = v.vector_rotateDeg(rx, ry, rdiff)
            entity_setPosition(e, newx + rx, newy + ry)
            entity_rotate(e, rot)
        end
    end
    
    v.lastx = px
    v.lasty = py
    v.lastrot = rot
end

local function doCameraIntro(me)
    if v.camDone then
        return
    end
    v.camDone = true
    
    setOverrideMusic("miniboss")
    updateMusic()
    
    setCameraLerpDelay(0.4)
    cam_toEntity(me)
    wait(1)
    emote(EMOTE_NAIJAUGH)
    wait(0.5)
    cam_toEntity(v.n)
    wait(1)
    setCameraLerpDelay(0)
end

local function hasInVac(ent)
    for vac, e in pairs(v.deps) do
        if entity_isName(vac, "bigcellboss_vacuole") and (type(e) == "userdata" or type(e) == "number") then -- userdata for 1.1.3+, number for < 1.1.3
            if e == ent then
                return vac
            end
        end
    end
    return nil
end

local function doSwallow(me, e)
    entity_playSfx(me, "gulp")
    local ex, ey = entity_getPosition(e)
    local x, y = entity_getPosition(me)
    local vac = createEntity("bigcellboss_vacuole", "", ex, ey)
    v.deps[vac] = e
    entity_alpha(vac, 0)
    entity_alpha(vac, 0.6, 1.7)
    entity_setMaxSpeedLerp(vac, 5)
    entity_setMaxSpeedLerp(vac, 1, 3)
    entity_msg(vac, "lock", e)
    
    -- make sure naija is always on top and not buried by others
    if v.nvac ~= 0 then
        entity_moveToFront(v.nvac)
    end
    
    entity_moveToFront(me) -- boss should still be on top of all
    
    return vac
end

local function suckFilter(e)
    return not v.deps[e] and entity_getCollideRadius(e) <= 80 and not hasInVac(e)
end

-- called when sucked in / entered
local function handleNaijaIn(me)
    v.pushTQ(2.2, function() entity_setState(me, STATE_IDLE) end)
    v.inside = true
    entity_msg(v.nuc, "enteredme")
    --entity_alpha(me, 0.5, 1)
    bone_alpha(v.body, 0.5, 1)
    avatar_setPullTarget(0)
    --entity_stopPull(v.nuc)
    v.pushTQ(1, function() v.deps[v.nuc] = true end)
    
    -- HACK: initial euglena
    if v.eugl ~= 0 then
        entity_setHealth(v.eugl, 3)
        v.eugl = 0
    end
end

-- called after bursting out / left
local function handleNaijaOut(me)
    v.clingT = 0.2
    entity_setState(me, STATE_IDLE) -- TODO: what about STATE_PISSED or something?
    entity_msg(v.nuc, "leftme")
    --entity_alpha(me, 1, 2)
    bone_alpha(v.body, 1, 2)
    if entity_isBeingPulled(v.nuc) then
        v.deps[v.nuc] = nil
    end
    
    -- make stitch appear
    if #v.stitches > 0 then
        local b = table.remove(v.stitches, 1)
        bone_alpha(b, 1, 1.5)
    end
end

local function doSuckIn(e, params)
    local me = params.me
    local x = params.x
    local y = params.y
    local dt = params.dt
    
    local d = entity_getDistanceToEntity(me, e)
    if d == 0 then
        return
    end
    
    local factor = (1050 / d)
    factor = factor ^ 0.7
    factor = factor * dt * 4100

    local vx, vy = vector_normalize(v.makeVector(entity_x(e), entity_y(e), x, y))
    vx = vx * factor
    vy = vy * factor
    entity_addVel(e, vx, vy)
    
    
    local nx, ny = entity_getPosition(e)
    local dx, dy = v.makeVector(x, y, nx, ny)
    local d = vector_getLength(dx, dy)
    if d < 50 then
        local vac = doSwallow(me, e)
        
        if e == v.n then
            v.nvac = vac
            handleNaijaIn(me)
        elseif e == v.nuc then
            v.pushTQ(1, function()
                v.deps[v.nuc] = true
                --entity_stopPull(me, v.nuc)
                avatar_setPullTarget(0)
                entity_setState(vac, STATE_DEATHSCENE)
            end)
            entity_msg(v.nuc, "gotcha")
        end
    end
end

local function handleSucking(me, dt)
    local x, y = bone_getWorldPosition(v.suckbone)
    local params = { x = x, y = y, me = me, dt = dt }
    v.forAllEntities(doSuckIn, params, suckFilter)
end

local function doInitialEuglena(me)
    local e = entity_getNearestEntity(me, "euglena")
    if e == 0 then
        debugLog("No euglena!")
        return
    end
    
    entity_setPosition(e, entity_getPosition(me))
    doSwallow(me, e)
    entity_setHealth(e, 99999)
    v.eugl = e
end

local function delayInit(me)
    for i = 1, MITO_COUNT do
        local e = createEntity("bigcellboss_mito", "", entity_getPosition(me))
        v.deps[e] = true
    end
    v.deps[v.nuc] = true 
    doInitialEuglena(me)
end

-- the entity's main update function
function update(me, dt)

    entity_setCollideRadius(me, COLLIDE_RADIUS) -- for the HACK at end of update()
    
    if v.needinit then
        v.needinit = false
        local x, y = entity_getPosition(me)
        v.nuc = createEntity("bigcellboss_nucleus", "", x, y)
        v.pushTQ(1, delayInit, me) -- HACK: delaying this solves problems with the nuc beeing far away off the map. No idea at all.
    end

    v.updateTQ(dt)
    
    if not v.seen and entity_isEntityInRange(me, v.n, 800) then
        playSfx("naijagasp")
        v.seen = true
    end
        
    entity_doFriction(me, dt, 100)
    
    if not v.ndied and entity_getHealth(v.n) <= 0 then
        setOverrideMusic("")
        updateMusic()
        v.ndied = true
    end
    
    --entity_doCollisionAvoidance(me, dt, 10, 0.1)
    --entity_doCollisionAvoidance(me, dt, 4, 0.5)
    
    if not v.inside and #v.deps < 7 and v.sucktimer > 0 then
        v.sucktimer = v.sucktimer - dt
        if v.sucktimer <= 0 then
            v.sucktimer = 0
            avatar_fallOffWall()
            entity_setState(me, STATE_SUCK)
        end
    end

    if entity_getVelLen(me) > 10 then
        entity_rotateToVel(me, 1.2)
    end
    
    entity_updateMovement(me, dt)
    
    local scx, scy = entity_getScale(me)
    
    updateInternalEntities(me)
    
    if entity_isState(me, STATE_SUCK) then
        handleSucking(me, dt)
        entity_rotateToEntity(me, v.n, 2)
    end
    
    -- not trapped but still inside of body?
    if v.inside and v.nvac == 0 then
        
        local canBreakOut = avatar_isBursting() and isForm(FORM_NORMAL) and getCostume():lower() == "urchin" -- wtf?
        if canBreakOut then
            v.inside = entity_isEntityInRange(me, v.n, entity_getCollideRadius(me)) -- outer rim
        end
        local nx, ny = entity_getPosition(v.n)
        if not v.inside then
            debugLog("no longer inside")
            spawnParticleEffect("cellsplash", nx, ny)
            playSfx("squishy-die")
            bone_damageFlash(v.body, 1) -- yellow
            v.sucktimer = 1
            handleNaijaOut(me)
        elseif not canBreakOut and not entity_isEntityInRange(me, v.n, entity_getCollideRadius(me) * 0.77) then -- need to be completely inside, but isn't -> pull back!
            local x, y = entity_getVectorToEntity(v.n, me, 1000)
            entity_addVel(v.n, x, y)
        end
            
    end
    
    if v.clingT >= 0 then
        v.clingT = v.clingT - dt
    end
    
    if v.nvac ~= 0 then
        if entity_isState(v.nvac, STATE_DEATHSCENE) then
            v.nvac = 0
            debugLog("v.nvac died")
        end
    elseif not v.inside and v.clingT <= 0 then
            
        -- not sucked in .. should be able to still swim around in cell body
        if entity_getState(me)==STATE_IDLE then
            if entity_isEntityInRange(me, v.n, 900) and v.sucktimer == 0 then
                v.sucktimer = 2.5
            end
        end
        
        -- handle clinging onto it + push away if too near
        if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0) then
            if avatar_isBursting() and entity_setBoneLock(v.n, me) then
                debugLog("bigcellboss bonelock")
                if v.sucktimer > 1 then
                    v.sucktimer = 1
                end
            else
                local x, y = entity_getVectorToEntity(me, v.n, 1000)
                entity_addVel(v.n, x, y)
            end
        end
    end
    
    
    -- HACK HACK HACK!!
    -- this is necessary, because otherwise the big cell goes haywire when the nuc is near
    -- (see ScriptedEntity.cpp:onAlwaysUpdate(), if (isPullable() && !fillGridFromQuad) ... for this)
    -- imho, the only way not to enter the `if (e && e != this && e->life == 1 && e->ridingOnEntity != this)`
    -- without touching the obstruction grid is having no collide radius.
    -- Note: setting this to 0 can cause the old 1.1.0 version for OSX to crash
    -- NO WAIT: the crash is still there. This *can* be 0. But its halfway gone in 1.1.1 for win32. Looks like the 1.1.0 mac version sucks.
    entity_setCollideRadius(me, 0.0001)
end

function enterState(me)
    if entity_isState(me, STATE_IDLE) then
        debugLog("bigcellboss idle")
        entity_animate(me, "idle", -1)
    elseif entity_isState(me, STATE_SUCK) then
        if v.nvac ~= 0 then
            entity_setState(me, STATE_IDLE)
            return
        end
        debugLog("bigcellboss suck")
        v.sucksfx = playSfx("suckloop", nil, nil, -1)
        fadeSfx(v.sucksfx, 13)
        entity_animate(me, "suck", -1)
        entity_rotateToEntity(me, v.n, 3.3)
        doCameraIntro(me)
    elseif entity_isState(me, STATE_DEATHSCENE) then
        debugLog("bigcellboss deathscene")
        entity_setStateTime(me, 15)
        cam_toEntity(me)
        entity_color(me, 1, 0.5, 0.5, 3)
        playSfx("bossdiebig")
        watch(0.2)
        fade2(0,0,1,1,1)
        fade2(1,0.2,1,1,1)
        watch(0.2)
        fade2(0,0.5,1,1,1)
        entity_offset(me, -8, 0)
        entity_offset(me, 8, 0, 0.05, -1, 1)
        local sx, sy = entity_getScale(me)
        entity_scale(me, sx * 1.2, sy * 1.2, 2)
        watch(1)
        entity_alpha(me, 0, 3)
        watch(1)
        playSfx("rotcore-die")
        spawnParticleEffect("cellexplode", entity_getPosition(me))
        fade2(0,1,1,1)
        fade2(1,1,1,1,0.2)
        watch(0.2)
        fade2(0,1,1,1,1)
        playSfx("grouper-die")
        watch(5)
        
        setOverrideMusic("")
        updateMusic()
        
        doDeathStuff(me)
        
        entity_delete(me) -- prevent reappearing for short time
        
        watch(2)
        setCameraLerpDelay(0.4)
        cam_toEntity(v.n)
        pickupGem("boss-jelly")
        learnSong(SONG_NATUREFORM)
		changeForm(FORM_NATURE)
        wait(3)
        setCameraLerpDelay(0)
    end
end

function exitState(me)
    if entity_isState(me, STATE_SUCK) then
        fadeSfx(v.sucksfx, 0.7)
        v.sucksfx = 0
    end
end

function msg(me, s, x)
    if s == "flash" then
        bone_damageFlash(v.body, x)
    end
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
    return attacker == v.nuc
end

function songNote(me, note)
    -- DEBUG
    --entity_rotate(me, entity_getRotation(me) + 360, 4, -1)
    --entity_damage(me, v.nuc, 9999)
    --entity_heal(v.n, 99)
    --setCostume("urchin")
    --learnSong(SONG_BIND)
end

function lightFlare(me)
end

function song(me)
end

function songNoteDone(me)
end


-- DO NOT ENABLE THIS ON THE STRANGE MAP !! (It lags the game to death)
-- this is intended for the dbg map where almost nothing else is around.
-- if the crash occurs, it happens after returning from update(), not in some code i wrote.
-- no idea, can't fix the random crash problem.

--[[
if isMapName("dbg") then
    dofile(appendUserDataPath("_mods/Labyrinth/scripts/_debugHooks.lua"))
    installDebugHooks("cel")
end
]]
