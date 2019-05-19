if not v then v = {} end

--dofile("scripts/include/nodecollectibletemplate.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/nodecollectibletemplate.lua"))

function init(me)
	v.commonInit(me, "CollectibleMithalanCostume", FLAG_COLLECTIBLE_MITHALANCOSTUME)
end

function update(me, dt)
end
