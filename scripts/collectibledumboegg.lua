--FG TODO

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

n = 0

hatchMax = 5
hatchTimer = hatchMax

rollTimer = 0
rollMax = 2

hint = false

function init(me)
	setupEntity(me, "Collectibles/egg-dumbo")
	loadSound("Pet-Hatch")
end

function postInit(me)
	n = getNaija()
end

function update(me, dt)
	if isFlag(FLAG_PET_DUMBO, 1) then
		entity_alpha(me, 0)
	end
	
	if isFlag(FLAG_PET_DUMBO, 0) and not hint and entity_isEntityInRange(me, n, 256) then
		playSfx("secret")
		setControlHint("You've discovered a LightCell Pet Egg!", 0, 0, 0, 6)
		hint = true
	end
	
	--[[
	if entity_isState(me, STATE_IDLE) and entity_getAlpha(me) == 1 and isFlag(FLAG_PET_DUMBO, 0) then
		hatchTimer = hatchTimer + dt*0.5
		if hatchTimer > hatchMax then
			hatchTimer = hatchMax
		end
	end
	]]--
	if entity_getAlpha(me) == 1 and isFlag(FLAG_PET_DUMBO, 0) then
		if entity_isEntityInRange(me, n, 300) then
			entity_offset(me, math.random(2)-1, 0)
			hatchTimer = hatchTimer - dt
			if hatchTimer < 0 then
				
				hatchTimer = 0
				entity_setState(me, STATE_HATCH)
			end
		else
			entity_offset(me, 0, 0)
			hatchTimer = hatchTimer + dt*0.5
			if hatchTimer > hatchMax then
				hatchTimer = hatchMax
			end
		end
	end
	
	rollTimer = rollTimer + dt
	if rollTimer >= rollMax then
		rollTimer = 0
		entity_rotate(me, 0)
		if chance(50) then
			entity_rotate(me, -30, 0.2, 3, 1, 1)
		else
			entity_rotate(me, 30, 0.2, 3, 1, 1)
		end
	end
end

function lightFlare(me)
	--[[
	if entity_getAlpha(me) == 1 and isFlag(FLAG_PET_DUMBO, 0) then
		hatchTimer = hatchTimer - 3.1
		if hatchTimer <= 0 then
			hatchTimer = 0
			
			entity_setState(me, STATE_HATCH)
		end
		spawnParticleEffect("DumboEggCharge", entity_x(me), entity_y(me))
	end
	]]--
end

function enterState(me, state)
	if entity_isState(me, STATE_HATCH) then
		playSfx("Pet-Hatch")
		entity_setStateTime(me, 2)
		
		entity_alpha(me, 0.7, 2)
		entity_scale(me, 1.2, 1.2, 2)
	end
end

function exitState(me, state)
	if entity_isState(me, STATE_HATCH) then
		
		setFlag(FLAG_PET_DUMBO, 1)
		e = setActivePet(FLAG_PET_DUMBO)
		
		if e ~= 0 then
			entity_setPosition(e, entity_x(me), entity_y(me))
		end
		
		playSfx("Secret")
		playSfx("Collectible")
	end
end
