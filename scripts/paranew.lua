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

-- PARANEW

v.blupTimer = 0
v.dirTimer = 0
v.blupTime = 3.0

v.sz = 1.0
v.dir = 0

local MOVE_STATE_UP = 0
local MOVE_STATE_DOWN = 1
local MOVE_STATE_AWAY = 2

v.moveState = 0
v.moveTimer = 0
v.velx = 0
v.waveDir = 1
v.waveTimer = 0
v.soundDelay = 0
v.glows = nil

v.n = 0

v.seen = false

local function doIdleScale(me)
	entity_scale(me, 1*v.sz, 1.05*v.sz)
	entity_scale(me, 1.1*v.sz, 0.95*v.sz, v.blupTime, -1, 1, 1)
end

function init(me)
	v.glows = {}

	setupBasicEntity(
	me,
	"",								-- texture
	6,								-- health
	2,								-- manaballamount
	2,								-- exp
	10,								-- money
	0,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, 0 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000,							-- updateCull -1: disabled, default: 4000
	0
	)

	entity_initSkeletal(me, "paranew")
	
	entity_setEntityType(me, ET_NEUTRAL)
	
	entity_setEntityLayer(me, 0)
	

	
	
	doIdleScale(me)
	
	
		
	entity_setState(me, STATE_IDLE)
	--entity_setCullRadius(me, -3)
	entity_setCull(me, false)
	
	--hide glow bones, back, and tentacles
	bone_alpha(entity_getBoneByIdx(me, 4), 0, 0)
	bone_alpha(entity_getBoneByIdx(me, 5), 0, 0)
	bone_alpha(entity_getBoneByIdx(me, 2), 0, 0)
	bone_alpha(entity_getBoneByIdx(me, 3), 0, 0)
	bone_alpha(entity_getBoneByIdx(me, 6), 0, 0)
	bone_alpha(entity_getBoneByIdx(me, 1), 0, 0)

	entity_setCollideRadius(me, 90)
	
	entity_setInternalOffset(me, 0, 64)
	
	entity_generateCollisionMask(me)
    
	entity_setDamageTarget(me, DT_AVATAR_BITE, false)
    
    entity_setDeathParticleEffect(me, "anemoneexplode")
	
end

function postInit(me)
	v.n = getNaija()
	entity_update(me, math.random(100)/100.0)
end

function update(me, dt)
	--dt = dt * 1.5
	local sx,sy = entity_getScale(me)
		
	v.moveTimer = v.moveTimer - dt
	if v.moveTimer < 0 then
		if v.moveState == MOVE_STATE_DOWN then		
			v.moveState = MOVE_STATE_UP
			entity_setMaxSpeedLerp(me, 1.5, 0.2)
			--entity_scale(me, 0.75, 1, 1, 1, 1)
			v.moveTimer = 3 + math.random(200)/100.0
			--entity_sound(me, "JellyBlup")
		elseif v.moveState == MOVE_STATE_UP then
			v.velx = math.random(400)+100
			if math.random(2) == 1 then
				v.velx = -v.velx
			end
			v.moveState = MOVE_STATE_DOWN
			entity_setMaxSpeedLerp(me, 1, 1)
			v.moveTimer = 5 + math.random(200)/100.0 + math.random(3)
		else
			v.moveState = MOVE_STATE_DOWN
		end
	end
	
	v.waveTimer = v.waveTimer + dt
	if v.waveTimer > 2 then
		v.waveTimer = 0
		if v.waveDir == 1 then
			v.waveDir = -1
		else
			v.waveDir = 1
		end
	end

	if v.moveState == MOVE_STATE_UP then
		entity_addVel(me, v.velx*dt, -600*dt)
		entity_rotateToVel(me, 8)
		
	elseif v.moveState == MOVE_STATE_DOWN then
		entity_addVel(me, 0, 50*dt)
		entity_rotateTo(me, 0, 8)
		entity_exertHairForce(me, 0, 200, dt*0.6, -1)
		entity_doCollisionAvoidance(me, dt, 15, 1)
		--entity_doCollisionAvoidance(me, dt, 10, 0.5)
	elseif v.moveState == MOVE_STATE_AWAY then
		entity_rotateTo(me, 0, 8)
	end

	entity_doCollisionAvoidance(me, dt, 12, 2)
	--[[
	entity_doEntityAvoidance(me, dt, 32, 1.0)
	entity_doCollisionAvoidance(me, 1.0, 8, 1.0)
	entity_updateCurrents(me, dt)
	]]--
	entity_updateMovement(me, dt)
	
	entity_handleShotCollisions(me)
	
	if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0) then
		if avatar_isBursting() and avatar_isLockable() and entity_setBoneLock(v.n, me) then
			-- yay!
		else
			local x, y = entity_getVectorToEntity(me, v.n, 1000)
			entity_addVel(v.n, x, y)
		end
	end
	
	--[[
	local bx, by = bone_getWorldPosition(entity_getBoneByIdx(me, 0))
	entity_setHairHeadPosition(me, bx, by)
	entity_updateHair(me, dt*5)
	]]--
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setMaxSpeed(me, 40)
		entity_animate(me, "idle", LOOP_INF)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	if damageType == DT_AVATAR_ENERGYBLAST or damageType == DT_AVATAR_VINE then
       		return false
  	end
	return true	
end

function exitState(me)
end
