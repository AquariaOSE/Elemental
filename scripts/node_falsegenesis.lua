if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Elemental/scripts/flags.lua"))

v.n = 0

function init(me)
	v.n = getNaija()
end


function update(me, dt)

	--Display once if Naija enters
	if isFlag(FALSE_GENESIS, 0) and node_isEntityIn(me, v.n) then
		setFlag(FALSE_GENESIS, 1)
		setControlHint("Hi false.genesis!", 0, 0, 0, 10)
	end 

end
