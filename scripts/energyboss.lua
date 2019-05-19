--FG TODO
-- based on hellbeast

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

bone_tongue = 0
bone_hand = 0
bone_head = 0
bone_body = 0
bone_upperLeg = 0
bone_tongue = 0
bone_jaw = 0
bone_target = 0

naijaPit = 0

inHand = false
node_right = 0
node_left = 0
node_hang = 0
node_middle = 0
node_check = 0
node_mermanSpawn = 0
node_nostomp = 0

handSpin = 0

sx = 0
sy = 0 

holding = 0

soundDelay = 0

skull = false

STATE_ATTACK1 		= 1000
STATE_ATTACK2 		= 1001
STATE_ATTACK3 		= 1002
STATE_HOLDING 		= 1003
STATE_ATTACK4 		= 1004
STATE_ACIDSPRAY 	= 1005
STATE_PAIN 			= 1006
STATE_DIE 			= 1007
STATE_DONE 			= 1008
STATE_MOVERIGHT		= 1009
STATE_MOVELEFT		= 1010
STATE_ATTACK5		= 1011
STATE_TRANSFORM		= 1012
STATE_CREATEMERMAN	= 1013
-- yer done!

attacksToGo = 3

lastAcid = false

getHitDelay = 0

-- initial attackDelay value set below
attackDelay = 0


hurtDelay =0

hits = 0
maxHeadHits = 3
headHits = maxHeadHits
maxHandHits = 6
handHits = 0

minPullSpd = 100
maxPullSpd = 1800
pullSpdRate = 1000

grabPoint = 0

started = false

fireDelay = 0

n = 0

beam = 0
canMove = true

skullHits = 80
lessThan = skullHits*0.6
finalStage = false

function init(me)
	setupBasicEntity(
	me,
	"",								-- texture
	90,								-- health
	1,								-- manaballamount
	1,								-- exp
	1,								-- money
	0,								-- collideRadius (only used if hit entities is on)
	STATE_IDLE,						-- initState
	90,								-- sprite width
	90,								-- sprite height
	1,								-- particle "explosion" type, maps to particleEffects.txt -1 = none
	0,								-- 0/1 hit other entities off/on (uses collideRadius)
	-1,							-- updateCull -1: disabled, default: 4000
	0
	)
	
	entity_initSkeletal(me, "energyboss")
	entity_generateCollisionMask(me)
	entity_scale(me, 5, 5)

	--entity_setDamageTarget(me, DT_AVATAR_ENERGYBLAST, false)
	entity_setCull(me, false)
	
	--entity_setState(me, STATE_IDLE)
	
	bone_tongue = entity_getBoneByName(me, "Tongue")
	bone_hand = entity_getBoneByName(me, "Hand")
	--bone_leftThumb = entity_getBoneByName(me, "LeftThumb")
	bone_head = entity_getBoneByName(me, "Head")
	bone_body = entity_getBoneByName(me, "Body")
	bone_upperLeg = entity_getBoneByName(me, "UpperLeg")
	bone_tongue = entity_getBoneByName(me, "Tongue")
	bone_jaw = entity_getBoneByName(me, "Jaw")
	
	bone_target = entity_getBoneByName(me, "Target")
	
	bone_setSegs(bone_tongue, 2, 12, 0.4, 0.3, -0.02, 0, 8, 0)
	
	node_left = entity_getNearestNode(me, "HELLBEAST_LEFT")
	node_right = entity_getNearestNode(me, "HELLBEAST_RIGHT")
	node_middle = entity_getNearestNode(me, "HELLBEAST_MIDDLE")
	node_hang = entity_getNearestNode(me, "HELLBEAST_HANG")
	
	node_nostomp = getNode("NOSTOMP")
		
	node_check = entity_getNearestNode(me, "HELLBEAST_CHECK")
	node_mermanSpawn = entity_getNearestNode(me, "MERMAN_SPAWN")
	
	grabPoint = entity_getBoneByName(me, "GrabPoint")
	bone_alpha(grabPoint, 0)
	
	
	naijaPit = getNode("NAIJAPIT")
	
	entity_setState(me, STATE_IDLE)
	
	--entity_setDamageTarget(me, DT_AVATAR_SHOCK, false)
	
	entity_setTargetPriority(me, 2)
	entity_setTargetRange(me, 10000)
	n = getNaija()
	
	hits = 3
	
	loadSound("HellBeast-Beam")
	loadSound("HellBeast-Die")
	loadSound("HellBeast-Idle")
	loadSound("HellBeast-Roar")
	loadSound("HellBeast-Stomp")
	loadSound("HellBeast-Suck")
	loadSound("hellbeast-skullhit")
	loadSound("merman-bloat-explode")
	loadSound("mia-appear")
	loadSound("BossDieBig")
	loadSound("BossDieSmall")
	loadSound("hellbeast-shot")
	loadSound("hellbeast-shot-skull")
	
	
	entity_setDamageTarget(me, DT_AVATAR_PET, false)
