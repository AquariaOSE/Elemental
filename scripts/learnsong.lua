
-- helper entity to learn songs

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.n = 0
v.done = false
v.song = false

-- constant lookup table
local _SONGTAB =
{
    [SONG_ENERGYFORM]   = "ENERGY FORM", 
    [SONG_SPIRITFORM]   = "SPIRIT FORM",
    [SONG_NATUREFORM]   = "NATURE FORM",
    [SONG_BEASTFORM]    = "BEAST FORM",
    [SONG_DUALFORM]     = "DUAL FORM", -- unused
    [SONG_FISHFORM]     = "FISH FORM",
    [SONG_SUNFORM]      = "SUN FORM",
    [SONG_BIND]         = "BIND",
    [SONG_SHIELD]       = "SHIELD",
}

local function getSongName(s)
    local r = _SONGTAB[s]
    if r then
        return r
    end
    return "[ERROR - missing data]"
end


function v.commonInit(me, song)
    setupEntity(me)
    entity_setTexture(me, "bg-light-0003")
    entity_initEmitter(me, 0, "glowlearnsong")
    entity_initEmitter(me, 1, "glowlearnsong")
    
    esetv(me, EV_LOOKAT, 1)
    entity_setNaijaReaction(me, "smile")
    entity_setAllDamageTargets(me, false)
    
    if song then
        v.song = song
    end
end

-- to be overridden by includer
function init(me)
    v.commonInit(me) -- song will be set later with a msg
end

function postInit(me)
    v.n = getNaija()
    if v.song and hasSong(v.song) then
        entity_delete(me)
        return
    end
    entity_startEmitter(me, 0)
    entity_startEmitter(me, 1)
end

function update(me, dt)
    if not v.done and v.song then
        if hasSong(v.song) then
            entity_delete(me, 0)
            v.done = true
        elseif entity_isEntityInRange(me, v.n, 60) then
            entity_stopEmitter(me, 0)
            entity_stopEmitter(me, 1)
            learnSong(v.song)
            setControlHint("You've learned the " .. getSongName(v.song) .. " song!", 0, 0, 0, 10)
            spawnParticleEffect("naijalearnsong", entity_getPosition(getNaija()))
            spawnParticleEffect("naijalearnsong", entity_getPosition(me))
            playSfx("secret")
            entity_delete(me, 1)
            v.done = true
        end
    end
end

function msg(me, s, x)
    if s == "setsong" then
        v.song = x
    end
end

function enterState() end
function exitState() end
function animationKey() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
function damage() return false end
