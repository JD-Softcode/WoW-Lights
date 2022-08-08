--   ## WoW Lights - ©2022 J∆•Softcode (www.jdsoftcode.net) ##

-------------------------- ADD-ON GLOBALS ------------------------

WoWLights = {}							--  namespace for all addon functions.
WowPtGridSize = 3.35
WLTexWide = 6
WLTexHigh = 3
WLTex = {}



-------------------------- STARTUP ------------------------

print("Wowlights Startup")
WoWLightsFrame = CreateFrame("Frame","WoW Lights",UIParent)
WoWLightsFrame:SetSize(WowPtGridSize * WLTexWide, WowPtGridSize * WLTexHigh)
WoWLightsFrame:SetPoint("BOTTOMLEFT", 0, -2*WowPtGridSize)

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

		tex = WoWLightsFrame:CreateTexture("","ARTWORK")
		tex:SetSize(WowPtGridSize,WowPtGridSize)
		tex:SetPoint("TOPLEFT", WoWLightsFrame, (c-1)*WowPtGridSize,(r-1)*WowPtGridSize)
		tex:SetColorTexture(rr, gg, bb,1)	
		WLTex[r*WLTexWide + c] = tex
	end
end

-- use this for an entire-keyboard effect
WLTexOverall = WoWLightsFrame:CreateTexture("","OVERLAY")
WLTexOverall:SetAllPoints()
WLTexOverall:SetColorTexture(1,1,1,0) -- transparent for now	

-- Could add full width/height additional layers?
-- Can do animation too

-- I can make gradient textures!  But it's only sampled by ~8 keys
 

-------------------------- PLUG INTO EVENTS OF INTEREST ------------------------

function WoWLights_OnLoad(self)
	
	print("Wowlights OnLoad")
	
	local f = WoWLightsFrame
	f:RegisterEvent("PLAYER_ENTERING_WORLD")	-- environment ready
	f:RegisterEvent("PLAYER_STARTED_MOVING")
end

-------------------------- EVENT ROUTINES CALLED BY WOW ------------------------

---##################################
---#########  ON_EVENT   ############
---##################################
function WoWLights_OnEvent(self,event, ...)
	print("WoW lights Event: "..event)
	local arg1, arg2 = ...;
    if event == "PLAYER_ENTERING_WORLD" then        -- set stuff up
    	print("PLAYER_ENTERING_WORLD")
        WoWLightsFrame:Show()
    elseif event == "PLAYER_STARTED_MOVING" then
    	print("Moving")
    else
    	print("WoWLights: Registered for but didn't handle "..event)  
    end    
end


---##################################
---#########  ON_UPDATE   ###########
---##################################
function WoWLights_OnUpdate(self,elapsed)

end

WoWLightsFrame:SetScript("OnEvent", WoWLights_OnEvent)
WoWLightsFrame:SetScript("OnUpdate", WoWLights_OnUpdate)
WoWLights_OnLoad(WoWLightsFrame)


