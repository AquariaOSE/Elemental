-- based on gateway

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.b = 0

function init(me)
	setupBasicEntity(
	me,
	"4elementblockenergy",			-- texture
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
	entity_initSkeletal(me, "4elementblockenergy")	
	entity_setAllDamageTargets(me, true)
	
	entity_setEntityLayer(me, -2)
	
	v.b = entity_getNearestNode(me, "gatewayblock")
	if v.b ~= 0 and node_isEntityIn(v.b, me) then
	else
		v.b = 0
	end
	
	entity_scale(me, 1.5, 1.5)
	
	entity_generateCollisionMask(me)
	

	
	entity_setCullRadius(me, 1024)
end

function postInit(me)
	n = getNaija()
	entity_setTarget(me, getNaija())
end

function update(me, dt)
    local n = getNaija()
	--entity_updateMovement(me, dt)
	
	entity_handleShotCollisionsSkeletal(me)
	
	if v.b ~= 0 then
		if node_isEntityIn(v.b, n) then
			xd = entity_x(n) - node_x(v.b)
			yd = 0
			entity_touchAvatarDamage(me, 0, 0, 0, 0)
			avatar_fallOffWall()
		end
	end
		
	local bone = entity_collideSkeletalVsCircle(me, n)
	if bone ~= 0 then
		entity_clearVel(n)
		if entity_x(n) > entity_x(me) then
			entity_addVel(n, 500, 0)
		else
			entity_addVel(n, -500, 0)
		end
		entity_touchAvatarDamage(me, 0, 0, 0, 0)
		avatar_fallOffWall()
	end
	
end

function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_ENERGYBLAST and  dmg > 0.99  then
		return true
	end
	
	playNoEffect()
	return false
end

