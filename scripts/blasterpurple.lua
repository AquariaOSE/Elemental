-- ================================================================================================
-- B L A S T E R P U R P L E    (based on bigblaster)
-- ================================================================================================

-- FG: This is the last boss... for real now.
-- a rather quick hack of the original script, but evil enough to be shipped.
-- although the gameplay may suggest otherwise, i assure anyone reading this that i was completely sober while hacking on it
-- works in conjunction with trigger_bigblaster.lua for the extra rainbow effect

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/inc_util.lua"))
dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))

-- entity specific
local STATE_FIRE				= 1000
local STATE_PULLBACK			= 1001
local STATE_WAITING			= 1002

local MAX_SHOTS = 7
local SCALE = 1.2
local SCALEMULT = 1.8

v.fireDelay = 0
v.soundDelay = 0
v.shotsFired = 0
v.pissed = false
v.n = 0
v.spawnT = 3
v.door = 0
v.closedoor = 0
v.ndied = false
v.breakT = 0
v.wallT = 0
v.mb = false
v.ignoreT = 0
v.wakeup = false
v.laughed = false

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	35,							-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	48,								-- collideRadius (only used if hit entities is on)
	STATE_WAITING,					-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	3000							-- updateCull -1: disabled, default: 4000
	)
		
	entity_initSkeletal(me, "blasterpurple")
	entity_animate(me, "idle", -1)
		
	entity_setDeathParticleEffect(me, "Explode")
	
	entity_scale(me, SCALE, SCALE)
	
	v.soundDelay = math.random(3)+1
	
	entity_setEatType(me, EAT_FILE, "Blaster")
	
	entity_setDeathScene(me, true)
	loadSound("BossDieSmall")
	loadSound("BossDieBig")
	loadSound("BigBlasterRoar")
	loadSound("BigBlasterLaugh")
	loadSound("sunworm-roar")
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	entity_setDamageTarget(me, DT_ENEMY_ENERGYBLAST, false)
    
    setStringFlag("TEMP_weird", "") -- see trigger_bigblaster.lua
    
    entity_initEmitter(me, 0, "wake")
    
    entity_setCullRadius(me, 9999)
end

function postInit(me)
    --if entity_isFlag(me, 1) then
    --    entity_delete(me)
    --end
    v.n = getNaija()
    entity_setTarget(me, v.n)
    
    v.closedoor = getNode("blasterclosedoor")
    
    local doornode = getNode("blasterdoor")
    v.door = node_getNearestEntity(doornode, "energydoor")
    
    local open = entity_getNearestNode(me, "openenergydoor")
    local orb = entity_getNearestNode(me, "blasterorb")
    
    if isFlag(BLASTERBOSS_DONE, 1) then
        if node_isFlag(open, 0) then
            local e = node_getNearestEntity(orb, "energyorb")
            if e == 0 or not node_isEntityIn(orb, e) then
                createEntity("energyorb", "", node_getPosition(orb))
            end
        end
        entity_delete(me)
    end
    
end


-- reversed... i know this is weird

local function closeDoor()
    if not (entity_isState(v.door, STATE_OPEN) or entity_isState(v.door, STATE_OPENED)) then
        debugLog("close door")
        entity_setState(v.door, STATE_OPEN)
        
        setOverrideMusic("sunworm")
        --setOverrideMusic("worship5")
        updateMusic()
    end
end

local function openDoor()
    if not (entity_isState(v.door, STATE_CLOSE) or entity_isState(v.door, STATE_CLOSED)) then
        debugLog("open door")
        entity_setState(v.door, STATE_CLOSE)
    end
end

local function isAlone(me)
    -- returns true if filter matches (= another one found), and then directly exits, returning true. Invert, voila.
    return not v.forAllEntities(function() return true end, nil, function(e)
        return e ~= me and entity_getHealth(e) > 0 and entity_isName(e, "blasterpurple")
    end)
end

local function filter_isOtherBigBlaster(e, me)
    return e ~= me and entity_isName(e, "blasterpurple")
end

local function spawnMinion(me)
    local e = createEntity("blasterpurple_small", "", entity_getPosition(me))
    --entity_setDamageTarget(e, DT_ENEMY_ENERGYBLAST, false)
    --entity_setDamageTarget(e, DT_ENEMY, false)
    return e
end

