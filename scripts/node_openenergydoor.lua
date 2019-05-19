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

--dofile("scripts/inc_flags.lua")

-- open types
local OPEN_CLOSED = 0
local OPEN_ORB = 1
local OPEN_FORCE = 2
local OPEN_DEBUG = 3 -- not saved

v.needinit = true
v.activated = false
v.camshown = false

function init(me)
	--node_setCursorActivation(me, v.isDebug())
end

function v.doActivate(me, showcam, atype)

    if v.activated then
        return
    end
    
    if v.camshown then
        showcam = false
    end
    
    debugLog("openenergydoor activate!")
    
    local near = me
    local cam = 0
    local c = node_getContent(me)
    if c ~= "" then
        cam = node_getNearestNode(me, c)
        near = cam
    end
    debugLog("using node " .. node_getName(near))
    local energyOrb = node_getNearestEntity(me, "EnergyOrb")
	if energyOrb ~= 0 or atype ~= OPEN_ORB then
        local isnear = false
        local charged = false
        
        if energyOrb ~= 0 then
            isnear = node_isEntityInRange(me, energyOrb, 40)
            charged = entity_isState(energyOrb, STATE_CHARGED)
            if isnear then debugLog("isnear: YES") else debugLog("isnear: NOT") end
            if charged then debugLog("charged: YES") else debugLog("charged: NOT") end
            
            -- HACK: energyorb does not send itself correctly, autodetect if we have an orb or not
            if isnear and charged then
                atype = OPEN_ORB
            end
        end
        
        if --[[(atype == OPEN_DEBUG and v.isDebug() and getNodeToActivate() == me)
        or]] (atype == OPEN_FORCE)
        or (atype == OPEN_ORB and charged and isnear) then
            local door = node_getNearestEntity(near, "EnergyDoor")
            if door ~= 0 then
                v.activated = true -- required, otherwise watch() may lead to C stack overflow
                debugLog("door id: " .. entity_getID(door))
                if cam ~= 0 and showcam then
                    v.camshown = true
                    debugLog("cam to " .. c)
                    cam_toNode(cam)
                    entity_setState(door, STATE_OPEN)
                    watch(2)
                    cam_toEntity(getNaija())
                else
                    debugLog("door open without cam")
                    entity_setState(door, STATE_OPEN)
                end
                
                if atype == OPEN_ORB then
                    local id = entity_getID(energyOrb)
                    node_setFlag(me, id)
                    debugLog("door open saved, orb id: " .. id)
                elseif atype == OPEN_FORCE then
                    node_setFlag(me, -1)
                else
                    debugLog("door not saved, was debug open")
                    v.activated = false -- for debugging
                end
            else
                debugLog("openenergydoor: door not found!")
            end
        end
	end
    
    --v.nodeDebugVis(me, node_getFlag(me) ~= 0, 2)
end

function activate(me, who) -- if user clicked on node, who is 0
    local atype = OPEN_FORCE
    if who == 0 then
        atype = OPEN_DEBUG
        v.activated = false
    end
    v.doActivate(me, true, atype)
end

function v.loadActivationState(me)
    local orbId = node_getFlag(me)
    --v.nodeDebugVis(me, orbId ~= 0, 2)
    if orbId > 0 then
        debugLog("door was opened, orbId: " .. orbId)
        local e = getEntityByID(orbId)
        
        -- in case the orb was spawned dynamically, the ID may not exist; in this case, create one and use that
        if e == 0 or not entity_isName(e, "EnergyOrb") then
            debugLog("orb not found, creating")
            e = createEntity("EnergyOrb")
        end
        
        debugLog("... found orb, setting pos")
        entity_setPosition(e, node_getPosition(me))
        entity_setState(e, STATE_CHARGED)
        v.doActivate(me, false, OPEN_FORCE) -- trigger it early to suppress camera movement
        v.activated = true
    elseif orbId < 0 then
        v.doActivate(me, false, OPEN_FORCE) -- trigger it early to suppress camera movement
        v.activated = true
    end
end

function update(me, dt)

    if v.needinit then
        v.needinit = false
        v.loadActivationState(me)
    end
    
    -- orbholder seems to be lazy sometimes and forgets to activate us, so we check it here to be sure
    if not v.activated then
        local orb = node_getNearestEntity(me, "EnergyOrb")
        if orb ~= 0 and entity_isState(orb, STATE_CHARGED) and node_isEntityIn(me, orb) then
            debugLog("openenergydoor: fallback activate!")
            v.doActivate(me, true, OPEN_ORB)
        end
    end
end
