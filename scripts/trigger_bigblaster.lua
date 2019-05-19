
-- created by bigblaster, when it wants to make a weird shot.
-- have to use extra entity because of shotHitEntity() extra effect.

dofile(appendUserDataPath("_mods/Labyrinth/scripts/template_trigger.lua"))

v.t = 20 -- shot life time is 18, so this should be enough
v.done = false
v.q = 0
v.qfade = false
v.lt = 2
v.qfadefast = false

v.vfxT = 0

function init(me)
    v.commonInit(me)
    entity_setEntityType(me, ET_ENEMY)
end

local function trigger2(me, dt)

    if v.q ~= 0 then
        local x, y = entity_getPosition(v.n)
        entity_setPosition(me, x, y)
        quad_setPosition(v.q, x, y)
        
        
        if v.lt >= 0 and v.t > 3 then
            v.lt = v.lt - dt
            if v.lt <= 0 then
                v.lt = math.random(1500, 1800) / 1000
                if chance(50) then
                    if entity_getHealthPerc(v.n) < 0.36 then
                        emote(EMOTE_NAIJAUGH)
                    elseif isForm(FORM_ENERGY) then
                        emote(EMOTE_NAIJAEVILLAUGH)
                    else
                        emote(EMOTE_NAIJALAUGH)
                    end
                end
            end
        end
        
        -- too much? If the timer is >= 1 this is ok though.
        if v.vfxT >= 0 and v.t > 4 then
            v.vfxT = v.vfxT - dt
            if v.vfxT <= 0 then
                v.vfxT = 1
                playVisualEffect(VFX_RIPPLE, x, y)
            end
        end
        
        local p = entity_getHealthPerc(v.n)
        --if p < 0.8 then
        --    p = p + 0.2
        --end
        quad_color(v.q, 1, p, p, 2.5)
    else
        entity_setPosition(me, -9999, -9999) -- move out of the way so that no shots will ever target it
    end
    

    
    if v.t >= 0 then
        v.t = v.t - dt
        if v.t <= 5.1 and v.q ~= 0 and not v.qfade then
            setStringFlag("TEMP_weird", "")
            quad_alpha(v.q, 0, 5)
            --quad_color(v.q, 1, 0.2, 0.2, 4)
            entity_color(v.n, 1, 1, 1, 4)
            v.qfade = true
        end
        
        if v.t <= 0 then
            if v.q ~= 0 then
                quad_delete(v.q)
                v.q = 0
            end
            entity_delete(me)
        end
    end
    
    -- HACK: when all overlays should be removed, blasterpurple sets this stringflag
    -- all shots are cleared at this point, so there won't be any other overlay appearing
    if not v.qfadefast and getStringFlag("TEMP_weirdfade") ~= "" then
        v.t = 1.6 -- hacky
        if v.q ~= 0 then
            quad_alpha(v.q, 0, 1.5)
        end
        setStringFlag("TEMP_weird", "")
        entity_color(v.n, 1, 1, 1, 2)
        v.qfade = true
        v.qfadefast = true
    end
end

function v.trigger(me, dt)
    
    local s = createShot("weirdball", me, v.n)
    shot_setOut(s, 40)
    
    v.trigger = trigger2 -- patch out
end

function shotHitEntity(me, e)
    if e == v.n and getStringFlag("TEMP_weird") == "" then
        entity_setEntityType(me, ET_NEUTRAL) -- must stick to naija now; set neutral to prevent energy shots targeting it
        setStringFlag("TEMP_weird", "1") -- prevent effect stacking
        local q = createQuad("particles/tripper")
        quad_alpha(q, 0)
        quad_alpha(q, 1, 1.5)
        --quad_setBlendType(q, BLEND_ADD)
        quad_scale(q, 5, 5)
        quad_scale(q, 6, 6, 9)
        quad_rotate(q, 360, 16)
        entity_color(v.n, 0.1, 0.1, 0.1, 0.5)
        local p = entity_getHealthPerc(v.n)
        --if p < 0.8 then
        --    p = p + 0.2
        --end
        quad_color(q, 1, p, p)
        v.q = q
        v.t = 12
        setPoison(0.5, 9)
    else
        entity_delete(me)
    end
end
