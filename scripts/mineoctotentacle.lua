if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

function init(me)
    setupEntity(me)
    entity_setEntityType(me, ET_NEUTRAL)
    entity_initSkeletal(me, "mineoctotentacle")
    esetv(me, EV_LOOKAT, 0)
    entity_setState(me, STATE_IDLE)
    entity_setAllDamageTargets(me, false)
    entity_animate(me, "idle", -1)
    entity_setEntityLayer(me, -3)
end

function postInit(me)
end

function update(me, dt)
end

function enterState(me)
end

function exitState(me)
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
