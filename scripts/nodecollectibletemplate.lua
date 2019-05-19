if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.done = false

function v.commonUpdate(me, object, flag)
	if isFlag(flag, 1) and not v.done then
		v.done = true
		local collectible = createEntity(object, "", node_x(me), node_y(me))
		entity_setState(collectible, STATE_COLLECTEDINHOUSE)
	end
end
