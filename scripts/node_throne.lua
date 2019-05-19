if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

function init(me)
	node_setCursorActivation(me, true)
end

function update(me, dt)
end

function activate(me)
	local n = getNaija()
	avatar_fallOffWall()
	entity_idle(n)
	watch(0.1)
	entity_swimToNode(n, me)
	entity_watchForPath(n)
	
	
	entity_animate(n, "sitThrone", -1)

	overrideZoom(0.5, 2)
	
	watch(2)
	
	while (not isLeftMouse()) and (not isRightMouse()) do
		watch(FRAME_TIME)
	end
	
	entity_idle(n)
	entity_addVel(n, 0, -200)
	overrideZoom(1, 1)
	watch(1)
	overrideZoom(0)
end
