if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))
dofile(appendUserDataPath("_mods/Labyrinth/scripts/inc_util.lua"))
dofile(appendUserDataPath("_mods/Labyrinth/scripts/inc_timerqueue.lua"))

local STATE_AWARE = 1000
local STATE_ANGRY = 1001

local BEAM_TIME = 3.5 -- how long beams stay active. -- TODO: start low, increase with damage?

v.tent = 0
v.tentAnim = "idle"

v.inactive = true

v.sz = 1.2

v.head = 0
v.eye1 = 0
v.eye2 = 0
v.squeeze = 0

v.beamT = 0
v.beam1 = 0
v.beam2 = 0

v.tx = 0 -- beam target point
v.ty = 0
v.txs = 0 -- beam target point speed
v.tys = 0
v.tq = 0 -- debug quad (targeting)
v.mq = 0 -- debug quad (movement)

v.pissed = false
v.shotsAfterBeam = false

v.shelter = false -- if true, seek shelter node
v.shelterNode = 0 -- target node to go to
v.shelterT = 0 -- how long to stay in shelter or seeking it
v.shelterIgnoreT = 0 -- never seek shelter if > 0

v.bumpT = 0 -- do not apply free movmement while this is on
v.damageT = 0 -- no damage while this is on

v.inkT = 1.5

v.timer = 0 -- for sin/cos

v.shotT = 0
v.shotRounds = 0

v.zoom = true

v.ndied = false -- true when pwn3d

local function doDeathStuff(me)
    local doornode = entity_getNearestNode(me, "doortrigger")
    local door = node_getNearestEntity(doornode, "wooddoor")
    entity_setState(door, STATE_OPEN)
    overrideZoom(0)
    local pearlspawn = getNode("driftpearlspawn")
    createEntity("driftpearl", "", node_getPosition(pearlspawn))
end

local function initBattle(me)
    if v.inactive then
        local function shootPeriodic()
            local tm = v.rangeTransform(entity_getHealthPerc(me), 0, 1,  1.5, 5)
            v.pushTQ(tm, shootPeriodic)
            createShot("raspberrydouble", me, v.n)
        end
        shootPeriodic()
        
        v.inactive = false
        
        playSfx("bigblasterlaugh")
        setOverrideMusic("mithala")
        updateMusic()
    end
end

local function applyZoom(me)
    if v.zoom and entity_isState(me, STATE_IDLE) then
        overrideZoom(0)
        v.zoom = false
        debugLog("zoom back")
    elseif not v.zoom and not entity_isState(me, STATE_IDLE) then
        overrideZoom(0.35, 2)
        v.zoom = true
        debugLog("zoom out")
    end
end

local function setTentacleAnim(a)
    if a == v.tentAnim then
        return
    end
    debugLog("setTentacleAnim " .. a)  
    for _, t in pairs(v.tent) do
        entity_animate(t.e, a, -1)
    end
    v.tentAnim = a
end

local function setupTentacles(me)
    local x, y = entity_getPosition(me)
    local ents = {}
    for i = 1, 7 do
        local b = entity_getBoneByIdx(me, i)
        local e = createEntity("mineoctotentacle", "", x, y)
        ents[i] = e
        local rnd =  math.random(100) / 1000
        v.tent[b] = { e = e, updateMult = rnd, b = entity_getBoneByIdx(e, 0) }
        
        bone_alpha(b, 0)
        bone_alpha(v.tent[b].b, 0)
        
        --if i == 1 or i == 3 or i == 6 then
        if i == 1 or i == 3 or i == 2 or i == 4 then
            entity_initHair(e, 40, 6, 50, "mineoctoboss/backtentacle")
        else
            entity_initHair(e, 40, 6, 50, "mineoctoboss/tentacle")
        end
        
        entity_update(e, math.random(10000) / 1000)
    end
    
    --[[for i = 1, 7 do
        if i == 1 or i == 5 or i == 6 then
            entity_moveToBack(ents[i])
        end
    end]]
    -- what a coincidence!
    for i = 1, 4 do
        entity_moveToBack(ents[i])
    end
    
end

