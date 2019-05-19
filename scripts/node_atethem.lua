if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))
dofile(appendUserDataPath("_mods/Labyrinth/scripts/inc_util.lua"))

v.n = 0
v.done = false

local function isGhost(e)
    return entity_isName(e, "kuirlinghost")
end

local function wakeup(e)
    entity_msg(e, "wakeup")
end

local function wakeupGhosts()
    v.forAllEntities(wakeup, nil, isGhost)
end



function init(me)
	v.n = getNaija()
    
    -- FIXME: is that good here? i think once activated, they should stay active.
    if isFlag(ATE_THEM, 1) then
        wakeupGhosts()
        v.done = true
    end
    
end

function update(me, dt)

	if not v.done then
    
        if node_isEntityIn(me, v.n) then
            v.done = true
            wakeupGhosts()

            --Display once if Naija enters
            if isFlag(ATE_THEM, 0) then
                
                setFlag(ATE_THEM, 1) -- FG: FIXME ASAP- this of for testing ONLY!
                setControlHint("Oh, horrible! It not only enslaved the kuirlins, it ATE them!", 0, 0, 0, 5)
            end
        end
    end

end
