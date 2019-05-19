if not v then v = {} end

-- song cave collectible

--dofile("scripts/include/collectibletemplate.lua")
dofile(appendUserDataPath("_mods/Elemental/scripts/collectibletemplate.lua"))

function init(me)
	v.commonInit(me, "Collectibles/jellyplant", FLAG_COLLECTIBLE_JELLYPLANT)
end

function update(me, dt)
	v.commonUpdate(me, dt)
	local glow = createQuad("Naija/LightFormGlow", 13)
	quad_scale(glow, 10, 10)

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
		createEntity("Triffle", "", entity_x(me)-150, entity_y(me)-200)
		createEntity("Triffle", "", entity_x(me)+75, entity_y(me)-220)
		createEntity("DeepJelly", "", entity_x(me), entity_y(me)-400)
	end	
end

function exitState(me, state)
	v.commonExitState(me, state)
end
