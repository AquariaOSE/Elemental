if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))
--dofile(appendUserDataPath("_mods/Labyrinth/scripts/inc_util.lua"))

local SING_TIME = 2

local FOUNDMSG = "You have found a driftpearl treasure! Sing to reveal its color!"

local SIZES = {
    .6, -- pearl 0
    .6, -- pearl 1
    .6, -- pearl 2
    .6, -- pearl 3
    .6, -- pearl 4
    .7, -- pearl 5
    .7, -- pearl 6
    .6, -- pearl 7
    1.0, -- pearl 8 (any color)
}

local SHADOWSIZES = {
    1, -- pearl 0
    1, -- pearl 1
    1, -- pearl 2
    1, -- pearl 3
    1, -- pearl 4
    1, -- pearl 5
    1, -- pearl 6
    1, -- pearl 7
    0.5, -- pearl 8 (any color)
}

local SHADOW_OFFS = {
    20, -- pearl 0
    5, -- pearl 1
    7, -- pearl 2
    0, -- pearl 3
    7, -- pearl 4
    3, -- pearl 5
    1, -- pearl 6
    3, -- pearl 7
    -4, -- pearl 8 (any color) (does not have shadow)
}

v.n = 0
v.noteId = -1 -- 0 to 7, or 8 for any
v.holdingNote = false
v.holdingT = 0
v.colored = false
v.colbone = 0
v.shadow = 0
v.shownmsg = false
v.cancollect = false
v.home = false
v.needinit = true
v.incut = false

local function collectScene(me)
    if v.incut then return end
    
    setFlag(FLAG_FOUND_DRIFTPEARL0 + v.noteId, 1)
    setFlag(FLAG_DRIFTPEARLS_COLLECTED, getFlag(FLAG_DRIFTPEARLS_COLLECTED) + 1)

    v.incut = true
    entity_idle(getNaija())
    entity_flipToEntity(getNaija(), me)
    cam_toEntity(me)
    
    overrideZoom(1.2, 7)
    musicVolume(0.1, 3)
    
    setSceneColor(1, 0.9, 0.5, 3)
    
    spawnParticleEffect("treasure-glow", entity_x(me), entity_y(me))
    
    playSfx("low-note1", 0, 0.4)
    playSfx("low-note5", 0, 0.4)
    
    watch(2)
    bone_alpha(v.shadow, 0, 1)
    watch(1)
    
    entity_setPosition(me, entity_x(me), entity_y(me)-100, 3, 0, 0, 1)
    entity_scale(me, 1.2, 1.2, 3)
    --playSfx("secret")
    playSfx("Collectible")
    
    
    watch(3)
    
    playSfx("secret", 0, 0.5)
    cam_toEntity(getNaija())
    
    musicVolume(1, 2)
    
    setSceneColor(1, 1, 1, 1)
    
    overrideZoom(0)
    
    v.incut = false
    
    entity_alpha(me, 0, 1)
    entity_delete(me, 1)
end

local function doColoring(me)
    if v.colored then return end
    
    spawnParticleEffect("pearlsparkle", entity_x(me), entity_y(me))
    entity_startEmitter(me, 1)
    entity_stopEmitter(me, 0)
    -- TODO: play sfx ?
    entity_playSfx(me, "secret") -- HM?!
    local r,g,b = getNoteColor(v.noteId)
    bone_alpha(entity_getBoneByName(me, "white"), 0, 3)
    bone_alpha(v.colbone, 1, 0.7)
    v.colored = true
    v.cancollect = true
end

local function initTex(me, id)
    entity_initSkeletal(me, "driftpearl", "driftpearl" .. id)
    
    v.colbone = entity_getBoneByName(me, "colored")
    v.shadow = entity_getBoneByName(me, "shadow")
    
    bone_alpha(v.colbone, 0.001) -- not 0, otherwise it won't draw
    bone_offset(v.shadow, 0, SHADOW_OFFS[id+1])
