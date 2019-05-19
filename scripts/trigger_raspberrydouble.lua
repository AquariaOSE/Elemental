if not v then v = {} end

-- created when a raspberrybig shot hits a wall.

dofile(appendUserDataPath("_mods/Labyrinth/scripts/inc_util.lua"))
dofile(appendUserDataPath("_mods/Labyrinth/scripts/template_trigger.lua"))


function v.trigger(me, dt)

    -- created by shot hitting a surface, so it should be nearby
    entity_rotateToSurfaceNormal(me)
    local nx, ny = entity_getNormal(me)
    nx, ny = vector_setLength(nx, ny, 16)
    
    -- need wall normal adjustment, otherwise the shot will be stuck in the wall in many cases
    local s1 = createShot("raspberry", me, v.n, entity_x(me) + nx, entity_y(me) + ny)
    local s2 = createShot("raspberry", me, v.n, entity_x(me) + nx, entity_y(me) + ny)
    
    local vx, vy = entity_getVectorToEntity(me, v.n)
    nx, ny = vector_setLength(nx, ny, 65)
    vx = vx + nx
    vy = vy + ny
    
    local a, b = v.vector_rotateDeg(vx, vy, 20)
    shot_setAimVector(s1, a, b)
    
    a, b = v.vector_rotateDeg(vx, vy, -20)
    shot_setAimVector(s2, a, b)
    
    entity_delete(me)
end
