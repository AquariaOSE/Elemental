if not v then v = {} end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))

v.n = 0
v.landed = false

function init(me)
    v.n = getNaija()
end


function update(me, dt)

    --Spawn once if Naija enters
    if not v.landed and node_isEntityIn(me, v.n) then
	spawnParticleEffect("splash", entity_getPosition(getNaija()))
	playSfx("splash-into")	
	v.landed = true   
    end 

end
