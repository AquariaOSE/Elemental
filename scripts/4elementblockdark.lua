-- based on gateway

dofile("scripts/entities/entityinclude.lua")

n = 0
t = 0
b = 0

function init(me)
	setupBasicEntity(
	me,
	"4elementblockdark",			-- texture
	1,								-- health
	4,								-- exp
	0,								-- manaballamount
	0,								-- money
	256,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	512,							-- sprite width	
	512,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "4elementblockdark")	
	entity_setAllDamageTargets(me, true)
	
	entity_setEntityLayer(me, -2)
	
	b = entity_getNearestNode(me, "gatewayblock")
	if b ~= 0 and node_isEntityIn(b, me) then
	else
		b = 0
	end
	
	entity_scale(me, 1.5, 1.5)
	
	entity_generateCollisionMask(me)
	

	
	entity_setCullRadius(me, 1024)
end

function postInit(me)
	n = getNaija()
	entity_setTarget(me, n)
end

function update(me, dt)
	--entity_updateMovement(me, dt)
	
	entity_handleShotCollisionsSkeletal(me)
	
	if b ~= 0 then
		if node_isEntityIn(b, n) then
			xd = 0
			yd = entity_y(n) - node_y(b)
			entity_touchAvatarDamage(me, 0, 0, 0, 0)
			avatar_fallOffWall()
		end
	end
		
	bone = entity_collideSkeletalVsCircle(me, n)
	if bone ~= 0 then
		entity_clearVel(n)
		if entity_y(n) > entity_y(me) then
			entity_addVel(n, 0, 500)
		else
			entity_addVel(n, 0, -500)
		end
		entity_touchAvatarDamage(me, 0, 0, 0, 0)
		avatar_fallOffWall()
	end
	
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		return true
	end
	
	playNoEffect()
	return false
end