local function updateTentacles(me, dt)
    for myb, t in pairs(v.tent) do
        local b, e, um = t.b, t.e, t.updateMult
        local bx, by = bone_getWorldPosition(myb)
        local br = bone_getWorldRotation(myb)
        entity_setPosition(e, bx, by)
        entity_rotate(e, br)
        
        local nx, ny = bone_getNormal(b)
        ny = ny + 0.3
        entity_setHairHeadPosition(e, bx, by)
        entity_exertHairForce(e, nx * 1200, ny * 800, dt)
        entity_updateHair(e, dt)
        
        entity_update(e, dt * um) -- forcefully update to improve animation permutation
    end
end

local function updateBeam(b, bone)
    beam_setPosition(b, bone_getWorldPosition(bone))
    local bx, by = bone_getWorldPosition(bone)
    --local nx, ny = entity_getPosition(v.n)
    --local vx, vy = v.makeVector(bx, by, nx, ny)
    local vx, vy = v.makeVector(bx, by, v.tx, v.ty)
    beam_setAngle(b, v.vector_getAngleDeg(vx, vy))
end

local function updateTargetPoint(dt)

    local nx, ny = entity_getPosition(v.n)
    
    if not entity_isPositionInRange(v.n, v.tx, v.ty, 1000) then
        v.tx = nx
        v.ty = ny
        return
    end
    
    local dx, dy = v.makeVector(v.tx, v.ty, nx, ny)
    local m
    
    
    local d = vector_getLength(dx, dy)
    m = dt * ((d + 15) / 50) ^ 0.5
    
    v.txs = v.txs + dx * m
    v.tys = v.tys + dy * m
    
    local frict = (1 - (dt * 0.7))
    
    v.txs = v.txs * frict
    v.tys = v.tys * frict
    
    v.tx = v.tx + v.txs * dt
    v.ty = v.ty + v.tys * dt
    
    --[[if entity_isPositionInRange(v.n, v.tx, v.ty, 30) then
        m = dt
    elseif entity_isPositionInRange(v.n, v.tx, v.ty, 300) then
        dx, dy = vector_normalize(dx, dy)
        m = dt * 363
    else
        dx, dy = vector_normalize(dx, dy)
        local d = vector_getLength(dx, dy)
        local sc = v.rangeTransform(d, 300, 500,    363, 900)
        m = dt * sc
    end]]
    
    --v.tx = v.tx + dx * m
    --v.ty = v.ty + dy * m
    
    if v.tq ~= 0 then
        quad_setPosition(v.tq, v.tx, v.ty)
    end
end

local function setupBeam(bone)
    local b = createBeam()
    beam_setDamage(b, 1)
    beam_setBeamWidth(b, 10)
    beam_setTexture(b, "particles/octobeam")
    updateBeam(b, bone)
    return b
end

local function createShotCircle(me, c)
    local x, y = entity_getPosition(me)

    local maxa = 3.141596 * 2
    local step = maxa / c
    local offs = math.random(0, maxa * 1000) / 1000
    maxa = maxa + offs -- less predictable
    local a = offs
    while a < maxa do
        local s = createShot("raspberrydouble", me) -- not targeted
        shot_setAimVector(s, math.sin(a), math.cos(a))
        a = a + step
    end
end

local function destroyBeams()
    if v.beam1 ~= 0 then beam_delete(v.beam1) end
    if v.beam2 ~= 0 then beam_delete(v.beam2) end
    v.beam1 = 0
    v.beam2 = 0
end

local function doIdleScale(me)
    entity_scale(me, 1.05*v.sz, 0.95*v.sz)
    entity_scale(me, 0.95*v.sz, 1.05*v.sz, 2, -1, 1, 1)
end

local sin = math.sin
local cos = math.cos

