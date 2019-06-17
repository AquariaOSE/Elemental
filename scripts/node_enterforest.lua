dofile(appendUserDataPath("_mods/Elemental/scripts/flags.lua"))

function init(me)
end

function update(me, dt)
	if isFlag(ENTER_FOREST, 0) and node_isEntityIn(me, getNaija()) then
		setFlag(ENTER_FOREST, 1)
		centerText("Forest Element")
	end
end
