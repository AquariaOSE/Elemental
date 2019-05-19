if not v then v = {} end

local chargeIDOffset = 5000
function init(me)
	node_setCursorActivation(me, false)
	if getFlag(v.flag) > 0 then
		local charged = true
		local id = getFlag(v.flag)
		if id > chargeIDOffset then
			charged = false
			id = id - chargeIDOffset
		end
		--[[
		if getFlag(chargeFlag) == 0 then
			charged = false
		end
		]]--
		
		local orbHolder = getEntityByID(v.holderID)		
		local energyOrb = getEntityByID(id)
		if energyOrb ~=0 and orbHolder ~=0 then
			--debugLog(string.format("%s : setting orb to %d, %d", node_getName(me), entity_x(orbHolder), entity_y(orbHolder)))
			entity_setPosition(energyOrb, entity_x(orbHolder), entity_y(orbHolder))
			if charged then
				entity_setState(energyOrb, STATE_CHARGED)
			end
		end
		if charged then
			local door = getEntityByID(v.doorID)
			if door ~= 0 then
				entity_setState(door, STATE_OPENED)
			end
		end
	end
end

function activate(me)
	if getFlag(v.flag)==0 or getFlag(v.flag) >= chargeIDOffset then
		local energyOrb = node_getNearestEntity(me, "EnergyOrb")
		if energyOrb ~= 0 then
			if entity_isState(energyOrb, STATE_CHARGED) then
				debugLog("Saving orb in slot, charged")
				setFlag(v.flag, entity_getID(energyOrb))
				local door = getEntityByID(v.doorID)
				if door ~= 0 then
					entity_setState(door, STATE_OPEN)
				else
					debugLog("COULD NOT FIND DOOR")
				end
			else
				debugLog("Saving orb in slot, not charged")
				setFlag(v.flag, entity_getID(energyOrb)+chargeIDOffset)				
			end
		else
			debugLog("Could not find orb")
		end
	end
end

function update(me, dt)
end