end

function postInit(me)
	if getFlag(FLAG_BOSS_MITHALA) > 0 then
		entity_setState(me, STATE_DONE)
		bone_setTexture(bone_head, "hellbeast/skull")
		bone_setTexture(bone_jaw, "hellbeast/skulljaw")
		bone_alpha(bone_tongue, 0)
		entity_animate(me, "done", -1, true)
		entity_setAllDamageTargets(me, true)
		entity_setColor(me, 0.6, 0.2, 0.2)
	end
	sx = entity_x(me)
	sy = entity_y(me)
	
	-- cache
	createEntity("cannon", "", -100, -100)
	e = createEntity("cannon", "", -100, -100)
	entity_setState(e, STATE_BLOATED)
end

function damage(me, attacker, bone, damageType, dmg)
--[[
	hits = hits + 1
	if hits > 5 then
		hits = 0
		if entity_isState(me, STATE_THREE) then
			entity_setState(me, STATE_TWO)
		else
			entity_setState(me, STATE_THREE)
		end
	end
	return false
	]]-- 

	if entity_isState(me, STATE_HOLDING) then
		handHits = handHits - dmg
		if handHits <= 0 then
			-- move to some hurt state instead
			inHand = false
			entity_setState(me, STATE_IDLE)
		end
	end	
	
	if skull then
		if bone == bone_head or bone == bone_jaw then
			debugLog("skull hit")
			bone_damageFlash(bone_head)
			bone_damageFlash(bone_jaw)
			bone_damageFlash(entity_getBoneByIdx(me, 0))
			bone_offset(bone_head, 0, 0)
			bone_offset(bone_head, 20, 0, 0.1, 1, 1)
			
			playSfx("hellbeast-skullhit")
			skullHits = skullHits - dmg
			if skullHits < lessThan and not finalStage then
				finalStage = true
				playMusicStraight("mithalapeace")
			end
			if skullHits <= 0 then
				entity_setState(me, STATE_DIE)
			end
			shakeCamera(2, 1)
		else
			playNoEffect()
		end
	else
		
		if not (entity_isState(me, STATE_MOVELEFT) or entity_isState(me, STATE_ATTACK4)) then
			if (bone == bone_head or bone == bone_jaw or bone == bone_tongue or bone == bone_body or bone == bone_upperLeg) then
			headHits = headHits - dmg
			end
		end
	end
	
	if not skull then
		bone_damageFlash(bone_head, 1)
		bone_damageFlash(bone_jaw, 1)
		--playNoEffect()
	end
	
	entity_heal(me, 999)

	
	-- for debug
	--[[
	if not entity_isState(me, STATE_DIE) then
		entity_setState(me, STATE_DIE)
	end
	]]--
	
	
	--bone_damageFlash(bone)
	return false
end

function animationKey(me, key)
	if entity_isState(me, STATE_PAIN) and key==3 then
		shakeCamera(10, 1.5)
	end
	if ((entity_isState(me, STATE_MOVERIGHT) or entity_isState(me, STATE_MOVELEFT)) and key == 2)
		or (entity_isState(me, STATE_ATTACK3) and key == 2)
		or ((entity_isState(me, STATE_MOVERIGHT) or entity_isState(me, STATE_MOVELEFT)) and key == 6)
		then
			playSfx("HellBeast-Stomp")
			shakeCamera(30, 0.5)
			if not skull then
				setSceneColor(0.7, 0.7, 0.7)
				setSceneColor(1, 1, 1, 0.5)
			end
	end
	if entity_isState(me, STATE_MOVERIGHT) or entity_isState(me, STATE_MOVELEFT) then
		if key == 0 or key == 2 or key == 3 or key == 6 or key == 7 then
			canMove = false
		else
			canMove = true
		end
	end
	if entity_isState(me, STATE_ACIDSPRAY) and key == 3 then
		--playSfx("HellBeast-Beam")
		x,y = bone_getPosition(bone_tongue)
		--beam = createBeam(x, y, 90)
	end
	if entity_isState(me, STATE_CREATEMERMAN) then	
		lastAcid = false
		if key == 1 then
			bx, by = bone_getWorldPosition(bone_tongue)
			spawnParticleEffect("mermanspawn", bx, by)
			playSfx("mia-appear")
		elseif key == 3 then
			bx, by = bone_getWorldPosition(grabPoint)
			
			holding = createEntity("cannon", "", bx, by)
			
		elseif key == 4 then
			holding = 0
		end
	end
