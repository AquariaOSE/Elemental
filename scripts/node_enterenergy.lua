dofile(appendUserDataPath("_mods/Elemental/scripts/flags.lua"))

n = 0

function init(me)
	n = getNaija()
end

function update(me, dt)
	if isFlag(ENTER_ENERGY, 0) and node_isEntityIn(me, n) then
		setFlag(ENTER_ENERGY, 1)
		centerText("Energy Element")
	end
end