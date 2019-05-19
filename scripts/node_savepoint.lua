if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.done = false

function init(me)
	node_setCursorActivation(me, true)
end
	
function activate(me)
	local n = getNaija()
	local node = entity_getNearestNode(n, "avatar_nosave")
	if not node_isEntityIn(node, n) then
		savePoint(me)
	else
		playSfx("denied")
	end
end

function update(me, dt)
	if node_isEntityIn(me, getNaija()) then
		if node_isFlag(me, 0) then
			pickupGem("savepoint")
			node_setFlag(me, 1)
		end
	end
end