local function doMovement(me, dt)

    if v.shelter then
        --entity_clearVel(me)
        if v.shelterT >= 0 then
            v.shelterT = v.shelterT - dt
            if v.shelterT <= 0 then
                debugLog("shelter done")
                v.shelter = false
                v.shelterNode = 0
                -- TODO: come back out
            else
                if v.shelterNode == 0 then
                    debugLog("into shelter")
                    v.shelterNode = entity_getNearestNode(me, "shelter")
                    
                    -- FIXME: this is shit
                    -- nah, works. good enough i bet.
                    entity_moveToNode(me, v.shelterNode)
                    
                    v.pushTQ(1, function() createShot("mineocto-ink", me, v.n) end)
                    
                    
                end 
            end
        end
    else
        if v.bumpT >= 0 then
            v.bumpT = v.bumpT - dt
        else
            -- screwed sin/cos formula
            local k = v.timer * 0.9
            local addx = (sin(k) * 100) + (cos(k * -0.36) * 80) + (sin(k * 0.40) * -50) + (sin(k * 0.10) * 130)
            local addy = (cos(k) * 100) + (sin(k * -1.30) * 80) + (cos(k * 0.65) * -50) + (cos(k * 0.11) * 130)
            addy = addy * 1.5 -- the map is a vertical shaft after all
            
            local vx, vy = entity_getVectorToEntity(me, v.n)
            vx, vy = vector_setLength(vx, vy, 170)
            addx = addx + vx
            addy = addy + vy
            
            local m = dt * 10
            entity_addVel(me, addx * m, addy * m)
            
            
            entity_doCollisionAvoidance(me, dt, 4 + entity_getCollideRadius(me) / 20, 1.0)
            --entity_doEntityAvoidance(me, dt, entity_getCollideRadius(me) / 2, 0.2)
            --entity_doSpellAvoidance(me, dt, 200, 0.2)

            --entity_doEntityAvoidance(me, dt)
            entity_updateMovement(me, dt)
        end
        
        -- FIXME: update movement anyways
        -- check if this like should go here
    end
end

local function abortShelter(me)
    if v.shelter and v.shelterT > 0.1 then
        debugLog("abortShelter")
        v.shelterT = 0.1 -- not safe! get out!
        v.shelterIgnoreT = math.random(800, 1500) / 100
        if v.shelterNode ~= 0 and node_isEntityIn(v.shelterNode, me) then
            entity_setMaxSpeedLerp(me, 5)
            entity_setMaxSpeedLerp(me, 1, 2)
            entity_doCollisionAvoidance(me, 0.5, 6 + entity_getCollideRadius(me) / 20, 2)
        else
            entity_setMaxSpeedLerp(me, 3)
            entity_setMaxSpeedLerp(me, 1, 2)
            entity_stopInterpolating(me)
        end
    end
end
local function onRockHit(me, rock)
    
    -- impact
    local ix = entity_velx(rock)
    local iy = entity_vely(rock)
    
    entity_setMaxSpeedLerp(me, 3)
    entity_setMaxSpeedLerp(me, 1, 0.8)
    
    entity_addVel(me, ix * 0.5, iy * 0.5)
    entity_addVel(rock, ix * -0.5, iy * -0.5)
    
    if v.shelter then
        abortShelter(me)
    elseif not v.pissed and v.shelterIgnoreT <= 0 then
        v.shelter = true
        v.shelterT = math.random(40, 90) / 10
    end
end

local function setStare(me, on)
    if on then
        entity_animate(me, "stare", -1)
    else
        entity_animate(me, "idle", -1)
    end
end

local function wave(lots)
    if v.pissed then
        if lots then
            setTentacleAnim("wavefast")
        else
            setTentacleAnim("wavemed")
        end
    else
        if lots then
            setTentacleAnim("wavemed")
        else
            setTentacleAnim("idle")
        end
    end
end

local function doBeams(me, t)
    
    local created = false
    if v.beam1 == 0 then
        v.beam1 = setupBeam(v.eye1)
        v.beam2 = setupBeam(v.eye2)
        created = true
    end
    
    t = t or BEAM_TIME
    if v.pissed then
       t = t * 1.4
    end
    
    if t > v.beamT then
        v.beamT = t
    end
    
    if v.beamT > 3 then
        if created then
            entity_playSfx(me, "rotcore-beam")
        end
        v.shotsAfterBeam = true
    else
        if created then
            entity_playSfx(me, "originalraspberryshot")
            v.shotsAfterBeam = false
        end
    end
end