end

function update(me, dt)
	if not entity_isState(me, STATE_DONE) and getFlag(FLAG_BOSS_MITHALA) > 0 then
		return
	end
	if not(entity_isState(me, STATE_DONE) or entity_isState(me, STATE_DIE)) then
		if entity_isEntityInRange(me, n, 2848) then
			if not started then
				emote(EMOTE_NAIJAUGH)
				playMusic("Mithala")
				playSfx("HellBeast-Roar")
				started = true
				attackDelay = -2
				nd = getNode("MERSPAWN")
				createEntity("cannon", "", node_x(nd), node_y(nd))
			end
			soundDelay = soundDelay - dt
			if soundDelay < 0 then
				entity_playSfx(me, "HellBeast-Idle")
				soundDelay = (math.random(100)/100.0)*1 + 0.5
			end
		end
	end
	entity_clearTargetPoints(me)
	entity_addTargetPoint(me, bone_getWorldPosition(bone_head))
	entity_addTargetPoint(me, bone_getWorldPosition(bone_jaw))
	
	
	--[[
	if isLeftMouse() then
		cutscene(me)
	end
	]]--
	--[[
	entity_addTargetPoint(me, bone_getWorldPosition(bone_body))
	entity_addTargetPoint(me, bone_getWorldPosition(bone_upperLeg))
	]]--
	if not entity_isState(me, STATE_DIE) and not entity_isState(me, STATE_DONE) then
		overrideZoom(0.3, 1)
		
		--[[
		if node_getNumEntitiesIn(node_check, "cannon")<=0 then
			createEntity("cannon", "", node_x(node_mermanSpawn), node_y(node_mermanSpawn))
		end
		]]--
	end
	entity_handleShotCollisionsSkeletal(me)	
	
	if entity_isState(me, STATE_IDLE) then
		if headHits <= 0 then
			headHits = maxHeadHits
			debugLog("HeadHits exceeded")
			
			if entity_x(me) < node_x(node_left)+100 then
				if node_getNumEntitiesIn(node_check, "bomb")>=0 then
					entity_setState(me, STATE_ATTACK4, -1, true)
				else
					entity_setState(me, STATE_MOVERIGHT)
				end
			else
				if node_getNumEntitiesIn(node_check, "bomb")<0 then
					entity_setState(me, STATE_MOVERIGHT)
				else
					entity_setState(me, STATE_MOVELEFT)
				end
			end
			return
		end	
		
		attackDelay = attackDelay + dt
		if attackDelay > 1.8 then
			attackDelay = (3-hits)*0.2
			my_x = entity_x(me)
			my_y = entity_y(me)
			
			if not skull then
				attacksToGo = attacksToGo - 1
				
				if node_getNumEntitiesIn(node_check, "bomb")<0 then
					if attacksToGo <= 0 then
						attacksToGo = hits + 3
						entity_setState(me, STATE_CREATEMERMAN)
						return
					end
				else
					attacksToGo = 2
				end
			end
			
			if node_isEntityIn(naijaPit, n) then
				debugLog("in pit")
				if node_isEntityIn(node_nostomp, me) then
					debugLog("no stomp")
					lastAcid = false
					entity_setState(me, STATE_ATTACK5)
				else
					debugLog("not no stomp")
					if not lastAcid then
						if chance(50) then
							entity_setState(me, STATE_ACIDSPRAY)
							lastAcid = true
						else
							lastAcid = false
							entity_setState(me, STATE_MOVERIGHT)
						end
					else
						lastAcid = false
						entity_setState(me, STATE_MOVERIGHT)
					end
				end
			else
				if entity_y(n) < my_y+50 and entity_y(n) > my_y-200 and entity_x(n) < my_x+1024 then
					entity_setState(me, STATE_ATTACK2)
				elseif entity_y(n) >= my_y  and entity_x(n) < my_x + 750 then
					if not node_isEntityIn(me, nostomp) then
						entity_setState(me, STATE_ATTACK3)
					else
						attackDelay = 2
					end
				elseif entity_y(n) < my_y-200 then
					if entity_x(n) < entity_x(me)+ 300 then
						entity_setState(me, STATE_ATTACK1)
					else
						entity_setState(me, STATE_ACIDSPRAY)
					end
				--elseif entity_y(n) < my_y+800 then
				else

					if chance(55) then
						if my_x < node_x(node_right)-100 or lastAcid then
							lastAcid = false
							entity_setState(me, STATE_MOVERIGHT)
						else
							if node_isEntityIn(naijaPit, n) then
								entity_setState(me, STATE_ATTACK5)
								lastAcid = false
							else
								lastAcid = true
								entity_setState(me, STATE_ACIDSPRAY)
							end
						end
					else
						if not lastAcid then
							lastAcid = true
							entity_setState(me, STATE_ACIDSPRAY)
						else
							entity_setState(me, STATE_MOVERIGHT)
						end
					end
				end
			end
			
		end

	end
	
	if entity_isState(me, STATE_ATTACK4) then
		pullSpd = pullSpd + pullSpdRate * dt
		if pullSpd > maxPullSpd then
			pullSpd = maxPullSpd
		end
		x,y = bone_getWorldPosition(bone_tongue)
		radius = 1500
		length = pullSpd
		entity_pullEntities(me, x, y, radius, length, dt)
		
		if getHitDelay > 0 then
			getHitDelay = getHitDelay - dt
		else
			--ent = entity_getNearestEntity(me, "bomb")
			ent = getFirstEntity()
			while ent ~= 0 do
				if entity_getEntityType(ent)==ET_ENEMY or entity_getEntityType(ent)==ET_AVATAR then
					if entity_isPositionInRange(ent, x, y, 180) then
						-- chompy
						entity_stopPull(ent)						
						
						if entity_isState(ent, STATE_BLOATED) then
							attackDelay = 0
							spawnParticleEffect("mermanexplode", entity_x(ent), entity_y(ent))
							playSfx("merman-bloat-explode")
							entity_delete(ent)
							--debugLog(string.format("%s %d", "hits: ", hits))
							setSceneColor(0.7, 1, 0.5)
							setSceneColor(1, 1, 1, 1)
							hits = hits - 1
							if hits == 1 then
								playMusic("mithalaanger")
								entity_setColor(me, 1, 0.5, 0.5, 4)
							end
							getHitDelay = 3
							if hits <= 0 then
								--entity_delete(me)
								fade2(1, 0, 1, 1, 1)
								bone_setTexture(bone_head, "hellbeast/skull")
								bone_setTexture(bone_jaw, "hellbeast/skulljaw")
								bone_alpha(bone_tongue, 0)
								fade2(0, 0.5, 1, 1, 1)
								playSfx("mia-appear")
								entity_setState(me, STATE_TRANSFORM, -1, true)
								return
								--entity_setState(me, STATE_DIE)
							else
								entity_setState(me, STATE_PAIN)
							end
							bone_damageFlash(bone_head)
							bone_damageFlash(bone_jaw)
							bone_damageFlash(bone_body)
						elseif entity_isName(ent, "bomb") then
							entity_delete(ent)
						else
							if entity_getEntityType(ent) == ET_AVATAR then
								entity_damage(ent, me, 1)
							else
								entity_damage(ent, me, 999)
							end
						end
					end
				end
				ent = getNextEntity()
			end
		end
	end
	
	if entity_isState(me, STATE_ACIDSPRAY) then
		if beam ~= 0 then
			beam_setAngle(beam, bone_getWorldRotation(bone_tongue)+90)
			beam_setPosition(beam, bone_getWorldPosition(bone_tongue))
		end
		fireDelay = fireDelay + dt
		amount = 0.5
		if skull then
			amount = 0.2
		end
		if fireDelay > amount then
			fireDelay = 0
			x,y = bone_getWorldPosition(bone_tongue)
			tx,ty = bone_getWorldPosition(bone_target)
			vx = tx - x
			vy = (ty - y)*1.5
			if skull then
				dx = entity_x(n) - x
				dy = entity_y(n) - y
				vx,vy = vector_normalize(vx, vy)
				dx,dy = vector_normalize(dx,dy)
				vx = dx
				vy = dy
			end
			if skull then
				playSfx("hellbeast-shot-skull")
				createShot(string.format("hellbeast-skull", 4-hits), me, n, x, y, vx, vy)
			else
				playSfx("hellbeast-shot")
				createShot(string.format("hellbeast%d", 4-hits), me, n, x, y, vx, vy)
			end
		end
	end
	--[[
	if entity_isState(me, STATE_ACIDSPRAY) then
		fireDelay = fireDelay - dt
		if fireDelay < 0 then
			x,y = bone_getWorldPosition(bone_tongue)
			entity_setTarget(me, n)
			entity_fireAtTarget(me, "Purple", 1, 1000, 100, 0, 0, offx, offy, 0, 0, x, y)
			fireDelay = fireDelay + 0.2
		end
	end
	]]--

	if hurtDelay > 0 then
		hurtDelay = hurtDelay - dt
	else
		if not inHand and
		not entity_isState(me, STATE_DONE) and not entity_isState(me, STATE_DIE)
		then
			bone = entity_collideSkeletalVsCircle(me, n)
			if bone ~= 0 then
				if not entity_isState(me, STATE_IDLE) then
					if bone == bone_hand then
						if (entity_isState(me, STATE_ATTACK2) or entity_isState(me, STATE_ATTACK5)) then
							inHand = true
							avatar_fallOffWall()
							entity_setState(me, STATE_HOLDING)
							entity_animate(n, "trapped", -1, LAYER_OVERRIDE)
							handSpin = 4
							return
						end
					end
				end
				if entity_isState(me, STATE_ATTACK4) then
					entity_setState(me, STATE_IDLE)
				end
				if not inHand then
					if not entity_isState(me, STATE_PAIN) and not entity_isState(me, STATE_DIE) and not entity_isState(me, STATE_CREATEMERMAN)
					and not entity_isState(me, STATE_TRANSFORM) then
						entity_damage(n, me, 1)
					end
					entity_push(n, 1200, 0, 0)
				end
			end
			if entity_x(n) < entity_x(me) then
				entity_setPosition(n, entity_x(me) + 1, entity_y(n))
				if entity_velx(n) < 0 then
					vx = entity_velx(n)
					vy = entity_vely(n)
					if vx < 0 then
						vx = -vx
					end
					entity_clearVel(n)
					entity_addVel(n, vx, vy)
				end
			end
		end
	end

	
	--[[
	if entity_isState(me, STATE_TWO) then
		x,y = bone_getWorldPosition(bone_tongue)
		entity_velTowards(getNaija(), x, y, 1200*dt, 1000)
	end
	]]--

	if inHand then
		--debugLog(string.format("%s %d", "handHits: ", handHits))
		entity_setPosition(n, bone_getWorldPosition(grabPoint))
		entity_rotate(n, bone_getWorldRotation(grabPoint))
		entity_flipToEntity(n, me)
		hurtDelay = 1
		
		if avatar_isRolling() then
			handSpin = handSpin - dt
			
			if handSpin < 0 then
				handSpin = 0
				inHand = false
				entity_setState(me, STATE_IDLE)
			end
		end
		
		if entity_isState(me, STATE_IDLE) then
			inHand = false
			entity_idle(n)
		end
	end
	
	if holding ~= 0 then
		entity_setPosition(holding, bone_getWorldPosition(grabPoint))
		entity_rotate(n, bone_getWorldRotation(grabPoint))
	end
	
	moveSpd = 500
	if canMove then
		if entity_isState(me, STATE_MOVERIGHT) then
			entity_setPosition(me, entity_x(me)+moveSpd*dt, entity_y(me))
		end
		if entity_isState(me, STATE_MOVELEFT) then
			entity_setPosition(me, entity_x(me)-moveSpd*1.3*dt, entity_y(me))
		end	
	end
	if entity_isState(me, STATE_ATTACK1) or entity_isState(me, STATE_ATTACK2) or entity_isState(me, STATE_ATTACK3) or entity_isState(me, STATE_HOLDING) or entity_isState(me, STATE_ATTACK4) or entity_isState(me, STATE_ACIDSPRAY) or entity_isState(me, STATE_PAIN) then
		if not entity_isAnimating(me) then
			if entity_isState(me, STATE_PAIN) then
				lastAcid = true
				entity_setState(me, STATE_ACIDSPRAY)
				--entity_setState(me, STATE_MOVERIGHT)
				attackDelay = -1
			else
				entity_setState(me, STATE_IDLE)
			end
		end
	end
	if entity_isState(me, STATE_DIE) and not entity_isAnimating(me) then
		entity_setState(me, STATE_DONE)
	end
	
	if entity_isState(me, STATE_MOVERIGHT) and entity_x(me) > node_x(node_right) then
		entity_setState(me, STATE_IDLE)
	end
	
	if entity_isState(me, STATE_MOVELEFT) and entity_x(me) < node_x(node_left) then
		entity_setState(me, STATE_IDLE)
	end	
