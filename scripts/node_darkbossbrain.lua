--FG TODO

-- based on priestbrain

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

n = 0
started = false
darkbosss = {}
numdarkbosss = 0
door = 0

function init(me)
	n = getNaija()

	e = getFirstEntity()
	i = 1
	while e ~=0 do
		if entity_isName(e, "darkboss") then
			darkbosss[i] = e
			i = i + 1
		end
		e = getNextEntity()
	end
	numdarkbosss = i
	
	door = node_getNearestEntity(me, "energydoor")
	
	if not isFlag(FLAG_MITHALAS_DARKBOSSS, 0) then
		entity_setState(door, STATE_OPENED)
	end
end
	
function activate(me)	
end

function update(me, dt)
	if isFlag(FLAG_MITHALAS_DARKBOSSS,0) then
		if not started then
			if node_isEntityIn(me, n) then
				started = true
				entity_idle(n)

				for i=1,darkbosss do
					cam_toEntity(darkbosss[i])
					entity_setState(darkbosss[i], STATE_APPEAR)
					watch(1)
				end
				overrideZoom(0.6, 1)
				cam_toEntity(n)
				for i=1,numdarkbosss do
					entity_setState(darkbosss[i], STATE_IDLE)
				end				
			end
		else
			c = 0
			e = getFirstEntity()
			while e ~= 0 do
				if entity_getEntityType(e) == ET_ENEMY and entity_isName(e, "darkboss") then					
					c = c + 1
				end
				e = getNextEntity()
			end
			if c == 0 then
				setFlag(FLAG_MITHALAS_DARKBOSSS, 1)
				setFlag(FLAG_MINIBOSS_DARKBOSSS, 1)
				updateMusic()
				overrideZoom(0)
				entity_idle(n)
				changeForm(FORM_NORMAL)
				watch(1)
				entity_setInvincible(n, true)
				watch(1)				
				entity_animate(n, "agony", LOOP_INF)
				learnSong(SONG_BEASTFORM)
				watch(1)
				changeForm(FORM_BEAST)
				voice("naija_song_spiritform")
				setControlHint(getStringBank(44), 0, 0, 0, 10, "", SONG_BEASTFORM)
				entity_setInvincible(n, false)
				entity_setState(door, STATE_OPEN)
			end
		end
	end
end
