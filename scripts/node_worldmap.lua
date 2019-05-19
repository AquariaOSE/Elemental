if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))


function init(me)
    if isFlag(FLAG_WORLDMAP_INITED, 0) then
        pickupGem("Naija-Token", 1)
        setFlag(FLAG_WORLDMAP_INITED, 1)
    end
end


function update(me, dt)
end
