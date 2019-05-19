if not v then v = {} end

-- mithalas collectible: mithalan costume

--dofile("scripts/include/collectiblecostumetemplate.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/collectiblecostumetemplate.lua"))

function init(me)
	v.commonInit2(me, "Collectibles/mutant-costume", FLAG_COLLECTIBLE_MUTANTCOSTUME, "mutant")
end
