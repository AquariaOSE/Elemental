if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))

v.n = 0

function init(me)
	v.n = getNaija()
end


function update(me, dt)

	--Display once if Naija enters
	if isFlag(MINEOCTOBOSS_DONE, 0) and isFlag(GOOD_KITCHEN, 0) and node_isEntityIn(me, v.n) then
		setFlag(GOOD_KITCHEN, 1)
		setControlHint("Oh, good!  A kitchen, and no one's about.  I hope they won't mind if I use their stove. . .", 0, 0, 0, 8)
	end 

end