if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Elemental/scripts/mm_common.lua"))

v.spawnEntity = "mm_minimapper"

function init(me)
	node_setCursorActivation(me, false)
	local thisMap
    local mapArr = v.mapArr
	
	-- Search mapArr for the map's name
	local thisMapName = string.lower(getMapName())
	for i,list in ipairs(mapArr) do
		if string.lower(list[1]) == thisMapName then
			thisMap = i 
			break 
		end
	end
	
	-- Update "map seen" flag
	if thisMap and getFlag(mapArr[thisMap][7]) == 0 then
		setFlag(mapArr[thisMap][7], 1)
		--centerText(mapArr[thisMap][8])
	end
	
	--Create minimapper entity
	createEntity(v.spawnEntity, "", entity_getPosition(getNaija()))
end


function update(me, dt)
	--[[
	tmp = getStringFlag("gemstore")
	setStringFlag("gemstore", tmp.."testing   ")
	--setControlHint(string.format("\"%s\"\n\"%s\"",tmp,getStringFlag("gemstore")), 0, 0, 0, 2)
	debugLog(getStringFlag("gemstore"))
	]]--
end
