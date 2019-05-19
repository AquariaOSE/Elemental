if not v then v = {} end

-- energy temple collectible: energy temple costume

--dofile("scripts/include/collectiblecostumetemplate.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/collectiblecostumetemplate.lua"))

function init(me)
	v.commonInit2(me, "Collectibles/seahorse-costume", FLAG_COLLECTIBLE_SEAHORSECOSTUME, "seahorse")
end
