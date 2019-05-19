if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

function init(me)
	node_setCursorActivation(me, true)
end
	
function activate(me)
	local n = getNaija()
	avatar_fallOffWall()
	entity_idle(n)
    watch(0.1)
	entity_setInvincible(n, true)
	entity_swimToNode(n, me)
	entity_watchForPath(n)
	
	entity_animate(n, "sitBack", LOOP_INF)

	overrideZoom(0.5, 2)
	watch(2)
	
	emote(EMOTE_NAIJASIGH)
	
	while (not isLeftMouse()) and (not isRightMouse()) do
		watch(FRAME_TIME)		
	end
	
	entity_idle(n)
	entity_addVel(n, 0, -200)
	overrideZoom(1, 1)
	esetv(n, EV_NOINPUTNOVEL, 0)
	watch(1)
	esetv(n, EV_NOINPUTNOVEL, 1)
	overrideZoom(0)
	entity_setInvincible(n, false)
end

function update(me, dt)
end