function init(me)
    v.tent = {}
    setupEntity(me)
    entity_setEntityType(me, ET_ENEMY)
    entity_initSkeletal(me, "mineoctoboss")
    entity_setState(me, STATE_IDLE)
    
    v.eye1 = entity_getBoneByName(me, "eye1")
    v.eye2 = entity_getBoneByName(me, "eye2")
    
    
    bone_alpha(v.eye1, 0.001)
    bone_alpha(v.eye2, 0.001)
    
    entity_initEmitter(me, 0, "octoaura")
    
    v.head = entity_getBoneByIdx(me, 0)
    v.squeeze = entity_getBoneByIdx(me, 14)
    
    loadSound("rotcore-beam")
    loadSound("rotcore-die2")
    loadSound("camopus-roar")
    loadSound("bigblasterlaugh")
    loadSound("bossdiebig")
    loadSound("bossdiesmall")
    
    entity_scale(me, v.sz, v.sz)
    entity_setHealth(me, 18) -- 24
    entity_setCollideRadius(me, 150)
    entity_setMaxSpeed(me, 500)
    entity_setDeathScene(me, true)
    
    doIdleScale(me)
    
    -- prevent texture unload
    quad_alpha(createQuad("mineoctoboss/armwrap"), 0)
    quad_alpha(createQuad("mineoctoboss/armwrap-squeeze"), 0)
    
    entity_setCull(me, false)
    
end

function postInit(me)

    if getFlag(MINEOCTOBOSS_DONE) ~= 0 then
        doDeathStuff(me)
        entity_delete(me)
        return
    end
    
    v.n = getNaija()
    setupTentacles(me)
    
    
    -- DEBUG - enable to see beam target point and movement speed
    --v.tq = createQuad("missingimage")
    --v.mq = createQuad("test/vector")
    --quad_setPosition(v.tq, entity_getPosition(v.n))
    
    -- pulse func
    local kuirlinhead = entity_getBoneByIdx(me, 13)
    
    local function doUnsqueeze()
        bone_alpha(v.squeeze, 0, 0.6)
    end
    
    local function doSqueeze()
        bone_alpha(v.squeeze, 1, 0.6)
    end
        
    local function dmgf()
        v.pushTQ(3.8, dmgf)
        bone_damageFlash(kuirlinhead)
        
        v.pushTQ(3.2, doSqueeze)
        v.pushTQ(0.4, doUnsqueeze)
    end
    dmgf()
    
end

local function update_(me, dt)
    
    v.updateTQ(dt)
    
    if v.damageT >= 0 then
        v.damageT = v.damageT - dt
    end
    
    if v.shelterIgnoreT >= 0 then
        v.shelterIgnoreT = v.shelterIgnoreT - dt
    end
    
    if not v.ndied and entity_getHealth(v.n) <= 0 then
        setOverrideMusic("")
        updateMusic()
        v.ndied = true
    end
    
    if v.pissed then
        dt = dt * 1.3
    end
    
    v.timer = v.timer + dt
    
    applyZoom(me)

    updateTentacles(me, dt)
    updateTargetPoint(dt)
    
    if entity_getHealth(me) > 0 then
    
        if v.beamT > 0 then
            updateBeam(v.beam1, v.eye1)
            updateBeam(v.beam2, v.eye2)
            
            v.beamT = v.beamT - dt
            if v.beamT <= 0 then
                destroyBeams()
                if v.shotsAfterBeam then
                    v.shotRounds = 2
                    v.shotT = 0.5
                end
            elseif v.beamT < 1.5 and entity_getAnimationName(me) == "stare" then
                setStare(me, false)
            end
        end
        
        if v.shotT >= 0 then
            v.shotT = v.shotT - dt
            if v.shotT <= 0 and v.shotRounds > 0 then
                local dmgperc = 1 - entity_getHealthPerc(me)
                local shots = math.floor(3 + (9 * dmgperc))
                v.shotT = v.shotT + 0.5
                createShotCircle(me, shots)
                v.shotRounds = v.shotRounds - 1
            end
        end
    end
    
    -- DEBUG related
    if v.mq ~= 0 then
        local a = v.vector_getAngleDeg(entity_velx(me), entity_vely(me))
        local spd = entity_getVelLen(me)
        quad_rotate(v.mq, a)
        local s = spd / 150
        quad_scale(v.mq, s, s)
        quad_setPosition(v.mq, entity_getPosition(me))
    end
    
    -- clinging & pushback
    if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0) then
        if avatar_isBursting() and entity_setBoneLock(v.n, me) then
            v.pushTQ(0.6, function()
                entity_playSfx(me, "camopus-roar", nil, 1.5)
                shakeCamera(15, 1)
                avatar_fallOffWall()
                v.pushTQ(0.2, function() doBeams(me, 0.8) end)
            end)
        else
            local x, y = entity_getVectorToEntity(me, v.n, 1000)
            entity_addVel(v.n, x, y)
            entity_setMaxSpeedLerp(v.n, 2)
            entity_setMaxSpeedLerp(v.n, 1, 0.55)
        end
        
        -- push back octo a bit
        if entity_getBoneLockEntity(v.n) ~= me then
            local x, y = entity_getVectorToEntity(v.n, me, 10000)
            entity_addVel(me, x, y)
            --v.bumpT = 0.28
        end
    end
    
    entity_handleShotCollisions(me)
    
    
    if v.inactive then
       return
    end
       
    
    doMovement(me, dt)

    for _, t in pairs(v.tent) do
        if entity_collideHairVsCircle(t.e, v.n, 35) then -- max 40 segs
            entity_damage(v.n, me, 1)
            avatar_fallOffWall()
            --v.bumpT = 1.5
        end
    end
    
    
    -- main fight logic below
    
    local hp = entity_getHealthPerc(me)
    
    if hp < 0.8 and entity_isEntityInRange(me, v.n, 400) and not entity_isState(me, STATE_ANGRY) then
        entity_setState(me, STATE_ANGRY)
    end
    
    if not entity_isEntityInRange(me, v.n, 3000) and not entity_isState(me, STATE_IDLE) then
        entity_setState(me, STATE_IDLE)
        debugLog("too far away, going idle")
    end
    
    if v.pissed then
        if v.inkT >= 0 then
            v.inkT = v.inkT - dt
            if v.inkT <= 0 then
                v.inkT = math.random(400, 600) / 100
                if v.pissed then v.inkT = v.inkT / 2.5 end
                local ink = createShot("mineocto-ink", me, v.n)
            end
        end
    
    elseif hp < 0.4 then
        debugLog("now pissed!")
        entity_color(me, 1, 0.5, 0.5, 2)
        for _, t in pairs(v.tent) do
            entity_color(t.e, 1, 0.5, 0.5, 2)
        end
        v.pissed = true
        setOverrideMusic("mithalaanger")
        updateMusic()
    end
    
