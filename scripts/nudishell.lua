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
-- NUDISHELL (Stripped down version of nudicommon)
-- ================================================================================================

 
function init(me)
	setupBasicEntity(
	me,
	"nudi-shell",					-- texture
	3,								-- health
	1,								-- manaballamount
	1,								-- exp
	0,								-- money
	20,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	3000							-- updateCull -1: disabled, default: 4000
	)
    
	entity_setMaxSpeed(me, 300)
	entity_setEntityType(me, ET_NEUTRAL)
    entity_setProperty(me, EP_MOVABLE, true)
	entity_setAllDamageTargets(me, false)
    entity_setWeight(me, 300)
end

function update(me, dt)
	entity_handleShotCollisions(me)
	entity_updateMovement(me, dt)
	entity_touchAvatarDamage(me, 60, 0, 1200)
end

function enterState(me)
end

function exitState(me)
end

function hitSurface(me)
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

function activate(me)
end

function dieNormal(me)
end

