-- based on priestbrain

if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

dofile(appendUserDataPath("_mods/Elemental/scripts/flags.lua"))

n = 0
started = false
priests = {}
numPriests = 0
door = 0

function init(me)
	n = getNaija()

	e = getFirstEntity()
	i = 1
	while e ~=0 do
		if entity_isName(e, "Airboss") or entity_isName(e, "Airboss2") then
			priests[i] = e
			i = i + 1
		end
		e = getNextEntity()
	end
	numPriests = i
	
	door = node_getNearestEntity(me, "energydoor")
	
	if not isFlag(FLAG_MITHALAS_PRIESTS, 0) then
		entity_setState(door, STATE_OPENED)
	end
end
	
function activate(me)	
end

function update(me, dt)
	if isFlag(FLAG_MITHALAS_PRIESTS,0) then
		if not started then
			if node_isEntityIn(me, n) then
				started = true
				entity_idle(n)
				playMusic("MiniBoss")
				for i=1,numPriests do
					cam_toEntity(priests[i])
					entity_setState(priests[i], STATE_APPEAR)
					watch(1)
				end
				overrideZoom(0.6, 1)
				cam_toEntity(n)
				for i=1,numPriests do
					entity_setState(priests[i], STATE_IDLE)
				end				
			end
		else
			c = 0
			e = getFirstEntity()
			while e ~= 0 do
				if entity_getEntityType(e) == ET_ENEMY and entity_isName(e, "Airboss") or entity_isName(e, "Airboss2") then					
					c = c + 1
				end
				e = getNextEntity()
			end
			if c == 0 then
				setFlag(FLAG_MITHALAS_PRIESTS, 1)
				setFlag(FLAG_MINIBOSS_PRIESTS, 1)
				updateMusic()
				overrideZoom(0)
				entity_idle(n)
				changeForm(FORM_NORMAL)
				watch(1)
				entity_setInvincible(n, true)
				watch(1)				
				entity_animate(n, "agony", LOOP_INF)
				learnSong(SONG_SUNFORM)
				watch(1)
				changeForm(FORM_SUN)
				entity_setInvincible(n, false)
				entity_setState(door, STATE_OPEN)
				loadMap("4elements")
			end
		end
	end
	
	if isFlag(FLAG_MITHALAS_PRIESTS,1) then
		loadMap("4elements")
	end
end
