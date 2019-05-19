if not v then v = {} end

v.naijain = false
v.n = 0

function init(me)
	v.n = getNaija()
end

function update(me)
	if node_isEntityIn(me, v.n) and not v.naijain then
		overrideZoom(0.5, 1)
		v.naijain = true
	elseif not node_isEntityIn(me, v.n) and v.naijain then
		v.naijain = false
		overrideZoom(0, 1)
	end
end
