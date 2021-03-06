-- based on wisp

dofile("scripts/entities/entityinclude.lua")

n = 0
mld = 0.2
ld = mld
note = -1
excited = 0
glow = 0

function init(me)
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	entity_setTexture(me, "Sunkrinkut")
	entity_setAllDamageTargets(me, true)
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
	entity_setDamageTarget(me, DT_AVATAR_BITE, false)
	entity_setDamageTarget(me, DT_AVATAR_SHOCK, false)

	
	entity_setCollideRadius(me, 20)
	
	entity_setState(me, STATE_IDLE)
	entity_addRandomVel(me, 500)
	
	glow = createQuad("Naija/LightFormGlow", 13)
	quad_scale(glow, 2, 2)	
	
	entity_setHealth(me, 2)
	
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	
	bone_setSegs(entity_getBoneByName(me, "Body"), 2, 16, 0.6, 0.6, -0.058, 0, 6, 1)

	
	entity_setUpdateCull(me, 3000)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function dieNormal(me)
	if chance(50) then
		spawnIngredient("GlowingEgg", entity_x(me), entity_y(me))
	end
end

function postInit(me)
	n = getNaija()
	entity_setTarget(me, n)
end

function update(me, dt)
	ld = ld - dt
	if ld < 0 then
		ld = mld
		l = createQuad("Naija/LightFormGlow", 13)
		r = 1
		g = 1
		b = 1
		if note ~= -1 then
			r, g, b = getNoteColor(note)
			r = r*0.5 + 0.5
			g = g*0.5 + 0.5
			b = b*0.5 + 0.5
		end
		quad_setPosition(l, entity_getPosition(me))
		quad_scale(l, 1.5, 1.5)
		quad_alpha(l, 0)
		quad_alpha(l, 1, 0.5)
		quad_color(l, r, g, b)		
		quad_delete(l, 4)
		quad_color(glow, r, g, b, 0.5)
	end
	--entity_doCollisionAvoidance(me, dt, 8, 0.2)
	entity_doCollisionAvoidance(me, dt, 4, 0.8)
	entity_updateMovement(me, dt)
	entity_handleShotCollisions(me)
	--entity_touchAvatarDamage(me, entity_getCollideRadius(me), 1, 500)	
	if excited > 0 then
		excited = excited - dt
		if excited < 0 then
			entity_addRandomVel(me, 500)
		end
		if entity_isTargetInRange(me, 256) then
			entity_moveAroundTarget(me, dt, 1000)
		else
			entity_moveTowardsTarget(me, dt, 400)
		end
	end
	if not entity_isRotating(me) then
		entity_rotateToVel(me, 0.2)
	end
		
	quad_setPosition(glow, entity_getPosition(me))
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
	elseif entity_isState(me, STATE_DEAD) then
		quad_delete(glow, 1)
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
end

function songNote(me, n)
	note = n
	excited = 10
	--entity_rotate(me, entity_getRotation(me)+360, 0.5, 0, 0, 1)
	quad_scale(glow, 2, 2)
	quad_scale(glow, 4, 4, 0.5, 1, 1, 1)
	entity_setMaxSpeedLerp(me, 1.25)
	entity_setMaxSpeedLerp(me, 1, 3)
end

function songNoteDone(me, note)
	excited = 3
end

function song(me, song)
end

function activate(me)
end

