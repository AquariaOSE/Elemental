if not v then v = {} end

-- song cave collectible

--dofile("scripts/include/collectibletemplate.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/collectibletemplate.lua"))

function init(me)
	v.commonInit(me, "Collectibles/bio-seed", FLAG_COLLECTIBLE_BIOSEED)
end

function update(me, dt)
	v.commonUpdate(me, dt)
end

function enterState(me, state)
	v.commonEnterState(me, state)
	if entity_isState(me, STATE_COLLECTEDINHOUSE) then
		local ent
		ent = createEntity("BioPlant", "", entity_x(me)-150, entity_y(me)-100)
		entity_rotate(ent, entity_getRotation(ent)-10)
		ent = createEntity("BioPlant", "", entity_x(me)+25, entity_y(me)-120)
		entity_rotate(ent, entity_getRotation(ent)+15)
		ent = createEntity("BioPlant", "", entity_x(me)+125, entity_y(me)-105)
		entity_rotate(ent, entity_getRotation(ent)+8)
	end	
end

function exitState(me, state)
	v.commonExitState(me, state)
end
