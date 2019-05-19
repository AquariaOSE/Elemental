-- ================================================================================================
-- P U R P W A L L S H O O T E R 
-- ================================================================================================

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.fireDelay = 2
v.moveTimer = 0

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"purpwallshooter",					-- texture
	4,								-- health
	2,								-- manaballamount
	2,								-- exp
	1,								-- money
	34,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	entity_setEatType(me, EAT_FILE, "raspberry")
	entity_scale(me, 0.75, 0.75)
	entity_setDropChance(me, 25)
	entity_clampToSurface(me)
	entity_setDeathParticleEffect(me, "PurpleExplode")
	entity_setSegs(me, 2, 16, 0.6, 0.6, -0.028, 0, 6, 1)
	esetv(me, EV_WALLOUT, 12)
	esetvf(me, EV_CLAMPTRANSF, 0.2)
end

function update(me, dt)
	if eisv(me, EV_CLAMPING, 0) then
		-- dt, pixelsPerSecond, climbHeight, outfromwall
		-- out: 24
		entity_moveAlongSurface(me, dt, 40, 6)
		entity_rotateToSurfaceNormal(me, 0.1)
		-- entity_rotateToSurfaceNormal(0.1)
		v.moveTimer = v.moveTimer + dt
		if v.moveTimer > 10 then
			entity_switchSurfaceDirection(me)
			v.moveTimer = 0
		end
		if not(entity_hasTarget(me)) then
			entity_findTarget(me, 1200)
		else
			if v.fireDelay > 0 then
				v.fireDelay = v.fireDelay - dt
				if v.fireDelay < 0 then
					-- dmg, mxspd, homing, numsegs, out
					entity_doGlint(me, "Particles/PurpleFlare")
					--entity_fireAtTarget(me, "Purple", 1, 400, 200, 3, 64)
					local nx, ny = entity_getNormal(me)
					nx, ny = vector_setLength(nx, ny, 48)
				
					local s = createShot("Raspberry", me, entity_getTarget(me), entity_x(me)+nx, entity_y(me)+ny)
					
					--shot_setAimVector(s, )
					--[[
					
					shot_setAimVector(s, entity_getNormal(me))
					shot_setOut(s, 64)
					
					shot_setAimVector(s, 
					]]--
					
					v.fireDelay = 5
				end
			end
		end
	end
	
	entity_handleShotCollisions(me)
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me)+10, 0.5, 500)	then
		avatar_fallOffWall()
	end
	
	if isObstructed(entity_x(me), entity_y(me)) then
		entity_adjustPositionBySurfaceNormal(me, 1)
	end
end

function dieNormal(me)
end

--[[
function diedFrom(attacker, damageType)
	if damageType ~= DT_AVATAR_BITE then
		spawnIngredient("RubberyMeat", entity_getPosition(me))
	end
end
]]--

function enterState(me)
	if entity_getState(me)==STATE_IDLE then	
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE or attacker == me then
		entity_changeHealth(me, -99)
	end
	return true
end

function exitState(me)
end

function hitSurface(me)
end
