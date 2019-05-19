--FG TODO

-- based on energy barrier
if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

init_x = 0
init_y = 0

dist = 700

lastRot = -1

topy=0
btmy=0
leftx=0
rightx=0

halfWidth = 32

flicker 		= false
FLICKER_TIME1 	= 1.2
FLICKER_TIME2 	= 1.0
flickerTimer 	= FLICKER_TIME1
orient 			= ORIENT_NONE

function commonInit(me)
	setupEntity(me, "EnergyBarrierblue", 1)
	entity_setActivationType(me, AT_NONE)
	entity_setUpdateCull(me, 1024)
	entity_alpha(me, 0)
end

function update(me, dt)
	adjust = 25
	if entity_getRotation(me) ~= lastRot then
		lastRot = entity_getRotation(me)
		if entity_getRotation(me) < 90 then
			topy = findWall(entity_x(me), entity_y(me), 0, -1)
			btmy = findWall(entity_x(me), entity_y(me), 0, 1)
			leftx = entity_x(me)-halfWidth
			rightx = entity_x(me)+halfWidth
			orient = ORIENT_VERTICAL
			topy = topy + adjust
			btmy = btmy - adjust			
			entity_setWidth(me, rightx-leftx)
			entity_setHeight(me, btmy-topy)

		elseif entity_getRotation(me) < 180 then
			leftx = findWall(entity_x(me), entity_y(me), -1, 0)
			rightx = findWall(entity_x(me), entity_y(me), 1, 0)
			topy = entity_y(me)-halfWidth
			btmy = entity_y(me)+halfWidth
			orient = ORIENT_HORIZONTAL
			leftx = leftx + adjust
			rightx = rightx - adjust			
			entity_setHeight(me, rightx-leftx)
			entity_setWidth(me, btmy-topy)			
		end
	end
	
	if entity_isState(me, STATE_PULSE) then
		pulseTimer = pulseTimer - dt
		if pulseTimer < 0 then
			entity_setState(me, STATE_OFF)
		end
	end
	
	if entity_isState(me, STATE_FLICKER) then
		flickerTimer = flickerTimer - dt
		if flickerTimer < 0 then
			if flicker == false then
				flickerTimer = FLICKER_TIME1
			elseif flicker == true then
				flickerTimer = FLICKER_TIME2
			end
			if flicker then
				entity_alpha(me, 0, 0.1)
				flicker = false
				--setSceneColor(1, 1, 1, 0.5)
			else
				entity_playSfx(me, "FizzleBarrier")
				if entity_getRotation(me) == 0 then
					spawnParticleEffect("EnergyBarrierFlickerblue", entity_x(me), entity_y(me))
				else
					spawnParticleEffect("EnergyBarrierFlickerblue2", entity_x(me), entity_y(me))
				end
				entity_alpha(me, 1, 0.1)
				flicker = true
				--setSceneColor(1, 0.5, 0.5, 0.5)
			end
		end
	end
	
	if entity_isState(me, STATE_IDLE)
	or (entity_isState(me, STATE_FLICKER) and flicker==true)
	or entity_isState(me, STATE_PULSE)
	then
		--debugLog("state is idle")
		e = getFirstEntity()
		while e ~= 0 do
			--debugLog("Found an entity")
			if (entity_getEntityType(e)==ET_ENEMY or entity_getEntityType(e)==ET_AVATAR)
			and not entity_isProperty(e, EP_MOVABLE) and not entity_isDead(e) and entity_getCollideRadius(e) > 0 and not eisv(e, EV_TYPEID, EVT_PET) then
				--debugLog("Found an enemy / the player")
				if entity_x(e) >= leftx and entity_x(e) <= rightx
				and entity_y(e) >= topy and entity_y(e) <= btmy then
					vel = 0
					if orient == ORIENT_VERTICAL then	
						if entity_x(e) > entity_x(me) then
							entity_push(e, 1000, entity_vely(e), 0.5, 1000)
						else
							entity_push(e, -1000, entity_vely(e), 0.5, 1000)
						end
					elseif orient == ORIENT_HORIZONTAL then
						if entity_y(e) > entity_y(me) then
							entity_push(e, entity_velx(e), 1000, 0.5, 1000)
						else
							entity_push(e, entity_velx(e), -1000, 0.5, 1000)
						end
					end
					spawnParticleEffect("HitEnergyBarrierblue", entity_x(e), entity_y(e))
					if entity_getEntityType(e) == ET_AVATAR then
						debugLog("hit avatar")
						entity_damage(e, me, 2.5)
					else
						entity_damage(e, me, 5)
					end
				end
			end
			if entity_isName(e, "MetalObject") then
				if entity_x(e) > leftx and entity_x(e) < rightx
				and entity_y(e) > topy and entity_y(e) < btmy then
					entity_setState(me, STATE_DISABLED)
				end
			end
			e = getNextEntity()
		end
	end
--[[
	if not entity_isState(me, STATE_OPENED) and not entity_isState(me, STATE_OPEN) then
		init_x = entity_x(me)
		init_y = entity_y(me)
	end
	if entity_getState(me)==STATE_OPEN then
		--reconstructGrid()
		if not entity_isInterpolating(me) then
		
		
			entity_setState(me, STATE_OPENED)
		end
	end
	]]--
end

function enterState(me)
	if entity_isState(me, STATE_DISABLED) then
		entity_alpha(me, 0)
	elseif entity_isState(me, STATE_PULSE) then
		entity_alpha(me, 1, 0.1)
		spawnParticleEffect("EnergyBarrierFlickerBlue", entity_x(me), entity_y(me))
		pulseTimer = 1

	elseif entity_isState(me, STATE_OFF) then
		entity_alpha(me, 0, 0.1)
	end
--[[
	if entity_isState(me, STATE_OPEN) then
		if entity_getRotation(me)==0 then
			entity_interpolateTo(me, init_x, init_y-dist, 2)
		elseif entity_getRotation(me) == 90 then
			entity_interpolateTo(me, init_x+dist, init_y, 2)
		elseif entity_getRotation(me) == 270 then
			entity_interpolateTo(me, init_x-dist, init_y, 2)			
		end
	elseif entity_isState(me, STATE_OPENED) then
		if entity_getRotation(me)==0 then
			entity_setPosition(me, init_x, init_y-dist)
		elseif entity_getRotation(me) == 90 then
			entity_setPosition(me, init_x+dist, init_y)
		elseif entity_getRotation(me) == 270 then
			entity_setPosition(me, init_x-dist, init_y)			
		end
		reconstructGrid()		
	end
	]]--
end

function exitState(me)
end

function hitSurface(me)
end
