if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))

v.n = 0

function init(me)
	v.n = getNaija()
end


function update(me, dt)

	--Display once if Naija enters
	if isFlag(PEARL_STASH, 0) and node_isEntityIn(me, v.n) then
		setFlag(PEARL_STASH, 1)
		setControlHint("Ah!  Li will have to see this!", 0, 0, 0, 5)
	end 

end
