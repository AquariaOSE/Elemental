if not v then v = {} end

-- song cave collectible

--dofile("scripts/include/collectibletemplate.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/collectibletemplate.lua"))

function init(me)
	v.commonInit(me, "Collectibles/mithalas-banner", FLAG_COLLECTIBLE_BANNER)
end

function update(me, dt)
	v.commonUpdate(me, dt)
end

function enterState(me, state)
	v.commonEnterState(me, state)
	if entity_isState(me, STATE_COLLECTEDINHOUSE) then
		--[[
		createEntity("JellySmall", "", node_x(me)-64, node_y(me))
		createEntity("JellySmall", "", node_x(me)+64, node_y(me))
		createEntity("JellySmall", "", node_x(me), node_y(me)+32)
		]]--
	end	
end

function exitState(me, state)
	v.commonExitState(me, state)
end
