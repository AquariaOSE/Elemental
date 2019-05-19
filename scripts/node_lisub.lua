if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))

v.n = 0

function init(me)
	v.n = getNaija()
end


function update(me, dt)

	--Display once if Naija enters
	if isFlag(LI_SUB, 0) and not isFlag(FLAG_ENDING, 1) and node_isEntityIn(me, v.n) then
		setFlag(LI_SUB, 1)
		setControlHint("Ah, Li's old submarine. I bet that as soon as he's done repairing it, we will go on a nice adventure...", 0, 0, 0, 10)
	end 

end