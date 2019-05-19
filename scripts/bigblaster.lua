--FG TODO

-- ================================================================================================
-- B L A S T E R
-- ================================================================================================

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

-- entity specific
STATE_FIRE				= 1000
STATE_PULLBACK			= 1001
STATE_WAITING			= 1002
fireDelay = 0
motherChance = 10
soundDelay = 0

shotsFired = 0
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	100,							-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	48,								-- collideRadius (only used if hit entities is on)
	STATE_WAITING,					-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	2000							-- updateCull -1: disabled, default: 4000
	)
		
	entity_initSkeletal(me, "BigBlaster")
	entity_animate(me, "idle", -1)
		
	entity_setDeathParticleEffect(me, "Explode")
	
	entity_scale(me, 1.2, 1.2)
	
	soundDelay = math.random(3)+1
	
	entity_setEatType(me, EAT_FILE, "Blaster")
	
	entity_setDeathScene(me, true)
	loadSound("BossDieSmall")
	loadSound("BossDieBig")
	loadSound("BigBlasterRoar")
	loadSound("BigBlasterLaugh")
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function update(me, dt)

	if entity_isState(me, STATE_WAITING) then
		if entity_isEntityInRange(me, getNaija(), 2000) then
			playSfx("BigBlasterLaugh")
			shakeCamera(2, 3)
			entity_setState(me, STATE_IDLE)
		end
		return
	end
	
	if true then
		if entity_hasTarget(me) then
			if entity_isTargetInRange(me, 200) then
				entity_moveTowardsTarget(me, dt, -200)
			end
			if entity_isTargetInRange(me, 64) then
	--			entity_hurtTarget(1);
				entity_moveTowardsTarget(me, dt, -1000)
			end
		end
		
		if fireDelay > 0 then
			fireDelay = fireDelay - dt
			if fireDelay < 0 then
				fireDelay = 0
			end
		end
		
		if entity_getState(me)==STATE_IDLE then
			if not entity_hasTarget(me) then
				entity_findTarget(me, 1000)
			else
				if entity_isTargetInRange(me, 1600) then				
					entity_moveTowardsTarget(me, dt, 400)		-- move in if we're too far away
					if entity_isTargetInRange(me, 350) and fireDelay==0 then
						entity_setState(me, STATE_FIRE)
					end
				end
							
			end
			soundDelay = soundDelay - dt 
			if soundDelay < 0 then
				entity_playSfx(me, "BlasterIdle")
				soundDelay = math.random(3)+1
			end
		end
		if entity_getState(me)==STATE_FIRE then
			entity_moveTowardsTarget(me, dt, -600)
		end
		if entity_getState(me)==STATE_PULLBACK then
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
	end
	entity_doEntityAvoidance(me, dt, 256, 0.2)
--	entity_doSpellAvoidance(dt, 200, 1.5);
	entity_doCollisionAvoidance(me, dt, 6, 0.5)
	entity_rotateToVel(me, 0.1)
	entity_updateCurrents(me, dt)
	entity_updateMovement(me, dt)
	
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, 32, 0, 1000)
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		fireDelay = 1
		entity_setMaxSpeed(me, 600)
	elseif entity_getState(me)==STATE_FIRE then
		entity_setStateTime(me, 0.2)
		entity_setMaxSpeed(me, 800)
		s = createShot("BigBlasterFire", me, entity_getTarget(me))
		shot_setOut(s, 32)
	elseif entity_getState(me)==STATE_PULLBACK then
		if chance(50) then
			shakeCamera(2, 3)
			playSfx("BigBlasterRoar")
		end
		entity_setMaxSpeed(me, 900)
	elseif entity_isState(me, STATE_DEATHSCENE) then
		clearShots()
		entity_setStateTime(me, 99)
		entity_setInvincible(n, true)
		entity_idle(n)
		
		cam_toEntity(me)
		entity_setInternalOffset(me, 0, 0)
		entity_setInternalOffset(me, 0, 10, 0.1, -1)
		playSfx("BossDieSmall")
		entity_idle(n)
		fade(1, 0.5, 1, 1, 1)
		watch(0.5)
		fade(0, 1, 1, 1, 1)
		watch(0.5)
		playSfx("BigBlasterLaugh")
		watch(0.7)
		entity_color(me, 1, 0, 0, 2)
		watch(1.0)
		playSfx("BigBlasterRoar")
		watch(0.5)
		playSfx("BossDieBig")
		fade(1, 0.2, 1, 1, 1)
		watch(0.2)
		watch(0.5)
		fade(0, 1, 1, 1, 1)
		debugLog(string.format("node(%d, %d", node_x(node), node_y(node)))
		cam_toEntity(e)
		watch(3)
		cam_toEntity(getNaija())
		entity_setState(me, STATE_DEAD, -1, 1)
	end
end

function exitState(me)
	if entity_getState(me)==STATE_FIRE then
		shotsFired = shotsFired + 1
		if shotsFired < 8 then
			entity_setState(me, STATE_FIRE)
		else
			entity_setState(me, STATE_PULLBACK, 1)
		end
		
	elseif entity_getState(me)==STATE_PULLBACK then
		shotsFired = 0
		entity_setState(me, STATE_IDLE)
	end
end

function hitSurface(me)
end

function activate(me)
	msg1("Naija: Pet!")
	entity_setBehaviorType(me, BT_ACTIVEPET)
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		entity_changeHealth(me, -99)
	end
	return true
end

function dieNormal(me)
	if chance(100) then
		spawnIngredient("VolcanoRoll", entity_x(me), entity_y(me))
	end
end
