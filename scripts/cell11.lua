--based on minnow and naijaswarmercommon

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end
n = 0

add = math.random(50)

minCap = 400
maxCap = 700
cap = minCap

body = 0
glow = 0

singingDelay = 0

curNote = 0

singing = false

function commonInit(me, tex)
	setupBasicEntity(
	me,
	"",						-- texture
	1,							-- health
	2,							-- manaballamount
	2,							-- exp
	10,							-- money
	20,							-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,							-- particle "explosion" type, 0 = none
	1,							-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)	
	setupEntity(me)
	entity_setEntityType(me, ET_ENEMY)
	
	entity_initSkeletal(me, "Cell11")
	entity_setAllDamageTargets(me, false)
	entity_setCollideRadius(me, 20)
	entity_setHealth(me, 1)
	entity_generateCollisionMask(me)
	
	entity_setDeathParticleEffect(me, "TinyRedExplode")

	body = entity_getBoneByName(me, "Body")
	bone_setSegs(entity_getBoneByName(me, "Body"), 2, 16, 0.6, 0.6, -0.058, 0, 6, 1)
	
	if tex ~= "" then
		bone_setTexture(body, tex)
	end
	
	if chance(50) then
		entity_setEntityLayer(me, 0)
	else
		entity_setEntityLayer(me, 1)
	end
	
	--entity_setEntityLayer(me, -1)
	
	--entity_alpha(me, 0.5)
	
	bone_alpha(body, 0.5)
	
	entity_setState(me, STATE_IDLE)
	esetv(me, EV_LOOKAT, 0)
	
	bone_setBlendType(glow, BLEND_ADD)
	
	bone_alpha(glow, 0)
	bone_scale(glow, 2, 2)
	bone_scale(glow, 4, 4, 1, -1, 1)
	
	entity_addRandomVel(me, 600)
	
	esetv(me, EV_LOOKAT, 0)
end

function init(me)
	commonInit(me, "")
end

function postInit(me)
	n = getNaija()
	entity_setTarget(me, n)
end

function update(me, dt)
	cap = cap - dt*400
	if cap < minCap then
		cap = minCap
	end
	if singing and avatar_isBursting() then
		cap = maxCap
		add = 600
	end
	--entity_doCollisionAvoidance(me, dt, 4, 0.5)
	
	
	entity_doCollisionAvoidance(me, dt, 5, 0.5)
	
	--x, y = getMouseWorldPos()
	
	if singing then
		x,y = entity_getPosition(n)
		
		entity_moveTowards(me, x, y, dt, 300+add)
		
		entity_doEntityAvoidance(me, dt, 32, 0.5)
		
		if singingDelay > 0 then
			singingDelay = singingDelay - dt
			if singingDelay < 0 then
				singing = false
			end
		end
	else
		ent = entity_getNearestEntity(me, entity_getName(me), 256)
		if ent ~= 0 then
			x,y = entity_getPosition(ent)
			entity_moveTowards(me, x, y, dt, 800+add)
		end
		entity_doEntityAvoidance(me, dt, 40, 0.5)
		--entity_doEntityAvoidance(me, dt, 32,
		
		if entity_handleShotCollisions(me) then
		end
	end
	
	vx = entity_velx(me)
	vy = entity_vely(me)
	
	vx, vy = vector_cap(vx, vy, cap)
	entity_clearVel(me)
	entity_addVel(me, vx, vy)
	
	entity_setPosition(me, entity_x(me) + entity_velx(me)*dt, entity_y(me)+entity_vely(me)*dt)

	--entity_updateMovement(me, dt)
	entity_rotateToVel(me)
	
	len = vector_getLength(vx, vy)
	addInfluence(entity_x(me), entity_y(me), 16, len)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", -1)
	end
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
    return me == attacker
end

function animationKey(me, key)
end

function hitSurface(me)
end

function songNote(me, note)
	curNote = note 
	singing = true
	
	singingDelay = 0
	
	r, g, b = getNoteColor(note)
	bone_alpha(glow, 0.5, 1)
	bone_setColor(glow, r, g, b, 1)
end

function songNoteDone(me, note)
	if note == curNote then
		singingDelay = 3
		
		bone_alpha(glow, 0, 4)
		bone_setColor(glow, 1, 1, 1, 4)
	end
end

function song(me, song)
end

function activate(me)
end

function lightFlare(me)
    if not v.off and entity_isEntityInRange(me, n, 800) then -- FIXME: finetune distance
        entity_damage(me, me, 1)
        local vx, vy = entity_getVectorToEntity(n, me)
        vx, vy = vector_normalize(vx, vy)
        
        entity_setMaxSpeedLerp(me, 3)
        entity_setMaxSpeedLerp(me, 1, 0.7)
        
        entity_addVel(me, vx * 2000, vy * 2000)
    end

end