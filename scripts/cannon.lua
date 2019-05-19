-- ================================================================================================
-- based on RASPBERRY and mots-energy
-- ================================================================================================
if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end
-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

fireDelay = 0.1
moveTimer = 0
maxShots = 8
lastShot = maxShots

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"cannon",			-- texture
	50,								-- health
	2,								-- exp
	2,								-- manaballamount
	1,								-- money
	128,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	256,							-- sprite width	
	256,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	entity_scale(me, 0.375, 0.672)
	entity_setDropChance(me, 10)
	entity_clampToSurface(me)
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	esetv(me, EV_WALLOUT, 16)
end

spd = 0

function postInit(me)
end


function update(me, dt)
	entity_handleShotCollisions(me)
	if entity_touchAvatarDamage(me, 48, 0, 48) then
		avatar_fallOffWall()
	end
	if not(entity_hasTarget(me)) then
		entity_findTarget(me, 5000)
	else
		if fireDelay > 0 then
			fireDelay = fireDelay - dt
			if fireDelay < 0 then
				-- dmg, mxspd, homing, numsegs, out
				entity_doGlint(me, "Particles/PurpleFlare")
				-- entity_fireAtTarget(me, "Purple", 1, 400, 200, 3, 64)
							
				s = createShot("cannon", me, entity_getTarget(me))
				shot_setOut(s, 32)
				
				if lastShot <= 1 then
					fireDelay = 1.5
					lastShot = maxShots
				else
					fireDelay = 0.25
					lastShot = lastShot - 1
				end				
			end
		end
	end
	
	if isObstructed(entity_x(me), entity_y(me)) then
		entity_adjustPositionBySurfaceNormal(me, 1)
	end
end



function enterState(me)
end

function exitState(me)
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
	playNoEffect()
	return false
end