if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))
dofile(appendUserDataPath("_mods/Labyrinth/scripts/inc_timerqueue.lua"))

v.n = 0
v.seen = false

function init(me)
	v.n = getNaija()
end


function update(me, dt)
    v.updateTQ(dt)
    if not v.seen and node_isEntityIn(me, v.n) then
        v.seen = true
        local octo = getEntity("mineoctoboss")
        if octo ~= 0 then
            v.pushTQ(3, function()
                playSfx("naijaugh4")
                setControlHint("Oh, stop!  Drop him!  Let him go!", 0, 0, 0, 5)
                v.pushTQ(1.5, function()
                    entity_msg(octo, "start")
                end)
            end)
        end
    end
end
