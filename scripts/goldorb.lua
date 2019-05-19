--FG TODO

-- ================================================================================================
-- based on ENERGY ORB
-- ================================================================================================

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.map = "airflip"

charge = 0
delay = 1

-- REMEMBER TO UPDATE ENERGYORBCRACKED WHEN CHANGING THIS FILE!
 
-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupEntity(me, "goldorb")
	--entity_setProperty(me, EP_SOLID, true)
	entity_setProperty(me, EP_MOVABLE, true)
	entity_setWeight(me, 200)
	entity_setCollideRadius(me, 32)
	entity_setAffectedBySpells(me, 1)
	
	entity_setMaxSpeed(me, 450)
	--entity_setMaxSpeed(me, 600)
	
	entity_setEntityType(me, ET_ENEMY)
	
	entity_setAllDamageTargets(me, false)
	entity_setDamageTarget(me, DT_AVATAR_VINE, true)
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, true)
	entity_setDamageTarget(me, DT_AVATAR_SHOCK, true)
	
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
		entity_setDamageTarget(me, DT_AVATAR_VINE, false)
		entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
		entity_setDamageTarget(me, DT_AVATAR_SHOCK, false)
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
		if damageType == DT_AVATAR_VINE or damageType == DT_AVATAR_ENERGYBLAST or damageType == DT_AVATAR_SHOCK  then
			loadMap("Airflip")
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
