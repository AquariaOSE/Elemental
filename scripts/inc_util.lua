
-- FG's all purpose include file
-- useful functions and other stuff

if not v then v = {} end

if not rawget(v, "__loaded_util") then -- include guard, avoiding any warnings

-------- misc. constants --------------
RADTODEG = 180.0 / 3.14159265359
DEGTORAD = 3.14159265359 / 180.0

-- runs a function for all entites
-- * f:      function to run. once it returns true, stop processing.
-- * param:  passed as additional parameter, as in f(entity, param)
-- * filter: if given, f will only be called if filter(entity, fparam) returns true
-- * fparam: passed to the filter function
function v.forAllEntities(f, param, filter, fparam)
	local e = getFirstEntity()
    local nx = getNextEntity
    if not filter then
        while e ~= 0 do
            if f(e, param) == true then
                return true
            end
            e = nx()
        end
    else
        while e ~= 0 do
            if filter(e, fparam) then
                if f(e, param) == true then
                    return true
                end
            end
            e = nx()
        end
    end
	return false
end

-- returns a table[1..n] with all entites, optionally matching a given filter function
-- * filter: if given, the entity will only be included if filter(entity, fparam) returns true
-- * fparam: passed to the filter function
function v.getAllEntities(filter, fparam)
	local e = getFirstEntity()
    local tab = {}
    local ins = table.insert
    local nx = getNextEntity
    if not filter then
        while e ~= 0 do
            ins(tab, e)
            e = nx()
        end
    else
        while e ~= 0 do
            if filter(e, fparam) then
                ins(tab, e)
            end
            e = nx()
        end
    end
    return tab
end


-- note: works reliably only for rectangular nodes!
function v.node_getRandomPoint(me)
    local xs, ys = node_getSize(me)
    local xc, yc = node_getPosition(me) -- center
    
    local x = xc - (xs / 2)
    local y = yc - (ys / 2)
    
    x = x + math.random() * xs
    y = y + math.random() * ys
    
    return x, y
end

function v.node_getParam(node, i)
    return string.explode(node_getName(node), " ", true)[i + 1] or ""
end


function v.disableEntity(e)
    entity_alpha(e, 0)
    entity_setUpdateCull(e, 0)
    entity_setEntityType(e, ET_NEUTRAL)
    esetv(e, EV_LOOKAT, false)
    entity_setAllDamageTargets(e, false)
    entity_setPosition(e, 0, 0)
end

-- give position on the screen, return position in-game
function v.toWorldFromWindow(wx, wy)
	local cx, cy = getScreenCenter()
    local zoom =  v.getZoom()
	return cx + (-400 + wx) / zoom, cy + (-300 + wy) / zoom
end

-- get globalscale -- afaik there is no API function for this, use this as workaround
function v.getZoom()
    local x, y = entity_getPosition(getNaija())
    local nx = x + 100
    local ny = y + 100
    local wx, wy = toWindowFromWorld(x, y)
    local wx2, wy2 = toWindowFromWorld(nx, ny)
    
    local dx = math.abs(wx2 - wx)
    
    local zoom = dx / 100
    --debugLog("zoom: " .. zoom)
    
    return zoom
end

v.__cursor = false

local function _getCursor()
    if not v.__cursor then
        v.__cursor = getEntity("logichelp_cursorpos")
        if v.__cursor == 0 then
            centerText("inc_util.lua::_getCursor() - no cursor entity exists")
        end
    end
    return v.__cursor
end

function v.getNearestEntityToCursor(name, range, ty, dt, ignore)
    return entity_getNearestEntity(_getCursor(), name, range, ty, dt, ignore)
end

function v.entity_getVectorToCursor(e)
    return entity_getVectorToEntity(e, _getCursor())
end

-- vector support


function v.vector_rotateRad(x, y, a)
    local ox = x
    local oy = y
    x = math.cos(a)*ox - math.sin(a)*oy;
	y = math.sin(a)*ox + math.cos(a)*oy;
    return x, y
end


function v.vector_rotateDeg(x, y, a)
    return v.vector_rotateRad(x, y, DEGTORAD * a)
end

function v.vector_fromRad(r, len)
    if not len then len = 1 end
    return v.vector_rotateRad(0, -len, r)
end

function v.vector_fromDeg(r, len)
    if not len then len = 1 end
    return v.vector_rotateDeg(0, -len, r)
end

function v.makeVector(fromx, fromy, tox, toy)
    return tox - fromx, toy - fromy
end

function v.vector_getAngleDeg(vx, vy)
    local vx, vy = vector_normalize(vx, vy)
    return (math.atan2(vy, vx) * RADTODEG) + 90
end

-- string support

-- explode(string, seperator, skipEmpty)
function string.explode(p, d, skip)
  local t, ll, l, nw
  
  ll = 0
  t = {}
  if(#p == 1) then return {p} end
    while true do
      l=string.find(p,d,ll,true) -- find the next d in the string
      if l~=nil then -- if "not not" found then..
        nw = string.sub(p,ll,l-1)
        if not skip or #nw > 0 then
            table.insert(t, nw) -- Save it in our array.
        end
        ll=l+1 -- save just after where we found it for searching next time.
      else
        nw = string.sub(p,ll)
        if not skip or #nw > 0 then
            table.insert(t, nw) -- Save what's left in our array.
        end
        break -- Break at end, as it should be, according to the lua manual.
      end
    end
  return t
end

function string.startsWith(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.endsWith(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end


-- functional support

function v.fun_map(t, f)
    for i, e in pairs(t) do
        t[i] = f(e)
    end
end

--- etc blargh glagl

-- scale t from [lower, upper] into [rangeMin, rangeMax]
function v.rangeTransform(t, lower, upper, rangeMin, rangeMax)

    if t < lower then
        return rangeMin
    end
    if t > upper then
        return rangeMax
    end
    
    local d = (upper - lower)
    if d == 0 then
        return rangeMin
    end

    t = t - lower
    t = t / d
    t = t * (rangeMax - rangeMin)
    t = t + rangeMin
    return t
end


v.__loaded_util = true

end -- end include guard
