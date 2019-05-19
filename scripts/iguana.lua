-- ================================================================================================
-- I G I U A N A    (based on Euglena) (HACK HACK HACK HACK!!1)
-- ================================================================================================
-- added just right before release. Hope it's not too quirky -- FG


if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/inc_util.lua"))

-- ================================================================================================
-- L O C A L   V A R I A B L E S
-- ================================================================================================

local STATE_PUSHOFF = 1000

v.interestTimer = 0
v.interest = false
v.n = 0

v.hairtimer = 0
v.hairup = false
v.hvx = 0
v.hvy = 0
v.onwall = false
v.walldir = false
v.incurrent = false
v.jumpT = 0
v.ignoreWallT = 0
v.tailpos = 0 -- bone
v.lastx = 0
v.lasty = 0

-- ================================================================================================
-- F U N C T I O N S
-- ================================================================================================

function init(me)
	setupBasicEntity(
	me,
	"",						-- texture
	10,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	32,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	100,								-- sprite width
	200,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1							-- updateCull -1: disabled, default: 4000
	)
    
    entity_initSkeletal(me, "iguana_side")
	
	entity_setDropChance(me, 0)
	
	if chance(50) then
		v.interest = true
	end
    
	
	entity_addVel(me, math.random(1000)-500, math.random(1000)-500)
	--entity_setDeathParticleEffect(me, "TinyGreenExplode")
    
    entity_setCollideRadius(me, 64)
	
	entity_setMaxSpeed(me, 700)
	
	entity_setCanLeaveWater(me, true)
    
    local sc = math.random(850, 1050) / 1000
    entity_scale(me, sc, sc)
    
    entity_initHair(me, 40, 6 * sc, 48 * sc, "iguana/tail") -- self, divisions, lengthPerDiv, width, gfx
    
    esetv(me, EV_WALLOUT, 16)
    entity_setBeautyFlip(me, false)
    
    v.tailpos = entity_getBoneByIdx(me, 5)
    
    entity_animate(me, "idle", -1)
    
    entity_setUpdateCull(me, -1)
    
end

function postInit(me)
    entity_animate(me, "idle", -1)
end

local function updateNormalAnim(me, incurrent, force)
    if not force and v.incurrent == incurrent then
        return
    end
    
    if incurrent then
        entity_animate(me, "idle", -1)
        v.incurrent = true
    else
        entity_animate(me, "swim", -1)
        v.incurrent = false
    end
end

function postInit(me)
    v.n = getNaija()
    
    local vx, vy = v.vector_fromDeg(math.random(0, 360), 300)
    entity_addVel(me, vx, vy)
end

-- the entity's main update function
function update(me, dt)

    entity_handleShotCollisions(me)
    
    if entity_checkSplash(me) then
        if entity_isUnderWater(me) then
            entity_setWeight(me, 0)
        else
            entity_setWeight(me, 800)
            local vx, vy = vector_setLength(entity_velx(me), entity_vely(me), 300) -- shoot out a bit
            entity_addVel(me, vx, vy)
            entity_setMaxSpeedLerp(me, 5)
            entity_setMaxSpeedLerp(me, 1, 4)
        end
    end
    
    local rotoffs = 0

    if not v.onwall then
    
        
        --rotoffs = 0
        
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
        
        
        local current = entity_updateCurrents(me, dt)
        updateNormalAnim(me, current)
        
        entity_updateMovement(me, dt)
        entity_flipToVel(me)
        
        local x, y = entity_getPosition(me)
        if current then
            -- rotate based on actual movement dir
            local vx, vy = v.makeVector(x, y, v.lastx, v.lasty)
            entity_rotateToVec(me, -vx, -vy, 0.2) -- HACK: dunno but works
        else
            entity_rotateToVel(me, 0.2) -- does not work properly when in current
        end
        v.lastx = x
        v.lasty = y
        
        --if entity_isUnderWater(me) then
            v.interestTimer = v.interestTimer + dt
            if v.interestTimer > 12 then
                v.interest = not v.interest
                v.interestTimer = math.random(3)
            end
        --end
        

    else
        -- on wall
        if v.walldir then
            entity_moveAlongSurface (me, dt, 150)
        else
            entity_moveAlongSurface (me, dt, -150)
        end
        entity_rotateToSurfaceNormal(me, 0.13)
        entity_rotateOffset(me, 90)
        if v.walldir then
            rotoffs = -90
        else
            rotoffs = 90
        end
    end
    
    entity_rotateOffset(me, rotoffs)
    
    
    if v.jumpT >= 0 then
        v.jumpT = v.jumpT - dt
        if v.jumpT <= 0 then
            entity_setState(me, STATE_PUSHOFF)
        end
    end
    
    if v.ignoreWallT >= 0 and entity_isUnderWater(me) then
        entity_doCollisionAvoidance(me, dt, 10, 0.1)
        entity_doCollisionAvoidance(me, dt, 4, 0.5)
        v.ignoreWallT = v.ignoreWallT - dt
    end
    
    
    local scx, scy = entity_getScale(me)
    
    -- FG: tail whipping here
    if not v.incurrent and v.hairtimer >= 0 then
        v.hairtimer = v.hairtimer - dt
        if v.hairtimer <= 0 then
            v.hairtimer = 0.1 + (40 / entity_getVelLen(me)) -- adjust whip frequency to swim speed
            v.hairup = not v.hairup -- switch direction
            local vx, vy = entity_velx(me), entity_vely(me)
            if v.hairup then
                v.hvx, v.hvy = -vy * 2, vx * 2 -- perpendicular left
            else
                v.hvx, v.hvy = vy * 2, -vx * 2 -- perpendicular right
            end
        end
        entity_exertHairForce(me, v.hvx, v.hvy, 0.003)
    end
    
    entity_setHairHeadPosition(me, bone_getWorldPosition(v.tailpos))
    entity_updateHair(me, dt)
    
end

function enterState(me)
    if entity_isState(me, STATE_IDLE) then
        updateNormalAnim(me, v.incurrent, true)
    elseif entity_isState(me, STATE_PUSHOFF) then
        if v.onwall then
            v.onwall = false
            entity_applySurfaceNormalForce(me, math.random(350, 700))
            local t = entity_animate(me, "pushoff")
            entity_setStateTime(me, t)
            v.ignoreWallT = math.random(200, 1000) / 100
        else
            entity_setState(me, STATE_IDLE)
        end
    end
end

function exitState(me)
end

function hitSurface(me)
    if not v.onwall and (v.ignoreWallT <= 0 or not entity_isUnderWater(me)) then
        v.onwall = entity_clampToSurface(me)
        if v.onwall then
            v.walldir = chance(50)
            if v.walldir == entity_isfh(me) then
                entity_fh(me) -- always face wall
            end
            v.jumpT = math.random(200, 1000) / 100
            entity_animate(me, "crawl", -1)
        end
    end
end

function damage(me, attacker, bone, damageType, dmg)
	return true
end

function songNote(me, note)
end

function song()
end

function songNoteDone()
end

function animationKey(me, k)
end
