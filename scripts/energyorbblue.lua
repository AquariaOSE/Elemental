-- ================================================================================================
-- based on ENERGY ORB
-- ================================================================================================

dofile("scripts/entities/entityinclude.lua")
charge = 0
delay = 1

-- REMEMBER TO UPDATE ENERGYORBCRACKED WHEN CHANGING THIS FILE!
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupEntity(me, "EnergyOrbBlue")
	--entity_setProperty(me, EP_SOLID, true)
	entity_setDamageTarget(me, DT_AVATAR_FROSTBLAST, false)
	entity_setProperty(me, EP_MOVABLE, true)
	entity_setWeight(me, 200)
	entity_setCollideRadius(me, 32)
	entity_setAffectedBySpells(me, 1)
	entity_setName(me, "EnergyOrbBlue")
	
	entity_setMaxSpeed(me, 450)
	--entity_setMaxSpeed(me, 600)
	
	entity_setEntityType(me, ET_ENEMY)
	
	entity_setAllDamageTargets(me, false)
	entity_setDamageTarget(me, DT_AVATAR_FROSTBLAST, true)
	entity_setDamageTarget(me, DT_AVATAR_FROSTSHOCK, true)
	
	--entity_setBounceType(me, BOUNCE_REAL)
	--entity_setProperty(me, EP_BATTERY, true)
end

function update(me, dt)
	--if not entity_isState(me, STATE_CHARGED) then
	entity_handleShotCollisions(me)
	--end
	
	--[[
	if not entity_isState(me, STATE_INHOLDER) then
		entity_updateMovement(me, dt)
	end
	]]--
	entity_updateMovement(me, dt)
	entity_updateCurrents(me)
	
	if not entity_isState(me, STATE_CHARGED) then
		delay = delay - dt
		if delay < 0 then
			delay = 0.5
			charge = charge - 1
			if charge < 0 then
				charge = 0
			end
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_CHARGED) then
		debugLog("state charged!")
		entity_setTexture(me, "EnergyOrb-Charged")
		entity_setDamageTarget(me, DT_AVATAR_FROSTBLAST, false)
		entity_setDamageTarget(me, DT_AVATAR_FROSTSHOCK, false)
		--msg("CHARGED")
	elseif entity_isState(me, STATE_INHOLDER) then
		entity_setWeight(me, 0)
		entity_clearVel(me)
	end
end

function exitState(me)
end

function hitSurface(me)
	--entity_sound(me, "rock-hit")
end

function damage(me, attacker, bone, damageType, dmg)	
	if not entity_isState(me, STATE_CHARGED) then
		if damageType == DT_AVATAR_FROSTBLAST then
			--charge = charge + dmg
		elseif damageType == DT_AVATAR_FROSTSHOCK then
			charge = charge + 10
		end
		if charge >= 10 then
			playSfx("EnergyOrbCharge")
			spawnParticleEffect("EnergyOrbCharge", entity_x(me), entity_y(me))
			entity_setState(me, STATE_CHARGED)
		end
	end
	return false
end

function activate(me)
end
