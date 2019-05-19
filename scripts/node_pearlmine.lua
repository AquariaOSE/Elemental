if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))

v.n = 0

function init(me)
	v.n = getNaija()
end


function update(me, dt)

	--Display once if Naija enters
	if isFlag(PEARL_MINE, 0) and node_isEntityIn(me, v.n) then
		setFlag(PEARL_MINE, 1)
		setControlHint("Look at all the drift pearl they're carrying! I wonder if they mine it somewhere...", 0, 0, 0, 10)
	end 

end
