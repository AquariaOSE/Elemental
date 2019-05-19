--ARRAY ICON ENTRIES
--x, y, +/-flag, image path
--x and y are offsets from the tile center

mapArr = 
	{
		{"Forest", "mapforest.png", 768, 1536, 1024, 1024, 650, "Forest Element",
			{
				{1024,  1504, -655, "gui/icon-help.png"},
				{1808,  2048, -651, "gui/icon-help.png"}
			}
		},
		{"4Elements", "map4elements.png", 1792, 1792, 512, 512, 651, "4Elements",
			{
				{2048,  1760, -652, "gui/icon-help.png"},
				{2048,  2336, -653, "gui/icon-help.png"},
				{2320,  2048, -658, "gui/icon-help.png"},
				{2048,  2048, -662, "gui/icon-help.png"}
			}
		},
		{"air", "mapair.png", 1536, 768, 1024, 1024, 652, "Air Element",
			{
				{1872,  848, -663, "gui/icon-help.png"},
				{1824,  1104, -664, "gui/icon-help.png"}
			}
		},
		{"dark", "mapdark.png", 1536, 2304, 1024, 1024, 653, "Dark Element",
			{
				{2104,  3328, -661, "gui/icon-help.png"},
				{1520,  2944, -656, "gui/icon-help.png"}
			}
		},
		{"energypassage", "mapenergypassage.png", 2304, 1536, 1024, 1024, 654, "Energy Element",
			{

			}
		},
		{"forestveil", "mapforestveil.png", 768, 1024, 512, 512, 655, "Forest Veil",
			{

			}
		},
		{"icepassage", "mapicepassage.png", 1280, 2816, 256, 512, 656, "Ice Passage",
			{
				{1364,  3360, -657, "gui/icon-help.png"}
			}
		},
		{"ice", "mapice.png", 1024, 3328, 1024, 1024, 657, "Ice Element",
			{
				{2064,  3648, -665, "gui/icon-help.png"}
			}
		},
		{"energy", "mapenergy.png", 2304, 1536, 1024, 1024, 658, "Energy Element",
			{

			}
		},
		{"start", "mapstart.png", 970, 1215, 512, 512, 659, "Naija's Home",
			{
				{1226,  1759, -650, "gui/icon-help.png"}
			}
		},
		{"energyboss", "mapno.png", 2304, 1536, 1024, 1024, 660, "Energy Element",
			{

			}
		},
		{"firekrinkut", "mapfirekrinkut.png", 2048, 3296, 512, 256, 661, "Fire Krinkut's Cave",
			{

			}
		},
		{"end", "mapno.png", 2048, 2048, 1, 1, 662, "end",
			{

			}
		},
		{"airboss", "mapno.png", 1616, 592, 1, 1, 663, "Air Element",
			{

			}
		},
		{"airflip", "mapno.png", 1536, -1792, 1024, 1024, 664, "Air Element",
			{
				{1872,  848, -663, "gui/icon-help.png"}
			}
		},
	}
--[[
mapArr entry format:
{ [map file name],
  [world map tile image path],
  [tile x position],
  [tile y position],
  [tile x size],
  [tile y size],
  [flag indicating that map has been entered],
  [test to display on entering map],
  {list of map markers}
}

Unexplored passage entry format:
{ [x position relative to center of map tile],
  [y position relative to center of map tile],
  [flag id for when to display the icon*],
  [path to icon image]
}

*negative flag id values mean that icon will be displayed until
 the flag is set to a non-zero value.  Note that icons in a map
 tile entry will not be displayed if the map has not been explored.
 For icons that you want to have appear regardless of whether a
 map tile has been explored, use the gemArr list.
]]--

-- Note on choice of flags:
-- The default scenario uses flags 650-669 (and 670-699 are unused) to track which maps have been explored.
-- Note: You will need to have unique entries for different versions of a map, although you may
-- use the same flags.

mmScaleFactor = 1/1
--[[
Size of world map tiles relative to the maptemplate images.
Example: if the world map tiles are 1/4 the size of the maptemplate
 images, mmScaleFactor = 1/4.
]]--


gemArr = {}
--[[
Do not modify this.  If you need to start the game with
non-map-specific icons visible, call the foundGem function
from mod-init.lua.

If there is demand during the beta test, I'll create an 
initialization function that can be used to set up an initial
global map gem list.
]]--