end

function init(me)

    setupEntity(me)
    
    entity_setAllDamageTargets(me, false)
    esetv(me, EV_LOOKAT, 1)
    
    entity_initEmitter(me, 0, "pearlglow1")
    entity_initEmitter(me, 1, "pearlglow2")
    
    entity_startEmitter(me, 0)
    
    entity_setNaijaReaction(me, "smile")
    
    entity_setCanLeaveWater(me, true)
end

function postInit(me)
    v.n = getNaija()
end

local function firstUpdate(me)
    local seting = getNearestNodeByType(entity_x(me), entity_y(me), PATH_SETING)
    if seting ~= 0 and node_isEntityIn(seting, me) then
        v.noteId = node_getAmount(seting)
        if v.noteId < 0 or v.noteId > 7 then
            centerText("Hey - driftpearl note ID should be between 0 and 7")
            v.noteId = -1
        else
            v.colored = isFlag(FLAG_FOUND_DRIFTPEARL0 + v.noteId, 1)
            initTex(me, v.noteId)
        end
    else
        for i = 0,8 do
            local spawnpoint = entity_getNearestNode(me, "collectiblepearl" .. i)
            if spawnpoint == 0 then
                debugLog("no spawnpoint! collectiblepearl" .. i)
            end
            if spawnpoint ~= 0 and node_isEntityIn(spawnpoint, me) then
                debugLog("yes - in collectiblepearl" .. i .. " node")
                v.home = true
                break
            else
                debugLog("no - not in collectiblepearl" .. i .. " node")
            end
        end
        
        if not v.home then
            -- HACK - must be the driftpearl dropped after pearlmine bossfight
            initTex(me, 8) -- means any
            v.noteId = -1
            v.colored = isFlag(FLAG_FOUND_DRIFTPEARL0 + 8, 1)
            bone_alpha(v.shadow, 0.001)
        end
    end
    
    if v.noteId < 0 then
        v.noteId = 8
    end
        
    if v.colored and not v.home then
        entity_delete(me)
    end
end

function update(me, dt)
    if v.needinit then
        v.needinit = false
        firstUpdate(me)
    end
    
    if v.holdingNote then
        v.holdingT = v.holdingT + dt
        if v.holdingT >= SING_TIME then
            v.holdingNote = false
            doColoring(me)
        end
    end
    
    if entity_isEntityInRange(me, v.n, 80) then
        if not v.colored then
            if not v.shownmsg then
                v.shownmsg = true
                setControlHint(FOUNDMSG, 0, 0, 0, 8, "driftpearl" .. v.noteId, nil, 0.45)
                playSfx("gem-collect")
            end
        elseif v.cancollect then
            collectScene(me)
        end
    end
    
    entity_updateMovement(me, dt)
end


function songNote(me, note)
    if note == v.noteId or v.noteId == -1 or v.noteId > 7 then
        --debugLog("holding right note...")
        v.holdingNote = true
    end
end

function songNoteDone(me, note, tm)
    if (note == v.noteId or v.noteId == -1 or v.noteId > 7) and v.holdingNote and tm > SING_TIME then
        doColoring(me)
    end
    v.holdingT = 0
    v.holdingNote = false
end

function msg(me, s, x)
    if s == "color" then
        initTex(me, x)
        entity_scale(me, SIZES[x+1], SIZES[x+1])
        bone_scale(v.shadow, SHADOWSIZES[x+1], SHADOWSIZES[x+1])
        -- instant color
        bone_alpha(entity_getBoneByName(me, "white"), 0)
        bone_alpha(v.colbone, 1)
        v.noteId = x
        v.colored = true
        v.shownmsg = true
        v.cancollect = false
        entity_stopEmitter(me, 0)
        entity_startEmitter(me, 1)
    end
end

function song(me, s)
end

function enterState(me)
end

function exitState(me)
end

function hitSurface(me)
end
