if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))

v.n = 0

function init(me)
	v.n = getNaija()
end


function update(me, dt)

	--Display once if Naija enters
	if isFlag(KUIRLIN_MYTH, 0) and node_isEntityIn(me, v.n) then
		setFlag(KUIRLIN_MYTH, 6)
		setControlHint("These must be Kuirlins!  I thought they were only a myth. They sure don't seem very friendly!", 0, 0, 0, 10)
	end 

end
