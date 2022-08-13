--   ## WoW Lights - ©2022 J∆•Softcode (www.jdsoftcode.net) ##

-------------------------- ADD-ON GLOBALS ------------------------

WoWLights = {}							--  namespace for all addon functions

WowPtGridSize = 3.35
WLTexWide = 6
WLTexHigh = 3

WLcombatFlash = false
WLcombatFlashState = false
WLtotalTime = 0


------------------------------ STARTUP ---------------------------

print("Wowlights Startup")

WoWLightsFrame = CreateFrame("Frame","WoW Lights",UIParent)
-- ?? do not parent="UIParent" so my frame remains while interface is hidden, and does not scale up/down with UI

WoWLightsFrame:SetScript("OnEvent", function(self, event, ...) 
	WoWLights:OnEvent(self,event, ...) 
end)

WoWLightsFrame:SetScript("OnUpdate", function(self, elapsed) 
	WoWLights:OnUpdate(elapsed) 
end)

WoWLightsFrame:RegisterEvent("ADDON_LOADED")




local function makeAlloverFrame(ff)

	local aof = CreateFrame("Frame","Overall",ff)
	aof:SetSize(WowPtGridSize * WLTexWide, WowPtGridSize * WLTexHigh)
	aof:SetPoint("TOPLEFT", ff, "TOPLEFT", 0, 0)

	aof.tex = aof:CreateTexture(nil,"OVERLAY")
	aof.tex:SetAllPoints()
	aof.tex:SetColorTexture(1,0,0,1)
	aof:SetAlpha(0)

	aof.fadeInOut = aof:CreateAnimationGroup()
	aof.fadeInOut:SetLooping("BOUNCE")

	aof.fader = aof.fadeInOut:CreateAnimation("ALPHA")
	aof.fader:SetFromAlpha(0.8)
	aof.fader:SetToAlpha(0.0)
	aof.fader:SetDuration(1.0)
	
	return aof
end



-------------------------- PLUG INTO EVENTS OF INTEREST ------------------------

local function OnLoad(ff)
	
	print("Doing Wowlights OnLoad")
	
	ff:SetSize(WowPtGridSize * WLTexWide, WowPtGridSize * WLTexHigh)
	ff:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)---2*WowPtGridSize)


	ff.alloverFrame = makeAlloverFrame(ff)

	-- set up individual lighting zones
	
	ff.baseTex = {}
	
	for r = 0,WLTexHigh-1 do
		for c = 0, WLTexWide-1 do

			rr = r/2.0
			gg = c/5.0
			bb = 0.5
		
			if (r+c)%2 == 0 then
				rr = 0
				gg = 0
				bb = 0
			end

		tex = ff:CreateTexture(nil,"BACKGROUND")
		tex:SetSize(WowPtGridSize,WowPtGridSize)
		tex:SetPoint("TOPLEFT", ff, "TOPLEFT", c*WowPtGridSize,r*WowPtGridSize - 2*WowPtGridSize)
		tex:SetColorTexture(rr, gg, bb,1)	
		ff.baseTex[r*WLTexWide + c] = tex
		end
	end

	-- events I'm interested in:
	ff:RegisterEvent("PLAYER_ENTERING_WORLD")	-- environment ready
	ff:RegisterEvent("PLAYER_STARTED_MOVING")
	ff:RegisterEvent("PLAYER_STOPPED_MOVING")
	ff:RegisterEvent("PLAYER_REGEN_DISABLED")
	ff:RegisterEvent("PLAYER_REGEN_ENABLED")
end


-------------------------- EVENT ROUTINES CALLED BY WOW ------------------------

---##################################
---#########  ON_EVENT   ############
---##################################
function WoWLights:OnEvent(ff,event, ...)
	--print("WoW lights Event: "..event)
	local arg1, arg2 = ...;
    if event == "PLAYER_ENTERING_WORLD" then        -- set stuff up
    	print("PLAYER_ENTERING_WORLD")
        WoWLightsFrame:Show()
        
    elseif event == "ADDON_LOADED" then
    	OnLoad(ff)
        
    elseif event == "PLAYER_STARTED_MOVING" then
    	ff.baseTex[0]:SetColorTexture(1, 1, 1, 1)
    	ff.baseTex[2]:SetColorTexture(1, 1, 1, 1)
    	ff.baseTex[4]:SetColorTexture(1, 1, 1, 1)
    	
    elseif event == "PLAYER_STOPPED_MOVING" then
    	ff.baseTex[0]:SetColorTexture(0, 0, 0, 1)
    	ff.baseTex[2]:SetColorTexture(0, 0, 0, 1)
    	ff.baseTex[4]:SetColorTexture(0, 0, 0, 1)
    	
    elseif event == "PLAYER_REGEN_DISABLED" then
    	--if not ff.overAllFrame.combatAnimGp:IsPlaying() then
    	print("play")
    	ff.alloverFrame.fadeInOut:Play()
    	--end
    	--WLcombatFlash = true;
    	
    elseif event == "PLAYER_REGEN_ENABLED" then
    	print("stop")
    	ff.alloverFrame.fadeInOut:Stop() -- restore to original state
    	--WLcombatFlash = false
    	--WLTexOverall:SetColorTexture(1,0,0,0)
    	
    else
    	print("WoWLights: Registered for but didn't handle "..event)  
    end    
end


---##################################
---#########  ON_UPDATE   ###########
---##################################
function WoWLights:OnUpdate(elapsed)

	if WLcombatFlash then
	
		if WLtotalTime >= 0.5 then
		
			if WLcombatFlashState then
				WLTexOverall:SetColorTexture(1,0,0,0)
				WLcombatFlashState = false
			else
				WLTexOverall:SetColorTexture(1,0,0,1)
				WLcombatFlashState = true
			end
			WLtotalTime = 0
			
		else
			WLtotalTime = WLtotalTime + elapsed
		end
	end

end
