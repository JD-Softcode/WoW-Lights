--   ## WoW Lights - ©2022 J∆•Softcode (www.jdsoftcode.net) ##

-------------------------- ADD-ON GLOBALS ------------------------

WoWLights = {}							--  namespace for all addon functions

WowPtGridSize = 3.35
WLTexWide = 6
WLTexHigh = 3
WLTex = {}

WLcombatFlash = false
WLcombatFlashState = false
WLtotalTime = 0


------------------------------ STARTUP ---------------------------

print("Wowlights Startup")

WoWLightsFrame = CreateFrame("Frame","WoW Lights",UIParent)
-- do not parent="UIParent" so my frame remains while interface is hidden, and does not scale up/down with UI?

WoWLightsFrame:SetScript("OnEvent", function(self, event, ...) 
	WoWLights:OnEvent(event, ...) 
end)

WoWLightsFrame:SetScript("OnUpdate", function(self, elapsed) 
	WoWLights:OnUpdate(elapsed) 
end)


-------------------------- PLUG INTO EVENTS OF INTEREST ------------------------

function WoWLights:OnLoad(ff)
	
	print("Doing Wowlights OnLoad")
	
	ff:SetSize(WowPtGridSize * WLTexWide, WowPtGridSize * WLTexHigh)
	ff:SetPoint("BOTTOMLEFT", 0, -2*WowPtGridSize)

	for r = 1,WLTexHigh do
		for c = 1, WLTexWide do

			rr = (r-1)/2.0
			gg = (c-1)/5.0
			bb = 0.5
		
			if (r+c)%2 == 0 then
				rr = 0
				gg = 0
				bb = 0
			end

			tex = ff:CreateTexture("","ARTWORK")
			tex:SetSize(WowPtGridSize,WowPtGridSize)
			tex:SetPoint("TOPLEFT", ff, (c-1)*WowPtGridSize,(r-1)*WowPtGridSize)
			tex:SetColorTexture(rr, gg, bb,1)	
			WLTex[(r-1)*WLTexWide + (c-1)] = tex
		end
	end

	-- use this for an entire-keyboard effect
	WLTexOverall = ff:CreateTexture("","OVERLAY")
	WLTexOverall:SetAllPoints()
	WLTexOverall:SetColorTexture(1,1,1,0) -- transparent for now	

	-- Could add full width/height additional layers?
	-- Can do animation too

	-- I can make gradient textures!  But it's only sampled by ~8 keys

	ff:RegisterEvent("PLAYER_ENTERING_WORLD")	-- environment ready
	ff:RegisterEvent("PLAYER_STARTED_MOVING")
	ff:RegisterEvent("PLAYER_STOPPED_MOVING")
	ff:RegisterEvent("PLAYER_REGEN_DISABLED")
	ff:RegisterEvent("PLAYER_REGEN_ENABLED")
end

-- perform OnLoad function, then exit
WoWLights:OnLoad(WoWLightsFrame)

-------------------------- EVENT ROUTINES CALLED BY WOW ------------------------

---##################################
---#########  ON_EVENT   ############
---##################################
function WoWLights:OnEvent(event, ...)
	--print("WoW lights Event: "..event)
	local arg1, arg2 = ...;
    if event == "PLAYER_ENTERING_WORLD" then        -- set stuff up
    	print("PLAYER_ENTERING_WORLD")
        WoWLightsFrame:Show()
    elseif event == "PLAYER_STARTED_MOVING" then
    	WLTex[0]:SetColorTexture(1, 1, 1, 1)
    	WLTex[2]:SetColorTexture(1, 1, 1, 1)
    	WLTex[4]:SetColorTexture(1, 1, 1, 1)
    elseif event == "PLAYER_STOPPED_MOVING" then
    	WLTex[0]:SetColorTexture(0, 0, 0, 1)
    	WLTex[2]:SetColorTexture(0, 0, 0, 1)
    	WLTex[4]:SetColorTexture(0, 0, 0, 1)
    elseif event == "PLAYER_REGEN_DISABLED" then
    	WLcombatFlash = true;
    elseif event == "PLAYER_REGEN_ENABLED" then
    	WLcombatFlash = false
    	WLTexOverall:SetColorTexture(1,0,0,0)
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

