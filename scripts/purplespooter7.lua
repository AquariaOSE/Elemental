dofile(appendUserDataPath("_mods/Labyrinth/scripts/purplespootercommon.lua"))

function init(me)
    v.commonInit(me, 7)
    
    entity_setWidth(me, 256)
    entity_setHeight(me, 256)
    
    esetv(me, EV_WALLOUT, 64)
    entity_initHair(me, 20, 6, 60, "purplespooter7hair")
end

function update(me, dt)
    v.commonUpdate(me, dt)
    
    -- FG: to fix hair movement... it does not consider EV_WALLOUT...
    local vx, vy = entity_getOffset(me)
    entity_setHairHeadPosition(me, entity_x(me) + vx, entity_y(me) + vy)
    entity_updateHair(me, dt)
end
