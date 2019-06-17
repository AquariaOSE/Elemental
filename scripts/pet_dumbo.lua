-- based on PET  DUMBO

dofile("scripts/entities/entityinclude.lua")

local STATE_ATTACKPREP		= 1000
local STATE_ATTACK			= 1001

v.rot = 0
v.glow = 0

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

	entity_scale(me, 1, 1)
	
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
	v.n = getNaija()
	v.glow = createQuad("Naija/LightFormGlow", 13)
end

function update(me, dt)
	if getPetPower()==1 then
		entity_setColor(me, 1, 0.5, 0.5, 0.1)
	else
		entity_setColor(me, 1, 1, 1, 1)
	end
	
	quad_scale(v.glow, 5 + (getPetPower()*8), 5 + (getPetPower()*8))
	
	if not isInputEnabled() or not entity_isUnderWater(v.n) then
		entity_setPosition(me, entity_x(v.n), entity_y(v.n), 0.3)
		entity_alpha(me, 0, 0.1)
		entity_stopEmitter(me, 0)
		return
	else
		entity_alpha(me, 1, 0.1)
		entity_startEmitter(me, 0)
	end
	
	local naijaUnder = entity_y(v.n) > getWaterLevel()
	if naijaUnder then
		if entity_y(me)-32 < getWaterLevel() then
			entity_setPosition(me, entity_x(me), getWaterLevel()+32)
		end
	else
		if entity_isState(me, STATE_FOLLOW) then
            local nx, ny = entity_getPosition(v.n)
			entity_setPosition(me, nx, ny, 0.1)
		end
	end
	
	if entity_isState(me, STATE_FOLLOW) then
		
		v.rot = v.rot + dt*0.2
		if v.rot > 1 then
			v.rot = v.rot - 1
		end
		local dist = 100
		local t = v.rot * 6.28
        
		if avatar_isRolling() then
			dist = 90
		end
		
		if not entity_isEntityInRange(me, v.n, 1024) then
			entity_setPosition(me, entity_getPosition(n))
		end
		
		if naijaUnder then
            local nx, ny = entity_getPosition(v.n)
			entity_setPosition(me, nx + math.sin(t)*dist, ny + math.cos(t)*dist, 0.6)
		end
		
		--entity_handleShotCollisions(me)
	end
	
	if v.glow ~= 0 then
		if entity_isInDarkness(me) then
			quad_alpha(v.glow, 1, 0.5)
		else
			quad_alpha(v.glow, 0, 0.5)
		end
        quad_setPosition(v.glow, entity_getPosition(me))
	end
end

function entityDied(me, ent)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_FOLLOW) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_DEAD) then
		if v.glow ~= 0 then
			quad_delete(v.glow)
			v.glow = 0
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
