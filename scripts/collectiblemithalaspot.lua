if not v then v = {} end

-- song cave collectible

--dofile("scripts/include/collectibletemplate.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/collectibletemplate.lua"))

function init(me)
	v.commonInit(me, "Collectibles/mithalaspot", FLAG_COLLECTIBLE_MITHALASPOT)
end

function update(me, dt)
	v.commonUpdate(me, dt)
end

function enterState(me, state)
	v.commonEnterState(me, state)
	if entity_isState(me, STATE_COLLECTEDINHOUSE) then
		createEntity("MithalasUrn", "", entity_x(me), entity_y(me))
        entity_alpha(me, 0)
	end	
end

function exitState(me, state)
	v.commonExitState(me, state)
end
