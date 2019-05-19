-- ================================================================================================
-- based on SPOOTER (ICE  SCOOTER)
-- ================================================================================================

dofile("scripts/entities/entityinclude.lua")
-- specific
STATE_JUMP				= 1000
STATE_TRANSITION		= 1001

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

jumpDelay = 0
moveTimer = 0
rotateOffset = 0
hungry = true
fedTime = 0
eatTime = 0
eating = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"icekrinkut",						-- texture
	50,							-- health
	2,							-- manaballamount
	2,							-- exp
	10,							-- money
	40,							-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	256,							-- sprite width	
	256,							-- sprite height
	1,							-- particle "explosion" type, 0 = none
	1,							-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	
	entity_clampToSurface(me)
	entity_setWeight(me, 300)
	
	entity_setDeathParticleEffect(me, "PurpleExplode")
	
	entity_setSegs(me, 2, 16, 0.4, 0.4, -0.05, 0, 6, 1)
	
	esetv(me, EV_WALLOUT, 24)
	esetv(me, EV_ENTITYDIED, 1)
end

function startEating(me, krill)
	eating = krill
	hungry = false
	entity_setState(krill, STATE_WAIT)
	entity_scale(krill, 0, 0, 1.5)
	
	entity_scale(me, 2,2)
	entity_scale(me, 2,1, 1, -2, 2)	
end

function clearEating(me)
	entity_scale(me, 2,2)
	fedTime = 2
	eatTime = 0
	eating = 0
	hungry = false
end

-- warning: only called if EV_ENTITYDIED set to 1!
function entityDied(me, ent)
	if ent == eating then
		clearEating(me)
	end
end

function update(me, dt)
	if entity_getState(me)==STATE_IDLE then
		--, 24

		entity_rotateToSurfaceNormal(me, 0.1)

		if eating==0 then
			entity_moveAlongSurface(me, dt, 100, 6)
			moveTimer = moveTimer + dt
			if moveTimer > 30 then
				entity_switchSurfaceDirection(me)
				moveTimer = 0
			end	
	
			if not(entity_hasTarget(me)) then
				entity_findTarget(me, 1200)
			else
				if entity_isTargetInRange(me, 600) then
					jumpDelay = jumpDelay - dt
					if jumpDelay < 0 then
						jumpDelay = 3
						entity_setState(me, STATE_JUMP)
					end
				end
			end
		end
		
	elseif entity_getState(me)==STATE_JUMP then
		rotateOffset = rotateOffset + dt * 400
		if rotateOffset > 180 then
			rotateOffset = 180
		end
		entity_rotateToVel(me, 0.1, rotateOffset)
		entity_updateMovement(me, dt)
		
	elseif not(entity_isState(me, STATE_TRANSITION)) then
		entity_updateMovement(me, dt)
	end

	entity_touchAvatarDamage(me, 64, 2, 400)
	entity_handleShotCollisions(me)
end

function hitSurface(me)
	if entity_getState(me)==STATE_JUMP then
		t = egetvf(me, EV_CLAMPTRANSF)
		if entity_checkSurface(me, 6, STATE_TRANSITION, t) then
			entity_rotateToSurfaceNormal(me, 0)
			entity_scale(me, 1, 0.5)
			entity_scale(me, 1, 1, t)
			entity_setInternalOffset(me, 0, 64)
			entity_setInternalOffset(me, 0, 0, t)
		else
			nx,ny = getWallNormal(entity_getPosition(me))
			nx,ny = vector_setLength(nx, ny, 400)
			entity_addVel(me, nx, ny)
		end
		--[[
		if entity_isNearObstruction(me, 4, OBSCHECK_4DIR) then
			entity_clampToSurface(me)
			entity_setState(me, STATE_TRANSITION, 0.001)
		end
		]]--
	end
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
		entity_setMaxSpeed(me, 800)
	elseif entity_getState(me)==STATE_JUMP then
		rotateOffset = 0
		entity_applySurfaceNormalForce(me, 800)
		entity_adjustPositionBySurfaceNormal(me, 10)
	end
end

function exitState(me)
	if entity_getState(me)==STATE_TRANSITION then
		entity_setState(me, STATE_IDLE)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if entity_isState(me, STATE_IDLE) then
		entity_setState(me, STATE_JUMP)
	end
	return false
end
