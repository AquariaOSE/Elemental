if not v then v = {} end

-- song cave collectible

--dofile("scripts/include/collectibletemplate.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/collectibletemplate.lua"))

function init(me)
	v.commonInit(me, "Collectibles/upsidedownseed", FLAG_COLLECTIBLE_UPSIDEDOWNSEED)
end

function update(me, dt)
	v.commonUpdate(me, dt)
end

function enterState(me, state)
	v.commonEnterState(me, state)
	if entity_isState(me, STATE_COLLECTEDINHOUSE) then
		createEntity("UpsideDownJelly", "", entity_x(me)-20, entity_y(me)-350)
		createEntity("UpsideDownJelly", "", entity_x(me)+200, entity_y(me)+50)
	end	
end

function exitState(me, state)
	v.commonExitState(me, state)
end
