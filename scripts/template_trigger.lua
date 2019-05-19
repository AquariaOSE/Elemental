if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.n = 0
v.trigger = false -- should hold a trigger function

function v.commonInit(me)
    setupEntity(me)
    entity_setEntityType(me, ET_NEUTRAL) 
    entity_setTexture(me, "missingimage")
    
    entity_alpha(me, 0.001)
    esetv(me, EV_LOOKAT, false)
    entity_setAllDamageTargets(me, false)
    entity_setUpdateCull(me, -1)
    entity_setCanLeaveWater(me, true)
    v.n = getNaija()
end

-- overridden if needed

function init(me)
    v.commonInit(me)
end

function postInit(me)
    v.n = getNaija()
end

function update(me, dt)
    if v.trigger then
        v.trigger(me, dt)
    end
end

function enterState(me)
end

function exitState(me)
end

function msg(me, s, x)
    if s == "_resident" then -- used by logic_precache, to prevent opening and closing trigger scripts repeatedly
        v.trigger = false
    end
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