-- Function to call instead of pickupGem if you want a node to
-- have a gem on the world map.
-- iconname is just the name of the image in the gfx/gems folder
-- with no extension.  i.e. the image "gfx/gems/statue.png" could
-- be used by iconname = "statue".
function node_foundGem(me, iconname)
	-- debugLog("Creating gem " .. iconname .. " for node")
	-- Load the current gem array from the persistent store
	loadGemArr()
	
	-- Get the gem's location within the map.
	-- scan through mapArr to get the current map
	-- Search mapArr for the map's name
	thisMapName = string.lower(getMapName())
	for i,list in ipairs(mapArr) do
		if string.lower(list[1]) == thisMapName then
			-- use the current map's location to set the gem's location
			local eX, eY = node_getPosition(me)
			egX = eX/20*mmScaleFactor + list[3]-- -list[5]/2 -- 20 pixel map/pixel of mapTemplate
			egY = eY/20*mmScaleFactor + list[4]-- -list[6]/2
			break 
		end
	end
	
	-- Get the first empty slot in gemArr and add the new gem there
	i = 1
	while gemArr[i] ~= nil do i = i + 1 end
	gemArr[i] = {egX, egY, 0, "gems/"..iconname..".png"}
	
	-- update the persistent store.
	saveGemArr()
	
	-- Display the built-in "got a minimap gem" animation
	pickupGem(iconname)
end

-- Function to call instead of pickupGem if you want an entity to
-- have a gem on the world map.
function entity_foundGem(me, iconname)
	-- debugLog("Creating gem " .. iconname .. " for entity")
	-- Load the current gem array
	loadGemArr()
	
	-- Get the gem's location within the map.
	thisMapName = string.lower(getMapName())
	for i,list in ipairs(mapArr) do
		if string.lower(list[1]) == thisMapName then
			local eX, eY = entity_getPosition(me)
			egX = eX/20*mmScaleFactor + list[3] -- -list[5]/2
			egY = eY/20*mmScaleFactor + list[4] -- -list[6]/2
			break 
		end
	end
	
	-- Add the new gem to gemArr.
	i = 1
	while gemArr[i] ~= nil do i = i + 1 end
	gemArr[i] = {egX, egY, 0, "gems/"..iconname..".png"}
	
	-- Update the persistent store.
	saveGemArr()
	
	-- Display the built-in "got a minimap gem" animation
	pickupGem(iconname)
end

-- General function to add a gem at an arbitrary point on the map.
-- Needs global coordinates, not coordinates relative to any map.
function foundGem(x, y, flag, iconname, flashyflag)
	-- debugLog("Creating new global gem")
	-- Load the current gem array
	loadGemArr()
	
	-- Add the gem to the array
	i = 1
	while gemArr[i] ~= nil do i = i + 1 end
	gemArr[i] = {egX, egY, flag, "gems/"..iconname..".png"} -- global x,y,flag,image
	
	-- update the persistent store.
	saveGemArr()
	
	-- Display the built-in "got a minimap gem" animation if not supressed
	if flashyflag then pickupGem(iconname) end
end

-- Save the list of global gems to the persistent store
-- Mod designers should never need to call this directly
function saveGemArr()
	debugLog("Saving world map gem array\n")
	local gemLen = table.getn(gemArr)
	debugLog(gemLen)
	local saveString = "gemArr = {"
	for i,v in ipairs(gemArr) do
		saveString = saveString .. "{" .. v[1] .. "," .. v[2] .. "," .. v[3] .. ",\"" .. v[4] .. "\"}"
		if i ~= gemLen then saveString = saveString .. "," end
	end
	saveString = saveString .. "}"
	setStringFlag("gemarr", saveString)
	debugLog("Saved world map gem array\n"..saveString)
end

-- Recover the list of global gems from the persistent store
-- Mod designers should never need to call this directly
function loadGemArr()
	debugLog("Loading world map gem array")
	f = assert(loadstring(getStringFlag("gemarr")))
	f()
	debugLog("Successfully loaded world map gems")
end
	

--REMOVE GEM: need to pass node to reset node_flag
function RemoveGem(gemToRemove)
	gemToRemove = "gems/"..gemToRemove..".png"
	
	loadGemArr()
	for i, gem in ipairs(gemArr) do
		if gemToRemove == gem[4] then
			table.remove(gemArr, i)
			break
		end
	end
	saveGemArr()
end