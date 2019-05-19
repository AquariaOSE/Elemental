if not v then v = {} end

--dofile("scripts/include/nodecollectibletemplate.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/nodecollectibletemplate.lua"))

function init(me)
	
end

function update(me, dt)
	v.commonUpdate(me, "CollectibleStarfish", FLAG_COLLECTIBLE_STARFISH)
end
