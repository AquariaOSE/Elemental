dofile(appendUserDataPath("_mods/Elemental/scripts/flags.lua"))

n = 0

function init(me)
	n = getNaija()
end

function update(me, dt)
	if isFlag(ENTER_AIR, 0) and node_isEntityIn(me, n) then
		setFlag(ENTER_AIR, 1)
		centerText("Air Element")
	end
end