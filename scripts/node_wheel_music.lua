if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.fish = false
v.needinit = true
v.on = false
v.c = 6
v.t = 1

function init(me)
    -- have special override music then
    if isFlag(FLAG_ENDING, 1) then
        v.needinit = false
    end
end

local function lateInit(me)

    if hasSong(SONG_FISHFORM) then
        return -- set in update()
    end
    
    local c = 0
    if isFlag(BIGCELLBOSS_DONE, 1) then
        c = c + 1
    end
    if isFlag(MINEOCTOBOSS_DONE, 1) then
        c = c + 1
    end
    
    local m
    
    if c == 1 then
        m = "openwaters"
    elseif c == 2 then
        m = "openwaters2"
    end
    
    if m then
        debugLog("wheel music: " .. m)
        --playMusicStraight(m)
        setMusicToPlay(m)
        updateMusic()
        setStringFlag("TEMP_wheelmusic", m)
    else
        debugLog("wheel music: --default--")
        setStringFlag("TEMP_wheelmusic", "")
    end
end

function update(me, dt)
    if v.needinit then
        v.needinit = false
        lateInit(me)
        v.on = true
    end
    
    if v.on and not v.fish then
        if hasSong(SONG_FISHFORM) then
            v.fish = true
            local m = "openwaters3"
            --playMusicStraight(m)
            setMusicToPlay(m)
            updateMusic()
            setStringFlag("TEMP_wheelmusic", m)
        end
    end
    
    
    -- HACK: if the game refuses to start the music at all???!
    if v.c > 0 and v.t >= 0 then
        v.t = v.t - dt
        if v.t <= 0 then
            v.c = v.c - 1
            v.t = 1
            updateMusic()
        end
    end
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end

function song(me, s)
end
