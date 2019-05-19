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

function init(me)

    setupEntity(me, "paraplump/front", -1)
    entity_setCollideRadius(me, 180)
    entity_setBounce(me, 0.2)	
    entity_setCanLeaveWater(me, true)
    entity_setHealth(me, 6)

    entity_setDamageTarget(me, DT_ENEMY_POISON, true)
    entity_setDeathParticleEffect(me, "anemoneexplode")

    entity_setFillGrid(me, true)
    
    entity_scale(me, 1.3, 1.15)
    entity_alpha(me, 0.7)
end

function postInit(me)
    if entity_isFlag(me, 1) then
        entity_setFillGrid(me, false)
        reconstructEntityGrid()
        entity_delete(me)
    end
end

function update(me, dt)
    entity_handleShotCollisions(me)
end

function damage(me, attacker, bone, damageType, dmg)
    if (damageType == DT_AVATAR_ENERGYBLAST and dmg >= 1) or damageType == DT_AVATAR_SHOCK or damageType == DT_AVATAR_VINE or damageType == DT_AVATAR_BITE then
        playNoEffect()
        return false
    end
    return damageType == DT_ENEMY_POISON or damageType == DT_ENEMY_ACTIVEPOISON
end

function enterState(me)
    if entity_isState(me, STATE_DEAD) then
        entity_setFillGrid(me, false)
        reconstructEntityGrid()
        entity_setFlag(me, 1)
    end
end

function exitState(me)
end

function hitSurface(me)
end

function activate(me)
end