end

function update(me, dt)
    return update_(me, dt)
end


local deathCutscene -- body is at end of file

function enterState(me)
   if entity_isState(me, STATE_IDLE) then
        debugLog("state idle")
        setStare(me, false)
        wave(false)
    elseif entity_isState(me, STATE_AWARE) then
        debugLog("state aware")
        wave(true)
    elseif entity_isState(me, STATE_ANGRY) then
        debugLog("state angry")
        setStare(me, true)
        entity_setStateTime(me, 10)
        local t = 2
        if v.pissed then t = 1.1 end
        v.pushTQ(t, doBeams, me)
    elseif entity_isState(me, STATE_DEATHSCENE) then
        debugLog("state deathscene")
        wave(true)
        destroyBeams()
        
        deathCutscene(me)
    end
end

function exitState(me)
    if entity_isState(me, STATE_ANGRY) then
        entity_setState(me, STATE_AWARE)
    end
end

local function damageFlash(t)
    bone_damageFlash(v.head, t)
    for _, t in pairs(v.tent) do
        bone_damageFlash(t.b, t)
    end
end

local function onDamage(me, attacker, bone, damageType, dmg)
    if attacker ~= 0 and eisv(attacker, EV_TYPEID, EVT_ROCK) and damageType == DT_CRUSH then
        onRockHit(me, attacker)
        playSfx("rotcore-die2")
        shakeCamera(5, 1)
        entity_setState(me, STATE_ANGRY)
        return 3 -- handle and shelter
    end
    if (damageType == DT_AVATAR_ENERGYBLAST and dmg >= 1) or damageType == DT_AVATAR_SHOCK or attacker == me then
        return 1 -- just handle
    end
    if damageType == DT_AVATAR_VINE then -- vine
        entity_damage(me, me, 0.2)
        damageFlash() -- red
        entity_playSfx(attacker, "vinehit")
        createShot("raspberrydouble", me, attacker)
        entity_setState(me, STATE_ANGRY)
        return 2 -- do not handle, but exit shelter
    end
    if damageType == DT_AVATAR_ENERGYBLAST and dmg < 1 then -- urchin
        --[[entity_damage(me, me, 0.1)
        damageFlash(1) -- yellow
        playSfx("urchin-hit")
        return 2]]
        
        -- no damage for now is better?
        return 0
        
    end
    return 0 -- nothing
end

