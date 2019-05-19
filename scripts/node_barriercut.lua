if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))

v.n = 0

function init(me)
	v.n = getNaija()
end


function update(me, dt)

	--Display once if Naija enters
	if isFlag(BARRIER_CUT, 0) and node_isEntityIn(me, v.n) then
		setFlag(BARRIER_CUT, 1)
		setControlHint("Hmm, I'll need to find something sharp so I can burst through these weeds!", 0, 0, 0, 8)
	end 

end
