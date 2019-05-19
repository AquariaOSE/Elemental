--FG TODO

-- based on forestsprite

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

n = 0


STATE_SLEEP				= 1000
STATE_DANCE				= 1001

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "Cell02")	
	
	entity_setEntityLayer(me, 1)
	
	
	entity_setState(me, STATE_IDLE)
	
	entity_scale(me, 0.5, 0.5)
	
	entity_setMaxSpeed(me, 200)
end

function postInit(me)
	node = entity_getNearestNode(me, "DANCE")
	if node ~= 0 and node_isEntityIn(node, me) then
		entity_setState(me, STATE_DANCE, -1, 1)
	else
		node = entity_getNearestNode(me, "SLEEP")
		if node ~= 0 and node_isEntityIn(node, me) then
			entity_setState(me, STATE_SLEEP, -1, 1)
		end
	end
	n = getNaija()
	entity_setTarget(me, n)
end

seen = false

function update(me, dt)
	if entity_isState(me, STATE_IDLE) then
		entity_updateMovement(me, dt)
		entity_doCollisionAvoidance(me, dt, 8, 0.01)
		entity_flipToVel(me)
	end
	
	if entity_isState(me, STATE_SLEEP) and entity_isEntityInRange(me, n, 700) and not seen then
		seen = true
		emote(EMOTE_NAIJAGIGGLE)
	end
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	elseif entity_isState(me, STATE_SLEEP) then
		entity_animate(me, "sleep", -1)
	elseif entity_isState(me, STATE_DANCE) then
		-- switch off flag
		entity_fh(me)
		if isFlag(FLAG_BOSS_FOREST, 0) then
			entity_setStateTime(me, entity_animate(me, "dance1"))
		else
			entity_setStateTime(me, entity_animate(me, "dance2"))
		end
	end
end

function exitState(me)
	if entity_isState(me, STATE_DANCE) then
		entity_setState(me, STATE_DANCE)
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

