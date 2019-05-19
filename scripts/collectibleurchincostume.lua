if not v then v = {} end

-- veil collectible: urchin costume

--dofile("scripts/include/collectiblecostumetemplate.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/collectiblecostumetemplate.lua"))

function init(me)
	v.commonInit2(me, "Collectibles/urchin-costume", FLAG_COLLECTIBLE_URCHINCOSTUME, "URCHIN")
end
