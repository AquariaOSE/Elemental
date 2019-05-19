-- ================================================================================================
-- based on RASPBERRY
-- ================================================================================================

dofile("scripts/entities/entityinclude.lua")

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
	"mots-energy",			-- texture
	12.5,								-- health
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
	entity_setEatType(me, EAT_FILE, "mots-energy")
	entity_scale(me, 1, 1)
	entity_setDropChance(me, 10)
	entity_clampToSurface(me)
	entity_setSegs(me, 2, 16, 0.6, 0.6, -0.058, 0, 6, 1)
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	esetv(me, EV_WALLOUT, 16)
end

spd = 80

function update(me, dt)
	-- dt, pixelsPerSecond, climbHeight, outfromwall
	-- out: 24
	
	entity_moveAlongSurface(me, dt, spd, 6, 10)
	entity_rotateToSurfaceNormal(me, 0.1)
	
	entity_handleShotCollisions(me)
	if entity_touchAvatarDamage(me, 48, 4, 0.1) then
		avatar_fallOffWall()
	end
	-- entity_rotateToSurfaceNormal(0.1)
	moveTimer = moveTimer + dt * spd
	if moveTimer > 400 then
		entity_switchSurfaceDirection(me)
		moveTimer = 0
	end
	if not(entity_hasTarget(me)) then
		entity_findTarget(me, 1200)
	else
		if fireDelay > 0 then
			fireDelay = fireDelay - dt
			if fireDelay < 0 then
				-- dmg, mxspd, homing, numsegs, out
				entity_doGlint(me, "Particles/PurpleFlare")
				--entity_fireAtTarget(me, "Purple", 1, 400, 200, 3, 64)
							
				s = createShot("mots-energy", me, entity_getTarget(me))
				shot_setAimVector(s, entity_getNormal(me))
				shot_setOut(s, 32)
				
				if lastShot <= 1 then
					fireDelay = 2.5
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
	if entity_getState(me)==STATE_IDLE then
	end
end

function exitState(me)
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		entity_changeHealth(me, -99)
	end
	return true
end
