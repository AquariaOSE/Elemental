if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))

v.n = 0
v.created = false

function init(me)
    v.n = getNaija()
end


function update(me, dt)

    --Spawn once if Naija enters
    if not v.created and node_isEntityIn(me, v.n) then
        v.created = true
        local a = node_getNearestNode(me, "spawnchildren1")
        local b = node_getNearestNode(me, "spawnchildren2")
        createEntity("purplespooter4", "", node_getPosition(a))
        createEntity("purplespooter7", "", node_getPosition(b))
        
    end 

end
