dofile(appendUserDataPath("_mods/Labyrinth/scripts/purplespootercommon.lua"))

function init(me)

    local octoalive = getFlag(MINEOCTOBOSS_DONE) == 0
    
    v.commonInit(me, 5, octoalive) -- no clamp if alive
    
    local tex = "purplespooter5happy"
    if octoalive then
        tex = "purplespootersleeping"
        v.commonUpdate = function() end -- do nothing
        entity_setSegs(me) -- nothing
        entity_setEntityLayer(me, -2)
    end
    entity_setTexture(me, tex)
end
