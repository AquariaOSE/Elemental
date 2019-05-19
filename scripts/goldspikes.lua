
if not v then v = {} end

function init(me)
    setupEntity(me)
    entity_setTexture(me, "gold-spikes")
    entity_setAllDamageTargets(me, false)
    esetv(me, EV_LOOKAT, 0)
    
    --entity_setEntityLayer(me, -2) -- NOTE: If gold-spikes2 is used as texture, it looks better if this is enabled
end

function postInit(me)
end

function update(me, dt)
    entity_touchAvatarDamage(me, 130, 0.5)
end

function msg() end
function enterState() end
function exitState() end
function animationKey() end
function song() end
function songNoteDone() end
function songNote() end
function shiftWorlds() end
function lightFlare() end
function damage() return false end
