-- ================================================================================================
-- based on FireKrinkut and BLASTER
-- ================================================================================================

dofile("scripts/entities/entityinclude.lua")

-- entity specific
STATE_FIRE				= 1000
STATE_PULLBACK			= 1001
fireDelay = 0
motherChance = 10
soundDelay = 0
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"Cell04",								-- texture
	4,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	32,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	2000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setEatType(me, EAT_FILE, "Cell04")		
	entity_setDeathParticleEffect(me, "TinyGreenExplode")
end

function update(me, dt)
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, 32, 0, 1000)
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
						entity_setState(me, STATE_FIRE, 0.5)
					end
				end
							
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
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		fireDelay = 2
		entity_setMaxSpeed(me, 500)
	elseif entity_getState(me)==STATE_FIRE then
		entity_setMaxSpeed(me, 600)
		s = createShot("infpoison", me, entity_getTarget(me))
		shot_setOut(s, 32)
	elseif entity_getState(me)==STATE_PULLBACK then
		if chance(50) then
		end
		entity_setMaxSpeed(me, 650)
	end
end

function exitState(me)
	if entity_getState(me)==STATE_FIRE then
		entity_setState(me, STATE_PULLBACK, 1)
	elseif entity_getState(me)==STATE_PULLBACK then
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
			else
		if damageType == DT_ENEMY_POISON then
		return false
		end
	end
	return true
end
	
function dieNormal(me)
	if chance(50) then
		spawnIngredient("RottenMeat", entity_x(me), entity_y(me))
			else
		if chance(25) then
			spawnIngredient("RottenLoaf", entity_x(me), entity_y(me))
				else
			if chance(50) then			
				spawnIngredient("PoisonLoaf", entity_x(me), entity_y(me))	
					else
				if chance(100) then			
					spawnIngredient("RottenCake", entity_x(me), entity_y(me))	
				end
			end
		end
	end
end
