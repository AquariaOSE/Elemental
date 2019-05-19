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

-- VOLVOXTHREE

local MOVE_STATE_UP = 0
local MOVE_STATE_DOWN = 1
local MOVE_STATE_AWAY = 2

v.moveState = 0
v.moveTimer = 0
v.velx = 0

v.n = 0



function init(me)

	setupBasicEntity(
	me,
	"volvoxthree/glow",				-- texture
	2,								-- health
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
	
	entity_setEntityType(me, ET_NEUTRAL)
    entity_setDeathParticleEffect(me, "TinyGreenExplode")
	
	entity_setEntityLayer(me, 0)
		
	
    local sc = math.random(800, 1150) / 1000
    entity_scale(me, sc, sc)
    
    if chance(50) then
        entity_rotate(me, 360, 20, -1, 1)
    else
        entity_rotate(me, 360)
        entity_rotate(me, 0, 20, -1, 1)
    end
			
	entity_setState(me, STATE_IDLE)
	entity_setCull(me, false)

	entity_setCollideRadius(me, 50 * sc)
	
	entity_generateCollisionMask(me)
    entity_setMaxSpeed(me, 100)
	
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

	if v.moveState == MOVE_STATE_UP then
		entity_addVel(me, v.velx*dt, -600*dt)
		--entity_rotateToVel(me, 8)
		
	elseif v.moveState == MOVE_STATE_DOWN then
		entity_addVel(me, 0, 50*dt)
		--entity_rotateTo(me, 0, 8)
		entity_doCollisionAvoidance(me, dt, 15, 1)
		--entity_doCollisionAvoidance(me, dt, 10, 0.5)
	elseif v.moveState == MOVE_STATE_AWAY then
		--entity_rotateTo(me, 0, 8)
	end

	entity_doCollisionAvoidance(me, dt, 12, 2)
	--[[
	entity_doEntityAvoidance(me, dt, 32, 1.0)
	entity_doCollisionAvoidance(me, 1.0, 8, 1.0)
	entity_updateCurrents(me, dt)
	]]--
	entity_updateMovement(me, dt)
	
	entity_handleShotCollisions(me)
	
end

function hitSurface(me)
end

function enterState(me)
	if entity_isState(me, STATE_IDLE) then
		entity_setMaxSpeed(me, 40)
		entity_animate(me, "idle", LOOP_INF)
	end
end

function damage(me, attacker, bone, damageType, dmg, hx, hy)

	entity_setMaxSpeedLerp(me, 10)
	entity_setMaxSpeedLerp(me, 1, 2)
	
	v.moveState = MOVE_STATE_AWAY
	local vx = entity_x(me) - hx
	local vy = entity_y(me) - hy
	vx, vy = vector_setLength(vx, vy, 400)
	entity_addVel(me, vx, vy)
	
	--entity_rotateToVel(me, 2)
	return true
end

function exitState(me)
end

function dieNormal(me)
    if chance(25) then
        spawnIngredient("PlantLeaf", entity_getPosition(me))
    elseif chance(5) then
        spawnIngredient("GreenBulb", entity_getPosition(me))
    end
end