end

inCutScene = false
function cutscene(me)
	n = getNaija()
	if not inCutScene then		
		inCutScene = true
		

		setCameraLerpDelay(1)
		
		pn = getNode("NAIJADONE")
		setFlag(FLAG_BOSS_MITHALA, 1)
		ent = getFirstEntity()
		while ent ~= 0 do
			if entity_isName(ent, "cannon") or entity_isName(ent, "bomb") or entity_isName(ent, "bombgenerator") then
				entity_setDieTimer(ent, 0.1)
			end
			ent = getNextEntity()
		end		
		changeForm(FORM_NORMAL)
		
		
		setSceneColor(0.5, 0.1, 0.1, 1)
		entity_idle(n)
		entity_flipToEntity(n, me)
		fade2(1, 1, 1, 0, 0)
		watch(1)
		
		cam_toNode(getNode("WATCHDIE"))

		entity_setPosition(me, sx, sy)
		entity_setPosition(n, node_x(pn), node_y(pn))
		playMusicOnce("mithalaend")
		
		entity_animate(me, "pain", -1)
		
		fade2(0, 1.5, 1, 0, 0)
		watch(2)
		playSfx("HellBeast-Die")
		shakeCamera(100, 3)
		entity_animate(me, "die")
		watch(3)
		playSfx("BossDieSmall")
		fade(1, 0.2, 1, 1, 1)
		watch(0.2)
		fade(0, 0.5, 1, 1, 1)
		watch(0.5)
		playSfx("BossDieSmall")
		fade(1, 0.2, 1, 1, 1)
		watch(0.2)
		fade(0, 0.5, 1, 1, 1)
		watch(0.5)
		entity_color(me, 0.5, 0.5, 0.5, 1.5)
		entity_offset(me, 0, 0)
		entity_offset(me, 5, 0, 0.05, -1, 1)
		playSfx("BossDieSmall")
		--playSfx("BossDieBig")
		fade(1, 1, 1, 1, 1)
		watch(1.2)
		fade(0, 0.5, 1, 1, 1)
		entity_offset(me, 0, 0, 0.1)
		
		entity_heal(n, 1)
		entity_idle(n)
		entity_flipToEntity(n, me)
		watch(5)
		--debugLog("playing agony")
		
		entity_idle(n)
		emote(EMOTE_NAIJASADSIGH)
		
		cam_toEntity(n)
		--entity_setPosition(n, node_x(pn), node_y(pn), 2, 0, 0, 1)
		
		--cam_toNode(getNode("WATCHDIE"))
		watch(2)
		--entity_setPosition(n, node_x(pn), node_y(pn), 2, 0, 0, 1)
		overrideZoom(0.8, 5)
		watch(2)
		cam_toEntity(n)
		entity_animate(n, "agony", -1)
		watch(4)
		--[[
		fade2(1, 1, 1, 1, 1)
		watch(1)
		]]--
		setCameraLerpDelay(0)
		learnSong(SONG_ENERGYFORM)
		changeForm(FORM_ENERGY)
		
		--[[
		fade(0,0.5,1,1,1)
		fade2(0,0.5,1,1,1)
		entity_animate(n, "agony", LOOP_INF)
		
		showImage("Visions/Mithalas/00")
		watch(0.5)
		voice("naija_vision_mithalas")
		watchForVoice()
		hideImage()
		learnSong(SONG_ENERGYFORM)
		watch(1)
		entity_idle(n)
		changeForm(FORM_ENERGY)
		entity_addVel(n, 0, -100)
		entity_animate(n, "energy", 4)
		while entity_isAnimating(n) do
			watch(FRAME_TIME)
		end
		voice("naija_song_energyform")
		
		setControlHint(getStringBank(38), 0, 0, 0, 10, "", SONG_ENERGYFORM)

		overrideZoom(0)
		entity_idle(n)
		
		setCameraLerpDelay(0)
		]]--
		--watchForVoice()
		-- show help text
	end
