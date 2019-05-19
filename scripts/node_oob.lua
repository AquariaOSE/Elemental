if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Elemental/scripts/flags.lua"))

v.n = 0

function init(me)
	v.n = getNaija()
end


function update(me, dt)

	--Display once if Naija enters
	if isFlag(ENTER_OOB, 0) and node_isEntityIn(me, v.n) then
		setFlag(ENTER_OOB, 1)
		setControlHint("As i swam further i knew i had entered the out of bounds that would be used in the sequel couldn't you have waited or are you the one who is making the sequel?", 0, 0, 0, 20)
	end 

end
