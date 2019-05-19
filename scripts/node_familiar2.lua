if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))

v.n = 0

function init(me)
	v.n = getNaija()
end


function update(me, dt)

	--Display once if Naija enters
	if isFlag(FAMILIAR_PLACE2, 0) and hasSong(SONG_FISHFORM) and node_isEntityIn(me, v.n) then
		setFlag(FAMILIAR_PLACE2, 1)
		setControlHint("In fact, I wonder how long I've been down there... I wouldn't be surprised if Li's already home and very concerned about me.", 0, 0, 0, 10)
	end 

end
