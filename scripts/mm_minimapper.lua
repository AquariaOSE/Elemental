v = v or {}

if AQUARIA_VERSION then
    return -- newer versions don't need a minimap replacement
end

-- OLD VERSION CODE AHREAD

dofile("scripts/entities/entityinclude.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/flags.lua"))
dofile(appendUserDataPath("_mods/Elemental/scripts/mm_common.lua"))

v.flipY = 1 -- or -1 in mm_minimapperflip.lua

mapActive = false -- Flag indicating whether the minimap is in view.
mouseDown = false -- Flag indicating that the left mouse button was pressed last tick.
clickOne = false
maxInterClickTime = 0.5 -- Max delay between the clicks of a double-click
maxClickTime = 0.2 -- Ignore click-and-holds
clickTimer = 0 -- Global timer to track double-click validity
timeMult = 100000 -- 1/X, where X is the "paused" game speed multiplier. 100 000 works well.

mapScale = 0.9 -- change this value to have a bigger/smaller map
gemScale = 1 -- change this value to have bigger/smaller gems

mapSpeed = 2.5 -- speed of the map movement according to the cursor movement, 1 = same speed
bgAlpha = 0.7 -- transparency of the background

-- Variables to control map display
mapTileArr = {}
mapTilePosArr = {}
mapGemArr = {}
mapGemPosArr = {}
exploredMaps = {}
naijaGem = 0
background = 0
offsetX = 0
offsetY = 0
ngX = 0
ngY = 0

function init(me)
	n = getNaija()
	entity_setPosition(me, entity_x(n), entity_y(n))
	setupEntity(me)
	entity_alpha(me, 0)
end

function update(me, dt)


	
	-- Lock entity to the player's location.
	nX, nY = entity_getPosition(n)
	entity_setPosition(me, nX, nY)
	
	--can't access if in dialogue tree
	if not isFlag(DT_ACTIVE, 1) then
		
		if mapActive then
			clickTimer  = clickTimer + (dt*timeMult)
			
			-- Exit if the escape key is hit, to avoid locking up the game.
			if isEscapeKey() or isRightMouse() then
				mapActive = false
				clearMap()
				clickOne = false
				watch(0.5)
				enableInput()
			end
		
			x,y = getMousePos()
			
			-- Pan map
			if isLeftMouse() then
				
				offsetX = offsetX + (x - lastX)
				offsetY = offsetY + (y - lastY)

			end
			
			lastX = x
			lastY = y
			
			drawMap()
		else
			clickTimer  = clickTimer + dt
		end

		if not mouseDown and isLeftMouse() and mouseInMapTarget() then -- click start
			-- If it has been a long time since the last click, then remove the
			-- flag that marks the previous click as #1/2
			if clickTimer > maxInterClickTime then clickOne = false end
			
			mouseDown = true
			clickTimer = 0
		elseif mouseDown and not isLeftMouse() and mouseInMapTarget() then -- click end
			if clickTimer <= maxClickTime then -- Click was short enoguh to count as a "click"
				if not clickOne then -- This is the first click of the pair
					if not mapActive then  -- If the map is not up, mark this as the first click of the pair
						clickOne = true
					end
				elseif not mapActive then -- This is the second click.  Launch the map.
					mapActive = true
					setUpMap()
					disableInput()
				end
			end
			
			mouseDown = false
			clickTimer = 0 
		end
	end
end

-- Determine if the cursor is within the (rough) bounds of the minimap display
-- Does not currently properly handle widescreen displays (see below).
function mouseInMapTarget()

	x,y = getMousePos()
	-- getMousePos normalizes to an 800x600 screen.
	-- On widescreen, the x value ranges from -80 to +880
	-- Target zone:
	-- mousePosX > 700 and mousePosY > 500 (normal screen)
	-- mousePosX > 780 and mousePosY > 500 (widescreen)
	
	-- If the mouse is not low enough, no point in checking horizontal bounds.
	if y < 500 then return false end
	
	-- If in the target zone for widescreen, guaranteed to be good.
	if x > 780 then return true end
	
	-- If in the target zone for narrow screen, assume that player is
	-- not using a wide screen.  Unfortunately, it is apparently not
	-- possible to check for wide-screen-ness at the present time.
	if x > 700 then return true end
	
	-- If not in either target area, return false
	return false
end


-- Function to position all of the map quads at the appropriate loaction on-screen
function drawMap()
	mX, mY = getMouseWorldPos()
	cX, cY = getScreenCenter()
	
	quad_setPosition(background, cX, cY)
	
	for i,quad in ipairs(mapTileArr) do
		quad_setPosition(quad, cX + mapTilePosArr[i][1] * mapZoom + offsetX * mapSpeed,
							   cY + mapTilePosArr[i][2] * mapZoom + offsetY * mapSpeed)
	
	end
	
	for i,quad in ipairs(mapGemArr) do
		quad_setPosition(quad, cX + mapGemPosArr[i][1] * mapZoom + offsetX * mapSpeed,
		                       cY + mapGemPosArr[i][2] * mapZoom + offsetY * mapSpeed)
	end
	
	-- Place the Naija gem at the correct location
	if naijaGem ~= 0 then
		quad_setPosition(naijaGem, cX + ngX * mapZoom + offsetX * mapSpeed,
		                           cY + (ngY * mapZoom) * v.flipY + offsetY * mapSpeed)
	end