function damage(me, attacker, bone, damageType, dmg)
    
    --debugLog("dmgt: " .. v.damageT)
    
    if v.damageT > 0 then
        return false
    end
    
    local result = onDamage(me, attacker, bone, damageType, dmg)
    if result ~= 0 then
        v.damageT = 0.5
        initBattle(me) --- if we haven't already
        if result == 1 or result == 2 then
            abortShelter(me)
        end
    end
    
    return result == 1 or result == 3
end

function msg(me, s, x)
    if s == "start" then
        initBattle(me)
    end
end

function dieNormal(me)
end

function animationKey(me, key)
end

function hitSurface(me)
    if v.bumpT <= 0 then
        v.bumpT = 1
        --debugLog("bump!")
    end
end

function songNote(me, note)
    --entity_damage(me, me, 999) -- DEBUG
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end


deathCutscene = function(me)
    local n = v.n
    
    destroyBeams()
    
    -- drop rock if still carrying one - inteferferes with the cutscene
    --v.forAllEntities(entity_stopPull) -- WHAAT - this sometimes breaks all entities on the map! WEIRD! (Looking at the source code, this sets maxspeed to uninitialized memory. YAY!)
    
    avatar_setPullTarget(0)
    
    -- watch boss die
    entity_flipToEntity(n, me)
    entity_rotate(n, 0, 0.5)
    entity_setStateTime(me, 999) -- we do this manually
    setCameraLerpDelay(0.25)
    cam_toEntity(me)
    
    local bossend = getNode("bossend")
    local bossend2 = getNode("bossend2")
    local middle = getNode("shaftmiddle")
    
    -- move boss to center of cave (x-axis only)
    local x, y = entity_getPosition(me)
    
    if y > node_y(bossend) then
        y = node_y(bossend)
    end
    
    entity_interpolateTo(me, node_x(middle), y, 1)
    
    -- HACK: during death scene, update() is no longer called, do it manually
    for i = 0, 1, FRAME_TIME do
        watch(FRAME_TIME)
        update_(me, FRAME_TIME)
    end
    debugLog("boss in middle")
    x,y = entity_getPosition(me)
    
    setOverrideMusic("")
    updateMusic()
    musicVolume(0, 1)
    
    -- shake, grow, turn more red
    entity_color(me, 1, 0.35, 0.35, 3)
    entity_offset(me, -8, 0)
    entity_offset(me, 8, 0, 0.05, -1, 1)
    local sx, sy = entity_getScale(me)
    entity_scale(me, sx * 1.2, sy * 1.2, 2)

    
    shakeCamera(5, 1.5)
    
    debugLog("all tentacles dead")
    playSfx("bossdiesmall")
    watch(1.5)
    
    -- naija swims down past dying boss
    --esetv(n, EV_NOINPUTNOVEL, 0)
    entity_swimToNode(n, bossend)
    
    -- spawn rescued kuirlin
    local kx, ky = bone_getWorldPosition(entity_getBoneByIdx(me, 13))
    local kui = createEntity("kuirlinrescued", "", kx, ky)
    entity_alpha(kui, 0)
    entity_alpha(kui, 1, 0.4)
    entity_addVel(kui, 0, -100)
    
    -- spawn pearl
    --local pearl = createEntity("driftpearldrop", "", kx, ky)
    local pearl = createEntity("driftpearl", "", kx, ky)
    entity_setMaxSpeed(pearl, 700)
    esetv(pearl, EV_LOOKAT, 0) -- enabled again later - we want to have naija looking at the kuirlin, not at the pearl
    entity_setBounce(pearl, 0.2)
    entity_setWeight(pearl, 400)
    entity_alpha(pearl, 0)
    entity_alpha(pearl, 1, 0.4)
    entity_addVel(pearl, 150, -500)

    
    -- BOOM
    playSfx("bossdiesmall")
    spawnParticleEffect("octoexplode", x, y)
    shakeCamera(12, 1.5)
    watch(0.3)
    playSfx("bossdiebig")
    entity_alpha(me, 0, 1.5)
    for _, t in pairs(v.tent) do
        local bx, by = entity_getPosition(t.e)
        --spawnParticleEffect("bigredexplode", bx, by)
        --entity_changeHealth(t.e, t.e, -99)
        --entity_delete(t.e)
        entity_setState(t.e, STATE_DEAD) -- that works!
    end
    watch(1.5)
    destroyBeams() -- just in case
    entity_delete(me)
    me = 0 -- to be sure
    debugLog("final explode done")
    
    setFlag(MINEOCTOBOSS_DONE, 1)
    
    -- show kuirlin
    entity_flipToEntity(n, kui)
    watch(0.5)
    overrideZoom(1, 2)
    cam_toEntity(kui)
    debugLog("kui focused")
    while not entity_isNearObstruction(kui, 5, OBSCHECK_RANGE) --[[ and not isEscapeKey() ]] do -- FIXME
        watch(FRAME_TIME)
        entity_flipToEntity(n, kui)
    end
    entity_rotate(n, 0, 0.5)
    
    -- this breaks horribly... seems to work well enough without it
    --entity_setWeight(kui, 0)
    ---entity_clampToSurface(kui)
    
    setOverrideMusic("hopeofwinter")
    updateMusic()
    musicVolume(1, 1)
    
    watch(1.5)
    
    entity_swimToNode(n, bossend2)
    emote(EMOTE_NAIJASADSIGH)
    watch(1)
    setNaijaHeadTexture("smile", 10)
    entity_rotate(n, 0, 0.5)
    watch(1)
    
    entity_rotate(n, 0, 0.5)
    
    -- bow
    debugLog("kui bowing")
    --entity_rotate(kui, 30, 0.2, 3, 1) -- OLD
    entity_msg(kui, "happy")
    entity_animate(kui, "nod", 2)
    
    
    watch(3)
    entity_animate(kui, "idle", -1)
    
    debugLog("kui flip")
    entity_fh(kui)
    watch(0.3)
    
    -- go away
    overrideZoom(0.52, 1)
    entity_msg(kui, "go")
    local doortrigger = getNode("doortrigger")
    local t = 0
    local c = 0
    local spawn1 = getNode("kuirlinspawn1")
    local spawn2 = getNode("kuirlinspawn2")
    
    local function mkspawn(node)
        local e = createEntity("purplespooter" .. math.random(2, 7), "", node_getPosition(node))
        entity_msg(e, "speed", math.random(2400, 3600))
        entity_msg(e, "keepdir")
        entity_msg(e, "happy")
        entity_msg(e, "minetimer")
        entity_setUpdateCull(e, -1)
        return e
    end
    
    local function blahspawn()
        local e = mkspawn(spawn1)
        entity_msg(e, "switchdir")
        entity_fh(e)
        
        mkspawn(spawn2)
    end
    
    while not node_isEntityIn(doortrigger, kui) --[[ and not isEscapeKey() ]] do
        watch(FRAME_TIME)
        t = t + FRAME_TIME
        if c == 0 then
            if t > 1.4 then
                t = 0
                emote(EMOTE_NAIJALAUGH)
                c = c + 1
            end
        elseif c < 6 then
            if t > 0.4 then
                c = c + 1
                t = t - 0.4
                
                blahspawn()
            end
        elseif c >= 6 then -- HACK: unlock camera even if entity goes haywire
            if t > 2 then
                break
            end
        end
        
        -- HACK: just in case it falls into the "kuirlinremover" node because something fucks up
        if entity_getAlpha(kui) < 1 then
            kui = 0
            break
        end
    end
    cam_toEntity(n)
    
    esetv(pearl, EV_LOOKAT, 1)
    
    -- open door
    debugLog("opening door")
    local door = node_getNearestEntity(doortrigger, "wooddoor")
    entity_setState(door, STATE_OPEN)
    
    
    -- other drop stuff + get happy + leave
    
    
    debugLog("deathscene almost done")
    overrideZoom(0)
    --esetv(n, EV_NOINPUTNOVEL, 1)
    setCameraLerpDelay(0.1)
    setOverrideMusic("")
    --updateMusic() -- do NOT update music here, right now. Leave it on until the map is changed, or we enter an updatemusic node.
    
    wait(0.4)
    blahspawn()
    wait(0.4)
    blahspawn()
    wait(0.2)
    blahspawn()
    emote(EMOTE_NAIJALAUGH)
    
    for i = 1, 7 do
        wait(math.random(4000, 8000) / 10000)
        debugLog("spawn late " .. i)
        blahspawn()
        --if isEscapeKey() then break end -- DEBUG
    end
    debugLog("deathscene really done")
end