function update(me, dt)

    if isFlag(BLASTERBOSS_DONE, 0) then
        if node_isEntityIn(v.closedoor, v.n) then
            closeDoor()
        end
    end
    
    if not v.ndied and entity_getHealth(v.n) == 0 then
        v.ndied = true
        setOverrideMusic("")
        updateMusic()
    end
    
    if not v.laughed and entity_isEntityInRange(me, v.n, 2400) then
        v.laughed = true
        playSfx("BigBlasterLaugh")
        shakeCamera(2, 3)
    end

	if entity_isState(me, STATE_WAITING) then
		if entity_isEntityInRange(me, v.n, 1300) or entity_getHealthPerc(me) < 0.99 or v.wakeup then
			entity_setState(me, STATE_IDLE)
            debugLog("msg: wakeup")
            v.forAllEntities(entity_msg, "wakeup", filter_isOtherBigBlaster, me)
		end
		return
	end
	
    if not avatar_isShieldActive() then
        if entity_hasTarget(me) then
            if entity_isTargetInRange(me, 200) then
                entity_moveTowardsTarget(me, dt, -200)
            end
            if entity_isTargetInRange(me, 64) then
                entity_moveTowardsTarget(me, dt, -1000)
            end
        end
    end
    
    if v.fireDelay > 0 then
        v.fireDelay = v.fireDelay - dt
        if v.fireDelay < 0 then
            v.fireDelay = 0
        end
    end
    
    if entity_getState(me)==STATE_IDLE or avatar_isShieldActive() then
        if entity_isTargetInRange(me, 1800) then
            local spd = 400
            if avatar_isShieldActive() then
                spd = 800
            end
            entity_moveTowardsTarget(me, dt, spd)		-- move in if we're too far away
            local dist = 425
            if v.pissed then
                dist = 600
            end
            if entity_isTargetInRange(me, dist) and v.fireDelay==0 then
                entity_setState(me, STATE_FIRE)
            end
        end
        v.soundDelay = v.soundDelay - dt 
        if v.soundDelay < 0 then
            entity_playSfx(me, "BlasterIdle")
            v.soundDelay = math.random(3)+1
        end
    elseif entity_getState(me)==STATE_FIRE then
        entity_moveTowardsTarget(me, dt, -600)
    elseif entity_getState(me)==STATE_PULLBACK then
        if not entity_hasTarget(me) then
            entity_setState(me, STATE_IDLE)
        else
            if entity_isTargetInRange(me, 800) then
                entity_moveTowardsTarget(me, dt, -5000)
            else
                entity_setState(me, STATE_IDLE)
            end
        end
    end
    
    
    if v.pissed and v.spawnT >= 0 then
        v.spawnT = v.spawnT - dt
        if v.spawnT <= 0 then
            v.spawnT = math.random(4000, 5500) / 1000
            if avatar_isShieldActive() then
                v.spawnT = v.spawnT * 0.5
            end
            spawnMinion(me)
        end
    end
    
    if not avatar_isShieldActive() or v.ignoreT > 0 then
        entity_doCollisionAvoidance(me, dt, 6, 0.5)
        v.breakT = 0.5
        if v.mb then
            --entity_disableMotionBlur(me)
            entity_stopEmitter(me, 0)
            v.mb = false
        end
    else
        if v.wallT > 0 then
            entity_doCollisionAvoidance(me, dt, 6, 1)
        end
        if v.breakT >= 0 then
            v.breakT = v.breakT - dt
            if v.breakT <= 0 then
                v.breakT = 0.2
                --entity_addVel(me, entity_velx(me) * -0.2, entity_vely(me) * -0.2)
                local vx, vy = entity_getVectorToEntity(me, v.n)
                vx, vy = vector_setLength(vx, vy, math.random(400, 700) / 100)
                entity_addVel(me, vx, vy)
            end
        end
        entity_setMaxSpeed(me, 1500)
        entity_doFriction(me, dt, 100)
        if not v.mb then
            --entity_enableMotionBlur(me)
            entity_startEmitter(me, 0)
            v.mb = true
        end
    end
    
    if v.wallT >= 0 then
        v.wallT = v.wallT - dt
    end
    
    if v.ignoreT >= 0 then
        v.ignoreT = v.ignoreT - dt
    end
    
    entity_doEntityAvoidance(me, dt, 256, 0.2)
	entity_rotateToVel(me, 0.1)
	entity_updateCurrents(me, dt)
	entity_updateMovement(me, dt)
	
	entity_handleShotCollisions(me)
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 1000, 0.3) then
        v.ignoreT = math.random(1000, 2000) / 1000
    end
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		v.fireDelay = 1
		entity_setMaxSpeed(me, 600)
	elseif entity_getState(me)==STATE_FIRE then
		entity_setStateTime(me, 0.2)
		entity_setMaxSpeed(me, 800)
		local s
        if v.pissed then
            if avatar_isShieldActive() then
                createEntity("trigger_bigblaster", "", entity_getPosition(me))
                v.fireDelay = 0.2
            else
                if v.shotsFired == 0 or v.shotsFired == 1 then
                    createEntity("trigger_bigblaster", "", entity_getPosition(me))
                else
                    s = createShot("BigBlasterFire2", me, entity_getTarget(me))
                end
            end
        else
            if avatar_isShieldActive() then
                s = createShot("BigBlasterFire2", me, entity_getTarget(me))
                v.shotsFired = MAX_SHOTS -- only one
                v.fireDelay = 1.6
            else
                if v.shotsFired == MAX_SHOTS then
                    s = createShot("BigBlasterFire2", me, entity_getTarget(me))
                else
                    s = createShot("BigBlasterFire", me, entity_getTarget(me))
                end
            end
        end
        if s then
            shot_setOut(s, 32)
        end
	elseif entity_getState(me)==STATE_PULLBACK then
		if chance(50) then
			shakeCamera(2, 3)
			playSfx("BigBlasterRoar")
		end
		entity_setMaxSpeed(me, 900)
	elseif entity_isState(me, STATE_DEATHSCENE) then
        if not isAlone(me) then
            playSfx("bigblasterroar")
            playSfx("bossdiebig")
            local x, y = entity_getPosition(me)
            spawnParticleEffect("vercoreexplode", x, y)
            debugLog("msg: blasterpurple_die")
            v.forAllEntities(entity_msg, "blasterpurple_die", filter_isOtherBigBlaster, me)
            for i = 1, 5 do
                spawnMinion(me)
            end
        else -- last one
            setFlag(BLASTERBOSS_DONE, 1)
            clearShots()
            setStringFlag("TEMP_weirdfade", "1") -- checked by trigger_bigblaster.lua
            entity_setStateTime(me, 99)
            entity_setInternalOffset(me, 0, 0)
            entity_setInternalOffset(me, 0, 10, 0.1, -1)
            
            playSfx("BigBlasterRoar")
            wait(1.5)
            cam_toEntity(me)
            playSfx("BossDieSmall")
            entity_idle(v.n)
            fade(1, 0.5, 1, 1, 1)
            watch(0.5)
            fade(0, 1, 1, 1, 1)
            watch(0.5)
            playSfx("BigBlasterLaugh")
            watch(0.7)
            entity_color(me, 1, 0, 0, 2)
            spawnParticleEffect("vercoreexplode", entity_getPosition(me))
            watch(1.0)
            playSfx("BigBlasterRoar")
            watch(0.5)
            spawnParticleEffect("vercoreexplode", entity_getPosition(me))
            playSfx("BossDieBig")
            fade(1, 0.2, 1, 1, 1)
            watch(0.2)
            watch(0.5)
            fade(0, 1, 1, 1, 1)
            
            setOverrideMusic("")
            updateMusic()
            
            createEntity("energyorb", "", entity_getPosition(me))
            openDoor()
            watch(2)
            cam_toEntity(v.n)
        end
		entity_setState(me, STATE_DEAD, -1, 1)
        --entity_setFlag(me, 1)
	end
