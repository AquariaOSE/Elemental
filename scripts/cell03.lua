-- based on kuirlinghost and jellysmall

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Elemental/scripts/flags.lua"))

local STATE_CHASE = 1000
local STATE_WEIRD = 1001

v.rotvel = false
v.weirdT = 0
v.gaspT = 0
v.off = false
v.active = true
v.wakeupT = 1
v.collisionSegs = 40
glow = 0
bulb = 0
revertTimer = 0
baseSpeed = 150
excitedSpeed = 300
runSpeed = 600
useMaxSpeed = 0
pushed = false
shell = 0
soundDelay = 0
sx = 0
sy = 0
sz = 0.8
transition = false

function doIdleScale(me)
	entity_scale(me, 0.75*sz, 1*sz)
	entity_scale(me, 1*sz, 0.75*sz, 1.5, -1, 1, 1)
end

function init(me)
	setupBasicEntity(
	me,
	"Cell03",			-- texture
	1,								-- health
	0,								-- exp
	0,								-- manaballamount
	0,								-- money
	64,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
    local sc = math.random(80, 120) / 100
    entity_scale(me, sc, sc)
    entity_setAllDamageTargets(me, false)
    
    entity_setMaxSpeed(me, 450)
    entity_setState(me, STATE_IDLE)
    entity_setSegs(me, 2, 30, 0.5, 0.3, -0.018, 0.01, 3, 1)

    v.q = createQuad("Cell03", 13)
    sc = sc * 1.1
    quad_scale(v.q, sc, sc)
    quad_setBlendType(v.q, BLEND_ADD)
    quad_alpha(v.q, 0)
    		 
    v.q2 = createQuad("softglow-add", 13)
    quad_scale(v.q2, 2.5, 2.5)
    quad_setBlendType(v.q2, BLEND_ADD)
    quad_alpha(v.q2, 0)
    quad_color(v.q2, 0.5, 1, 0.5)

end

function postInit(me)
    n = getNaija()
    entity_setTarget(me, n)
    
    --entity_alpha(me, 0.4, 3, -1, 1)
end

function songNote(me, note)
	if getForm()~=FORM_NORMAL then
		return
	end
	
	--[[
	sx, sy = entity_getScale(me)
	entity_scale(me, sx, sy)
	sx = sx*1.1
	sy = sy*1.1
	if sx > 1.0 then
		sx = 1.0
	end
	if sy > 1.0 then
		sy = 1.0
	end
	entity_scale(me, sx, sy, 0.2, 1, -1)
	]]--

	--[[
	entity_setWidth(me, 128)
	entity_setHeight(me, 128)
	entity_setWidth(me, 512, 0.5, 1, -1)
	entity_setHeight(me, 512, 0.5, 1, -1)
	]]--
	
	bone_scale(shell, 1,1)
	bone_scale(shell, 1.1, 1.1, 0.1, 1, -1)
	
	entity_setMaxSpeed(me, excitedSpeed)
	revertTimer = 3
	transTime = 0.5
	r,g,b = getNoteColor(note)
	bone_setColor(bulb, r,g,b, transTime)
	r = (r+1.0)/2.0
	g = (g+1.0)/2.0
	b = (b+1.0)/2.0
	bone_setColor(shell, r,g,b, transTime)
end

function update(me, dt)
	if entity_isState(me, STATE_IDLE) and not transition and not entity_isScaling(me) then
		entity_scale(me, 0.75*sz, 1*sz, 0.2)
		transition = true
	end
	if transition then
		if not entity_isScaling(me) then
			doIdleScale(me)
			transition = false
		end
	end
	entity_handleShotCollisions(me)
	entity_findTarget(me, 1024)
	if not entity_hasTarget(me) then
		--entity_doCollisionAvoidance(me, dt, 4, 0.1)		
	end
	
	if revertTimer > 0 then
		soundDelay = soundDelay - dt
		if soundDelay < 0 then
			entity_sound(me, "JellyBlup", 1400+math.random(200))
			soundDelay = 4 + math.random(2000)/1000.0
		end
		revertTimer = revertTimer - dt
		if revertTimer < 0 then
			useMaxSpeed = baseSpeed
			entity_setMaxSpeed(me, baseSpeed)
			bone_setColor(shell, 1, 1, 1, 1)
		end
	end
	if entity_hasTarget(me) then
		if entity_isUnderWater(entity_getTarget(me)) then
			if getForm()==FORM_NORMAL or getForm()==FORM_NATURE then
					-- do something
				if entity_isTargetInRange(me, 1000) then
					if not entity_isTargetInRange(me, 64) then				
					entity_moveTowardsTarget(me, dt, 250)
					end
				end
			else
				if entity_isTargetInRange(me, 512) then		
					--entity_setMaxSpeed(me, 600)
					entity_setMaxSpeed(me, runSpeed)
					useMaxSpeed = runSpeed
					revertTimer = 0.1
					entity_moveTowardsTarget(me, dt, -250)
				end
			end		
		end
		
		--if not entity_isTargetInRange(me, 150) then
			
		--end
	end
	
	entity_doCollisionAvoidance(me, dt, 3, 1.0)
	entity_doEntityAvoidance(me, dt, 64, 0.2)
	entity_doSpellAvoidance(me, dt, 200, 0.8)
	
	entity_updateCurrents(me, dt*5)
	
	entity_rotateToVel(me, 0.1)
	entity_updateMovement(me, dt)	
end

function exitState(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		useMaxSpeed = baseSpeed
		entity_setMaxSpeed(me, baseSpeed)
		entity_animate(me, "idle", LOOP_INF)
		
		x = math.random(2000)-1000
		y = math.random(2000)-1000
		entity_addVel(me,x,y)
	end
end

function damage(me, attacker, bone, damageType, dmg)
    return me == attacker
end

function hitSurface(me)
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

function exitState(me)
end

function dieNormal(me)
	if chance(50) then
		spawnIngredient("Fishmeat", entity_x(me), entity_y(me))
	end
end
