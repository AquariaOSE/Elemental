if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.delayMax = 2
v.delay = v.delayMax

function v.commonInit(me, gfx)
	setupBasicEntity(me, 
	0,							-- texture
	12,								-- health
	2,								-- manaballamount
	2,								-- exp
	1,								-- money
	0,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	128,							-- sprite width	
	128,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)	
	entity_setTexture(me, gfx)
	entity_setWidth(me, 128)
	entity_setHeight(me, 128)
	entity_setAllDamageTargets(me, false)
end

function update(me, dt)
	v.delay = v.delay - dt
	if v.delay < 0 then
		v.delay = v.delayMax
		entity_fireGas(me, 96, 2.1, 0.5, "Gas", 0, 0.8, 0.6, 0, -128, 3)
	end
end

function damage(me, attacker, bone, damageType, dmg)
	return false
end

