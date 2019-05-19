if not v then v = {} end

--dofile("scripts/include/nodecollectibletemplate.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/nodecollectibletemplate.lua"))

function init(me)
	v.commonInit(me, "CollectibleUrchinCostume", FLAG_COLLECTIBLE_URCHINCOSTUME)
end

function update(me, dt)
end
