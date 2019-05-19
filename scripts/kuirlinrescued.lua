dofile(appendUserDataPath("_mods/Labyrinth/scripts/purplespootercommon.lua"))

v.head = 0

function init(me)
    setupEntity(me)
    
    -- old... no nexture anymore
    --entity_setTexture(me, "kuirlinrescued")
    
    entity_initSkeletal(me, "kuirlinrescued")
    
    entity_setCollideRadius(me, 40)
    entity_setHealth(me, 9)
    entity_setUpdateCull(me, -1)
    
    if isFlag(MINEOCTOBOSS_DONE, 1) then
        v.makeHappy(me)
    end
    
    entity_setWeight(me, 300)
    entity_setDeathSound(me, "")

    -- does not work with skeletal animation
    --entity_setSegs(me, 2, 16, 0.4, 0.4, -0.05, 0, 6, 1)

    esetv(me, EV_WALLOUT, 24)
    
    entity_scale(me, 0.75, 0.75)
    
    v.updateMulti = 5.5
    v.keepdir = true
    v.stop = true
    v.autojump = false
    
    entity_setBounce(me, 0) -- important
    
    v.head = entity_getBoneByIdx(me, 1)
    
    entity_setState(me, STATE_IDLE)
    entity_animate(me, "idle", -1)
end


function v.makeHappy(me)
    v.happy = true
    bone_setTexture(v.head, "kuirlinslave/headhappy")
end
