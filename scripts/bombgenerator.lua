--FG TODO

-- ================================================================================================
-- C E L L   G E N E R A T O R
-- ================================================================================================

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

delay = 1.0

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	--entity_setAllDamageTargets(me, false)
	
	--entity_initSkeletal(me, "dark-full")
	--entity_setTexture(me, "missingimage")
	
	entity_scale(me, 0, 0)
	
	entity_setTexture(me, "")

	--entity_generateCollisionMask(me)
	--entity_setCollideRadius(me, 32)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setHealth(me, 3)
	entity_setDropChance(me, 20, 1)
	
	--entity_setDeathParticleEffect(me, "TinyRedExplode")
	entity_setUpdateCull(me, -1)
end

function postInit(me)
	n = getNaija()
	--entity_setTarget(me, n)
end

function update(me, dt)

	if delay > 0 then
		delay = delay - dt
	else
		if not entity_hasTarget(me) then
			entity_findTarget(me, 10000)
			if entity_hasTarget(me) then
				if chance(100) then
					ent = createEntity("bomb", "", entity_x(me), entity_y(me))
				end
				entity_rotate(ent, entity_getRotation(me))
				delay = math.random(3.0) + 3.0
			end
		else
			if chance(100) then
				ent = createEntity("bomb", "", entity_x(me), entity_y(me))
			end
			entity_scale(ent, 0, 0)
			entity_scale(ent, 3, 3, 0.3)
			
			entity_rotate(ent, entity_getRotation(me))
			delay = math.random(3.0) + 3.0
		end
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_ROTATE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_WALK) then
		entity_animate(me, "idle", -1)		
	end
		
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function animationKey(me, key)
end

function hitSurface(me)
	--debugLog("HIT")
end

function songNote(me, note)
end

function songNoteDone(me, note)
end

function song(me, song)
end

function activate(me)
end

