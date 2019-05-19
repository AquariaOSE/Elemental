-- ================================================================================================
-- based on FROOG
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
flyTimer = 0
moveTowardsTimer = 0
y_range = 200
fudge = 40
soundDelay = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	3,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	40,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	
	entity_initSkeletal(me, "Froog")
	
	entity_setDeathParticleEffect(me, "TinyGreenExplode")

	entity_scale(me, 0.5, 0.5)
	entity_clampToSurface(me)
	entity_setState(me, STATE_IDLE)
	entity_setDropChance(me, 25)
	--entity_setBounce(0)
	esetv(me, EV_WALLOUT, 24)
	
	loadSound("FroogFlap")
end

function isInLine(me)
	if (entity_getRotation(me) >= -45 and entity_getRotation(me) <= 45) or
	(entity_getRotation(me) >= 135 and entity_getRotation(me) <= 225) then
		if entity_x(entity_getTarget(me)) > entity_x(me)-y_range/2 and entity_x(entity_getTarget(me)) < entity_x(me)+y_range/2 then
			return true
		end
	else
		if entity_y(entity_getTarget(me)) > entity_y(me)-y_range/2 and entity_y(entity_getTarget(me)) < entity_y(me)+y_range/2 then
			return true
		end
	end
	return false
end

function update(me, dt)
	entity_handleShotCollisions(me)
	entity_touchAvatarDamage(me, 32, -1, 1000)
	
	--[[
	if entity_hasTarget(me) then
		if entity_isTargetInRange(me, 64) then
			entity_hurtTarget(me, 1)
			entity_pushTarget(me, 500)
		end
	end
	]]--
	if jumpDelay > 0 then
		jumpDelay = jumpDelay - dt
		if jumpDelay < 0 then
			jumpDelay = 0
		end
	end
	if entity_getState(me)==STATE_IDLE then
		entity_rotateToSurfaceNormal(me, 0.1)
		entity_moveAlongSurface(me, dt, 0, 6, 24)
	--[[
		entity_moveAlongSurface(me, dt, 100, 6, 24)
		entity_rotateToSurfaceNormal(me, 0.1)
		moveTimer = moveTimer + dt
		if moveTimer > 30 then
			entity_switchSurfaceDirection(me)
			moveTimer = 0
		end
		]]--
		if not(entity_hasTarget(me)) then
			entity_findTarget(me, 2000)
		else
			if entity_isTargetInRange(me, 900) and isInLine(me) then
			--[[and entity_y(entity_getTarget(me)) > entity_y(me)-y_range/2
			and entity_y(entity_getTarget(me)) < entity_y(me)+y_range/2 then]]--
				--if trace(entity_x(me), entity_y(me), 5) then
					if jumpDelay == 0 then
						jumpDelay = 1.5
						entity_setState(me, STATE_JUMP)
					end
				--end
				--end
			end
		end
	elseif entity_getState(me)==STATE_JUMP then
		soundDelay = soundDelay + dt
		if soundDelay >= 0.5 then
			entity_playSfx(me, "FroogFlap")
			soundDelay = 0
		end

		if flyTimer > 0 then
			flyTimer = flyTimer - dt
			if flyTimer < 0 then
				flyTimer = 0
			end
		end
		rotateOffset = rotateOffset + dt * 400
		if rotateOffset > 180 then
			rotateOffset = 180
		end
		--[[
		if entity_hasTarget(me) then
			if moveTowardsTimer > 0 then
				moveTowardsTimer = moveTowardsTimer - dt
				if moveTowardsTimer < 0 then
					moveTowardsTimer = 0
				end
				entity_moveTowardsTarget(me, dt, 20000)
			end
		end
		]]--
		entity_rotateToVel(me, 0.1)
		--entity_rotateToVel(me, 0.1, rotateOffset)
		entity_updateMovement(me, dt)
--		entity_applySurfaceNormalForce(1000)
		
	elseif not(entity_getState(me)==STATE_TRANSITION) then
		entity_updateMovement(me, dt)
	end
end

function hitSurface(me)
	if entity_isState(me, STATE_JUMP) then
		--and flyTimer==0
		--msg1("hitsurface!")
		--entity_adjustPositionBySurfaceNormal(me, fudge)
		entity_clampToSurface(me, 0.1) -- (0.1)
		--entity_setState(STATE_IDLE)
		entity_setState(me, STATE_TRANSITION, 0.1)		
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setMaxSpeed(me, 900)
		entity_animate(me, "idle", LOOP_INF)
	elseif entity_isState(me, STATE_JUMP) then
		soundDelay = 999
		t = entity_getTarget(me)
		if t ~= 0 then
			entity_moveTowardsTarget(me, 1, 2000)
			amp = 1.5
			entity_addVel(me, entity_velx(entity_getTarget(me))*amp, entity_vely(entity_getTarget(me))*amp)
		end
		moveTowardsTimer = 0
		rotateOffset = 0
		flyTimer = 6
		entity_applySurfaceNormalForce(me, 800)
		--entity_adjustPositionBySurfaceNormal(me, 64)
		entity_adjustPositionBySurfaceNormal(me, fudge)
		entity_animate(me, "swim", LOOP_INF)
	end
end

function hit(me, attacker, bone, spellType, dmg)
	if entity_isState(me, STATE_IDLE) then
		entity_setState(me, STATE_JUMP)
	end
	return true
end

function exitState(me)
	if entity_isState(me, STATE_TRANSITION) then
		entity_setState(me, STATE_IDLE)
	end
end
