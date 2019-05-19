if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Elemental/scripts/inc_util.lua"))

v.n = 0
v.myWeight = 0
v.note = -1
v.notex = 0
v.notey = 0
v.lastvel = 0
--[[v.precalc = false
v.initT = 0
v.sentInit = false
v.countdownInitT = false]]

function v.commonInit(me, gfx, r)
	-- note: if you want to add different weight to each rock, then
	-- send it through here
	if r == 0 then
		r = 80
	end
	setupEntity(me, gfx, -1)
	
	v.myWeight = 480
	entity_setCollideRadius(me, r)
	entity_setBounce(me, 0.2)
	entity_setCanLeaveWater(me, true)
    
    entity_setMaxSpeed(me, 900)
	
	entity_setAllDamageTargets(me, false)
	
	esetv(me, EV_TYPEID, EVT_ROCK)
    
    entity_setProperty(me, EP_MOVABLE, true)
    
    -- Removed the hack. There are a lot less rocks in the pearlmine now, so delayed init is no longer necessary.
    entity_setProperty(me, EP_BLOCKER, true)
end

--[[
local function isRock(e, me)
    return e ~= me and eisv(e, EV_TYPEID, EVT_ROCK)
end

-- first come first serve.
-- the goal is to 
local function broadcastDelay(me)
    v.forAllEntities(entity_msg, "rock_init_delay", isRock, me)
    v.sentInit = true
    debugLog("Rock: my delay: " .. v.initT)
end
]]

function postInit(me)
	v.n = getNaija()

    -- HACK: to prevent intense stuttering during the first seconds due to obs mask recalc,
    -- make the game init the obstruction mask progressively after entering the map.
    --[[v.precalc = isMapName("labyrinth_pearlmine")
    
    if not v.precalc then
        entity_setProperty(me, EP_BLOCKER, true)
    end
    
    broadcastDelay(me)]]
end

function v.commonUpdate(me, dt)

    --[[if v.precalc then
        v.precalc = false
        for i = 1, 20 do
            -- still not perfect, but it does most of the costly calculations during the blank phase
            entity_update(me, FRAME_TIME)
        end
        v.countdownInitT = true
    end
    
    if v.countdownInitT and v.initT >= 0 then
        v.initT = v.initT - dt
        if v.initT <= 0 then
            entity_setProperty(me, EP_BLOCKER, true)
        end
    end]]
    
	entity_updateMovement(me, dt)
	
	if entity_checkSplash(me) then
	end
	if not entity_isUnderWater(me) then
		if not entity_isBeingPulled(me) then
			entity_setWeight(me, v.myWeight*2)
			entity_setMaxSpeedLerp(me, 5, 0.1)
		end
	else
		entity_setMaxSpeedLerp(me, 1, 0.1)
		entity_setWeight(me, v.myWeight)
	end
    
    if v.note >= 0 and entity_vely(me) > 50 and entity_getBoneLockEntity(v.n) == me then
        local m = dt * 450
        local addx = v.notex * m
        local addy = v.notey * m
        --debugLog(string.format("rock song add x: %.2f y: %.2f", addx, addy))
        entity_addVel(me, addx, addy)
    end
    
    -- HACK against continous hitSurface()
    local vel = entity_getVelLen(me)
    if vel > v.lastvel+10 or vel < 0.001 then
        v.lastvel = 0
    end
        
	
	
	if not entity_isBeingPulled(me) then
		if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0) then
			if avatar_isBursting() and avatar_isLockable() and entity_setBoneLock(v.n, me) then
				-- yay!
			else
				--[[
				local x, y = entity_getVectorToEntity(me, v.n, 1000)
				entity_addVel(n, x, y)
				]]--
			end
		end
	else
        v.lastvel = 0
		if entity_getBoneLockEntity(v.n) == me then
			avatar_fallOffWall()
		end
	end
	
	entity_handleShotCollisions(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function enterState(me)
end

function exitState(me)
end

function hitSurface(me)
    local vel = entity_getVelLen(me)
    
    if vel > 300 and vel > v.lastvel then
        v.lastvel = vel
        spawnParticleEffect("rockhit", entity_x(me), entity_y(me))
        entity_playSfx(me, "rockhit-big", nil, 1.5)
        --entity_playSfx(me, "rockhit", nil, 1.5)
        
        if vel > 700 and entity_getCollideRadius(me) > 40 then
            shakeCamera(5, 1)
        end
    end
end

function activate(me)
end

function songNote(me, note)
    v.note = note
    local x, y = getNoteVector(note, 1)
    v.notex, v.notey = vector_normalize(x, y)
    --debugLog("x: " .. x .. "  y: " .. y)
end

function songNoteDone(me, note, t)
    v.note = -1
    v.notex = 0
    v.notey = 0
end

function song(me, s)
end

function msg(me, s)
    if s == "rock_init_delay" and not v.sentInit then
        v.initT = v.initT + 0.1
    end
end