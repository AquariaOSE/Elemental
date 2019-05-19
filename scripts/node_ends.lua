dofile("_mods/Elemental/scripts/flags.lua")

n = 0

function init(me)
	n = getNaija()
end

function update(me, dt)
	if node_isEntityIn(me, n) then
		setFlag(FLAG_ENDING, 1)
		loadMap("forest")
	end
end
