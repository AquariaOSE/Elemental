if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))

v.n = 0

function init(me)
	v.n = getNaija()
end


function update(me, dt)

	--Display once if Naija enters
	if isFlag(TEXT_START, 0) and node_isEntityIn(me, v.n) then
		setFlag(TEXT_START, 1)
		setControlHint("Hmm, what will I do this morning?  Li's visiting the surface, and probably won't be back for a few days.  Perhaps I'll see if I can open up that blocked passage in the old labyrinth.  I'd better brush up on songs and collect some supplies. . . ", 0, 0, 0, 12)
	end 

end
