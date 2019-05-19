-- based on weedbarrier

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

v.n = 0
timeMult = -1

function init(me)
    setupEntity(me, "barrier", 1)
    entity_setActivationType(me, AT_NONE)
    entity_setHealth(me, 0)
    entity_setDamageTarget(me, true)
    entity_setDeathParticleEffect(me, "tinyredexplode")
    entity_setCollideRadius(me, 150)
end

function postInit(me) 
    v.n = getNaija()
end

function update(me, dt)
    entity_handleShotCollisions(me)
    
    -- HMM: does this always work? based on fishpass node...
    if entity_touchAvatarDamage(me, entity_getCollideRadius(me), 0) then
        local x, y = entity_getVectorToEntity(me, v.n)
        vector_setLength(x, y, 20000*dt)
        entity_clearVel(v.n)
        entity_addVel(v.n, x, y)
        entity_addVel2(v.n, x, y)
        entity_warpLastPosition(v.n)
    end
end

function enterState(me)
end

function damage(me, attacker, bone, damageType, dmg)
    if attacker == v.n then
        return true
    end
    return false
end

function exitState(me)
end

function hitSurface(me)
end
