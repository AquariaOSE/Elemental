if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.inside = false
v.t = 0

function init(me)
    --setOverrideMusic("")
    --updateMusic()
end

-- hrm.. unreliable?
--[[
local function playMus(override)
    debugLog("override music")
    updateMusic()
    if not override then
        local s = getStringFlag("TEMP_wheelmusic")
        if s ~= "" then
            playMusicStraight(s)
        end
    end
end
]]

function update(me, dt)
    if isFlag(MINEOCTOBOSS_DONE, 1) and not isFlag(FLAG_ENDING, 1) and v.t >= 0 then
        v.t = v.t - dt
        if v.t <= 0 then
            v.t = 0.5
            local n = getNaija()
            local ins = node_isEntityIn(me, n)
            if not ins then
                local house = entity_getNearestNode(n, "inhouse")
                ins = (house ~= 0) and node_isEntityIn(house, n)
            end
            if ins and not v.inside then
                setOverrideMusic("brightwaters")
                --playMus(true)
                updateMusic()
            elseif not ins and v.inside then
                setOverrideMusic("")
                --playMus(false)
                updateMusic()
            end
            v.inside = ins
        end
    end
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end

function song(me, s)
end
