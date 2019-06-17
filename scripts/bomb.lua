--FG TODO

-- ================================================================================================
-- based on Merman Thin and mantis bomb
-- ================================================================================================

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

swimTime = 0
swimTimer = swimTime - swimTime/4
dirTimer = 0
dir = 0


attackDelay = 0
maxAttackDelay = 1

local STATE_HANG 	= 1000
local STATE_SWIM 	= 1001
local STATE_BURST = 1002
local STATE_WALL = 1003
local STATE_WALLBURST = 1004

burstDelay = 0
checkSurfaceDelay = 0

bloatTimer = 0

lastx = 0
lasty = 0

bloated = false

n = 0

timer = 0

flashing = false

pulled = false

function init(me)
	setupBasicEntity(me, 
	"mantis/bomb",					-- texture
	1,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	30,								-- collideRadius (only used if hit entities is on)
	STATE_BLOATED,						-- initState
	128,								-- sprite width	
	128,								-- sprite height
	-1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setTexture(me, "mantis/bomb")

	entity_rotate(me, 360, 1, -1)

	entity_setState(me, STATE_BLOATED)
	
	
	entity_setTarget(me, getNaija())

	
	
	entity_scale(me, 3, 3)
	
	entity_setBeautyFlip(me, false)
	
	esetv(me, EV_WALLOUT, 32)
	
	entity_setProperty(me, EP_MOVABLE, true)
	
	entity_setDamageTarget(me, DT_ENEMY_POISON, false)
end

function postInit(me)
	n = getNaija()
	entity_setTarget(me, n)
end

function explode(me)
	playSfx("mantis-bomb")
	entity_delete(me)
	shakeCamera(4, 1)
	
	maxa = 3.14 * 2
	a = 0
	while a < maxa do
		s= createShot("mantisbomb", me)
		shot_setAimVector(s, math.sin(a), math.cos(a))
		a = a + (3.14*2)/16.0
	end
end

function update(me, dt)
	amt = 800
	


	
	entity_updateCurrents(me, dt)
	
	if entity_isState(me, STATE_BLOATED) then
		dirTimer = dirTimer + dt
		if dirTimer > 2 then
			dirTimer = 0
			if dir > 0 then
				dir = 0
			else
				dir = 1
			end
		end
		spd = 200
		if dir > 0 then
			spd = -spd
		end
		entity_addVel(me, spd*dt, 0)
		entity_doEntityAvoidance(me, dt, 256, 0.1)
		entity_doCollisionAvoidance(me, dt, 6, 0.5)
			
	end




	

	

	
	if entity_isBeingPulled(me) then
		entity_setMaxSpeedLerp(me, 2, 0.1)
	else
		entity_setMaxSpeedLerp(me, 1, 0.1)
	end
	
	if not entity_isState(me, STATE_WALL) then		
		entity_doFriction(me, dt, 100)
		if entity_isBeingPulled(me) then
			--entity_flipToEntity(me, n)
			entity_doCollisionAvoidance(me, dt, 5, 0.5)
		else
			entity_flipToVel(me)
		end
		entity_updateMovement(me, dt)
	else
		-- on wall
		entity_moveAlongSurface(me, dt, 350, 6)
		entity_rotateToSurfaceNormal(me)
		--[[
		if entity_x(me) == lastx and entity_y(me) == lasty then
			entity_setState(me, STATE_WALLBURST)
		end
		]]--
	end

	if not entity_isState(me, STATE_WALL) then
		if attackDelay < maxAttackDelay then
			attackDelay = attackDelay + dt
		else
			if entity_isEntityInRange(me, entity_getTarget(me), 128) then
				entity_animate(me, string.format("attack%d", math.random(3)), 0, LAYER_UPPERBODY)
				attackDelay = 0
			end
		end
	end
	if not entity_isBeingPulled(me) then
		if entity_touchAvatarDamage(me, entity_getCollideRadius(me, 3), 3, 1000, 1) then
			explode(me)
			return
		end
	end
	
	entity_handleShotCollisions(me)	
	
	lastx = entity_x(me)
	lasty = entity_y(me)
	
	rangeNode = entity_getNearestNode(me, "KILLENTITY")
	if node_isPositionIn(rangeNode, entity_x(me), entity_y(me)) then
		entity_setState(me, STATE_DIE)
	end
	
	timer = timer + dt
	if timer > 5 and not flashing then
		flashing = true
		entity_color(me, 1, 1, 1)
		entity_color(me, 1, 0.0, 0.0, 0.1, -1, 1)
		entity_offset(me, -10, 0)
		entity_offset(me, 10, 0, 0.05, -1, 1)
	end
	if timer > 10 then
		explode(me)
		return
	end
	
end

function damage(me, attacker, bone, damageType, dmg)
	explode(me)
	shakeCamera(10, 2)
	return true
end

function enterState(me)
end

function exitState(me)
end

function hitSurface(me)
end

function dieNormal(me)
end
