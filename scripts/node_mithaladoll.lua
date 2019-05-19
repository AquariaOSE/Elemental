if not v then v = {} end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))

v.n = 0

function init(me)
	v.n = getNaija()
end


function update(me, dt)

	--Display once if Naija enters
	if isFlag(MITHALA_DOLL, 0) and node_isEntityIn(me, v.n) then
		setFlag(MITHALA_DOLL, 1)
		setControlHint("My mithala doll!  So that's what happened to it!  Thieving rukh!", 0, 0, 0, 8)
	end 

end
