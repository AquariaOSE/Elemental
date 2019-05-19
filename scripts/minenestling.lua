-- Copyright (C) 2007, 2010 - Bit-Blot
--
-- This file is part of Aquaria.
--
-- Aquaria is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
--
-- See the GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

-- ================================================================================================
-- mineoctonestling      (based on Eviljelly)
-- ================================================================================================


-- ================================================================================================
-- L O C A L  V A R I A B L E S 
-- ================================================================================================

v.revertTimer = 0
v.baseSpeed = 100
v.excitedSpeed = 140
v.runSpeed = 190
v.useMaxSpeed = 0
v.sx = 0
v.sy = 0
v.sz = 0.8
v.transition = false
v.burstTimer = 0
v.collisionSegs = 40

-- ================================================================================================
-- FUNCTIONS
-- ================================================================================================

local function doIdleScale(me)
	entity_scale(me, 0.75*v.sz, 1*v.sz)
	entity_scale(me, 1*v.sz, 0.75*v.sz, 1.5, -1, 1, 1)
end

function init(me)
	setupBasicEntity(
	me,
	"minenestling/head",						-- texture
	7,							-- health
	2,							-- manaballamount
	2,							-- exp
	10,							-- money
	16,							-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	300,							-- sprite width	
	300,							-- sprite height
	1,							-- particle "explosion" type, 0 = none
	0,							-- 0/1 hit other entities off/on (uses collideRadius)
	4000,							-- updateCull -1: disabled, default: 4000
	1
	)

    entity_initHair(me, v.collisionSegs, 4, 60, "minenestling/tentacles")
	
	--entity_setRenderPass(me, 3)
		
	entity_setDeathParticleEffect(me, "TinyRedExplode")
	v.useMaxSpeed = v.baseSpeed
	entity_setEntityType(me, ET_ENEMY)
	
	entity_setState(me, STATE_IDLE)
	entity_setDropChance(me, 10, 1)
		
	doIdleScale(me)
	v.sx, v.sy = entity_getScale(me)
	
	--entity_setColor(me, 1, 0.5, 0.75)
	
	entity_setMaxSpeed(me, v.excitedSpeed)
	
	--entity_addIgnoreShotDamageType(me, DT_AVATAR_BITE)
	--entity_addIgnoreShotDamageType(me, DT_AVATAR_VINE)
    
    entity_setDamageTarget(me, DT_ENEMY_BEAM, false)
end

function postInit(me)
    v.n = getNaija()
    entity_setTarget(me, v.n)
end

function songNote(me, note)
end

function update(me, dt)
	entity_touchAvatarDamage(me, 16, 1, 1000)
	v.burstTimer = v.burstTimer + dt
	if v.burstTimer > 1 then
		entity_setMaxSpeedLerp(me, 1)
		entity_setMaxSpeedLerp(me, 6, 0.5, 1, 1)
		v.burstTimer = 0
	end

	if entity_isState(me, STATE_IDLE) and not v.transition and not entity_isScaling(me) then
		entity_scale(me, 0.75*v.sz, 1*v.sz, 0.2)
		v.transition = true
	end
	if v.transition then
		if not entity_isScaling(me) then
			doIdleScale(me)
			v.transition = false
		end
	end
	entity_handleShotCollisions(me)
	
	if v.revertTimer > 0 then
		v.revertTimer = v.revertTimer - dt
		if v.revertTimer < 0 then
			v.useMaxSpeed = v.baseSpeed
			entity_setMaxSpeed(me, v.baseSpeed)
		end
	end
	-- cheap hack
	if not avatar_isBursting() then
		entity_doEntityAvoidance(me, dt, 64, 0.8)
	end
    
    if entity_isTargetInRange(me, 1000) then
        if not entity_isTargetInRange(me, 64) then
            entity_moveTowardsTarget(me, dt, 1000)
        end
    end
	
	entity_doCollisionAvoidance(me, dt, 3, 1.0)
	
	entity_doSpellAvoidance(me, dt, 200, 0.8)
	
	entity_updateCurrents(me, dt)
	
	entity_rotateToVel(me, 0.1)
	entity_updateMovement(me, dt * 0.75)

    entity_setHairHeadPosition(me, entity_x(me), entity_y(me))
	entity_updateHair(me, dt)
    
    entity_handleShotCollisionsHair(me, v.collisionSegs)
	if entity_collideHairVsCircle(me, v.n, v.collisionSegs) then
		entity_touchAvatarDamage(me, 64, 1, 1000)
	end	
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		v.useMaxSpeed = v.baseSpeed
		entity_setMaxSpeed(me, v.baseSpeed)
		entity_animate(me, "idle", LOOP_INF)
		
		local x = math.random(2000)-1000
		local y = math.random(2000)-1000
		entity_addVel(me,x,y)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_BITE then
		entity_setHealth(me, 0)
	end
	return true
end

function exitState(me)
end

function dieNormal(me)
    if chance(66) then
        spawnIngredient("smalltentacle", entity_getPosition(me))
    end
end
