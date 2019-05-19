if not v then v = {} end

-- energy temple collectible: energy temple costume

--dofile("scripts/include/collectiblecostumetemplate.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/collectiblecostumetemplate.lua"))

function init(me)
	v.commonInit2(me, "Collectibles/EnergyTemple", FLAG_COLLECTIBLE_ENERGYTEMPLE, "ETC")
end
