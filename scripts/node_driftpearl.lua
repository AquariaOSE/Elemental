if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))

function init(me)
end

function update(me, dt)

	--Display once if Naija enters
	if isFlag(DRIFT_PEARL, 0) and node_isEntityIn(me, getNaija()) then
		setFlag(DRIFT_PEARL, 1)
		setControlHint("Perhaps I'll even find more of the drift pearl Li likes to carve.", 0, 0, 0, 12)
	end 

end
