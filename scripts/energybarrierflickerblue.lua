-- energy barrier flickering
dofile("_mods/Elemental/scripts/energybarrierblue.lua")

function init(me)
	commonInit(me)
	entity_setState(me, STATE_FLICKER)
end