if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.openTimer = 8

function v.commonInit(me, gfx)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_setName(me, "SporeChildFlower")
	entity_initSkeletal(me, gfx)
	entity_setState(me, STATE_IDLE)
	--entity_setDamageTarget(me, DT_AVATAR_NATURE, true)
	entity_setAllDamageTargets(me, false)
	--entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
	entity_setDamageTarget(me, DT_AVATAR_NATURE, true)
	entity_setCullRadius(me, 1024)
end

function postInit(me)
end

function v.commonUpdate(me, dt)
	if entity_isState(me, STATE_OPEN) and not entity_isAnimating(me) then
		entity_setState(me, STATE_OPENED)
	end
	if entity_isState(me, STATE_CLOSE) and not entity_isAnimating(me) then
		entity_setState(me, STATE_CLOSED)
	end	
	if entity_isState(me, STATE_IDLE) or entity_isState(me, STATE_CLOSED) then
		local ent = getFirstEntity()
		while ent~=0 do
			if entity_getAnimationName(ent)=="openFlower" then
				if entity_isEntityInRange(me, ent, 128) then
					v.openTimer = v.openTimer - dt
				end
			end
			ent = getNextEntity()
		end
		if v.openTimer < 0 then
			entity_setState(me, STATE_OPEN)
		end
	end
end

function songNote(me, note)
--[[
	if entity_isState(me, STATE_IDLE) then
		entity_setState(me, STATE_OPEN)
	end
]]--
end

function sporesDropped(me, x, y)
	if entity_isState(me, STATE_IDLE) or entity_isState(me, STATE_CLOSED) then
		if entity_isPositionInRange(me, x, y, 128) then
			entity_setState(me, STATE_OPEN)
		end
	end
end

function damage(me, attacker, bone, damageType, dmg)
--[[
	if damageType == DT_AVATAR_NATURE then
		if entity_isState(me, STATE_IDLE) then
			entity_setState(me, STATE_OPEN)
		end
		return false
	end
	]]--
	return false
end

function songNoteDone(me, note, len)
end

function v.commonEnterState(me, state)
	if entity_isState(me, STATE_OPEN) then
		playSfx("plant-open")
		entity_animate(me, "open")
	elseif entity_isState(me, STATE_CLOSE) then
		entity_animate(me, "close")		
	end
end

function exitState(me, state)
end

