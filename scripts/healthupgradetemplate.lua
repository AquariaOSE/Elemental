if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

v.myNote = 0
v.timingNote = false
v.noteTimer = 0
local NOTE_TIME = 2.5
v.core = 0
v.shell1 = 0
v.shell2 = 0
v.glow = 0

v.myID = 0

local STATE_SHAKE		= 1000

local function glowNormal(me)
	bone_alpha(v.glow, 0.3)
	bone_alpha(v.glow, 0.4, 1, -1, 1, 1)
	bone_scale(v.glow, 6, 6)
	bone_scale(v.glow, 8, 8, 1, -1, 1, 1)
end

local function glowSinging(me)
	bone_alpha(v.glow, 0.5)
	bone_alpha(v.glow, 0.7, 0.2, -1, 1, 1)

	bone_scale(v.glow, 6, 6)
	bone_scale(v.glow, 24, 24, 0.2, -1, 1, 1)
end

function v.commonInit(me, id)
	-- set color based on note
	setupEntity(me, "", "")
	entity_setEntityType(me, ET_NEUTRAL)
	entity_initSkeletal(me, "HealthUpgrade")
	
	
	v.core = entity_getBoneByName(me, "Core")
	v.shell1 = entity_getBoneByName(me, "Shell1")
	v.shell2 = entity_getBoneByName(me, "Shell2")
	v.glow = entity_getBoneByName(me, "Glow")
	
	if id == 0 then
		v.myNote = 0
	elseif id == 1 then
		v.myNote = 2
	elseif id == 2 then
		v.myNote = 4
	elseif id == 3 then
		v.myNote = 6
	elseif id == 4 then
		v.myNote = 1
	end		
	
	v.myID = id
	
	bone_setColor(v.core, getNoteColor(v.myNote))
	bone_setColor(v.shell1, getNoteColor(v.myNote))
	bone_setColor(v.shell2, getNoteColor(v.myNote))
	
	bone_setBlendType(v.glow, BLEND_ADD)
	bone_setColor(v.glow, getNoteColor(v.myNote))

	glowNormal(me)
	
	
	entity_scale(me, 0.6, 0.6)
	
	entity_setState(me, STATE_IDLE)
	
	entity_setEntityLayer(me, -1)
end

function postInit(me)
	--if entity_isFlag(me, 1) then
	if isFlag(FLAG_HEALTHUPGRADES + v.myID, 1) then
		entity_delete(me)
	end
	--end
end

v.incut = false

function update(me, dt)
	if v.incut then return end
	
	if entity_isState(me, STATE_OPENED) then
		if entity_isEntityInRange(me, getNaija(), 64) then
			v.incut = true
			playSfx("HealthUpgrade-Collect")
			spawnParticleEffect("HealthUpgradeReceived", entity_getPosition(me))
			setFlag(FLAG_HEALTHUPGRADES + v.myID, 1)
			upgradeHealth()
			setSceneColor(1, 1, 1, 4)
			entity_idle(getNaija())
			watch(3)
			
			if isFlag(FLAG_FIRSTHEALTHUPGRADE, 0) then
				voice("Naija_HealthUpgrade")
				setFlag(FLAG_FIRSTHEALTHUPGRADE, 1)
			else
				voice("naija_healthupgrade2")
			end
			entity_delete(me)
		end
	elseif entity_isState(me, STATE_OPEN) and not entity_isAnimating(me) then
		entity_setState(me, STATE_OPENED)
	else
		if v.timingNote then
			v.noteTimer = v.noteTimer + dt
			if v.noteTimer > NOTE_TIME then
				v.noteTimer = 0
				v.timingNote = false
				entity_setState(me, STATE_OPEN)
			end
		end
	end
end

function songNote(me, note)
	if entity_getAlpha(me) < 1 then return end
	if entity_isState(me, STATE_OPEN) or entity_isState(me, STATE_OPENED) then return end
	if note == v.myNote then
		entity_setState(me, STATE_SHAKE)
		v.timingNote = true
		v.noteTimer = 0
	else
		v.timingNote = false
	end
end

function songNoteDone(me, note, len)
	if entity_isState(me, STATE_OPEN) or entity_isState(me, STATE_OPENED) then return end
	if v.timingNote and note == v.myNote then		
		if not entity_isState(me, STATE_OPEN) then
			entity_setState(me, STATE_IDLE)
		end
	end
end

function enterState(me, state)
	--debugLog("HU enterState!")
	if entity_isState(me, STATE_IDLE) then
		if v.shell1~=0 and v.shell2 ~= 0 then
			bone_alpha(v.shell1, 0)
			bone_alpha(v.shell2, 0)
		end
		v.timingNote = false
		v.noteTimer = 0
		entity_animate(me, "idle", LOOP_INF)
		
		glowNormal(me)
	elseif entity_isState(me, STATE_SHAKE) then
		glowSinging(me)
		entity_animate(me, "shake", LOOP_INF)
	elseif entity_isState(me, STATE_OPEN) then
		bone_alpha(v.core, 0.01, 0.5)
		bone_alpha(v.shell1, 1, 0.1)
		bone_alpha(v.shell2, 1, 0.1)
		entity_animate(me, "open")
		
		local r, g, b = getNoteColor(v.myNote)
		setSceneColor(r, g, b, 2)
		
		playSfx(getNoteName(v.myNote, "low-"))
	end
end

function exitState(me, state)
end

