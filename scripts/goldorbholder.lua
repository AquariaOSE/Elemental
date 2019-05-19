--FG TODO

-- orb holder
if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

energyOrb = 0
openedDoors = false
savedOrb = false

function init(me)
	setupEntity(me, "orbHolder", -2)
	entity_setActivationType(me, AT_NONE)	
end

function update(me, dt)
	if entity_getState(me)==STATE_IDLE then
		if energyOrb == 0 then
			orb = entity_getNearestEntity(me, "goldorb") or entity_getNearestEntity(me, "goldorbflip")
			if orb ~=0 then
				if entity_isEntityInRange(me, orb, 64) then					
					entity_setWeight(orb, 0)
					entity_clearVel(orb)					
					energyOrb = orb
					entity_setProperty(orb, EP_MOVABLE, false)
				end
			end
		else
			entity_clearVel(energyOrb)
			entity_setPosition(energyOrb, entity_x(me), entity_y(me))
			if not openedDoors and entity_isState(goldorb, STATE_CHARGED) or entity_isState(goldorbflip, STATE_CHARGED) then
				openedDoors = true
				node = entity_getNearestNode(me)
				node_activate(node)
			end
			if not savedOrb and entity_isState(goldorb, STATE_IDLE) or entity_isState(goldorbflip, STATE_IDLE) then
				node = entity_getNearestNode(me)
				node_activate(node)
				savedOrb = true
			end
			if openedDoors and entity_isState(goldorb, STATE_IDLE) or entity_isState(goldorbflip, STATE_IDLE) then
				openedDoors = false
			end
		end
	end
end

function enterState(me)
	if entity_getState(me)==STATE_IDLE then
	end
end

function exitState(me)
end

function hitSurface(me)
end