end



function enterState(me, state)
	if entity_isState(me, STATE_IDLE) then
		entity_animate(me, "idle", LOOP_INF)
	elseif entity_isState(me, STATE_TRANSFORM) then
		skull = true
		entity_setStateTime(me, entity_animate(me, "transform"))
		setSceneColor(1, 0.5, 0.5, 2)
		attackDelay = -1
	elseif entity_isState(me, STATE_ATTACK1) then
		entity_animate(me, "attack1")
	elseif entity_isState(me, STATE_ATTACK2) then
		entity_animate(me, "attack2")
	elseif entity_isState(me, STATE_ATTACK3) then
		entity_animate(me, "attack3")
	elseif entity_isState(me, STATE_ATTACK4) then
		if skull then
			entity_setState(me, STATE_IDLE)
		else
			playSfx("HellBeast-Suck")
			pullSpd = minPullSpd
			entity_animate(me, "attack4")
		end
	elseif entity_isState(me, STATE_ATTACK5) then
		entity_setStateTime(me, entity_animate(me, "attack5"))
	elseif entity_isState(me, STATE_ACIDSPRAY) then	
		if skull then
			bx, by = bone_getWorldPosition(bone_tongue)
			spawnParticleEffect("mermanspawn", bx, by)
		end
		entity_animate(me, "acidSpray")
		fireDelay = -1.5
	elseif entity_isState(me, STATE_PAIN) then	
		playSfx("HellBeast-Roar")	
		entity_animate(me, "pain")
	elseif entity_isState(me, STATE_HOLDING) then
		entity_animate(me, "holding")
		handHits = maxHandHits
	elseif entity_isState(me, STATE_DIE) then

		cutscene(me)
	elseif entity_isState(me, STATE_DONE) then
		debugLog("DONE")
		overrideZoom(0)
	elseif entity_isState(me, STATE_MOVERIGHT) then
		lastAcid = false
		entity_animate(me, "move", -1)
		--entity_setPosition(me, entity_x(me)+800, entity_y(me), 3)
		entity_setStateTime(me, 3)
	elseif entity_isState(me, STATE_MOVELEFT) then
		attackDelay = attackDelay - 1
		if attackDelay < -1 then
			attackDelay = -1
		end
		
		entity_animate(me, "move", -1)
		--entity_setPosition(me, entity_x(me)-800, entity_y(me), 3)
		entity_setStateTime(me, 3)
	elseif entity_isState(me, STATE_CREATEMERMAN) then
		entity_setStateTime(me, entity_animate(me, "create"))
	end
end

function exitState(me, state)
	if entity_isState(me, STATE_HOLDING) then
		if inHand then
			entity_damage(n, me, 1.5, DT_ENEMY)
		end
		inHand = false
		entity_idle(n)
		hurtDelay = 2
	elseif entity_isState(me, STATE_MOVERIGHT) or entity_isState(me, STATE_MOVELEFT) then
		playSfx("HellBeast-Stomp")
		shakeCamera(10, 1)
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_ATTACK4) then
	elseif entity_isState(me, STATE_ATTACK5) then
		attackDelay = -4
		entity_setState(me, STATE_IDLE)
	elseif entity_isState(me, STATE_ACIDSPRAY) then
		if beam ~= 0 then
			beam_delete(beam)
			beam = 0
		end
	elseif entity_isState(me, STATE_TRANSFORM) then
		entity_setState(me, STATE_ACIDSPRAY)
	elseif entity_isState(me, STATE_CREATEMERMAN) then
		entity_setState(me, STATE_IDLE)
	end
end
