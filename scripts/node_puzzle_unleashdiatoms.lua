if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end
dofile(appendUserDataPath("_mods/Labyrinth/scripts/flags.lua"))

v.n = 0

v.diatoms = nil
v.diatomDestination = 0
v.spawnDiatoms = 0
v.numDiatoms = 3


function init(me)
	v.diatoms = {}
	v.n = getNaija()
	v.spawnDiatoms = getNode("spawnDiatoms")
	v.diatomDestination = getNode("diatomvsparamecium")
	
	--spawns Diatoms
	for i=1, v.numDiatoms do
		local temp = createEntity("diatom", "", node_x(v.spawnDiatoms), node_y(v.spawnDiatoms))
		table.insert(v.diatoms, temp)
	end
	
	setFlag(PUZZLE_DIATOMS, 0)
end


function update(me, dt)

	--rocks have been moved so puzzle can start
	if isFlag(PUZZLE_DIATOMS, 0) and node_isEntityIn(me, v.n) then
		setFlag(PUZZLE_DIATOMS, 1)
		--setControlHint("", 0, 0, 0, 4)
		
		--move diatoms to cluster of paramecium
		for i=1, #v.diatoms do
			--entity_followPath(v.diatoms[i], v.diatomDestination, SPEED_SLOW)
			entity_moveToNode(v.diatoms[i], v.diatomDestination, SPEED_SLOW)
		end
	end 

end
