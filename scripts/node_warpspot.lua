
-- activated by node_warpon.lua

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.n = 0
v.dest = 0
v.t = 0
v.on = false

local function doActivate(me)
    spawnParticleEffect("warpspiral", node_getPosition(me))
    spawnParticleEffect("warpspiral", node_getPosition(me))
    v.on = true
end

function init(me)
    v.n = getNaija()

    local dest = getNearestNodeByType(node_x(me), node_y(me), PATH_SETING)
    debugLog("warpspot 1: " .. node_getName(dest))
    local destname = node_getContent(dest)
    debugLog("warpspot 2: " .. destname)
    v.dest = node_getNearestNode(me, destname)
    
    if v.dest == 0 then
        centerText("Oops! node_warpspot.lua - no dest")
        return
    end
    debugLog("warpspot 3: " .. node_getName(v.dest))
    
    if node_isFlag(me, 1) then
        doActivate(me)
    end
end

function update(me, dt)
    if v.on and node_isEntityIn(me, v.n) then
        if v.dest ~= 0 then
            screenFadeGo(0.5)
            local x, y = node_getPosition(v.dest)
            spawnParticleEffect("spirit-big", x, y)
            playSfx("spirit-return")
            entity_setPosition(v.n, x, y)
            cam_snap()
            
            if chance(60) then
                v.t = 1.3
            end
        end
    end
    
    if v.t > 0 then
        v.t = v.t - dt
        if v.t <= 0 then
            emote(EMOTE_NAIJAGIGGLE) -- HMM: really?
        end
    end
end

function activate(me)
    if not v.on then
        node_setFlag(me, 1)
        doActivate(me)
        --cam_toNode(me)
        --watch(1)
        --playSfx("secret")
        --watch(1.5)
        --cam_toEntity(v.n)
    end
end


function song() end
function songNote() end
function songNoteDone() end

