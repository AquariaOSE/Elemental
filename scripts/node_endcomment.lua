if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Elemental/scripts/flags.lua"))

v.li = 0
v.isendcomment = false
v.incut = false


function init(me)
    --create Li on map
    -- DO NOT SET FLAG OR setLi() !!

    if hasSong(SONG_FISHFORM) then
    
        local oldli = getFlag(FLAG_LI)
        -- HACK: need this flag to make him show up without helmet when created.
        -- not changing the original Li script and copying it into the mod now
        -- because i'm a lazy bum -- FG
        setFlag(FLAG_LI, 100)
        local li = getEntity("Li")
        if li == 0 then
            v.li = createEntity("Li", "", node_x(me), node_y(me))
        else
            v.li = li
            if not isFlag(FLAG_ENDING, 2) then
                entity_setPosition(v.li, node_x(me), node_y(me))
            end
        end
        
        entity_fh(v.li)
        
        -- HACK: fix back
        setFlag(FLAG_LI, oldli)
    end

end


function update(me, dt)
	--Display once if learned fish song and Naija enters
    local n = getNaija()
	if not v.incut and isFlag(TEXT_END, 0) and hasSong(SONG_FISHFORM) and node_isEntityIn(me, n) and v.li ~= 0 then
        setFlag(TEXT_END, 1)
        
        v.incut = true
        setCutscene(1, 1)
        
        if not isForm(FORM_NORMAL) then
            changeForm(FORM_NORMAL)
        end
        
        setOverrideMusic("licave")
        updateMusic()

        setFlag(FLAG_LI, 100)
        setFlag(FLAG_ENDING, 1)
        -- disable scenes that make no sense anymore at this point
        setFlag(DRIFT_PEARL, 1)
        setFlag(LI_SUB, 1)
        
        loadMap("Forest")
	end 
end
