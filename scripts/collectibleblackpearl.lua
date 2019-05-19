if not v then v = {} end

-- song cave collectible

--dofile("scripts/include/collectibletemplate.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/collectibletemplate.lua"))

function init(me)
	v.commonInit(me, "Collectibles/blackpearl", FLAG_COLLECTIBLE_BLACKPEARL)
end

function update(me, dt)
	v.commonUpdate(me, dt)
end

function enterState(me, state)
	v.commonEnterState(me, state)
	if entity_isState(me, STATE_COLLECTEDINHOUSE) then
		local ent
		ent = createEntity("Clam", "", entity_x(me)+200, entity_y(me)-150)
		entity_rotate(ent, entity_getRotation(ent)-18)
	end	
end

function exitState(me, state)
	v.commonExitState(me, state)
end
