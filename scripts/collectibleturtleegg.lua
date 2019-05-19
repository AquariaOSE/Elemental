if not v then v = {} end

-- song cave collectible

--dofile("scripts/include/collectibletemplate.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/collectibletemplate.lua"))

function init(me)
	v.commonInit(me, "Collectibles/turtle-egg", FLAG_COLLECTIBLE_TURTLEEGG)
end

function update(me, dt)
	v.commonUpdate(me, dt)
end

function enterState(me, state)
	v.commonEnterState(me, state)
	if entity_isState(me, STATE_COLLECTEDINHOUSE) then
		createEntity("SeaTurtleBaby", "", entity_x(me)-100, entity_y(me)-50)
		createEntity("SeaTurtleBaby", "", entity_x(me)-50, entity_y(me)-100)
	end	
end

function exitState(me, state)
	v.commonExitState(me, state)
end
