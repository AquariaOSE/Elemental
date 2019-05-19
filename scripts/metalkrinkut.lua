-- ================================================================================================
-- based on WALKER   (alpha)
-- ================================================================================================

dofile("scripts/entities/entityinclude.lua")

-- ================================================================================================
-- L O C A L   V A R I A B L E S 
-- ================================================================================================

moveTimer = 0
n = 0

seen = false
sighTimer = 5

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	setupBasicEntity(me, 
	"MetalKrinkut/MetalKrinkut",					-- texture
	123,							-- health
	4,								-- manaballamount
	0,								-- exp
	0,								-- money
	480,							-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	512,							-- sprite width	
	512,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	3210							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setCullRadius(me, 2048)
	
	entity_setEntityType(me, ET_NEUTRAL)
	entity_setDeathParticleEffect(me, "Explode")
	
	entity_initSkeletal(me, "MetalKrinkut")
	bone_body = entity_getBoneByName(me, "Body")
	entity_generateCollisionMask(me)
	
	entity_scale(me, 1.25, 1.25)
	
	
	entity_setDamageTarget(me, DT_AVATAR_LIZAP, false)
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
	
	--esetv(me, EV_WALLOUT, 23)
	--entity_clampToSurface(me)
end

function postInit(me)
	entity_setState(me, STATE_IDLE)
	
	n = getNaija()
	
	-- FLIP WITH A FLIP NODE
	node = entity_getNearestNode(me, "FLIP")
	if node ~=0 then
		if node_isEntityIn(node, me) then 
			entity_fh(me)
			--entity_switchSurfaceDirection(me)
		end
	end
end

function update(me, dt)
	-- NAIJA ATTACHING TO BODY
	rideBone = entity_collideSkeletalVsCircle(me, n)
	if rideBone == bone_body and avatar_isBursting() and entity_setBoneLock(n, me, rideBone) then
	elseif rideBone ~=0 then
		vecX, vecY = entity_getVectorToEntity(me, n, 1000)
		entity_addVel(n, vecX, vecY)
	end
	
	-- emote
	if entity_isEntityInRange(me, n, 512) then
		if not seen then
			if chance(50) then
				emote(EMOTE_NAIJAWOW)
			else
				emote(EMOTE_NAIJALAUGH)
			end
		end
		seen = true
		sighTimer = sighTimer - dt
		if sighTimer < 0 then
			emote(EMOTE_NAIJAGIGGLE)
			sighTimer = 8 + math.random(4)
		end
	end
		
	-- MOVEMENT
	--entity_rotateToSurfaceNormal(me, 0.54)	
	-- COLLISIONS
	entity_handleShotCollisionsSkeletal(me)
end

function enterState(me)
	if entity_getState(me) == STATE_IDLE then
		entity_animate(me, "idle", LOOP_INF)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	playNoEffect()
	return false
end
