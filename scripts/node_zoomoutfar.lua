if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.n = 0
v.wasIn = false

function init(me)
	v.n = getNaija()
end

function update(me, dt)
	if node_isEntityIn(me, v.n) then
		overrideZoom(0.3, 1)
		v.wasIn = true
	else
		if v.wasIn then
			v.wasIn = false
			overrideZoom(0, 4)
		end
	end
end
