if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

function init(me)
end

function update(me, dt)
	local n = getNaija()
	if not isForm(FORM_FISH) and node_isEntityIn(me, n) then
		local x = entity_x(n) - node_x(me)
		local y = entity_y(n) - node_y(me)
		avatar_fallOffWall()
		vector_setLength(x, y, 20000*dt)
		entity_clearVel(n)
		entity_addVel(n, x, y)
		entity_addVel2(n, x, y)
		
		entity_warpLastPosition(n)
	end
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
