-- based on PET  DUMBO

dofile("scripts/entities/entityinclude.lua")

STATE_ATTACKPREP		= 1000
STATE_ATTACK			= 1001

lungeDelay = 0

spinDir = -1

rot = 0
shotDrop = 0

glow = 0

function init(me)
	setupBasicEntity(
	me,
	"",						-- texture
	4,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	4,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1,								-- updateCull -1: disabled, default: 4000
	1
	)
	
	entity_initSkeletal(me, "Cell10")
	
	entity_setDeathParticleEffect(me, "TinyBlueExplode")

	lungeDelay = 1.0
	
	entity_scale(me, 1, 1)
	
	rot = 0
	
	esetv(me, EV_LOOKAT, 0)
	esetv(me, EV_ENTITYDIED, 1)
	esetv(me, EV_TYPEID, EVT_PET)
	
	for i=DT_AVATAR,DT_AVATAR_END do
		entity_setDamageTarget(me, i, false)
	end
	
	--[[
	entity_color(me, 1, 1, 1)
	entity_color(me, 0.6, 0.6, 0.6, 0.5, -1, 1)
	]]--
	

	
	bone_setSegs(entity_getBoneByName(me, "Body"), 2, 16, 0.6, 0.6, -0.058, 0, 6, 1)
	
	entity_initEmitter(me, 0, "DumboGlow")
	entity_startEmitter(me, 0)
	
	entity_setDeathSound(me, "")
end

function postInit(me)
	n = getNaija()
end

function update(me, dt)
	if getPetPower()==1 then
		entity_setColor(me, 1, 0.5, 0.5, 0.1)
	else
		entity_setColor(me, 1, 1, 1, 1)
	end
	
	glow = createQuad("Naija/LightFormGlow", 13)
	quad_scale(glow, 5 + (getPetPower()*8), 5 + (getPetPower()*8))
	
	if not isInputEnabled() or not entity_isUnderWater(n) then
		entity_setPosition(me, entity_x(n), entity_y(n), 0.3)
		entity_alpha(me, 0, 0.1)
		entity_stopEmitter(me, 0)
		return
	else
		entity_alpha(me, 1, 0.1)
		entity_startEmitter(me, 0)
	end
	
	naijaUnder = entity_y(n) > getWaterLevel()
	if naijaUnder then
		if entity_y(me)-32 < getWaterLevel() then
			entity_setPosition(me, entity_x(me), getWaterLevel()+32)
		end
	else
		if entity_isState(me, STATE_FOLLOW) then
			entity_setPosition(me, entity_x(n), entity_y(n), 0.1)
		end
	end
	
	if entity_isState(me, STATE_FOLLOW) then
		
		rot = rot + dt*0.2
		if rot > 1 then
			rot = rot - 1
		end
		dist = 100
		t = 0
		x = 0
		y = 0
		if avatar_isRolling() then
			dist = 90
			spinDir = -avatar_getRollDirection()
			t = rot * 6.28
		else
			t = rot * 6.28
		end
		
		if not entity_isEntityInRange(me, n, 1024) then
			entity_setPosition(me, entity_getPosition(n))
		end
		
		a = t
		x = x + math.sin(a)*dist
		y = y + math.cos(a)*dist
		if naijaUnder then
			entity_setPosition(me, entity_x(n)+x, entity_y(n)+y, 0.6)
		end
		
		--entity_handleShotCollisions(me)
	end
	
	if glow ~= 0 then
		if entity_isInDarkness(me) then
			quad_alpha(glow, 1, 0.5)
		else
			quad_alpha(glow, 0, 0.5)
		end
	end
	
	quad_setPosition(glow, entity_getPosition(me))
	quad_delete(glow, 0.1)
	glow = 0
end

function entityDied(me, ent)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_FOLLOW) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_DEAD) then
		if glow ~= 0 then
			quad_delete(glow)
			glow = 0
		end
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function hitSurface(me)
end

function shiftWorlds(me, old, new)
end
