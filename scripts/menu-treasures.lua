if not v then v = {} end
if not AQUARIA_VERSION then dofile("scripts/entities/entityinclude.lua") end

local function hitWatch(tlen)
	local h = entity_getHealth(getNaija())
	
	local t = 0
	while t < tlen do
		watch(FRAME_TIME)
		t = t + FRAME_TIME
		
		if entity_getHealth(getNaija()) < h then
			return true
		end
	end
	
	return false
end

local function changeCostume(cost)

		setInvincibleOnNested(false)
		
		hideInGameMenu()
		
		esetv(getNaija(), EV_LOOKAT, 0)
		entity_idle(getNaija())
		
		entity_animate(getNaija(), "changeCostume")
		
		if hitWatch(0.5) then setInvincibleOnNested(true) return end
		
		fade(1, 0.5)
		
		if hitWatch(1) then fade(0, 0.1) setInvincibleOnNested(true) return end
		
		playSfx("ChangeClothes1")
		if hitWatch(1) then fade(0, 0.1) setInvincibleOnNested(true) return end

		playSfx("ChangeClothes2")
		
		if hitWatch(0.5) then fade(0, 0.1) setInvincibleOnNested(true) return end
		
		if getCostume()==cost then
			setCostume("")
		else
			setCostume(cost)
		end
		
		if hitWatch(0.4) then fade(0, 0.1) setInvincibleOnNested(true) return end
		
		if chance(50) then
			if chance(50) then
				emote(EMOTE_NAIJASIGH)
			else
				emote(EMOTE_NAIJAGIGGLE)
			end
		end
		
		fade(0, 0.5)
		if hitWatch(0.5) then fade(0, 0.1) setInvincibleOnNested(true) return end
		
		if hitWatch(0.5) then setInvincibleOnNested(true) return end
		
		setInvincibleOnNested(true)
		
		esetv(getNaija(), EV_LOOKAT, 1)
end
--[[
FLAG_COLLECTIBLE_URCHINCOSTUME		= 517
FLAG_COLLECTIBLE_TEENCOSTUME		= 518
FLAG_COLLECTIBLE_MUTANTCOSTUME		= 519
FLAG_COLLECTIBLE_JELLYCOSTUME		= 520
FLAG_COLLECTIBLE_MITHALANCOSTUME	= 521
]]--
function useTreasure(idx)
	debugLog("useTreasure!")
	if idx == FLAG_COLLECTIBLE_ENERGYTEMPLE then
		changeCostume("ETC")
	elseif idx == FLAG_COLLECTIBLE_CRABCOSTUME then
		changeCostume("CC")
	elseif idx == FLAG_COLLECTIBLE_URCHINCOSTUME then
		changeCostume("urchin")
	elseif idx == FLAG_COLLECTIBLE_TEENCOSTUME then
		changeCostume("teen")
	elseif idx == FLAG_COLLECTIBLE_MUTANTCOSTUME then
		changeCostume("mutant")
	elseif idx == FLAG_COLLECTIBLE_JELLYCOSTUME then
		changeCostume("jelly")
	elseif idx == FLAG_COLLECTIBLE_MITHALANCOSTUME then
		changeCostume("mithalan")
	elseif idx == FLAG_COLLECTIBLE_SEAHORSECOSTUME then
		changeCostume("seahorse")
	else
		playSfx("denied")
	end
end
