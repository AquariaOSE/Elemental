if not v then v = {} end

-- song cave collectible

--dofile("scripts/include/collectibletemplate.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/collectibletemplate.lua"))

function init(me)
	v.commonInit(me, "Collectibles/NaijaCave", FLAG_COLLECTIBLE_NAIJACAVE)
end

function update(me, dt)
	v.commonUpdate(me, dt)
end

function enterState(me, state)
	v.commonEnterState(me, state)
	if entity_isState(me, STATE_COLLECTEDINHOUSE) then
		-- spawn a bunch o' plants
		local node, ent
		node = getNode("PLANT1")
		ent = createEntity("SongStalk", "", node_x(node), node_y(node))
		node = getNode("PLANT2")
		ent = createEntity("Phonograph", "", node_x(node), node_y(node))
		entity_rotate(ent, 60)
		node = getNode("PLANT3")
		ent = createEntity("forestsprite", "", node_x(node), node_y(node))
		node = getNode("PLANT4")
		ent = createEntity("forestsprite", "", node_x(node), node_y(node))
		node = getNode("PLANT5")
		ent = createEntity("forestsprite", "", node_x(node), node_y(node))
		--setElementLayerVisible(7, true)
	end
end

function exitState(me, state)
	v.commonExitState(me, state)
end
