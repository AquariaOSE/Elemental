if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Labyrinth/scripts/inc_stats.lua"))

function init(me)
	node_setCursorActivation(me, true)
end
	
function activate(me)
	v.showStats(false)
end

function update(me, dt)
end

function song() end
function songNoteDone() end
function songNote() end
