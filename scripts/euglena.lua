-- ================================================================================================
-- E U G L E N A   based on Metaray
-- ================================================================================================

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Elemental/scripts/inc_util.lua"))

-- ================================================================================================
-- L O C A L   V A R I A B L E S
-- ================================================================================================

v.interestTimer = 0
v.interest = false
v.n = 0

v.hairtimer = 0
v.hairup = false
v.hvx = 0
v.hvy = 0

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"euglena/body",						-- texture
	5,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	32,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	128,								-- sprite width
	128,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1							-- updateCull -1: disabled, default: 4000
	)
	
	entity_setDropChance(me, 10)
	
	if chance(50) then
		v.interest = true
	end
	
	entity_addVel(me, math.random(1000)-500, math.random(1000)-500)
	--entity_setDeathParticleEffect(me, "TinyGreenExplode")
    
    entity_setCollideRadius(me, 64)
	
	entity_setMaxSpeed(me, 500)
	
	entity_setCanLeaveWater(me, true)
    
    local sc = math.random(700, 1200) / 1000
    entity_scale(me, sc, sc)
    
    entity_initHair(me, 32, 8 * sc, 20 * sc, "euglena/tail") -- self, divisions, lengthPerDiv, width, gfx
end

function postInit(me)
    v.n = getNaija()
end

-- the entity's main update function
function update(me, dt)
	local dmg = 0
	if not entity_isUnderWater(me) and getForm() ~= FORM_BEAST then
		dmg = 0.5	
	end
		
		
	entity_handleShotCollisions(me)
    
    if entity_checkSplash(me) then
        if entity_isUnderWater(me) then
            entity_setWeight(me, 0)
        else
            entity_setWeight(me, 800)
        end
    end

	-- in idle state only
	if entity_getState(me)==STATE_IDLE then		
		entity_doCollisionAvoidance(me, dt, 10, 0.1)
		entity_doCollisionAvoidance(me, dt, 4, 0.5)
	end
	local bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then		
		entity_touchAvatarDamage(me, 0, dmg, 500)
	end
	if not entity_hasTarget(me) then
		entity_findTarget(me, 500)
	else
		-- has target
		if entity_isUnderWater(me) then
			if not entity_isNearObstruction(entity_getTarget(me), 5) then
				if v.interest then
					entity_moveTowardsTarget(me, dt, 500)
				end
			end
		end
	end
	entity_flipToVel(me)
	entity_rotateToVel(me, 0.3)
	entity_updateCurrents(me, dt)
	entity_updateMovement(me, dt)	
	
	--if entity_isUnderWater(me) then
		v.interestTimer = v.interestTimer + dt
		if v.interestTimer > 12 then
			v.interest = not v.interest
			v.interestTimer = math.random(3)
		end
	--end
    
    
    local scx, scy = entity_getScale(me)
    
    -- FG: tail whipping here
    if v.hairtimer >= 0 then
        v.hairtimer = v.hairtimer - dt
        if v.hairtimer <= 0 then
            v.hairtimer = 0.1 + (20 / entity_getVelLen(me)) -- adjust whip frequency to swim speed
            v.hairup = not v.hairup -- switch direction
            local vx, vy = entity_velx(me), entity_vely(me)
            if v.hairup then
                v.hvx, v.hvy = -vy * 2, vx * 2 -- perpendicular left
            else
                v.hvx, v.hvy = vy * 2, -vx * 2 -- perpendicular right
            end
        end
        entity_exertHairForce(me, v.hvx, v.hvy, 0.017)
    end
    
    local hairOffsX, hairOffsY = v.vector_fromDeg(entity_getRotation(me), -45 * scy)
    
    entity_setHairHeadPosition(me, entity_x(me) + hairOffsX, entity_y(me) + hairOffsY)
    entity_updateHair(me, dt)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setMaxSpeed(me, 500)
	end
end

function exitState(me)
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
	entity_setMaxSpeed(me, 600)
	return true
end

function songNote(me, note)
end
