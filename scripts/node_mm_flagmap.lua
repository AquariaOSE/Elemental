--dofile("scripts/entities/entityinclude.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/mm_common.lua"))

timer = 0

function init(me)
	node_setCursorActivation(me, false)
	thisMap = 0
	
	-- Search mapArr for the map's name
	thisMapName = string.lower(getMapName())
	for i,list in ipairs(mapArr) do
		if string.lower(list[1]) == thisMapName then
			thisMap = i 
			break 
		end
	end
	
	-- Update "map seen" flag
	if getFlag(mapArr[thisMap][7]) == 0 then
		setFlag(mapArr[thisMap][7], 1)
		--centerText(mapArr[thisMap][8])
	end
	
	--Create minimapper entity
	createEntity("mm_Minimapper", "", entity_getPosition(getNaija()))
end


function update(me, dt)
	--[[
	tmp = getStringFlag("gemstore")
	setStringFlag("gemstore", tmp.."testing   ")
	--setControlHint(string.format("\"%s\"\n\"%s\"",tmp,getStringFlag("gemstore")), 0, 0, 0, 2)
	debugLog(getStringFlag("gemstore"))
	]]--
end