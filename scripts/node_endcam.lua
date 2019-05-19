
if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Elemental/scripts/flags.lua"))
dofile(appendUserDataPath("_mods/Elemental/scripts/inc_util.lua"))

local MAPORDER = {
    forest		    	= { map = "air",   				  mus = "licave" }, -- credits1
    air				    = { map = "dark", 				  mus = "licave" }, -- credits2
    dark			    = { map = "energy",			      mus = "licave" }, -- credits3
    energy			    = { map = "icepassage", 		  mus = "licave" }, -- credits4
    icepassage		    = { map = "ice2",     			  mus = "licave" }, -- credits5
    ice2			    = { map = false,                  mus = "flyaway" }, -- credits6
}

v.n = 0
v.needinit = false
v.on = false
v.nextmap = 0
v.i = 0
v.camlerp = 1
v.zoom = 0.52
v.speed = -200
v.dummy = 0 -- cam entity
v.t = 0
v.overlay = 0

function init(me)
    v.needinit = isFlag(FLAG_ENDING, 1)
    local nextmap = MAPORDER[getMapName()]
    if not nextmap then
        centerText("ERROR: node_endcam.lua - missing entry for map " .. getMapName())
        v.needinit = false
        return
    end
    v.nextmap = nextmap
    
    if v.needinit then
        setOverrideMusic(v.nextmap.mus or "")
        updateMusic()
    end
end

local function getProps(x, y)
    local seting = getNearestNodeByType(x, y, PATH_SETING)
    if seting == 0 or not node_isPositionIn(seting, x, y) then
        return 0, 0, 0, 0
    end
    local arr = node_getName(seting):explode(" ", true)
    table.remove(arr, 1) -- drop node name
    
    if arr[1] == "show" then
        local tex = arr[2] or "missingimage"
        debugLog("show overlay " .. tex)
        local e = createEntity("guielement")
        v.overlay = e
        entity_switchLayer(e, 1)
        entity_setTexture(e, tex)
        entity_msg(e, "x", 400)
        entity_msg(e, "y", 300)
        entity_alpha(e, 0)
        
        local sc = tonumber(arr[3]) or 0
        if sc ~= 0 then
            entity_msg(e, "scale", sc* 1000)
        end
        
        entity_alpha(e, 1, tonumber(arr[4]) or 3)
        
        return 0,0,0,0
        
    elseif arr[1] == "hide" then
        debugLog("hide overlay")
        if v.overlay ~= 0 then
            entity_alpha(v.overlay, 0, tonumber(arr[2]) or 3)
            v.overlay = 0
        end
        return 0,0,0,0
    elseif arr[1] == "fadeout" then
        fade2(1, tonumber(arr[2]) or 2)
    end
    
    return tonumber(arr[1]) or 0, tonumber(arr[2]) or 0, tonumber(arr[3]) or 0, tonumber(arr[4]) or 0
end

local function moveCamToNextNode(me)
    v.i = v.i + 1
    local x, y = node_getPathPosition(me, v.i)
    
    if x == 0 and y == 0 then
        enableInput()
        if v.nextmap.map then
            debugLog("end camera path done")
            loadMap(v.nextmap.map)
        else
            setFlag(FLAG_ENDING, 2)
            fade2(0, 5)
            setOverrideMusic("")
            updateMusic()
			quit()
        end
        v.on = false
        return
    end
    
    debugLog("cam to idx " .. v.i)
    
    local waittime, zoom, speed, lerp = getProps(x, y)
    
    if lerp ~= 0 then
        v.camlerp = lerp
        setCameraLerpDelay(lerp)
    end
    
    if speed ~= 0 then
        v.speed = speed
    end
    
    if zoom ~= 0 then
        if zoom < 0 then
            debugLog("zoom reset")
            overrideZoom(0)
            v.zoom = 0
        else
            debugLog("zoom " .. zoom)
            overrideZoom(zoom, 3)
            v.zoom = zoom
        end
    end

    entity_setPosition(v.dummy, x, y, v.speed)
    
    debugLog("waiting " .. waittime)
    v.t = waittime
end


local function doCamPath(me)

    debugLog("end cam path start")
    setCameraLerpDelay(1)
    v.i = 0
    
    moveCamToNextNode(me)
    
end

function update(me, dt)

    if v.needinit then

        v.n = getNaija()
        local li = getLi()
        if li ~= 0 then
            entity_alpha(li, 0)
        end
        overrideZoom(v.zoom)
        fade2(1, 0)
        fade2(0, 2)
        v.dummy = createEntity("empty")
        entity_warpToNode(v.dummy, me)
        
        -- for 1.1.1 and below - somehow this doesn't like music override in init()
        setOverrideMusic(v.nextmap.mus or "")
        updateMusic()
        
        --- DEBUG
        --entity_setTexture(v.dummy, "misssingimage")
        --entity_alpha(v.dummy, 1)
        
        v.needinit = false
        entity_alpha(v.n, 0)
        
        cam_toEntity(v.dummy)
        cam_snap()
        
        doCamPath(me)
        v.on = true
    end
    
    if v.on then
        setCameraLerpDelay(v.camlerp) -- force permanent override (necessary because it is reset in Game::applyState())
        overrideZoom(v.zoom, 3)
        disableInput()
        entity_setInvincible(v.n, true)
        entity_setPosition(v.n, entity_getPosition(v.dummy))
        if not entity_isInterpolating(v.dummy) then
            if v.t > 0 then
                v.t = v.t - dt
            else
                moveCamToNextNode(me)
            end
        end
    end
end

function songNote(me, note)
end

function songNoteDone(me, note, done)
end
