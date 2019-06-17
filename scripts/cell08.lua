-- ================================================================================================
-- Based on JELLYSHOCK
-- ================================================================================================

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.blupTimer = 0
v.dirTimer = 0
v.blupTime = 3.0


local STATE_SHOCK			= 1000

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================
v.sz = 1.0
v.dir = 0

local MOVE_STATE_UP = 0
local MOVE_STATE_DOWN = 1

v.moveState = 0
v.moveTimer = 0
v.velx = 0
v.waveDir = 1
v.waveTimer = 0
v.soundDelay = 0
v.shockDelay = 5

v.collisionSegs = 28

local function doIdleScale(me)	
	entity_scale(me, 1.0*sz, 0.75*sz, blupTime, -1, 1, 1)
end

function init(me)
	setupBasicEntity(
	me,
	"Cell08",						-- texture
	50,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	128,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	512,							-- sprite width	
	512,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000,							-- updateCull -1: disabled, default: 4000
	1
	)
	
	entity_setEntityType(me, ET_ENEMY)
	
	entity_setDeathParticleEffect(me, "Explode")
	
	--entity_initSkeletal(me, "Cell08")
	
	--entity_scale(me, 1, 1)

	entity_setState(me, STATE_IDLE)
	entity_setDropChance(me, 50)
	
	entity_scale(me, 0.75*v.sz, 1*v.sz)
	doIdleScale(me)
	
	entity_exertHairForce(me, 0, 400, 1)
	--entity_setWeight(me, 1000)	
	--entity_initStrands(me, 5, 16, 8, 15, 0.8, 0.8, 1)			
end

function update(me, dt)
	dt = dt * 1.5
    local n = getNaija()
	if true then
		if avatar_isBursting() or entity_getRiding(n)~=0 then
			local e = entity_getRiding(n)
			if entity_touchAvatarDamage(me, 128, 0, 400) then
				if e~=0 then
					local x,y = entity_getVectorToEntity(me, e)
					x,y = vector_setLength(x, y, 25)
					entity_addVel(e, x, y)
				end
				local len = 500
				local x,y = entity_getVectorToEntity(n, me)
				x,y = vector_setLength(x, y, len)
				entity_push(me, x, y, 0.01, len, 0)
				entity_sound(me, "JellyBlup", 800)
			end		
		else
			if entity_touchAvatarDamage(me, 128, 0, 1000) then		
				entity_sound(me, "JellyBlup", 800)
			end
		end
	end
	entity_handleShotCollisions(me)
	
	--[[
	if entity_collideHairVsCircle(me, n, v.collisionSegs) then
		entity_touchAvatarDamage(me, 0, 0, 800)
	end
	]]--
	
	v.moveTimer = v.moveTimer - dt
	if v.moveTimer < 0 then
		if v.moveState == MOVE_STATE_DOWN then		
			v.moveState = MOVE_STATE_UP
			entity_setMaxSpeedLerp(me, 1.5, 0.2)
			entity_scale(me, 0.75, 1, 1, 1, 1)
			v.moveTimer = 3 + math.random(200)/100.0
			entity_sound(me, "JellyBlup")
		elseif v.moveState == MOVE_STATE_UP then
			v.velx = math.random(400)+100
			if math.random(2) == 1 then
				v.velx = -v.velx
			end
			v.moveState = MOVE_STATE_DOWN
			doIdleScale(me)
			entity_setMaxSpeedLerp(me, 1, 1)
			v.moveTimer = 5 + math.random(200)/100.0 + math.random(3)
		end
	end
	
	v.waveTimer = v.waveTimer + dt
	if v.waveTimer > 2 then
		v.waveTimer = 0
		if v.waveDir == 1 then
			v.waveDir = -1
		else
			v.waveDir = 1
		end
	end
	
	
	--entity_exertHairForce(me, entity_velx(me), entity_vely(me), dt, -1)
	
	if moveState == MOVE_STATE_UP then
		entity_addVel(me, v.velx*dt, -600*dt)
		entity_rotateToVel(me, 1)
		--entity_exertHairForce(me, waveTimer*5*waveDir, 0, dt)	
		--entity_exertHairForce(me, 0, 10, dt)
		--entity_exertHairForce(me, waveTimer*50*waveDir, waveTimer*50, dt)	
	elseif moveState == MOVE_STATE_DOWN then
		entity_addVel(me, 0, 50*dt)
		entity_rotateTo(me, 0, 3)
		--entity_exertHairForce(me, waveTimer*50*waveDir, 400, dt)
		entity_exertHairForce(me, 0, 200, dt*0.6, -1)
		--entity_exertHairForce(me, waveTimer*25*waveDir, 0, dt)
		--entity_exertHairForce(me, waveTimer*50*waveDir, 0, dt)
	end
	

	
	
	entity_doEntityAvoidance(me, dt, 32, 1.0)
	entity_doCollisionAvoidance(me, 1.0, 8, 1.0)
	
	if not entity_isState(me, STATE_SHOCK) then
		entity_updateMovement(me, dt)
	end
	
	entity_setHairHeadPosition(me, entity_getPosition(me))
	entity_updateHair(me, dt)

	v.shockDelay = v.shockDelay - dt
	if v.shockDelay < 0 then
		v.shockDelay = 10 + math.random(5)
		entity_setState(me, STATE_SHOCK, 0.5)
	end
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setMaxSpeed(me, 50)
		--entity_animate(me, "idle", LOOP_INF)
	elseif entity_isState(me, STATE_SHOCK) then
		entity_sound(me, "EnergyOrbCharge")
		spawnParticleEffect("JellyShock", entity_getPosition(me))
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function exitState(me)
	if entity_isState(me, STATE_SHOCK) then
		entity_touchAvatarDamage(me, 170, 1, 800)
	end
end

function dieNormal(me)
	if chance(100) then
		spawnIngredient("SpicyMeat", entity_getPosition(me))
	end
end
