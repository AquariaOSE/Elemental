if not v then v = {} end

-- song cave collectible

--dofile("scripts/include/collectibletemplate.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/collectibletemplate.lua"))

function init(me)
	v.commonInit(me, "Collectibles/goldstar", FLAG_COLLECTIBLE_STARFISH)
	entity_setEntityLayer(me, -3)
end

function update(me, dt)
	v.commonUpdate(me, dt)
	local glow = createQuad("Naija/LightFormGlow", 13)
	quad_scale(glow, 5, 5)

	if glow ~= 0 then
		if entity_isInDarkness(me) then
			quad_alpha(glow, 1, 0.5)
		else
			quad_alpha(glow, 0, 0.5)
		end
	end
	
	quad_setPosition(glow, entity_getPosition(me))
	quad_delete(glow, 0.1)
end

function enterState(me, state)
	v.commonEnterState(me, state)
	if entity_isState(me, STATE_COLLECTEDINHOUSE) then
		--createEntity("Walker", "", entity_x(me), entity_y(me))
	end	
end

function exitState(me, state)
	v.commonExitState(me, state)
end
