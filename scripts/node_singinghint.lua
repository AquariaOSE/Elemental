if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

function init(me)
end

function update(me, dt)
	if isFlag(FLAG_NAIJA_SINGINGHINT, 0) then
		if node_isEntityIn(me, getNaija()) then
			if isPlat(PLAT_MAC) then
				setControlHint(getStringBank(82), 0, 1, 0, 12)
			else
				setControlHint(getStringBank(62), 0, 1, 0, 12)
			end
			setFlag(FLAG_NAIJA_SINGINGHINT, 1)
		end
	end
end
