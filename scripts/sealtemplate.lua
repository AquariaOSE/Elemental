if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.flag = 0
v.node = 0
v.gfx = ""
function v.commonInit(me, g, f)
	v.gfx = g
	v.flag = f
	setupEntity(me, v.gfx)
	entity_setEntityType(me, ET_NEUTRAL)
	--[[
	if not isFlag(v.flag, 0) then
		entity_alpha(me, 0)
	end
	]]--
	entity_setWeight(me, 200)
	if isFlag(v.flag, 0) then
		debugLog("SETTING MOVABLE to TRUE")
		entity_setProperty(me, EP_MOVABLE, true)
	else
		entity_setProperty(me, EP_MOVABLE, false)
	end
	--entity_setActivation(me, AT_CLICK, 512, 32)
end

function hitSurface(me)
end

function update(me, dt)
	if v.node == 0 then
		v.node = entity_getNearestNode(me, v.gfx)
	end
	if isFlag(v.flag, 0) then
		entity_updateMovement(me, dt)
		local x = node_x(v.node)
		local y = node_y(v.node)
		--debugLog(string.format("node(%d, %d)", x, y))
		if entity_isPositionInRange(me, x, y, 64) then
			--debugLog("IN RANGE!")
			entity_stopPull(me)
			entity_setProperty(me, EP_MOVABLE, false)
			setFlag(v.flag, 1)			
		end
	else
		entity_setPosition(me, node_x(v.node), node_y(v.node))
	end
end

function activate(me)
--[[
	if isFlag(v.flag, 0) then
		entity_alpha(me, 0, 1)
		spawnParticleEffect("Collect", entity_x(me), entity_y(me))
		setFlag(v.flag, 1)
		entity_setActivation(me, AT_NONE)
	end
	]]--
end

function enterState(me, state)
end

function exitState(me, state)
end