end

-- Create the quads for the world map, pause the game, zoom in.
function setUpMap()

	-- display the map and gems the same size independently of the current zoom

	-- Get current zoom level
	x1, y1 = toWindowFromWorld(entity_getPosition(n))
	x2, y2 = toWindowFromWorld(nX+100, nY+100)
	mapZoom = mapScale*50/(x2-x1)
	gemZoom = gemScale * mapZoom / mapScale * 2

	-- hide the 2 layers above the map
	setElementLayerVisible(7, false)
	setElementLayerVisible(8, false)

	lastX, lastY = getMousePos()
	
	-- "Pause" the game
	pauseGame()
	
	-- Block out the background
	background = createQuad("mmaps/mapbg", 0)
	quad_alpha(background, bgAlpha)
	quad_scale(background, 20, 20)
	
	-- Get the indices of the explored maps
	tileListSize = 1
	for i, list in ipairs(mapArr) do
		if getFlag(list[7]) ~= 0 then
			exploredMaps[tileListSize] = i
			tileListSize = tileListSize + 1
		end
	end
	
	-- Display the basic map tiles.
	for expIdx,mapArrIdx in ipairs(exploredMaps) do
		mapTileArr[expIdx] = createQuad(mapArr[mapArrIdx][2], 0)
		quad_alpha(mapTileArr[expIdx], 0.6)
		quad_scale(mapTileArr[expIdx], mapZoom, mapZoom)
		
		-- Store the basic position of each map tile
		mapTilePosArr[expIdx] = {mapArr[mapArrIdx][3] + mapArr[mapArrIdx][5] / 2, 
		                         mapArr[mapArrIdx][4] + mapArr[mapArrIdx][6] / 2}
	end
	
	gemIdx = 1
	
	-- Create all the (dynamic) global gems
	loadGemArr()
	for i, gem in ipairs(gemArr) do
		if gem[3] > 0 and getFlag(gem[3]) ~= 0		-- display if flag is set
			or gem[3] < 0 and getFlag(-gem[3]) == 0	-- display if -flag is not set
			or gem[3] == 0 then						-- display if flag is 0
			mapGemArr[gemIdx] = createQuad(gem[4], 0)
			quad_scale(mapGemArr[gemIdx], gemZoom,gemZoom)
			mapGemPosArr[gemIdx] = {gem[1], gem[2]}
			gemIdx = gemIdx + 1
		end
	end
	
	-- Display all associated gems.
	for expIdx,mapArrIdx in ipairs(exploredMaps) do
		for i,list in ipairs(mapArr[mapArrIdx][9]) do
			if list[3] > 0 and getFlag(list[3]) ~= 0	  -- display if flag is set
				or list[3] < 0 and getFlag(-list[3]) == 0 -- display if -flag is not set
				or list[3] == 0 then					  -- display if flag is 0
				
				mapGemArr[gemIdx] = createQuad(list[4], 0)
				quad_scale(mapGemArr[gemIdx], gemZoom ,gemZoom)
				mapGemPosArr[gemIdx] = {list[1],
				                        list[2]}
				gemIdx = gemIdx + 1	
			end
		end
			
	end

	-- create the Naija gem
	-- center view on Naija
	offsetX = 0
	offsetY = 0
	thisMapName = string.lower(getMapName())
	for expIdx,mapArrIdx in ipairs(exploredMaps) do
		-- check to see if this tile is the current map
		if string.lower(mapArr[mapArrIdx][1]) == thisMapName then
			-- if yes, increase alpha, and display the Naija gem
			quad_alpha(mapTileArr[expIdx], 1)

			naijaGem = createQuad("gems/naija-token.png", 0)
			quad_scale(naijaGem, gemZoom,gemZoom)

			-- Get the map position of Naija
			-- Requires a constant scale ratio of world map tile to maptemplate image
			nX, nY = entity_getPosition(n)

			-- naija's position according to the map
			ngX = nX/20 + mapArr[mapArrIdx][3]
			ngY = nY/20 + mapArr[mapArrIdx][4]

			-- center view en Naija
			offsetX = -ngX / mapSpeed * mapZoom
			offsetY = -ngY / mapSpeed * mapZoom
		end
	end

end

-- Delete the world map quads, unpause, unzoom.
function clearMap()
	
	unpauseGame()

	quad_delete(background, 0.5)
	if naijaGem ~= 0 then quad_delete(naijaGem, 0.2) end
	for i,quad in ipairs(mapTileArr) do quad_delete(quad, 0.2) end
	for i,quad in ipairs(mapGemArr) do quad_delete(quad, 0.2) end
	
	-- overrideZoom(0)
	
	-- show the 2 layers above the map
	setElementLayerVisible(7, true)
	setElementLayerVisible(8, true)
end

-- Note: This may not be the best pause system available, but it doesn't block input,
-- and under normal circumstances, nothing occurs in-game.  Some input can still get
-- through to Naija, but it doesn't generally do anything.  Singing is impossible,
-- and motion only occurs
function pauseGame()
	setGameSpeed(1/timeMult, 0)
end
function unpauseGame()
	setGameSpeed(1, 0)
end