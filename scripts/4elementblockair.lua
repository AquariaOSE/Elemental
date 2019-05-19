-- based on kuirlinghost and gateway

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end








function init(me)
	setupBasicEntity(
	me,
	"4elementblockair",			-- texture
	1,								-- health
	4,								-- exp
	0,								-- manaballamount
	0,								-- money
	256,								-- collideRadius (for hitting entities + spells)
	STATE_IDLE,						-- initState
	512,							-- sprite width	
	512,							-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	1,								-- 0/1 hit other entities off/on (uses collideRadius)
	4000							-- updateCull -1: disabled, default: 4000
	)
	entity_setEntityType(me, ET_ENEMY)
	entity_initSkeletal(me, "4elementblockair")	
    entity_setAllDamageTargets(me, true)
    
    entity_setEntityLayer(me, -2)
    

    
	b = entity_getNearestNode(me, "gatewayblock")
	if b ~= 0 and node_isEntityIn(b, me) then
	else
		b = 0
	end
	
	entity_scale(me, 1.5, 1.5)
	
	entity_generateCollisionMask(me)
	

	
	entity_setCullRadius(me, 1024)

    v.q = createQuad("Cell03", 13)
    sc = sc * 1.1
    quad_scale(v.q, sc, sc)
    quad_setBlendType(v.q, BLEND_ADD)
    quad_alpha(v.q, 0)
    		 
    v.q2 = createQuad("softglow-add", 13)
    quad_scale(v.q2, 2.5, 2.5)
    quad_setBlendType(v.q2, BLEND_ADD)
    quad_alpha(v.q2, 0)
    quad_color(v.q2, 0.5, 1, 0.5)

end

function postInit(me)
    v.n = getNaija()
    entity_setTarget(me, v.n)
    
    --entity_alpha(me, 0.4, 3, -1, 1)
end

function update(me, dt)
	--entity_updateMovement(me, dt)
	
	entity_handleShotCollisionsSkeletal(me)
	
	if b ~= 0 then
		if node_isEntityIn(b, v.n) then
			xd = 0
			yd = entity_y(v.n) - node_y(b)
			entity_touchAvatarDamage(me, 0, 0, 0, 0)
			avatar_fallOffWall()
		end
	end
		
	bone = entity_collideSkeletalVsCircle(me, v.n)
	if bone ~= 0 then
		entity_clearVel(v.n)
		if entity_y(v.n) > entity_y(me) then
			entity_addVel(v.n, 0, 500)
		else
			entity_addVel(v.n, 0, -500)
		end
		entity_touchAvatarDamage(me, 0, 0, 0, 0)
		avatar_fallOffWall()
	end
	
end






function exitState(me)
end

function damage(me, attacker, bone, damageType, dmg)
    return me == attacker
end


function hitSurface(me)
end


function lightFlare(me)
    if not v.off and entity_isEntityInRange(me, v.n, 800) then -- FIXME: finetune distance
        entity_damage(me, me, 1)
        local vx, vy = entity_getVectorToEntity(v.n, me)
        vx, vy = vector_normalize(vx, vy)
        
        entity_setMaxSpeedLerp(me, 3)
        entity_setMaxSpeedLerp(me, 1, 0.7)
        
        entity_addVel(me, vx * 2000, vy * 2000)
    end

end


