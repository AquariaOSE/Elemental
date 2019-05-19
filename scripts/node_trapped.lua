if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))
dofile(appendUserDataPath("_mods/Labyrinth/scripts/inc_util.lua"))
dofile(appendUserDataPath("_mods/Labyrinth/scripts/inc_timerqueue.lua"))

v.n = 0
v.active = true

function init(me)
    v.n = getNaija()
end

function update(me, dt)

    v.updateTQ(dt)

    if v.active and isFlag(FLAG_ENDING, 0) then
        
        if isFlag(TRAPPED_MAZE, 0) and node_isEntityIn(me, v.n) then
            v.active = false
            setFlag(TRAPPED_MAZE, 1)
            
            local entrancedoors = getNode("entrancedoors")
            
            local doors = v.getAllEntities(function(e)
                return entity_isName(e, "energydoor") and node_isEntityIn(entrancedoors, e)
            end)
            
            debugLog("found " .. #doors .. " doors")
            
            -- close from left to right
            table.sort(doors, function(a, b) return entity_x(a) < entity_x(b) end)
            
            for i, e in ipairs(doors) do
                v.pushTQ(i * 0.5, function() entity_setState(e, STATE_OPEN) end)
            end
            
            local function fx(node)
                entity_playSfx(doors[#doors], "rockhit-big", nil, 2)
                spawnParticleEffect("dust-down", node_getPosition(node))
                shakeCamera(10, 0.3)
            end
            
            local dust1 = getNode("doordust1")
            local dust2 = getNode("doordust2")
            
            fx(dust1)
            v.pushTQ(0.6, fx, dust2)
            
            overrideZoom(1.7, 4) -- 1.2 -- 1.45
            --esetv(v.n, EV_NOINPUTNOVEL, 0)
            
            cam_toNode(entrancedoors)
            entity_idle(v.n)
            watch(0.5)
            
            entity_clearVel(v.n)
            entity_rotate(v.n, 0, 0.3)
            watch(0.5)
            
            cam_toEntity(v.n)
            
            -- force look left
            if entity_isfh(v.n) then
                entity_fh(v.n)
            end
            watch(0.9)
            setNaijaHeadTexture("shock", 4.5)
            watch(2.3)
            
            emote(EMOTE_NAIJAUGH)
            entity_animate(v.n, "ack", 1)
            setControlHint("Ahh, no!  This may have been a huge mistake!  Li's going to be so disgusted with me!  But there has to be another way out!", 0, 0, 0, 12)
            
            watch(1.5)
            
            entity_animate(v.n, "agony")
            playSfx("naijalow1", nil, 2)
            watch(1)
            setNaijaHeadTexture("")
            watch(2)
            cam_toEntity(v.n)
            
            --esetv(v.n, EV_NOINPUTNOVEL, 1)
            overrideZoom(0)
            
        elseif isFlag(TRAPPED_MAZE, 1) then
            v.active = false
            local entrancedoors = getNode("entrancedoors")
            
            local doors = v.getAllEntities(function(e)
                return entity_isName(e, "energydoor") and node_isEntityIn(entrancedoors, e)
            end)
            
            debugLog("found " .. #doors .. " doors")
            
            for i, e in pairs(doors) do
                entity_setState(e, STATE_OPEN)
            end
        end
        
    end 
end