end

function exitState(me)
	if entity_getState(me)==STATE_FIRE then
		v.shotsFired = v.shotsFired + 1
		if v.shotsFired <= MAX_SHOTS then
			entity_setState(me, STATE_FIRE)
		else
			entity_setState(me, STATE_PULLBACK, 1)
		end
		
	elseif entity_getState(me)==STATE_PULLBACK then
		v.shotsFired = 0
		entity_setState(me, STATE_IDLE)
	end
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
    if attacker ~= 0 and (entity_isName(attacker, "blasterpurple") or entity_isName(attacker, "blasterpurple_small")) then
        return false
    end
	if damageType == DT_AVATAR_BITE then
		entity_damage(me, attacker, 4)
	end
	return true
end

function msg(me, s, x)
    if s == "blasterpurple_die" then
        if isAlone(me) and not v.pissed then
            entity_color(me, 1, 0.5, 0.5, 2)
            entity_scale(me, SCALE * SCALEMULT, SCALE * SCALEMULT, 2)
            v.pissed = true
            entity_setCollideRadius(me, entity_getCollideRadius(me) * SCALEMULT)
            entity_setHealth(me, entity_getHealth(me) + 60)
            playSfx("sunworm-roar")
            shakeCamera(10, 2)
        end
    elseif s == "wakeup" then
        v.wakeup = true
    end
end

function hitSurface(me)
    entity_addVel(me, entity_velx(me) * -2.5, entity_vely(me) * -2.5)
    spawnParticleEffect("rockhit", entity_x(me), entity_y(me))
    entity_playSfx(me, "rockhit-big", nil, 1.5)
    shakeCamera(7, 0.7)
    v.wallT = 1.5
end

function song() end
function songNote() end
function songNoteDone() end
function animationKey() end
function shotHitEntity() end
