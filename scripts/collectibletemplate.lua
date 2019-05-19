-- COLLECTIBLE ITEM

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Elemental/scripts/flags.lua"))

v.myFlag = 0
v.back = false

v.isCostume = false

function v.commonInit(me, gfx, flag, cst)
	v.myFlag = flag
	setupEntity(me, gfx)
	debugLog("in common init")
	if isFlag(flag, 1) then
		debugLog("setting state collected")
		entity_setState(me, STATE_COLLECTED)
		entity_alpha(me, 0, 0)
	end	
	
	local nd = entity_getNearestNode(me, "layerback")
	if nd ~= 0 and node_isEntityIn(nd, me) then
		entity_setEntityLayer(me, -1)
		v.back = true
	end
	
	v.isCostume = cst or false
end

function v.commonUpdate(me, dt)
	if entity_isState(me, STATE_IDLE) then
		if v.back then
			local e = getFirstEntity()
			while e ~= 0 do
				if eisv(e, EV_TYPEID, EVT_ROCK) then
					if entity_isEntityInRange(me, e, 64) then
						return
					end
				end
				e = getNextEntity()
			end
		end
		if entity_isEntityInRange(me, getNaija(), 96) then
			entity_setState(me, STATE_COLLECT, 6)
		end
	end
end

v.incut = false

function v.commonEnterState(me, state)
	if v.incut then return end
	
	if entity_isState(me, STATE_COLLECT) then
        local n = getNaija()
		v.incut = true
        
        -- FG: prevent hanging in air during scene
        if not entity_isUnderWater(n) then
            esetv(n, EV_NOINPUTNOVEL, 0)
            -- speed down
            entity_addVel(n, entity_velx(n) * -0.8, 0)
        end

		entity_idle(n)
		entity_flipToEntity(n, me)
		cam_toEntity(me)
		
		overrideZoom(1.2, 7)
		musicVolume(0.1, 3)
		
		setSceneColor(1, 0.9, 0.5, 3)
		
		spawnParticleEffect("treasure-glow", entity_x(me), entity_y(me))
		
		playSfx("low-note1", 0, 0.4)
		playSfx("low-note5", 0, 0.4)
		watch(3)
		
		setFlag(v.myFlag, 1)
		entity_setPosition(me, entity_x(me), entity_y(me)-100, 3, 0, 0, 1)
		entity_scale(me, 1.2, 1.2, 3)
		--playSfx("secret")
		playSfx("Collectible")
		
		
		watch(3)
		
		playSfx("secret", 0, 0.5)
		cam_toEntity(n)
		
		musicVolume(1, 2)
		
		setSceneColor(1, 1, 1, 1)
		
		overrideZoom(0)
		
		if v.isCostume then
			setControlHint(getStringBank(224), 0, 0, 0, 8, "gui/icon-treasures")
            -- FG: small addition here
            setFlag(FLAG_COSTUMES_COLLECTED, getFlag(FLAG_COSTUMES_COLLECTED) + 1)
            debugLog("Costumes collected now: " .. getFlag(FLAG_COSTUMES_COLLECTED))
		else
			if isFlag(FLAG_HINT_COLLECTIBLE, 0) then
				setControlHint(getStringBank(222), 0, 0, 0, 8)
				setFlag(FLAG_HINT_COLLECTIBLE, 1)
			else
				setControlHint(getStringBank(223), 0, 0, 0, 8, "gui/icon-treasures")
			end
            
            -- FG: small addition here
            setFlag(FLAG_THINGS_COLLECTED, getFlag(FLAG_THINGS_COLLECTED) + 1)
            debugLog("Things collected now: " .. getFlag(FLAG_THINGS_COLLECTED))
		end
        esetv(n, EV_NOINPUTNOVEL, 1) -- FG: added that too
		v.incut = false
	elseif entity_isState(me, STATE_COLLECTED) then	
		debugLog("COLLECTED, fading OUT alpha")
		entity_alpha(me, 0, 1)
	elseif entity_isState(me, STATE_COLLECTEDINHOUSE) then
		debugLog("COLLECTEDINHOUSE.. fading IN")
		entity_alpha(me, 1, 0.1)
	end
end

function v.commonExitState(me, state)
	if entity_isState(me, STATE_COLLECT) then
		entity_alpha(me, 0, 1)
		spawnParticleEffect("Collect", entity_x(me), entity_y(me))
		--clearControlHint()
		entity_setState(me, STATE_COLLECTED)
	end
end
