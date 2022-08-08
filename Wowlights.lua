--   ## WoW Lights - ©2022 J∆•Softcode (www.jdsoftcode.net) ##

-------------------------- ADD-ON GLOBALS ------------------------

WoWLights = {}							--  namespace for all addon functions.
WowPtGridSize = 3.35
WLTexWide = 6
WLTexHigh = 3
WLTex = {}


-------------------------- STARTUP ------------------------

print("Wowlights Startup")
WoWLights = CreateFrame("Frame","WoW Lights",UIParent)
WoWLights:SetSize(WowPtGridSize * WLTexWide, WowPtGridSize * WLTexHigh)
WoWLights:SetPoint("BOTTOMLEFT", 0, -2*WowPtGridSize)

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

		tex = WoWLights:CreateTexture()
		tex:SetSize(WowPtGridSize,WowPtGridSize)
		tex:SetPoint("TOPLEFT", WoWLights, (c-1)*WowPtGridSize,(r-1)*WowPtGridSize)
		tex:SetColorTexture(rr, gg, bb,1)	
		WLTex[r*WLTexWide + c] = tex
	end
end


--WoWLights.tex11 = WoWLights:CreateTexture("wl11")
--WoWLights.tex11:SetSize(WowPtGridSize,WowPtGridSize)
--WoWLights.tex11:SetPoint("TOPLEFT", WoWLights, 0,0)
--WoWLights.tex11:SetColorTexture(1,0,0,1)
--
--WoWLights.tex12 = WoWLights:CreateTexture("wl12")
--WoWLights.tex12:SetSize(WowPtGridSize,WowPtGridSize)
--WoWLights.tex12:SetPoint("TOPLEFT", WoWLights, WowPtGridSize,0)
--WoWLights.tex12:SetColorTexture(0,1,0,1)
--
--WoWLights.tex13 = WoWLights:CreateTexture("wl13")
--WoWLights.tex13:SetAllPoints(WoWLights)
--WoWLights.tex13:SetPoint("TOPLEFT", WoWLights, WowPtGridSize*2,0)
--WoWLights.tex13:SetColorTexture(0,0,1,1)


-------------------------- PLUG INTO EVENTS OF INTEREST ------------------------

function WoWLights:OnLoad()
	
	print("Wowlights OnLoad")
	
	local f = WoWLightsMainFrame						-- defined by the XML
	f:RegisterEvent("PLAYER_ENTERING_WORLD")	-- environment ready
end

-------------------------- EVENT ROUTINES CALLED BY WOW ------------------------

---##################################
---#########  ON_EVENT   ############
---##################################
function WoWLights:OnEvent(event, ...)
	print("WoW lights Event: "..event)
	local arg1, arg2 = ...;
    if event == "PLAYER_ENTERING_WORLD" then        -- set stuff up
    	print("PLAYER_ENTERING_WORLD")
        WoWLights:Show()
        
--        WoWLights:HookScript("OnUpdate", function(self, elapsed)
--        	self:OnUpdate(elapsed)
--        end)
        
        --self:setupGuardPixels()
    else
    	print("WoWLights: Registered for but didn't handle "..event)  
    end    
end


---##################################
---#########  ON_UPDATE   ###########
---##################################
function WoWLights:OnUpdate(elapsed)

end

